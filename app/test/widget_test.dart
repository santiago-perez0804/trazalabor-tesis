import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trazalabor/interfaz/comunes/indicador_conexion.dart';
import 'package:trazalabor/main.dart';

void main() {
  testWidgets('la app arranca y muestra el indicador de conexión',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hayConexionProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: const TrazaLaborApp(),
      ),
    );
    await tester.pump();

    expect(find.text('TrazaLabor'), findsOneWidget);
    expect(find.text('Sin conexión'), findsOneWidget);
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
