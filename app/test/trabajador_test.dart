import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/plantillas_labor.dart';
import 'package:trazalabor/dominio/validar_labor.dart';
import 'package:trazalabor/interfaz/comunes/indicador_conexion.dart';
import 'package:trazalabor/interfaz/proveedores.dart';
import 'package:trazalabor/interfaz/trabajador/pantalla_ejecucion.dart';
import 'package:trazalabor/interfaz/trabajador/pantalla_inicio_trabajador.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/repositorio_labores.dart';

import 'apoyo/autenticador_falso.dart';
import 'apoyo/desmontar.dart';

/// Sesión ya iniciada como Juan, sin conexión.
class _SesionJuan extends SesionNotifier {
  @override
  EstadoSesion build() => const ConSesion(juan, sinConexion: true);
}

void main() {
  late BaseDatos db;
  late String tareaId;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() async {
    db = BaseDatos(NativeDatabase.memory());
    final ahora = DateTime.now();
    for (final p in [encargado, juan]) {
      await db.into(db.usuarios).insert(UsuariosCompanion.insert(
          id: p.id,
          nombre: p.nombre,
          telefono: p.telefono,
          rol: p.rol,
          createdAtDevice: ahora));
    }
    await db.into(db.unidadesProductivas).insert(
        UnidadesProductivasCompanion.insert(
            id: 'up-7', nombre: 'Lote 7', tipo: 'LOTE', codigoQr: 'qr-7'));
    // El encargado asignó en este mismo teléfono una labor de mantenimiento.
    tareaId = await RepositorioLabores(db).crearLabor(
      BorradorLabor(
        unidadProductivaId: 'up-7',
        asignadoId: juan.id,
        tipoLabor: TipoLabor.mantenimiento,
        fechaProgramada: ahora,
        items: plantillaPara(TipoLabor.mantenimiento).items,
      ),
      creadorId: encargado.id,
    );
  });

  tearDown(() => db.close());

  Future<void> abrir(WidgetTester tester, Widget pantalla) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        baseDatosProvider.overrideWithValue(db),
        hayConexionProvider.overrideWith((ref) => Stream.value(false)),
        sesionProvider.overrideWith(_SesionJuan.new),
      ],
      child: MaterialApp(home: pantalla),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('mis tareas de hoy: la labor con su unidad, tipo y estado (HU-006 c1, c2)',
      (tester) async {
    await abrir(tester, const PantallaInicioTrabajador());

    expect(find.text('Lote 7 · Mantenimiento'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);
    // Lo que asignó el encargado todavía no se envió.
    expect(find.textContaining('operaciones pendientes de envío'), findsOneWidget);
    await desmontar(tester);
  });

  testWidgets('ejecución: marcar un ítem avanza la lista sin conexión (HU-007 c1)',
      (tester) async {
    await abrir(tester, PantallaEjecucion(tareaId: tareaId));

    expect(find.text('Lista de verificación · 0 de 2 ítems'), findsOneWidget);
    await tester.tap(find.text('Trabajo terminado'));
    await tester.pumpAndSettle();

    expect(find.text('Lista de verificación · 1 de 2 ítems'), findsOneWidget);
    expect(find.byKey(const ValueKey('boton-iniciar')), findsNothing,
        reason: 'marcar el ítem inició la labor');
    final eventos = await db.select(db.eventos).get();
    expect(eventos.map((e) => e.tipo),
        containsAll(['INICIADA', 'ITEM_COMPLETADO']));
    await desmontar(tester);
  });
}
