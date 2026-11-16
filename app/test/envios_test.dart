import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trazalabor/dominio/archivo_evidencia.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/plantillas_labor.dart';
import 'package:trazalabor/dominio/tipo_evento.dart';
import 'package:trazalabor/dominio/validar_cierre.dart';
import 'package:trazalabor/dominio/validar_labor.dart';
import 'package:trazalabor/dominio/validar_verificacion.dart';
import 'package:trazalabor/interfaz/comunes/indicador_conexion.dart';
import 'package:trazalabor/interfaz/comunes/pantalla_envios.dart';
import 'package:trazalabor/interfaz/proveedores.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/repositorio_bandeja.dart';
import 'package:trazalabor/repositorio/repositorio_ejecucion.dart';
import 'package:trazalabor/repositorio/repositorio_labores.dart';

import 'apoyo/autenticador_falso.dart';
import 'apoyo/desmontar.dart';

class _SesionJuan extends SesionNotifier {
  @override
  EstadoSesion build() => const ConSesion(juan, sinConexion: true);
}

/// Pantalla H "Para enviar" (decisión D33) y frases de "Qué pasó".
void main() {
  late BaseDatos db;
  late String tareaId;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() async {
    db = BaseDatos(NativeDatabase.memory());
    final ahora = DateTime.now();
    for (final p in [encargado, juan]) {
      await db
          .into(db.usuarios)
          .insert(
            UsuariosCompanion.insert(
              id: p.id,
              nombre: p.nombre,
              telefono: p.telefono,
              rol: p.rol,
              createdAtDevice: ahora,
            ),
          );
    }
    await db
        .into(db.unidadesProductivas)
        .insert(
          UnidadesProductivasCompanion.insert(
            id: 'up-7',
            nombre: 'Galpón',
            tipo: 'INSTALACION',
            codigoQr: 'qr',
          ),
        );
    tareaId = await RepositorioLabores(db).crearLabor(
      BorradorLabor(
        unidadProductivaId: 'up-7',
        asignadoId: juan.id,
        tipoLabor: TipoLabor.mantenimiento,
        fechaProgramada: ahora,
        items: plantillaPara(TipoLabor.mantenimiento).items,
        evidencia: EvidenciaRequerida.ninguna,
        requiereQr: false,
      ),
      creadorId: encargado.id,
    );
    // Lo del encargado ya se envió; lo que sigue es de Juan, sin señal.
    await db
        .update(db.operacionesPendientes)
        .write(const OperacionesPendientesCompanion(estado: Value('ENVIADO')));
    for (final id in ['ev-1', 'ev-2']) {
      await RepositorioEjecucion(db).adjuntarEvidencia(
        tareaId,
        ArchivoEvidencia(
          id: id,
          tipo: TipoEvidencia.foto,
          rutaLocal: '/no/existe/$id.jpg',
          tamanioBytes: 4,
          hashSha256: sha256.convert([1, 2, 3, 4]).toString(),
        ),
        usuarioId: juan.id,
      );
    }
  });

  tearDown(() => db.close());

  test('lo pendiente se agrupa por labor y cuenta los archivos', () async {
    var grupos = await RepositorioBandeja(db).observarPorEnviar().first;
    expect(grupos, hasLength(1));
    final g = grupos.single;
    expect(g.unidadNombre, 'Galpón');
    expect(g.estado, EstadoTarea.iniciada);
    expect(g.cambios, greaterThan(0));
    expect((g.archivos, g.archivosEnviados, g.fotos), (2, 0, 2));
    expect(g.tarjetas, 2, reason: 'cambios y archivos van por separado');

    // Sube una de las dos fotos: el avance pasa a 1 de 2.
    final subida = (await db.select(db.operacionesPendientes).get()).firstWhere(
      (o) => o.operacion == 'SUBIDA',
    );
    await (db.update(db.operacionesPendientes)
          ..where((o) => o.id.equals(subida.id)))
        .write(const OperacionesPendientesCompanion(estado: Value('ENVIADO')));
    grupos = await RepositorioBandeja(db).observarPorEnviar().first;
    expect((grupos.single.archivosEnviados, grupos.single.fotos), (1, 1));
  });

  testWidgets('"Para enviar" muestra la labor y sus fotos esperando señal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          baseDatosProvider.overrideWithValue(db),
          hayConexionProvider.overrideWith((ref) => Stream.value(false)),
          sesionProvider.overrideWith(_SesionJuan.new),
        ],
        child: const MaterialApp(home: PantallaEnvios()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Todo está guardado en tu teléfono'),
      findsOneWidget,
    );
    expect(find.text('Galpón · Mantenimiento'), findsOneWidget);
    expect(find.text('Galpón · 2 fotos'), findsOneWidget);
    expect(find.text('Esperando señal'), findsNWidgets(2));
    expect(find.text('Sin señal · 2 cosas guardadas'), findsOneWidget);
    await desmontar(tester);
  });

  test('frases llanas de "Qué pasó" (pantalla E)', () {
    String frase(TipoEvento t, [Map<String, Object?> p = const {}]) =>
        fraseEvento(
          tipo: t,
          payload: p,
          unidad: 'Lote 7',
          item: (id) => id == 'i-1' ? 'Dosis (l/ha)' : null,
          persona: (id) => id == 'u-pedro' ? 'Pedro G.' : null,
        );

    expect(frase(TipoEvento.iniciada), 'Empezó la labor');
    expect(frase(TipoEvento.qrVerificado), 'Leyó el código QR de Lote 7');
    expect(
      frase(TipoEvento.itemCompletado, {'item_id': 'i-1', 'valor': '1.5'}),
      'Cargó Dosis (l/ha): 1,5',
    );
    expect(
      frase(TipoEvento.itemCompletado, {'item_id': 'x', 'valor': 'SI'}),
      'Marcó: un ítem',
    );
    expect(
      frase(TipoEvento.evidenciaAdjunta, {'tipo': 'AUDIO'}),
      'Grabó un audio',
    );
    expect(
      frase(TipoEvento.noCompletada, {'motivo': 'Llovió'}),
      'No pudo terminar: Llovió',
    );
    expect(
      frase(TipoEvento.reasignada, {
        'nuevo_asignado_id': 'u-pedro',
        'motivo': 'Rehacer',
      }),
      'Se la reasignó a Pedro G.: Rehacer',
    );
  });
}
