import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/plantillas_labor.dart';
import 'package:trazalabor/dominio/validar_cierre.dart';
import 'package:trazalabor/dominio/validar_labor.dart';
import 'package:trazalabor/interfaz/comunes/indicador_conexion.dart';
import 'package:trazalabor/interfaz/encargado/pantalla_detalle_labor.dart';
import 'package:trazalabor/interfaz/encargado/pantalla_verificacion.dart';
import 'package:trazalabor/interfaz/proveedores.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/repositorio_ejecucion.dart';
import 'package:trazalabor/repositorio/repositorio_labores.dart';

import 'apoyo/autenticador_falso.dart';
import 'apoyo/desmontar.dart';

class _SesionEncargado extends SesionNotifier {
  @override
  EstadoSesion build() => const ConSesion(encargado);
}

/// Pantalla E (HU-012 y HU-013): lista "Por verificar", detalle con la
/// cronología y aprobación.
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
            nombre: 'Lote 7',
            tipo: 'LOTE',
            codigoQr: 'qr-7',
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
    // Juan la cierra (llegó por la sincronización).
    final ejec = RepositorioEjecucion(db);
    for (final i in (await ejec.leerDetalle(tareaId))!.items) {
      await ejec.completarItem(
        tareaId,
        i.id,
        i.tipoRespuesta == 'CHECK' ? null : 'Engrase',
        usuarioId: juan.id,
      );
    }
    await ejec.cerrarCompletada(tareaId, usuarioId: juan.id);
  });

  tearDown(() => db.close());

  Future<void> abrir(WidgetTester tester, Widget pantalla) async {
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          baseDatosProvider.overrideWithValue(db),
          hayConexionProvider.overrideWith((ref) => Stream.value(true)),
          sesionProvider.overrideWith(_SesionEncargado.new),
        ],
        child: MaterialApp(home: pantalla),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('"Por verificar" muestra la labor cerrada con su responsable', (
    tester,
  ) async {
    await abrir(tester, const PantallaVerificacion());

    expect(find.text('Lote 7 · Mantenimiento'), findsOneWidget);
    expect(find.textContaining('Juan P.'), findsOneWidget);
    expect(find.text('Terminada, falta tu revisión'), findsOneWidget);
    await desmontar(tester);
  });

  testWidgets(
    'detalle: cronología con hora del dispositivo y aprobar (c1, c2)',
    (tester) async {
      await abrir(tester, PantallaDetalleLabor(tareaId: tareaId));

      expect(find.text('Qué pasó'), findsOneWidget);
      expect(find.text('Terminó la labor'), findsOneWidget);
      expect(find.textContaining('todavía no llegó al servidor'), findsWidgets);
      expect(find.textContaining('Engrase'), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('boton-aprobar')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Aprobar').last);
      await tester.pumpAndSettle();

      expect(find.text('Aprobada'), findsOneWidget);
      expect(find.byKey(const ValueKey('boton-aprobar')), findsNothing);
      await desmontar(tester);
    },
  );
}
