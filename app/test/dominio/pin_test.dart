import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/control_intentos.dart';
import 'package:trazalabor/dominio/pin.dart';

void main() {
  group('validarPinNuevo', () {
    test('acepta un PIN de seis dígitos sin patrón', () {
      expect(validarPinNuevo('482913'), isNull);
      expect(validarPinNuevo('120034'), isNull);
    });

    test('rechaza longitud distinta de seis o caracteres no numéricos', () {
      expect(validarPinNuevo('12345'), isNotNull);
      expect(validarPinNuevo('1234567'), isNotNull);
      expect(validarPinNuevo('12a456'), isNotNull);
    });

    test('rechaza un único dígito repetido', () {
      expect(validarPinNuevo('111111'), contains('repetido'));
      expect(validarPinNuevo('000000'), contains('repetido'));
    });

    test('rechaza secuencias consecutivas ascendentes y descendentes', () {
      for (final pin in ['123456', '012345', '345678', '654321', '987654']) {
        expect(validarPinNuevo(pin), contains('seguidos'), reason: pin);
      }
    });
  });

  group('teléfono', () {
    test('se normaliza a solo dígitos', () {
      expect(normalizarTelefono('(351) 555-12 34'), '3515551234');
    });

    test('el email derivado usa los dígitos', () {
      expect(emailDesdeTelefono('351 555 1234'), '3515551234@trazalabor.local');
    });

    test('valida la cantidad de dígitos', () {
      expect(validarTelefono('351'), isNotNull);
      expect(validarTelefono('3515551234'), isNull);
    });
  });

  group('ControlIntentos', () {
    final t0 = DateTime(2026, 10, 30, 8);

    test('cinco fallos seguidos bloquean quince minutos (HU-001 c2)', () {
      var c = const ControlIntentos();
      for (var i = 0; i < 4; i++) {
        c = c.registrarFallo(t0);
        expect(c.estaBloqueado(t0), isFalse);
      }
      c = c.registrarFallo(t0);
      expect(c.estaBloqueado(t0), isTrue);
      expect(c.minutosRestantes(t0), 15);
      expect(c.estaBloqueado(t0.add(const Duration(minutes: 14))), isTrue);
      expect(c.estaBloqueado(t0.add(const Duration(minutes: 15))), isFalse);
    });

    test('un ingreso correcto reinicia la cuenta', () {
      var c = const ControlIntentos();
      for (var i = 0; i < 4; i++) {
        c = c.registrarFallo(t0);
      }
      c = c.registrarExito().registrarFallo(t0);
      expect(c.fallos, 1);
      expect(c.estaBloqueado(t0), isFalse);
    });

    test('vencido el bloqueo se vuelve a contar desde cero', () {
      var c = const ControlIntentos();
      for (var i = 0; i < 5; i++) {
        c = c.registrarFallo(t0);
      }
      final despues = t0.add(const Duration(minutes: 20));
      c = c.registrarFallo(despues);
      expect(c.fallos, 1);
      expect(c.estaBloqueado(despues), isFalse);
    });

    test('se guarda y se recupera en JSON', () {
      var c = const ControlIntentos();
      for (var i = 0; i < 5; i++) {
        c = c.registrarFallo(t0);
      }
      final copia = ControlIntentos.desdeJson(c.aJson());
      expect(copia.estaBloqueado(t0), isTrue);
    });
  });
}
