import 'package:trazalabor/infra/administracion_remota.dart';
import 'package:trazalabor/infra/autenticador_remoto.dart';

/// Servidor de administración simulado para pruebas.
class AdministracionFalsa implements AdministracionRemota {
  bool hayConexion = true;
  final restablecidos = <String>[];

  @override
  Future<void> restablecerPin(String usuarioId) async {
    if (!hayConexion) throw const ErrorSinConexion();
    if (usuarioId == 'desconocido') {
      throw const ErrorAdministracion('No existe ese usuario');
    }
    restablecidos.add(usuarioId);
  }
}
