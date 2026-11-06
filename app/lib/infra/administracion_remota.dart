import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'autenticador_remoto.dart' show ErrorSinConexion;

/// El servidor rechazó la operación; `mensaje` se puede mostrar tal cual.
class ErrorAdministracion implements Exception {
  const ErrorAdministracion(this.mensaje);
  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Acciones del encargado que solo puede hacer el servidor (requieren la
/// clave de servicio). A diferencia del resto de la administración, piden
/// conexión (decisión D20 en docs/trazabilidad.md).
abstract interface class AdministracionRemota {
  /// Borra la cuenta de Auth del trabajador: vuelve a quedar preregistrado y
  /// elige un PIN nuevo en su próximo ingreso (Edge Function `restablecer-pin`).
  Future<void> restablecerPin(String usuarioId);
}

class AdministracionSupabase implements AdministracionRemota {
  AdministracionSupabase(this._cliente);

  final SupabaseClient _cliente;
  static const _limite = Duration(seconds: 15);

  @override
  Future<void> restablecerPin(String usuarioId) async {
    try {
      await _cliente.functions
          .invoke('restablecer-pin', body: {'usuario_id': usuarioId})
          .timeout(_limite);
    } on FunctionException catch (e) {
      throw ErrorAdministracion(switch (e.status) {
        401 => 'Tu sesión venció. Cerrá sesión y volvé a ingresar con señal.',
        403 => 'Solo un encargado puede restablecer un PIN.',
        404 => 'Ese trabajador todavía no llegó al servidor. '
            'Esperá a que se sincronice y probá de nuevo.',
        _ => _mensajeDelServidor(e.details) ?? 'No se pudo restablecer el PIN.',
      });
    } on SocketException {
      throw const ErrorSinConexion();
    } on TimeoutException {
      throw const ErrorSinConexion();
    } on HttpException {
      throw const ErrorSinConexion();
    } on ClientException {
      throw const ErrorSinConexion();
    }
  }

  static String? _mensajeDelServidor(Object? detalles) =>
      detalles is Map ? detalles['error'] as String? : null;
}

/// Se usa cuando la app se compila sin credenciales: nunca hay servidor.
class AdministracionSinServidor implements AdministracionRemota {
  const AdministracionSinServidor();

  @override
  Future<void> restablecerPin(String usuarioId) =>
      Future.error(const ErrorSinConexion());
}
