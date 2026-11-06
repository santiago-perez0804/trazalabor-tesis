import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../dominio/perfil.dart';
import '../dominio/pin.dart';

/// El servidor rechazó el teléfono y el PIN.
class ErrorCredenciales implements Exception {
  const ErrorCredenciales();
}

/// No hubo forma de llegar al servidor (sin señal, sin datos, servidor caído).
class ErrorSinConexion implements Exception {
  const ErrorSinConexion();
}

/// La cuenta existe en Auth pero no hay un usuario activo vinculado.
class ErrorCuentaNoVinculada implements Exception {
  const ErrorCuentaNoVinculada();
}

/// Operaciones de autenticación contra el servidor. Interfaz para poder
/// probar el repositorio de sesión sin red.
abstract interface class AutenticadorRemoto {
  Future<EstadoCuenta> estadoCuenta(String telefono);

  /// Inicia sesión y devuelve el perfil vinculado a la cuenta.
  Future<Perfil> ingresar(String telefono, String pin);

  /// Crea la cuenta de un usuario preregistrado (HU-002 c3).
  Future<Perfil> activar(String telefono, String pin);

  Future<void> salir();
}

class AutenticadorSupabase implements AutenticadorRemoto {
  AutenticadorSupabase(this._cliente);

  final SupabaseClient _cliente;
  static const _limite = Duration(seconds: 10);

  @override
  Future<EstadoCuenta> estadoCuenta(String telefono) => _conRed(() async {
        final r = await _cliente.rpc<String>(
          'estado_cuenta',
          params: {'p_telefono': normalizarTelefono(telefono)},
        );
        return EstadoCuenta.desdeValor(r);
      });

  @override
  Future<Perfil> ingresar(String telefono, String pin) => _conRed(() async {
        try {
          await _cliente.auth.signInWithPassword(
            email: emailDesdeTelefono(telefono),
            password: pin,
          );
        } on AuthApiException catch (e) {
          if (e.statusCode == '400' || e.code == 'invalid_credentials') {
            throw const ErrorCredenciales();
          }
          rethrow;
        }
        return _perfilActual();
      });

  @override
  Future<Perfil> activar(String telefono, String pin) => _conRed(() async {
        await _cliente.auth.signUp(
          email: emailDesdeTelefono(telefono),
          password: pin,
        );
        return _perfilActual();
      });

  @override
  Future<void> salir() async {
    try {
      await _cliente.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      // Sin conexión igual se borra la sesión local.
    }
  }

  Future<Perfil> _perfilActual() async {
    final uid = _cliente.auth.currentUser?.id;
    if (uid == null) throw const ErrorCuentaNoVinculada();
    final fila = await _cliente
        .from('usuario')
        .select('id, nombre, telefono, rol, especialidad, activo, auth_id, created_at_device')
        .eq('auth_id', uid)
        .maybeSingle();
    if (fila == null) throw const ErrorCuentaNoVinculada();
    return Perfil.desdeJson(fila);
  }

  /// Traduce los errores de red (de cualquier capa) a [ErrorSinConexion].
  Future<T> _conRed<T>(Future<T> Function() accion) async {
    try {
      return await accion().timeout(_limite);
    } on SocketException {
      throw const ErrorSinConexion();
    } on TimeoutException {
      throw const ErrorSinConexion();
    } on AuthRetryableFetchException {
      throw const ErrorSinConexion();
    } on HttpException {
      throw const ErrorSinConexion();
    } on ClientException {
      throw const ErrorSinConexion();
    }
  }
}
