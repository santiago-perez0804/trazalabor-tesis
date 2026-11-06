import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trazalabor/dominio/perfil.dart';
import 'package:trazalabor/infra/almacen_seguro.dart';
import 'package:trazalabor/interfaz/comunes/indicador_conexion.dart';
import 'package:trazalabor/interfaz/proveedores.dart';
import 'package:trazalabor/main.dart';
import 'package:trazalabor/repositorio/base_datos.dart';

import 'apoyo/autenticador_falso.dart';
import 'apoyo/desmontar.dart';

void main() {
  late BaseDatos db;
  late AutenticadorFalso remoto;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    remoto = AutenticadorFalso();
  });

  tearDown(() => db.close());

  Widget app({Perfil? recordado}) => ProviderScope(
        overrides: [
          baseDatosProvider.overrideWithValue(db),
          almacenProvider.overrideWithValue(AlmacenEnMemoria()),
          autenticadorProvider.overrideWithValue(remoto),
          perfilRecordadoProvider.overrideWithValue(recordado),
          hayConexionProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: const TrazaLaborApp(),
      );

  Future<void> teclear(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(ValueKey('tecla-$d')));
      await tester.pump();
    }
  }

  testWidgets('arranca en el ingreso pidiendo el teléfono', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Ingresá tu número de teléfono'), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);
  });

  testWidgets('trabajador preregistrado: elige PIN y llega a sus tareas',
      (tester) async {
    remoto.agregar(juan, estado: EstadoCuenta.preregistrado);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('campo-telefono')), '3510000002');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Elegí tu PIN de 6 números'), findsOneWidget);

    // Una serie de números seguidos se rechaza.
    await teclear(tester, '123456');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('mensaje-ingreso')),
        matching: find.textContaining('seguidos'),
      ),
      findsOneWidget,
    );

    await teclear(tester, '482913');
    expect(find.text('Repetí tu PIN'), findsOneWidget);
    await teclear(tester, '482913');

    // El hash corre en otro isolate: se espera con runAsync.
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 3)));
    await tester.pumpAndSettle();

    expect(find.text('Mis tareas de hoy'), findsOneWidget);
    expect(find.text('Hola, Juan'), findsOneWidget);
    await desmontar(tester);
  });

  testWidgets('usuario recordado: se saluda y se pide solo el PIN', (tester) async {
    await tester.pumpWidget(app(recordado: encargado));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Encargado'), findsOneWidget);
    expect(find.text('No soy Encargado'), findsOneWidget);
    expect(find.byKey(const ValueKey('tecla-0')), findsOneWidget);
  });

  testWidgets('el indicador cambia a "En línea" con conexión', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hayConexionProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const MaterialApp(home: Scaffold(body: IndicadorConexion())),
      ),
    );
    await tester.pump();
    expect(find.text('En línea'), findsOneWidget);
  });
}
