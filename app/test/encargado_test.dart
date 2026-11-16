import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trazalabor/interfaz/comunes/indicador_conexion.dart';
import 'package:trazalabor/interfaz/encargado/formulario_trabajador.dart';
import 'package:trazalabor/interfaz/encargado/pantalla_nueva_labor.dart';
import 'package:trazalabor/interfaz/proveedores.dart';
import 'package:trazalabor/repositorio/base_datos.dart';

import 'apoyo/autenticador_falso.dart';
import 'apoyo/desmontar.dart';

/// Sesión ya iniciada como encargado.
class _SesionEncargado extends SesionNotifier {
  @override
  EstadoSesion build() => const ConSesion(encargado);
}

void main() {
  late BaseDatos db;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() async {
    db = BaseDatos(NativeDatabase.memory());
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: encargado.id,
            nombre: encargado.nombre,
            telefono: encargado.telefono,
            rol: 'ENCARGADO',
            createdAtDevice: DateTime(2026, 11, 6),
          ),
        );
  });

  tearDown(() => db.close());

  Future<void> abrir(WidgetTester tester, Widget pantalla) async {
    // Pantalla alta para no depender del desplazamiento.
    tester.view.physicalSize = const Size(900, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          baseDatosProvider.overrideWithValue(db),
          hayConexionProvider.overrideWith((ref) => Stream.value(false)),
          sesionProvider.overrideWith(_SesionEncargado.new),
        ],
        child: MaterialApp(home: pantalla),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('teléfono ya registrado: informa el motivo (HU-002 c2)', (
    tester,
  ) async {
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: 'u-juan',
            nombre: 'Juan P.',
            telefono: '3510000002',
            rol: 'TRABAJADOR',
            createdAtDevice: DateTime(2026, 11, 6),
          ),
        );
    await abrir(tester, const FormularioTrabajador());

    await tester.enterText(find.byKey(const ValueKey('campo-nombre')), 'Otro');
    await tester.enterText(
      find.byKey(const ValueKey('campo-telefono')),
      '351 000 0002',
    );
    await tester.tap(find.byKey(const ValueKey('boton-guardar')));
    await tester.pumpAndSettle();

    expect(
      find.text('Ese teléfono ya está registrado a nombre de Juan P.'),
      findsOneWidget,
    );
    expect(await db.select(db.operacionesPendientes).get(), isEmpty);
    // Franja permanente: sin señal y nada guardado para enviar.
    expect(find.text('Sin señal · se guarda en el teléfono'), findsOneWidget);
    await desmontar(tester);
  });

  testWidgets(
    'nueva labor fitosanitaria: trae sus ítems obligatorios e indica lo que falta (HU-005)',
    (tester) async {
      await abrir(tester, const PantallaNuevaLabor());

      await tester.tap(find.byKey(const ValueKey('campo-tipo')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicación fitosanitaria').last);
      await tester.pumpAndSettle();

      // HU-005 c2: cuatro ítems fijos con candado.
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(4));
      expect(find.textContaining('Dosis'), findsOneWidget);

      // HU-005 c3: sin unidad ni trabajador no se confirma.
      await tester.tap(find.byKey(const ValueKey('boton-asignar')));
      await tester.pumpAndSettle();
      expect(find.text('Elegí la unidad productiva.'), findsOneWidget);
      expect(find.text('Elegí el trabajador.'), findsOneWidget);
      expect(await db.select(db.tareas).get(), isEmpty);
      await desmontar(tester);
    },
  );
}
