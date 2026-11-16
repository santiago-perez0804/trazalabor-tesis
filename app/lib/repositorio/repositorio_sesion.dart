import 'dart:convert';

import '../dominio/control_intentos.dart';
import '../dominio/perfil.dart';
import '../dominio/pin.dart';
import '../infra/almacen_seguro.dart';
import '../infra/autenticador_remoto.dart';
import '../infra/hash_pin.dart';
import 'base_datos.dart';

sealed class ResultadoIngreso {
  const ResultadoIngreso();
}

class IngresoCorrecto extends ResultadoIngreso {
  const IngresoCorrecto(this.perfil, {this.sinConexion = false});
  final Perfil perfil;

  /// El PIN se validó en el dispositivo porque no había conexión (HU-001 c3).
  final bool sinConexion;
}

class IngresoRechazado extends ResultadoIngreso {
  const IngresoRechazado(this.mensaje);
  final String mensaje;
}

class IngresoBloqueado extends ResultadoIngreso {
  const IngresoBloqueado(this.minutos);
  final int minutos;
}

/// El encargado restableció el PIN: la cuenta volvió a quedar preregistrada y
/// el usuario tiene que elegir uno nuevo.
class IngresoPinRestablecido extends ResultadoIngreso {
  const IngresoPinRestablecido();
}

/// Qué tiene que hacer la pantalla después de ingresar el teléfono.
enum PasoSiguiente {
  crearPin,
  ingresarPin,
  desactivado,
  noDadoDeAlta,
  necesitaConexion,
}

/// Orquesta el inicio de sesión (HU-001) y la activación (HU-002 c3):
/// primero intenta con el servidor y, si no hay conexión, valida el PIN contra
/// el hash guardado en el dispositivo.
class RepositorioSesion {
  RepositorioSesion({
    required this._remoto,
    required this._almacen,
    required this._db,
    DateTime Function()? reloj,
    int? iteracionesHash,
  }) : _reloj = reloj ?? DateTime.now,
       _iteraciones = iteracionesHash;

  final AutenticadorRemoto _remoto;
  final AlmacenClaves _almacen;
  final BaseDatos _db;
  final DateTime Function() _reloj;
  final int? _iteraciones;

  /// PIN de la sesión en curso, **solo en memoria** (nunca se guarda): si se
  /// ingresó sin señal, permite autenticarse en el servidor cuando vuelve la
  /// conexión para sincronizar (decisión D28).
  String? _telSesion;
  String? _pinSesion;

  static const _clavePerfil = 'perfil_activo';
  static String _claveIntentos(String tel) => 'intentos_pin:$tel';
  static String _claveHash(String tel) => 'pin_hash:$tel';

