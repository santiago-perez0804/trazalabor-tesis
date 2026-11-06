import 'package:drift/drift.dart';

import '../dominio/pin.dart';
import '../dominio/validar_altas.dart';
import '../infra/administracion_remota.dart';
import '../infra/autenticador_remoto.dart' show ErrorSinConexion;
import 'base_datos.dart';
import 'fabrica_eventos.dart';
import 'registrar_accion.dart';

/// El alta o la modificación no se guardó; `errores` es campo → motivo.
class DatosRechazados implements Exception {
  const DatosRechazados(this.errores);
  final Map<String, String> errores;

  @override
  String toString() => errores.values.join(' ');
}

/// Alta, modificación y desactivación de trabajadores (HU-002, T-08).
/// Todo se guarda en el dispositivo y queda en la bandeja de salida.
class RepositorioTrabajadores {
  RepositorioTrabajadores(this._db, this._remoto, {DateTime Function()? reloj})
      : _reloj = reloj ?? DateTime.now;

  final BaseDatos _db;
  final AdministracionRemota _remoto;
  final DateTime Function() _reloj;

  static const _rol = 'TRABAJADOR';

  /// Todos los trabajadores, activos primero.
  Stream<List<Usuario>> observarTrabajadores() => (_db.select(_db.usuarios)
        ..where((u) => u.rol.equals(_rol))
        ..orderBy([
          (u) => OrderingTerm.desc(u.activo),
          (u) => OrderingTerm.asc(u.nombre),
        ]))
      .watch();

  /// HU-002 c4: un trabajador desactivado deja de figurar para nuevas asignaciones.
  Stream<List<Usuario>> observarAsignables() => (_db.select(_db.usuarios)
        ..where((u) => u.rol.equals(_rol) & u.activo.equals(true))
        ..orderBy([(u) => OrderingTerm.asc(u.nombre)]))
      .watch();

  Stream<Usuario?> observar(String id) =>
      (_db.select(_db.usuarios)..where((u) => u.id.equals(id)))
          .watchSingleOrNull();

  /// HU-002 c1: queda preregistrado (sin cuenta de Auth) hasta que el
  /// trabajador elija su PIN en el primer ingreso.
  Future<Usuario> alta({
    required String nombre,
    required String telefono,
    String? especialidad,
  }) async {
    final tel = normalizarTelefono(telefono);
    await _validar(nombre: nombre, telefono: tel);
    final fila = Usuario(
      id: nuevoId(),
      nombre: nombre.trim(),
      telefono: tel,
      rol: _rol,
      especialidad: _limpiar(especialidad),
      activo: true,
      createdAtDevice: _reloj(),
    );
    await _db.registrarAccion(Accion(cambios: [CambioEntidad(_db.usuarios, fila)]));
    return fila;
  }

  Future<void> modificar(
    String id, {
    required String nombre,
    required String telefono,
    String? especialidad,
  }) async {
    final tel = normalizarTelefono(telefono);
    await _validar(nombre: nombre, telefono: tel, excepto: id);
    final actual = await _leer(id);
    await _guardarCambio(actual.copyWith(
      nombre: nombre.trim(),
      telefono: tel,
      especialidad: Value(_limpiar(especialidad)),
    ));
  }

  /// HU-002 c4: el servidor rechaza su ingreso (RLS) y deja de ser asignable.
  Future<void> desactivar(String id) async =>
      _guardarCambio((await _leer(id)).copyWith(activo: false));

  Future<void> reactivar(String id) async =>
      _guardarCambio((await _leer(id)).copyWith(activo: true));

  /// Devuelve `null` si se restableció, o el motivo por el que no se pudo.
  Future<String?> restablecerPin(String id) async {
    try {
      await _remoto.restablecerPin(id);
      return null;
    } on ErrorSinConexion {
      return 'Para restablecer el PIN necesitás conexión.';
    } on ErrorAdministracion catch (e) {
      return e.mensaje;
    }
  }

  Future<void> _validar({
    required String nombre,
    required String telefono,
    String? excepto,
  }) async {
    final errores = validarTrabajador(nombre: nombre, telefono: telefono);
    if (!errores.containsKey('telefono')) {
      // HU-002 c2: el teléfono identifica al usuario y es único.
      final otro = await (_db.select(_db.usuarios)
            ..where((u) => u.telefono.equals(telefono)))
          .getSingleOrNull();
      if (otro != null && otro.id != excepto) {
        final punto = otro.nombre.endsWith('.') ? '' : '.';
        errores['telefono'] =
            'Ese teléfono ya está registrado a nombre de ${otro.nombre}$punto';
      }
    }
    if (errores.isNotEmpty) throw DatosRechazados(errores);
  }

  Future<Usuario> _leer(String id) =>
      (_db.select(_db.usuarios)..where((u) => u.id.equals(id))).getSingle();

  Future<void> _guardarCambio(Usuario fila) => _db.registrarAccion(Accion(
      cambios: [CambioEntidad(_db.usuarios, fila, operacion: TipoOperacion.update)]));

  static String? _limpiar(String? texto) {
    final t = texto?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
