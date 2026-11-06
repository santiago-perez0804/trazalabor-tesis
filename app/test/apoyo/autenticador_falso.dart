import 'package:trazalabor/dominio/perfil.dart';
import 'package:trazalabor/infra/autenticador_remoto.dart';

/// Servidor de autenticación simulado para pruebas.
class AutenticadorFalso implements AutenticadorRemoto {
  AutenticadorFalso({this.hayConexion = true});

  bool hayConexion;
  int llamadasIngresar = 0;

  /// teléfono → (estado, pin, perfil)
  final cuentas = <String, ({EstadoCuenta estado, String? pin, Perfil perfil})>{};

  void agregar(Perfil perfil, {EstadoCuenta estado = EstadoCuenta.activo, String? pin}) =>
      cuentas[perfil.telefono] = (estado: estado, pin: pin, perfil: perfil);

  void _red() {
    if (!hayConexion) throw const ErrorSinConexion();
  }

  @override
  Future<EstadoCuenta> estadoCuenta(String telefono) async {
    _red();
    return cuentas[telefono]?.estado ?? EstadoCuenta.inexistente;
  }

  @override
  Future<Perfil> ingresar(String telefono, String pin) async {
    llamadasIngresar++;
    _red();
    final c = cuentas[telefono];
    if (c == null || c.pin != pin) throw const ErrorCredenciales();
    // Como en el servidor: la cuenta de Auth existe, pero la RLS no le
    // devuelve su fila de `usuario` porque está desactivado.
    if (c.estado == EstadoCuenta.inactivo) throw const ErrorCuentaNoVinculada();
    return c.perfil;
  }

  @override
  Future<Perfil> activar(String telefono, String pin) async {
    _red();
    final c = cuentas[telefono];
    if (c == null || c.estado != EstadoCuenta.preregistrado) {
      throw Exception('no preregistrado');
    }
    cuentas[telefono] = (estado: EstadoCuenta.activo, pin: pin, perfil: c.perfil);
    return c.perfil;
  }

  @override
  Future<void> salir() async {}
}

const juan = Perfil(
  id: 'u-juan',
  nombre: 'Juan P.',
  telefono: '3510000002',
  rol: 'TRABAJADOR',
);

const encargado = Perfil(
  id: 'u-enc',
  nombre: 'Encargado de prueba',
  telefono: '3510000001',
  rol: 'ENCARGADO',
);
