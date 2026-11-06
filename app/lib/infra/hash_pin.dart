import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Hash local del PIN para validar el ingreso sin conexión (T-06).
///
/// PBKDF2-HMAC-SHA256 con salt aleatorio de 16 bytes (OWASP, Password Storage
/// Cheat Sheet). Se guarda como `pbkdf2-sha256$<iteraciones>$<salt>$<hash>`
/// en el almacenamiento cifrado de Android.
///
/// Nota para la tesis: un PIN de 6 dígitos tiene 10^6 combinaciones, así que
/// ninguna función de derivación lo protege por sí sola si se extrae el hash.
/// La protección real es la combinación de Keystore (almacenamiento cifrado),
/// el bloqueo por intentos y bcrypt + límites de frecuencia en el servidor.
abstract final class HashPin {
  /// Medido: 120 000 iteraciones tardan ~0,7 s en la PC (Dart puro), lo que
  /// en un teléfono de gama baja serían 2–3 s por ingreso. Con 50 000 se busca
  /// ~1 s en gama baja; se confirma en el celular real. Como cada valor
  /// guardado incluye sus iteraciones, cambiar este número no invalida PIN
  /// ya guardados (ver docs/trazabilidad.md).
  static const iteracionesPorDefecto = 50000;

  static Future<String> derivar(String pin, {int? iteraciones}) {
    final n = iteraciones ?? iteracionesPorDefecto;
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return Isolate.run(() async {
      final hash = await _pbkdf2(pin, salt, n);
      return 'pbkdf2-sha256\$$n\$${base64.encode(salt)}\$${base64.encode(hash)}';
    });
  }

  static Future<bool> verificar(String pin, String guardado) {
    final partes = guardado.split(r'$');
    if (partes.length != 4 || partes[0] != 'pbkdf2-sha256') {
      return Future.value(false);
    }
    final n = int.parse(partes[1]);
    final salt = base64.decode(partes[2]);
    final esperado = base64.decode(partes[3]);
    return Isolate.run(() async {
      final hash = await _pbkdf2(pin, salt, n);
      return _igualesEnTiempoConstante(hash, esperado);
    });
  }

  static Future<List<int>> _pbkdf2(String pin, List<int> salt, int n) async {
    final kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: n, bits: 256);
    final clave = await kdf.deriveKeyFromPassword(password: pin, nonce: salt);
    return clave.extractBytes();
  }

  static bool _igualesEnTiempoConstante(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diferencia = 0;
    for (var i = 0; i < a.length; i++) {
      diferencia |= a[i] ^ b[i];
    }
    return diferencia == 0;
  }
}
