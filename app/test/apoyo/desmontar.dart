import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Desmonta la app al final de una prueba de widgets. Al cerrarse, los
/// streams de Drift programan un temporizador de cero segundos; si no se
/// deja correr, la prueba falla por "timer pendiente" y la base no cierra.
Future<void> desmontar(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}
