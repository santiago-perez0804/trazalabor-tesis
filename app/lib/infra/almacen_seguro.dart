import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Almacenamiento clave-valor. En el dispositivo es el almacenamiento cifrado
/// del sistema operativo (Android Keystore); en las pruebas, memoria.
abstract interface class AlmacenClaves {
  Future<String?> leer(String clave);
  Future<void> escribir(String clave, String valor);
  Future<void> borrar(String clave);
}

class AlmacenSeguro implements AlmacenClaves {
  const AlmacenSeguro([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> leer(String clave) => _storage.read(key: clave);

  @override
  Future<void> escribir(String clave, String valor) =>
      _storage.write(key: clave, value: valor);

  @override
  Future<void> borrar(String clave) => _storage.delete(key: clave);
}

class AlmacenEnMemoria implements AlmacenClaves {
  final datos = <String, String>{};

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> escribir(String clave, String valor) async =>
      datos[clave] = valor;

  @override
  Future<void> borrar(String clave) async => datos.remove(clave);
}

/// La sesión de Supabase (testigos de acceso y de refresco) se guarda en el
/// almacenamiento cifrado, no en SharedPreferences (T-07, sección Seguridad).
class SesionSupabaseSegura extends LocalStorage {
  const SesionSupabaseSegura(this._almacen);

  static const _clave = 'supabase_sesion';
  final AlmacenClaves _almacen;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async => (await _almacen.leer(_clave)) != null;

  @override
  Future<String?> accessToken() => _almacen.leer(_clave);

  @override
  Future<void> removePersistedSession() => _almacen.borrar(_clave);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _almacen.escribir(_clave, persistSessionString);
}
