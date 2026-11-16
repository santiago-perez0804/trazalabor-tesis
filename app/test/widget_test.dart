import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trazalabor/dominio/perfil.dart';
import 'package:trazalabor/infra/almacen_seguro.dart';
import 'package:trazalabor/interfaz/comunes/barra_app.dart';
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

  testWidgets('arranca en el ingreso con teléfono y PIN en una pantalla', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Labores del campo'), findsOneWidget);
    expect(find.text('Tu número de teléfono'), findsOneWidget);
    expect(find.text('Tu PIN de 6 números'), findsOneWidget);
    expect(find.text('Sin señal · se guarda en el teléfono'), findsOneWidget);
    await desmontar(tester);
  });

  testWidgets('trabajador preregistrado: elige PIN y llega a sus tareas', (
    tester,
  ) async {
    remoto.agregar(juan, estado: EstadoCuenta.preregistrado);
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('campo-telefono')),
      '3510000002',
    );
    // Una serie de números seguidos se rechaza como PIN nuevo.
    await teclear(tester, '123456');
    await tester.tap(find.byKey(const ValueKey('boton-ingresar')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('mensaje-ingreso')),
        matching: find.textContaining('seguidos'),
      ),
      findsOneWidget,
    );

    await teclear(tester, '482913');
    await tester.tap(find.byKey(const ValueKey('boton-ingresar')));
    await tester.pumpAndSettle();
    expect(find.text('Repetí tu PIN'), findsOneWidget);
    await teclear(tester, '482913');

    // El hash corre en otro isolate: se espera con runAsync.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 3)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tareas de hoy'), findsOneWidget);
    expect(find.textContaining('Juan'), findsWidgets);
    await desmontar(tester);
  });

  testWidgets('usuario recordado: se saluda y se pide solo el PIN', (
    tester,
  ) async {
    await tester.pumpWidget(app(recordado: encargado));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Encargado'), findsOneWidget);
    expect(find.text('No soy Encargado'), findsOneWidget);
    expect(find.byKey(const ValueKey('campo-telefono')), findsNothing);
    expect(find.byKey(const ValueKey('tecla-0')), findsOneWidget);
    await desmontar(tester);
  });

  testWidgets('la franja cambia a "Con señal" con conexión', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hayConexionProvider.overrideWith((ref) => Stream.value(true)),
          porEnviarProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(home: Scaffold(body: FranjaConexion())),
      ),
    );
    await tester.pump();
    expect(find.text('Con señal · todo enviado'), findsOneWidget);
  });
}
