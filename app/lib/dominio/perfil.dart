/// Datos del usuario con sesión iniciada (subconjunto de la entidad Usuario).
class Perfil {
  const Perfil({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.rol,
    this.especialidad,
    this.activo = true,
    this.authId,
    this.createdAtDevice,
  });

  final String id;
  final String nombre;
  final String telefono;

  /// `ENCARGADO` o `TRABAJADOR`.
  final String rol;
  final String? especialidad;
  final bool activo;
  final String? authId;
  final DateTime? createdAtDevice;

  bool get esEncargado => rol == 'ENCARGADO';

  /// Primer nombre, para saludar ("Hola, Juan").
  String get nombreCorto => nombre.split(' ').first;

  /// Desde una fila de `usuario` tal como la devuelve PostgREST.
  factory Perfil.desdeJson(Map<String, dynamic> json) => Perfil(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        telefono: json['telefono'] as String,
        rol: json['rol'] as String,
        especialidad: json['especialidad'] as String?,
        activo: json['activo'] as bool? ?? true,
        authId: json['auth_id'] as String?,
        createdAtDevice: json['created_at_device'] == null
            ? null
            : DateTime.parse(json['created_at_device'] as String),
      );

  Map<String, dynamic> aJson() => {
        'id': id,
        'nombre': nombre,
        'telefono': telefono,
        'rol': rol,
        'especialidad': especialidad,
        'activo': activo,
        'auth_id': authId,
        'created_at_device': createdAtDevice?.toUtc().toIso8601String(),
      };
}

/// Respuesta de `estado_cuenta(telefono)` en el servidor.
enum EstadoCuenta {
  preregistrado('PREREGISTRADO'),
  activo('ACTIVO'),
  inactivo('INACTIVO'),
  inexistente('INEXISTENTE');

  const EstadoCuenta(this.valor);
  final String valor;

  static EstadoCuenta desdeValor(String valor) =>
      EstadoCuenta.values.firstWhere((e) => e.valor == valor);
}
