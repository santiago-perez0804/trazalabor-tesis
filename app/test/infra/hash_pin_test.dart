import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/infra/hash_pin.dart';

void main() {
  // Pocas iteraciones para que la prueba sea rápida; el formato es el mismo.
  const n = 1000;

  test('verifica el PIN correcto y rechaza uno incorrecto', () async {
    final guardado = await HashPin.derivar('482913', iteraciones: n);
    expect(guardado, startsWith('pbkdf2-sha256\$1000\$'));
    expect(await HashPin.verificar('482913', guardado), isTrue);
    expect(await HashPin.verificar('482914', guardado), isFalse);
  });

  test('el salt hace que el mismo PIN dé hashes distintos', () async {
    final a = await HashPin.derivar('482913', iteraciones: n);
    final b = await HashPin.derivar('482913', iteraciones: n);
    expect(a, isNot(b));
    expect(await HashPin.verificar('482913', b), isTrue);
  });

  test('un valor guardado con formato inválido no valida', () async {
    expect(await HashPin.verificar('482913', 'texto-cualquiera'), isFalse);
  });

  test('tiempo con las iteraciones por defecto', () async {
    final reloj = Stopwatch()..start();
    final guardado = await HashPin.derivar('482913');
    final derivar = reloj.elapsedMilliseconds;
    reloj.reset();
    await HashPin.verificar('482913', guardado);
    // ignore: avoid_print
    print('PBKDF2 ${HashPin.iteracionesPorDefecto} iteraciones: '
        'derivar ${derivar}ms, verificar ${reloj.elapsedMilliseconds}ms (PC)');
  });
}