  /// Perfil del último usuario que ingresó en este dispositivo, si lo hay.
  Future<Perfil?> perfilRecordado() async {
    final json = await _almacen.leer(_clavePerfil);
    return json == null
        ? null
        : Perfil.desdeJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<PasoSiguiente> pasoSiguiente(String telefono) async {
    final tel = normalizarTelefono(telefono);
    try {
      return switch (await _remoto.estadoCuenta(tel)) {
        EstadoCuenta.preregistrado => PasoSiguiente.crearPin,
        EstadoCuenta.activo => PasoSiguiente.ingresarPin,
        EstadoCuenta.inactivo => PasoSiguiente.desactivado,
        EstadoCuenta.inexistente => PasoSiguiente.noDadoDeAlta,
      };
    } on ErrorSinConexion {
      final hayHash = await _almacen.leer(_claveHash(tel)) != null;
      return hayHash
          ? PasoSiguiente.ingresarPin
          : PasoSiguiente.necesitaConexion;
    }
  }

  Future<ResultadoIngreso> ingresar(String telefono, String pin) async {
    final tel = normalizarTelefono(telefono);
    final control = await _leerIntentos(tel);
    if (control.estaBloqueado(_reloj())) {
      return IngresoBloqueado(control.minutosRestantes(_reloj()));
    }

    try {
      final perfil = await _remoto.ingresar(tel, pin);
      return await _concretar(perfil, tel, pin);
    } on ErrorCredenciales {
      if (await _fueRestablecido(tel)) {
        await _almacen.borrar(_claveHash(tel));
        return const IngresoPinRestablecido();
      }
      return _registrarFallo(tel, control);
    } on ErrorCuentaNoVinculada {
      // La cuenta fue desactivada (la RLS ya no le devuelve su fila): se borra
      // el hash para que tampoco pueda ingresar sin conexión (HU-002 c4).
      await _remoto.salir();
      await _almacen.borrar(_claveHash(tel));
      return const IngresoRechazado(
        'Tu cuenta no está habilitada. Hablá con el encargado.',
      );
    } on ErrorSinConexion {
      return await _ingresarSinConexion(tel, pin, control);
    }
  }

  Future<ResultadoIngreso> activar(String telefono, String pin) async {
    final motivo = validarPinNuevo(pin);
    if (motivo != null) return IngresoRechazado(motivo);
    final tel = normalizarTelefono(telefono);
    try {
      final perfil = await _remoto.activar(tel, pin);
      return await _concretar(perfil, tel, pin);
    } on ErrorSinConexion {
      return const IngresoRechazado(
        'Para activar tu cuenta necesitás conexión. Probá donde haya señal.',
      );
    } catch (_) {
      return const IngresoRechazado(
        'No se pudo activar la cuenta. Pedile al encargado que revise tu alta.',
      );
    }
  }

  /// Inicia la sesión remota con el PIN de la sesión en curso. Devuelve
  /// `false` si no hay PIN en memoria o el servidor no lo acepta.
  Future<bool> reautenticar() async {
    final tel = _telSesion, pin = _pinSesion;
    if (tel == null || pin == null) return false;
    try {
      await _remoto.ingresar(tel, pin);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cierra la sesión. Conserva el hash del PIN para ingresar sin conexión.
  Future<void> salir() async {
    _telSesion = null;
    _pinSesion = null;
    await _remoto.salir();
    await _almacen.borrar(_clavePerfil);
  }

  Future<ResultadoIngreso> _concretar(
    Perfil perfil,
    String tel,
    String pin,
  ) async {
    if (!perfil.activo) {
      // HU-002 c4: un usuario desactivado no ingresa.
      await _remoto.salir();
      await _almacen.borrar(_claveHash(tel));
      return const IngresoRechazado(
        'Tu cuenta está desactivada. Hablá con el encargado.',
      );
    }
    await _almacen.escribir(
      _claveHash(tel),
      await HashPin.derivar(pin, iteraciones: _iteraciones),
    );
    await _almacen.escribir(_clavePerfil, jsonEncode(perfil.aJson()));
    await _guardarIntentos(tel, const ControlIntentos());
    await _guardarUsuarioLocal(perfil);
    _telSesion = tel;
    _pinSesion = pin;
    return IngresoCorrecto(perfil);
  }

  Future<ResultadoIngreso> _ingresarSinConexion(
    String tel,
    String pin,
    ControlIntentos control,
  ) async {
    final hash = await _almacen.leer(_claveHash(tel));
    final recordado = await perfilRecordado();
    final perfil = recordado?.telefono == tel
        ? recordado
        : await _perfilLocal(tel);
    if (hash == null || perfil == null) {
      return const IngresoRechazado(
        'Sin conexión. El primer ingreso en este teléfono necesita señal.',
      );
    }
    if (!await HashPin.verificar(pin, hash)) {
      return _registrarFallo(tel, control);
    }

    await _almacen.escribir(_clavePerfil, jsonEncode(perfil.aJson()));
    await _guardarIntentos(tel, const ControlIntentos());
    _telSesion = tel;
    _pinSesion = pin;
    return IngresoCorrecto(perfil, sinConexion: true);
  }

  /// La cuenta existía pero el servidor la informa preregistrada: el encargado
  /// restableció el PIN (Edge Function `restablecer-pin`).
  Future<bool> _fueRestablecido(String tel) async {
    try {
      return await _remoto.estadoCuenta(tel) == EstadoCuenta.preregistrado;
    } on ErrorSinConexion {
      return false;
    }
  }

  Future<ResultadoIngreso> _registrarFallo(
    String tel,
    ControlIntentos control,
  ) async {
    final nuevo = control.registrarFallo(_reloj());
    await _guardarIntentos(tel, nuevo);
    if (nuevo.estaBloqueado(_reloj())) {
      return IngresoBloqueado(nuevo.minutosRestantes(_reloj()));
    }
    final quedan = ControlIntentos.maximoFallos - nuevo.fallos;
    return IngresoRechazado(
      'PIN incorrecto. Te ${quedan == 1 ? 'queda 1 intento' : 'quedan $quedan intentos'}.',
    );
  }

  /// El contador es por teléfono: si varios comparten el equipo, los errores
  /// de uno no bloquean a los demás.
  Future<ControlIntentos> _leerIntentos(String tel) async {
    final json = await _almacen.leer(_claveIntentos(tel));
    return json == null
        ? const ControlIntentos()
        : ControlIntentos.desdeJson(jsonDecode(json) as Map<String, Object?>);
  }

  Future<void> _guardarIntentos(String tel, ControlIntentos c) =>
      _almacen.escribir(_claveIntentos(tel), jsonEncode(c.aJson()));

  /// El perfil viene del servidor: se guarda en la base local sin encolarlo.
  Future<void> _guardarUsuarioLocal(Perfil p) => _db
      .into(_db.usuarios)
      .insertOnConflictUpdate(
        Usuario(
          id: p.id,
          authId: p.authId,
          nombre: p.nombre,
          telefono: p.telefono,
          rol: p.rol,
          especialidad: p.especialidad,
          activo: p.activo,
          createdAtDevice: p.createdAtDevice ?? _reloj(),
        ),
      );

  Future<Perfil?> _perfilLocal(String tel) async {
    final fila = await (_db.select(
      _db.usuarios,
    )..where((u) => u.telefono.equals(tel))).getSingleOrNull();
    if (fila == null || !fila.activo) return null;
    return Perfil(
      id: fila.id,
      nombre: fila.nombre,
      telefono: fila.telefono,
      rol: fila.rol,
      especialidad: fila.especialidad,
      activo: fila.activo,
      authId: fila.authId,
      createdAtDevice: fila.createdAtDevice,
    );
  }
}
