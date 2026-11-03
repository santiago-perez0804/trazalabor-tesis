// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_datos.dart';

// ignore_for_file: type=lint
class $UsuariosTable extends Usuarios with TableInfo<$UsuariosTable, Usuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authIdMeta = const VerificationMeta('authId');
  @override
  late final GeneratedColumn<String> authId = GeneratedColumn<String>(
    'auth_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _rolMeta = const VerificationMeta('rol');
  @override
  late final GeneratedColumn<String> rol = GeneratedColumn<String>(
    'rol',
    aliasedName,
    false,
    check: () => rol.isIn(const ['ENCARGADO', 'TRABAJADOR']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _especialidadMeta = const VerificationMeta(
    'especialidad',
  );
  @override
  late final GeneratedColumn<String> especialidad = GeneratedColumn<String>(
    'especialidad',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtDeviceMeta = const VerificationMeta(
    'createdAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtDevice =
      GeneratedColumn<DateTime>(
        'created_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedAtServerMeta = const VerificationMeta(
    'receivedAtServer',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAtServer =
      GeneratedColumn<DateTime>(
        'received_at_server',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    authId,
    nombre,
    telefono,
    rol,
    especialidad,
    activo,
    createdAtDevice,
    receivedAtServer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuario';
  @override
  VerificationContext validateIntegrity(
    Insertable<Usuario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('auth_id')) {
      context.handle(
        _authIdMeta,
        authId.isAcceptableOrUnknown(data['auth_id']!, _authIdMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    } else if (isInserting) {
      context.missing(_telefonoMeta);
    }
    if (data.containsKey('rol')) {
      context.handle(
        _rolMeta,
        rol.isAcceptableOrUnknown(data['rol']!, _rolMeta),
      );
    } else if (isInserting) {
      context.missing(_rolMeta);
    }
    if (data.containsKey('especialidad')) {
      context.handle(
        _especialidadMeta,
        especialidad.isAcceptableOrUnknown(
          data['especialidad']!,
          _especialidadMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('created_at_device')) {
      context.handle(
        _createdAtDeviceMeta,
        createdAtDevice.isAcceptableOrUnknown(
          data['created_at_device']!,
          _createdAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDeviceMeta);
    }
    if (data.containsKey('received_at_server')) {
      context.handle(
        _receivedAtServerMeta,
        receivedAtServer.isAcceptableOrUnknown(
          data['received_at_server']!,
          _receivedAtServerMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Usuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Usuario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      authId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_id'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      )!,
      rol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol'],
      )!,
      especialidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}especialidad'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      createdAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_device'],
      )!,
      receivedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at_server'],
      ),
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class Usuario extends DataClass implements Insertable<Usuario> {
  final String id;
  final String? authId;
  final String nombre;
  final String telefono;
  final String rol;
  final String? especialidad;
  final bool activo;
  final DateTime createdAtDevice;
  final DateTime? receivedAtServer;
  const Usuario({
    required this.id,
    this.authId,
    required this.nombre,
    required this.telefono,
    required this.rol,
    this.especialidad,
    required this.activo,
    required this.createdAtDevice,
    this.receivedAtServer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || authId != null) {
      map['auth_id'] = Variable<String>(authId);
    }
    map['nombre'] = Variable<String>(nombre);
    map['telefono'] = Variable<String>(telefono);
    map['rol'] = Variable<String>(rol);
    if (!nullToAbsent || especialidad != null) {
      map['especialidad'] = Variable<String>(especialidad);
    }
    map['activo'] = Variable<bool>(activo);
    map['created_at_device'] = Variable<DateTime>(createdAtDevice);
    if (!nullToAbsent || receivedAtServer != null) {
      map['received_at_server'] = Variable<DateTime>(receivedAtServer);
    }
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      authId: authId == null && nullToAbsent
          ? const Value.absent()
          : Value(authId),
      nombre: Value(nombre),
      telefono: Value(telefono),
      rol: Value(rol),
      especialidad: especialidad == null && nullToAbsent
          ? const Value.absent()
          : Value(especialidad),
      activo: Value(activo),
      createdAtDevice: Value(createdAtDevice),
      receivedAtServer: receivedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAtServer),
    );
  }

  factory Usuario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Usuario(
      id: serializer.fromJson<String>(json['id']),
      authId: serializer.fromJson<String?>(json['auth_id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String>(json['telefono']),
      rol: serializer.fromJson<String>(json['rol']),
      especialidad: serializer.fromJson<String?>(json['especialidad']),
      activo: serializer.fromJson<bool>(json['activo']),
      createdAtDevice: serializer.fromJson<DateTime>(json['created_at_device']),
      receivedAtServer: serializer.fromJson<DateTime?>(
        json['received_at_server'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auth_id': serializer.toJson<String?>(authId),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String>(telefono),
      'rol': serializer.toJson<String>(rol),
      'especialidad': serializer.toJson<String?>(especialidad),
      'activo': serializer.toJson<bool>(activo),
      'created_at_device': serializer.toJson<DateTime>(createdAtDevice),
      'received_at_server': serializer.toJson<DateTime?>(receivedAtServer),
    };
  }

  Usuario copyWith({
    String? id,
    Value<String?> authId = const Value.absent(),
    String? nombre,
    String? telefono,
    String? rol,
    Value<String?> especialidad = const Value.absent(),
    bool? activo,
    DateTime? createdAtDevice,
    Value<DateTime?> receivedAtServer = const Value.absent(),
  }) => Usuario(
    id: id ?? this.id,
    authId: authId.present ? authId.value : this.authId,
    nombre: nombre ?? this.nombre,
    telefono: telefono ?? this.telefono,
    rol: rol ?? this.rol,
    especialidad: especialidad.present ? especialidad.value : this.especialidad,
    activo: activo ?? this.activo,
    createdAtDevice: createdAtDevice ?? this.createdAtDevice,
    receivedAtServer: receivedAtServer.present
        ? receivedAtServer.value
        : this.receivedAtServer,
  );
  Usuario copyWithCompanion(UsuariosCompanion data) {
    return Usuario(
      id: data.id.present ? data.id.value : this.id,
      authId: data.authId.present ? data.authId.value : this.authId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      rol: data.rol.present ? data.rol.value : this.rol,
      especialidad: data.especialidad.present
          ? data.especialidad.value
          : this.especialidad,
      activo: data.activo.present ? data.activo.value : this.activo,
      createdAtDevice: data.createdAtDevice.present
          ? data.createdAtDevice.value
          : this.createdAtDevice,
      receivedAtServer: data.receivedAtServer.present
          ? data.receivedAtServer.value
          : this.receivedAtServer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Usuario(')
          ..write('id: $id, ')
          ..write('authId: $authId, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('rol: $rol, ')
          ..write('especialidad: $especialidad, ')
          ..write('activo: $activo, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('receivedAtServer: $receivedAtServer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    authId,
    nombre,
    telefono,
    rol,
    especialidad,
    activo,
    createdAtDevice,
    receivedAtServer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Usuario &&
          other.id == this.id &&
          other.authId == this.authId &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.rol == this.rol &&
          other.especialidad == this.especialidad &&
          other.activo == this.activo &&
          other.createdAtDevice == this.createdAtDevice &&
          other.receivedAtServer == this.receivedAtServer);
}

class UsuariosCompanion extends UpdateCompanion<Usuario> {
  final Value<String> id;
  final Value<String?> authId;
  final Value<String> nombre;
  final Value<String> telefono;
  final Value<String> rol;
  final Value<String?> especialidad;
  final Value<bool> activo;
  final Value<DateTime> createdAtDevice;
  final Value<DateTime?> receivedAtServer;
  final Value<int> rowid;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.authId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.rol = const Value.absent(),
    this.especialidad = const Value.absent(),
    this.activo = const Value.absent(),
    this.createdAtDevice = const Value.absent(),
    this.receivedAtServer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsuariosCompanion.insert({
    required String id,
    this.authId = const Value.absent(),
    required String nombre,
    required String telefono,
    required String rol,
    this.especialidad = const Value.absent(),
    this.activo = const Value.absent(),
    required DateTime createdAtDevice,
    this.receivedAtServer = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       telefono = Value(telefono),
       rol = Value(rol),
       createdAtDevice = Value(createdAtDevice);
  static Insertable<Usuario> custom({
    Expression<String>? id,
    Expression<String>? authId,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? rol,
    Expression<String>? especialidad,
    Expression<bool>? activo,
    Expression<DateTime>? createdAtDevice,
    Expression<DateTime>? receivedAtServer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (authId != null) 'auth_id': authId,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (rol != null) 'rol': rol,
      if (especialidad != null) 'especialidad': especialidad,
      if (activo != null) 'activo': activo,
      if (createdAtDevice != null) 'created_at_device': createdAtDevice,
      if (receivedAtServer != null) 'received_at_server': receivedAtServer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsuariosCompanion copyWith({
    Value<String>? id,
    Value<String?>? authId,
    Value<String>? nombre,
    Value<String>? telefono,
    Value<String>? rol,
    Value<String?>? especialidad,
    Value<bool>? activo,
    Value<DateTime>? createdAtDevice,
    Value<DateTime?>? receivedAtServer,
    Value<int>? rowid,
  }) {
    return UsuariosCompanion(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      especialidad: especialidad ?? this.especialidad,
      activo: activo ?? this.activo,
      createdAtDevice: createdAtDevice ?? this.createdAtDevice,
      receivedAtServer: receivedAtServer ?? this.receivedAtServer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (authId.present) {
      map['auth_id'] = Variable<String>(authId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(rol.value);
    }
    if (especialidad.present) {
      map['especialidad'] = Variable<String>(especialidad.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (createdAtDevice.present) {
      map['created_at_device'] = Variable<DateTime>(createdAtDevice.value);
    }
    if (receivedAtServer.present) {
      map['received_at_server'] = Variable<DateTime>(receivedAtServer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('authId: $authId, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('rol: $rol, ')
          ..write('especialidad: $especialidad, ')
          ..write('activo: $activo, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('receivedAtServer: $receivedAtServer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnidadesProductivasTable extends UnidadesProductivas
    with TableInfo<$UnidadesProductivasTable, UnidadProductiva> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnidadesProductivasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    check: () => tipo.isIn(const ['LOTE', 'POTRERO', 'INSTALACION']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _superficieHaMeta = const VerificationMeta(
    'superficieHa',
  );
  @override
  late final GeneratedColumn<double> superficieHa = GeneratedColumn<double>(
    'superficie_ha',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoQrMeta = const VerificationMeta(
    'codigoQr',
  );
  @override
  late final GeneratedColumn<String> codigoQr = GeneratedColumn<String>(
    'codigo_qr',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activaMeta = const VerificationMeta('activa');
  @override
  late final GeneratedColumn<bool> activa = GeneratedColumn<bool>(
    'activa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    tipo,
    superficieHa,
    codigoQr,
    latitud,
    longitud,
    activa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unidad_productiva';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnidadProductiva> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('superficie_ha')) {
      context.handle(
        _superficieHaMeta,
        superficieHa.isAcceptableOrUnknown(
          data['superficie_ha']!,
          _superficieHaMeta,
        ),
      );
    }
    if (data.containsKey('codigo_qr')) {
      context.handle(
        _codigoQrMeta,
        codigoQr.isAcceptableOrUnknown(data['codigo_qr']!, _codigoQrMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoQrMeta);
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    }
    if (data.containsKey('activa')) {
      context.handle(
        _activaMeta,
        activa.isAcceptableOrUnknown(data['activa']!, _activaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnidadProductiva map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnidadProductiva(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      superficieHa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}superficie_ha'],
      ),
      codigoQr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_qr'],
      )!,
      latitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitud'],
      ),
      longitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitud'],
      ),
      activa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activa'],
      )!,
    );
  }

  @override
  $UnidadesProductivasTable createAlias(String alias) {
    return $UnidadesProductivasTable(attachedDatabase, alias);
  }
}

class UnidadProductiva extends DataClass
    implements Insertable<UnidadProductiva> {
  final String id;
  final String nombre;
  final String tipo;
  final double? superficieHa;
  final String codigoQr;
  final double? latitud;
  final double? longitud;
  final bool activa;
  const UnidadProductiva({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.superficieHa,
    required this.codigoQr,
    this.latitud,
    this.longitud,
    required this.activa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || superficieHa != null) {
      map['superficie_ha'] = Variable<double>(superficieHa);
    }
    map['codigo_qr'] = Variable<String>(codigoQr);
    if (!nullToAbsent || latitud != null) {
      map['latitud'] = Variable<double>(latitud);
    }
    if (!nullToAbsent || longitud != null) {
      map['longitud'] = Variable<double>(longitud);
    }
    map['activa'] = Variable<bool>(activa);
    return map;
  }

  UnidadesProductivasCompanion toCompanion(bool nullToAbsent) {
    return UnidadesProductivasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      tipo: Value(tipo),
      superficieHa: superficieHa == null && nullToAbsent
          ? const Value.absent()
          : Value(superficieHa),
      codigoQr: Value(codigoQr),
      latitud: latitud == null && nullToAbsent
          ? const Value.absent()
          : Value(latitud),
      longitud: longitud == null && nullToAbsent
          ? const Value.absent()
          : Value(longitud),
      activa: Value(activa),
    );
  }

  factory UnidadProductiva.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnidadProductiva(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      tipo: serializer.fromJson<String>(json['tipo']),
      superficieHa: serializer.fromJson<double?>(json['superficie_ha']),
      codigoQr: serializer.fromJson<String>(json['codigo_qr']),
      latitud: serializer.fromJson<double?>(json['latitud']),
      longitud: serializer.fromJson<double?>(json['longitud']),
      activa: serializer.fromJson<bool>(json['activa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'tipo': serializer.toJson<String>(tipo),
      'superficie_ha': serializer.toJson<double?>(superficieHa),
      'codigo_qr': serializer.toJson<String>(codigoQr),
      'latitud': serializer.toJson<double?>(latitud),
      'longitud': serializer.toJson<double?>(longitud),
      'activa': serializer.toJson<bool>(activa),
    };
  }

  UnidadProductiva copyWith({
    String? id,
    String? nombre,
    String? tipo,
    Value<double?> superficieHa = const Value.absent(),
    String? codigoQr,
    Value<double?> latitud = const Value.absent(),
    Value<double?> longitud = const Value.absent(),
    bool? activa,
  }) => UnidadProductiva(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    tipo: tipo ?? this.tipo,
    superficieHa: superficieHa.present ? superficieHa.value : this.superficieHa,
    codigoQr: codigoQr ?? this.codigoQr,
    latitud: latitud.present ? latitud.value : this.latitud,
    longitud: longitud.present ? longitud.value : this.longitud,
    activa: activa ?? this.activa,
  );
  UnidadProductiva copyWithCompanion(UnidadesProductivasCompanion data) {
    return UnidadProductiva(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      superficieHa: data.superficieHa.present
          ? data.superficieHa.value
          : this.superficieHa,
      codigoQr: data.codigoQr.present ? data.codigoQr.value : this.codigoQr,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
      activa: data.activa.present ? data.activa.value : this.activa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnidadProductiva(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('superficieHa: $superficieHa, ')
          ..write('codigoQr: $codigoQr, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('activa: $activa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    tipo,
    superficieHa,
    codigoQr,
    latitud,
    longitud,
    activa,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnidadProductiva &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.tipo == this.tipo &&
          other.superficieHa == this.superficieHa &&
          other.codigoQr == this.codigoQr &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud &&
          other.activa == this.activa);
}

class UnidadesProductivasCompanion extends UpdateCompanion<UnidadProductiva> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> tipo;
  final Value<double?> superficieHa;
  final Value<String> codigoQr;
  final Value<double?> latitud;
  final Value<double?> longitud;
  final Value<bool> activa;
  final Value<int> rowid;
  const UnidadesProductivasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.tipo = const Value.absent(),
    this.superficieHa = const Value.absent(),
    this.codigoQr = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.activa = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnidadesProductivasCompanion.insert({
    required String id,
    required String nombre,
    required String tipo,
    this.superficieHa = const Value.absent(),
    required String codigoQr,
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.activa = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       tipo = Value(tipo),
       codigoQr = Value(codigoQr);
  static Insertable<UnidadProductiva> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? tipo,
    Expression<double>? superficieHa,
    Expression<String>? codigoQr,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<bool>? activa,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (tipo != null) 'tipo': tipo,
      if (superficieHa != null) 'superficie_ha': superficieHa,
      if (codigoQr != null) 'codigo_qr': codigoQr,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (activa != null) 'activa': activa,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnidadesProductivasCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String>? tipo,
    Value<double?>? superficieHa,
    Value<String>? codigoQr,
    Value<double?>? latitud,
    Value<double?>? longitud,
    Value<bool>? activa,
    Value<int>? rowid,
  }) {
    return UnidadesProductivasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      superficieHa: superficieHa ?? this.superficieHa,
      codigoQr: codigoQr ?? this.codigoQr,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      activa: activa ?? this.activa,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (superficieHa.present) {
      map['superficie_ha'] = Variable<double>(superficieHa.value);
    }
    if (codigoQr.present) {
      map['codigo_qr'] = Variable<String>(codigoQr.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (activa.present) {
      map['activa'] = Variable<bool>(activa.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnidadesProductivasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('superficieHa: $superficieHa, ')
          ..write('codigoQr: $codigoQr, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('activa: $activa, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TareasTable extends Tareas with TableInfo<$TareasTable, Tarea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TareasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unidadProductivaIdMeta =
      const VerificationMeta('unidadProductivaId');
  @override
  late final GeneratedColumn<String> unidadProductivaId =
      GeneratedColumn<String>(
        'unidad_productiva_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES unidad_productiva (id)',
        ),
      );
  static const VerificationMeta _creadorIdMeta = const VerificationMeta(
    'creadorId',
  );
  @override
  late final GeneratedColumn<String> creadorId = GeneratedColumn<String>(
    'creador_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuario (id)',
    ),
  );
  static const VerificationMeta _asignadoIdMeta = const VerificationMeta(
    'asignadoId',
  );
  @override
  late final GeneratedColumn<String> asignadoId = GeneratedColumn<String>(
    'asignado_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuario (id)',
    ),
  );
  static const VerificationMeta _tipoLaborMeta = const VerificationMeta(
    'tipoLabor',
  );
  @override
  late final GeneratedColumn<String> tipoLabor = GeneratedColumn<String>(
    'tipo_labor',
    aliasedName,
    false,
    check: () => tipoLabor.isIn(const [
      'GENERAL',
      'SIEMBRA',
      'APLICACION_FITOSANITARIA',
      'SANIDAD_ANIMAL',
      'MANTENIMIENTO',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaProgramadaMeta = const VerificationMeta(
    'fechaProgramada',
  );
  @override
  late final GeneratedColumn<String> fechaProgramada = GeneratedColumn<String>(
    'fecha_programada',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiereQrMeta = const VerificationMeta(
    'requiereQr',
  );
  @override
  late final GeneratedColumn<bool> requiereQr = GeneratedColumn<bool>(
    'requiere_qr',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requiere_qr" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _evidenciaRequeridaMeta =
      const VerificationMeta('evidenciaRequerida');
  @override
  late final GeneratedColumn<String> evidenciaRequerida =
      GeneratedColumn<String>(
        'evidencia_requerida',
        aliasedName,
        false,
        check: () => evidenciaRequerida.isIn(const [
          'NINGUNA',
          'FOTO',
          'AUDIO',
          'FOTO_Y_AUDIO',
        ]),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('NINGUNA'),
      );
  static const VerificationMeta _estadoActualMeta = const VerificationMeta(
    'estadoActual',
  );
  @override
  late final GeneratedColumn<String> estadoActual = GeneratedColumn<String>(
    'estado_actual',
    aliasedName,
    false,
    check: () => estadoActual.isIn(const [
      'CREADA',
      'ASIGNADA',
      'INICIADA',
      'COMPLETADA',
      'NO_COMPLETADA',
      'VERIFICADA',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CREADA'),
  );
  static const VerificationMeta _createdAtDeviceMeta = const VerificationMeta(
    'createdAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtDevice =
      GeneratedColumn<DateTime>(
        'created_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedAtServerMeta = const VerificationMeta(
    'receivedAtServer',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAtServer =
      GeneratedColumn<DateTime>(
        'received_at_server',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unidadProductivaId,
    creadorId,
    asignadoId,
    tipoLabor,
    descripcion,
    fechaProgramada,
    requiereQr,
    evidenciaRequerida,
    estadoActual,
    createdAtDevice,
    receivedAtServer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarea';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tarea> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unidad_productiva_id')) {
      context.handle(
        _unidadProductivaIdMeta,
        unidadProductivaId.isAcceptableOrUnknown(
          data['unidad_productiva_id']!,
          _unidadProductivaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unidadProductivaIdMeta);
    }
    if (data.containsKey('creador_id')) {
      context.handle(
        _creadorIdMeta,
        creadorId.isAcceptableOrUnknown(data['creador_id']!, _creadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creadorIdMeta);
    }
    if (data.containsKey('asignado_id')) {
      context.handle(
        _asignadoIdMeta,
        asignadoId.isAcceptableOrUnknown(data['asignado_id']!, _asignadoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_asignadoIdMeta);
    }
    if (data.containsKey('tipo_labor')) {
      context.handle(
        _tipoLaborMeta,
        tipoLabor.isAcceptableOrUnknown(data['tipo_labor']!, _tipoLaborMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoLaborMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('fecha_programada')) {
      context.handle(
        _fechaProgramadaMeta,
        fechaProgramada.isAcceptableOrUnknown(
          data['fecha_programada']!,
          _fechaProgramadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaProgramadaMeta);
    }
    if (data.containsKey('requiere_qr')) {
      context.handle(
        _requiereQrMeta,
        requiereQr.isAcceptableOrUnknown(data['requiere_qr']!, _requiereQrMeta),
      );
    }
    if (data.containsKey('evidencia_requerida')) {
      context.handle(
        _evidenciaRequeridaMeta,
        evidenciaRequerida.isAcceptableOrUnknown(
          data['evidencia_requerida']!,
          _evidenciaRequeridaMeta,
        ),
      );
    }
    if (data.containsKey('estado_actual')) {
      context.handle(
        _estadoActualMeta,
        estadoActual.isAcceptableOrUnknown(
          data['estado_actual']!,
          _estadoActualMeta,
        ),
      );
    }
    if (data.containsKey('created_at_device')) {
      context.handle(
        _createdAtDeviceMeta,
        createdAtDevice.isAcceptableOrUnknown(
          data['created_at_device']!,
          _createdAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDeviceMeta);
    }
    if (data.containsKey('received_at_server')) {
      context.handle(
        _receivedAtServerMeta,
        receivedAtServer.isAcceptableOrUnknown(
          data['received_at_server']!,
          _receivedAtServerMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tarea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tarea(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      unidadProductivaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidad_productiva_id'],
      )!,
      creadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creador_id'],
      )!,
      asignadoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asignado_id'],
      )!,
      tipoLabor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_labor'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      fechaProgramada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_programada'],
      )!,
      requiereQr: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requiere_qr'],
      )!,
      evidenciaRequerida: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidencia_requerida'],
      )!,
      estadoActual: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_actual'],
      )!,
      createdAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_device'],
      )!,
      receivedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at_server'],
      ),
    );
  }

  @override
  $TareasTable createAlias(String alias) {
    return $TareasTable(attachedDatabase, alias);
  }
}

class Tarea extends DataClass implements Insertable<Tarea> {
  final String id;
  final String unidadProductivaId;
  final String creadorId;
  final String asignadoId;
  final String tipoLabor;
  final String? descripcion;

  /// Fecha sin hora, 'AAAA-MM-DD' (tipo `date` en Postgres).
  final String fechaProgramada;
  final bool requiereQr;
  final String evidenciaRequerida;

  /// Proyección del último evento de estado (ver dominio/derivar_estado.dart).
  final String estadoActual;
  final DateTime createdAtDevice;
  final DateTime? receivedAtServer;
  const Tarea({
    required this.id,
    required this.unidadProductivaId,
    required this.creadorId,
    required this.asignadoId,
    required this.tipoLabor,
    this.descripcion,
    required this.fechaProgramada,
    required this.requiereQr,
    required this.evidenciaRequerida,
    required this.estadoActual,
    required this.createdAtDevice,
    this.receivedAtServer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unidad_productiva_id'] = Variable<String>(unidadProductivaId);
    map['creador_id'] = Variable<String>(creadorId);
    map['asignado_id'] = Variable<String>(asignadoId);
    map['tipo_labor'] = Variable<String>(tipoLabor);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['fecha_programada'] = Variable<String>(fechaProgramada);
    map['requiere_qr'] = Variable<bool>(requiereQr);
    map['evidencia_requerida'] = Variable<String>(evidenciaRequerida);
    map['estado_actual'] = Variable<String>(estadoActual);
    map['created_at_device'] = Variable<DateTime>(createdAtDevice);
    if (!nullToAbsent || receivedAtServer != null) {
      map['received_at_server'] = Variable<DateTime>(receivedAtServer);
    }
    return map;
  }

  TareasCompanion toCompanion(bool nullToAbsent) {
    return TareasCompanion(
      id: Value(id),
      unidadProductivaId: Value(unidadProductivaId),
      creadorId: Value(creadorId),
      asignadoId: Value(asignadoId),
      tipoLabor: Value(tipoLabor),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      fechaProgramada: Value(fechaProgramada),
      requiereQr: Value(requiereQr),
      evidenciaRequerida: Value(evidenciaRequerida),
      estadoActual: Value(estadoActual),
      createdAtDevice: Value(createdAtDevice),
      receivedAtServer: receivedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAtServer),
    );
  }

  factory Tarea.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tarea(
      id: serializer.fromJson<String>(json['id']),
      unidadProductivaId: serializer.fromJson<String>(
        json['unidad_productiva_id'],
      ),
      creadorId: serializer.fromJson<String>(json['creador_id']),
      asignadoId: serializer.fromJson<String>(json['asignado_id']),
      tipoLabor: serializer.fromJson<String>(json['tipo_labor']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      fechaProgramada: serializer.fromJson<String>(json['fecha_programada']),
      requiereQr: serializer.fromJson<bool>(json['requiere_qr']),
      evidenciaRequerida: serializer.fromJson<String>(
        json['evidencia_requerida'],
      ),
      estadoActual: serializer.fromJson<String>(json['estado_actual']),
      createdAtDevice: serializer.fromJson<DateTime>(json['created_at_device']),
      receivedAtServer: serializer.fromJson<DateTime?>(
        json['received_at_server'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unidad_productiva_id': serializer.toJson<String>(unidadProductivaId),
      'creador_id': serializer.toJson<String>(creadorId),
      'asignado_id': serializer.toJson<String>(asignadoId),
      'tipo_labor': serializer.toJson<String>(tipoLabor),
      'descripcion': serializer.toJson<String?>(descripcion),
      'fecha_programada': serializer.toJson<String>(fechaProgramada),
      'requiere_qr': serializer.toJson<bool>(requiereQr),
      'evidencia_requerida': serializer.toJson<String>(evidenciaRequerida),
      'estado_actual': serializer.toJson<String>(estadoActual),
      'created_at_device': serializer.toJson<DateTime>(createdAtDevice),
      'received_at_server': serializer.toJson<DateTime?>(receivedAtServer),
    };
  }

  Tarea copyWith({
    String? id,
    String? unidadProductivaId,
    String? creadorId,
    String? asignadoId,
    String? tipoLabor,
    Value<String?> descripcion = const Value.absent(),
    String? fechaProgramada,
    bool? requiereQr,
    String? evidenciaRequerida,
    String? estadoActual,
    DateTime? createdAtDevice,
    Value<DateTime?> receivedAtServer = const Value.absent(),
  }) => Tarea(
    id: id ?? this.id,
    unidadProductivaId: unidadProductivaId ?? this.unidadProductivaId,
    creadorId: creadorId ?? this.creadorId,
    asignadoId: asignadoId ?? this.asignadoId,
    tipoLabor: tipoLabor ?? this.tipoLabor,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    fechaProgramada: fechaProgramada ?? this.fechaProgramada,
    requiereQr: requiereQr ?? this.requiereQr,
    evidenciaRequerida: evidenciaRequerida ?? this.evidenciaRequerida,
    estadoActual: estadoActual ?? this.estadoActual,
    createdAtDevice: createdAtDevice ?? this.createdAtDevice,
    receivedAtServer: receivedAtServer.present
        ? receivedAtServer.value
        : this.receivedAtServer,
  );
  Tarea copyWithCompanion(TareasCompanion data) {
    return Tarea(
      id: data.id.present ? data.id.value : this.id,
      unidadProductivaId: data.unidadProductivaId.present
          ? data.unidadProductivaId.value
          : this.unidadProductivaId,
      creadorId: data.creadorId.present ? data.creadorId.value : this.creadorId,
      asignadoId: data.asignadoId.present
          ? data.asignadoId.value
          : this.asignadoId,
      tipoLabor: data.tipoLabor.present ? data.tipoLabor.value : this.tipoLabor,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      fechaProgramada: data.fechaProgramada.present
          ? data.fechaProgramada.value
          : this.fechaProgramada,
      requiereQr: data.requiereQr.present
          ? data.requiereQr.value
          : this.requiereQr,
      evidenciaRequerida: data.evidenciaRequerida.present
          ? data.evidenciaRequerida.value
          : this.evidenciaRequerida,
      estadoActual: data.estadoActual.present
          ? data.estadoActual.value
          : this.estadoActual,
      createdAtDevice: data.createdAtDevice.present
          ? data.createdAtDevice.value
          : this.createdAtDevice,
      receivedAtServer: data.receivedAtServer.present
          ? data.receivedAtServer.value
          : this.receivedAtServer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tarea(')
          ..write('id: $id, ')
          ..write('unidadProductivaId: $unidadProductivaId, ')
          ..write('creadorId: $creadorId, ')
          ..write('asignadoId: $asignadoId, ')
          ..write('tipoLabor: $tipoLabor, ')
          ..write('descripcion: $descripcion, ')
          ..write('fechaProgramada: $fechaProgramada, ')
          ..write('requiereQr: $requiereQr, ')
          ..write('evidenciaRequerida: $evidenciaRequerida, ')
          ..write('estadoActual: $estadoActual, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('receivedAtServer: $receivedAtServer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unidadProductivaId,
    creadorId,
    asignadoId,
    tipoLabor,
    descripcion,
    fechaProgramada,
    requiereQr,
    evidenciaRequerida,
    estadoActual,
    createdAtDevice,
    receivedAtServer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tarea &&
          other.id == this.id &&
          other.unidadProductivaId == this.unidadProductivaId &&
          other.creadorId == this.creadorId &&
          other.asignadoId == this.asignadoId &&
          other.tipoLabor == this.tipoLabor &&
          other.descripcion == this.descripcion &&
          other.fechaProgramada == this.fechaProgramada &&
          other.requiereQr == this.requiereQr &&
          other.evidenciaRequerida == this.evidenciaRequerida &&
          other.estadoActual == this.estadoActual &&
          other.createdAtDevice == this.createdAtDevice &&
          other.receivedAtServer == this.receivedAtServer);
}

class TareasCompanion extends UpdateCompanion<Tarea> {
  final Value<String> id;
  final Value<String> unidadProductivaId;
  final Value<String> creadorId;
  final Value<String> asignadoId;
  final Value<String> tipoLabor;
  final Value<String?> descripcion;
  final Value<String> fechaProgramada;
  final Value<bool> requiereQr;
  final Value<String> evidenciaRequerida;
  final Value<String> estadoActual;
  final Value<DateTime> createdAtDevice;
  final Value<DateTime?> receivedAtServer;
  final Value<int> rowid;
  const TareasCompanion({
    this.id = const Value.absent(),
    this.unidadProductivaId = const Value.absent(),
    this.creadorId = const Value.absent(),
    this.asignadoId = const Value.absent(),
    this.tipoLabor = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.fechaProgramada = const Value.absent(),
    this.requiereQr = const Value.absent(),
    this.evidenciaRequerida = const Value.absent(),
    this.estadoActual = const Value.absent(),
    this.createdAtDevice = const Value.absent(),
    this.receivedAtServer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TareasCompanion.insert({
    required String id,
    required String unidadProductivaId,
    required String creadorId,
    required String asignadoId,
    required String tipoLabor,
    this.descripcion = const Value.absent(),
    required String fechaProgramada,
    this.requiereQr = const Value.absent(),
    this.evidenciaRequerida = const Value.absent(),
    this.estadoActual = const Value.absent(),
    required DateTime createdAtDevice,
    this.receivedAtServer = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       unidadProductivaId = Value(unidadProductivaId),
       creadorId = Value(creadorId),
       asignadoId = Value(asignadoId),
       tipoLabor = Value(tipoLabor),
       fechaProgramada = Value(fechaProgramada),
       createdAtDevice = Value(createdAtDevice);
  static Insertable<Tarea> custom({
    Expression<String>? id,
    Expression<String>? unidadProductivaId,
    Expression<String>? creadorId,
    Expression<String>? asignadoId,
    Expression<String>? tipoLabor,
    Expression<String>? descripcion,
    Expression<String>? fechaProgramada,
    Expression<bool>? requiereQr,
    Expression<String>? evidenciaRequerida,
    Expression<String>? estadoActual,
    Expression<DateTime>? createdAtDevice,
    Expression<DateTime>? receivedAtServer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unidadProductivaId != null)
        'unidad_productiva_id': unidadProductivaId,
      if (creadorId != null) 'creador_id': creadorId,
      if (asignadoId != null) 'asignado_id': asignadoId,
      if (tipoLabor != null) 'tipo_labor': tipoLabor,
      if (descripcion != null) 'descripcion': descripcion,
      if (fechaProgramada != null) 'fecha_programada': fechaProgramada,
      if (requiereQr != null) 'requiere_qr': requiereQr,
      if (evidenciaRequerida != null) 'evidencia_requerida': evidenciaRequerida,
      if (estadoActual != null) 'estado_actual': estadoActual,
      if (createdAtDevice != null) 'created_at_device': createdAtDevice,
      if (receivedAtServer != null) 'received_at_server': receivedAtServer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TareasCompanion copyWith({
    Value<String>? id,
    Value<String>? unidadProductivaId,
    Value<String>? creadorId,
    Value<String>? asignadoId,
    Value<String>? tipoLabor,
    Value<String?>? descripcion,
    Value<String>? fechaProgramada,
    Value<bool>? requiereQr,
    Value<String>? evidenciaRequerida,
    Value<String>? estadoActual,
    Value<DateTime>? createdAtDevice,
    Value<DateTime?>? receivedAtServer,
    Value<int>? rowid,
  }) {
    return TareasCompanion(
      id: id ?? this.id,
      unidadProductivaId: unidadProductivaId ?? this.unidadProductivaId,
      creadorId: creadorId ?? this.creadorId,
      asignadoId: asignadoId ?? this.asignadoId,
      tipoLabor: tipoLabor ?? this.tipoLabor,
      descripcion: descripcion ?? this.descripcion,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      requiereQr: requiereQr ?? this.requiereQr,
      evidenciaRequerida: evidenciaRequerida ?? this.evidenciaRequerida,
      estadoActual: estadoActual ?? this.estadoActual,
      createdAtDevice: createdAtDevice ?? this.createdAtDevice,
      receivedAtServer: receivedAtServer ?? this.receivedAtServer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (unidadProductivaId.present) {
      map['unidad_productiva_id'] = Variable<String>(unidadProductivaId.value);
    }
    if (creadorId.present) {
      map['creador_id'] = Variable<String>(creadorId.value);
    }
    if (asignadoId.present) {
      map['asignado_id'] = Variable<String>(asignadoId.value);
    }
    if (tipoLabor.present) {
      map['tipo_labor'] = Variable<String>(tipoLabor.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (fechaProgramada.present) {
      map['fecha_programada'] = Variable<String>(fechaProgramada.value);
    }
    if (requiereQr.present) {
      map['requiere_qr'] = Variable<bool>(requiereQr.value);
    }
    if (evidenciaRequerida.present) {
      map['evidencia_requerida'] = Variable<String>(evidenciaRequerida.value);
    }
    if (estadoActual.present) {
      map['estado_actual'] = Variable<String>(estadoActual.value);
    }
    if (createdAtDevice.present) {
      map['created_at_device'] = Variable<DateTime>(createdAtDevice.value);
    }
    if (receivedAtServer.present) {
      map['received_at_server'] = Variable<DateTime>(receivedAtServer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TareasCompanion(')
          ..write('id: $id, ')
          ..write('unidadProductivaId: $unidadProductivaId, ')
          ..write('creadorId: $creadorId, ')
          ..write('asignadoId: $asignadoId, ')
          ..write('tipoLabor: $tipoLabor, ')
          ..write('descripcion: $descripcion, ')
          ..write('fechaProgramada: $fechaProgramada, ')
          ..write('requiereQr: $requiereQr, ')
          ..write('evidenciaRequerida: $evidenciaRequerida, ')
          ..write('estadoActual: $estadoActual, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('receivedAtServer: $receivedAtServer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsChecklistTable extends ItemsChecklist
    with TableInfo<$ItemsChecklistTable, ItemChecklist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsChecklistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tareaIdMeta = const VerificationMeta(
    'tareaId',
  );
  @override
  late final GeneratedColumn<String> tareaId = GeneratedColumn<String>(
    'tarea_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tarea (id)',
    ),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoRespuestaMeta = const VerificationMeta(
    'tipoRespuesta',
  );
  @override
  late final GeneratedColumn<String> tipoRespuesta = GeneratedColumn<String>(
    'tipo_respuesta',
    aliasedName,
    false,
    check: () => tipoRespuesta.isIn(const ['CHECK', 'NUMERO', 'TEXTO']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _obligatorioMeta = const VerificationMeta(
    'obligatorio',
  );
  @override
  late final GeneratedColumn<bool> obligatorio = GeneratedColumn<bool>(
    'obligatorio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("obligatorio" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completadoMeta = const VerificationMeta(
    'completado',
  );
  @override
  late final GeneratedColumn<bool> completado = GeneratedColumn<bool>(
    'completado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tareaId,
    orden,
    descripcion,
    tipoRespuesta,
    obligatorio,
    valor,
    completado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_checklist';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemChecklist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tarea_id')) {
      context.handle(
        _tareaIdMeta,
        tareaId.isAcceptableOrUnknown(data['tarea_id']!, _tareaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tareaIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('tipo_respuesta')) {
      context.handle(
        _tipoRespuestaMeta,
        tipoRespuesta.isAcceptableOrUnknown(
          data['tipo_respuesta']!,
          _tipoRespuestaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoRespuestaMeta);
    }
    if (data.containsKey('obligatorio')) {
      context.handle(
        _obligatorioMeta,
        obligatorio.isAcceptableOrUnknown(
          data['obligatorio']!,
          _obligatorioMeta,
        ),
      );
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    }
    if (data.containsKey('completado')) {
      context.handle(
        _completadoMeta,
        completado.isAcceptableOrUnknown(data['completado']!, _completadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemChecklist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemChecklist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tareaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tarea_id'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      tipoRespuesta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_respuesta'],
      )!,
      obligatorio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}obligatorio'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      ),
      completado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completado'],
      )!,
    );
  }

  @override
  $ItemsChecklistTable createAlias(String alias) {
    return $ItemsChecklistTable(attachedDatabase, alias);
  }
}

class ItemChecklist extends DataClass implements Insertable<ItemChecklist> {
  final String id;
  final String tareaId;
  final int orden;
  final String descripcion;
  final String tipoRespuesta;
  final bool obligatorio;
  final String? valor;
  final bool completado;
  const ItemChecklist({
    required this.id,
    required this.tareaId,
    required this.orden,
    required this.descripcion,
    required this.tipoRespuesta,
    required this.obligatorio,
    this.valor,
    required this.completado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tarea_id'] = Variable<String>(tareaId);
    map['orden'] = Variable<int>(orden);
    map['descripcion'] = Variable<String>(descripcion);
    map['tipo_respuesta'] = Variable<String>(tipoRespuesta);
    map['obligatorio'] = Variable<bool>(obligatorio);
    if (!nullToAbsent || valor != null) {
      map['valor'] = Variable<String>(valor);
    }
    map['completado'] = Variable<bool>(completado);
    return map;
  }

  ItemsChecklistCompanion toCompanion(bool nullToAbsent) {
    return ItemsChecklistCompanion(
      id: Value(id),
      tareaId: Value(tareaId),
      orden: Value(orden),
      descripcion: Value(descripcion),
      tipoRespuesta: Value(tipoRespuesta),
      obligatorio: Value(obligatorio),
      valor: valor == null && nullToAbsent
          ? const Value.absent()
          : Value(valor),
      completado: Value(completado),
    );
  }

  factory ItemChecklist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemChecklist(
      id: serializer.fromJson<String>(json['id']),
      tareaId: serializer.fromJson<String>(json['tarea_id']),
      orden: serializer.fromJson<int>(json['orden']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      tipoRespuesta: serializer.fromJson<String>(json['tipo_respuesta']),
      obligatorio: serializer.fromJson<bool>(json['obligatorio']),
      valor: serializer.fromJson<String?>(json['valor']),
      completado: serializer.fromJson<bool>(json['completado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tarea_id': serializer.toJson<String>(tareaId),
      'orden': serializer.toJson<int>(orden),
      'descripcion': serializer.toJson<String>(descripcion),
      'tipo_respuesta': serializer.toJson<String>(tipoRespuesta),
      'obligatorio': serializer.toJson<bool>(obligatorio),
      'valor': serializer.toJson<String?>(valor),
      'completado': serializer.toJson<bool>(completado),
    };
  }

  ItemChecklist copyWith({
    String? id,
    String? tareaId,
    int? orden,
    String? descripcion,
    String? tipoRespuesta,
    bool? obligatorio,
    Value<String?> valor = const Value.absent(),
    bool? completado,
  }) => ItemChecklist(
    id: id ?? this.id,
    tareaId: tareaId ?? this.tareaId,
    orden: orden ?? this.orden,
    descripcion: descripcion ?? this.descripcion,
    tipoRespuesta: tipoRespuesta ?? this.tipoRespuesta,
    obligatorio: obligatorio ?? this.obligatorio,
    valor: valor.present ? valor.value : this.valor,
    completado: completado ?? this.completado,
  );
  ItemChecklist copyWithCompanion(ItemsChecklistCompanion data) {
    return ItemChecklist(
      id: data.id.present ? data.id.value : this.id,
      tareaId: data.tareaId.present ? data.tareaId.value : this.tareaId,
      orden: data.orden.present ? data.orden.value : this.orden,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      tipoRespuesta: data.tipoRespuesta.present
          ? data.tipoRespuesta.value
          : this.tipoRespuesta,
      obligatorio: data.obligatorio.present
          ? data.obligatorio.value
          : this.obligatorio,
      valor: data.valor.present ? data.valor.value : this.valor,
      completado: data.completado.present
          ? data.completado.value
          : this.completado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemChecklist(')
          ..write('id: $id, ')
          ..write('tareaId: $tareaId, ')
          ..write('orden: $orden, ')
          ..write('descripcion: $descripcion, ')
          ..write('tipoRespuesta: $tipoRespuesta, ')
          ..write('obligatorio: $obligatorio, ')
          ..write('valor: $valor, ')
          ..write('completado: $completado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tareaId,
    orden,
    descripcion,
    tipoRespuesta,
    obligatorio,
    valor,
    completado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemChecklist &&
          other.id == this.id &&
          other.tareaId == this.tareaId &&
          other.orden == this.orden &&
          other.descripcion == this.descripcion &&
          other.tipoRespuesta == this.tipoRespuesta &&
          other.obligatorio == this.obligatorio &&
          other.valor == this.valor &&
          other.completado == this.completado);
}

class ItemsChecklistCompanion extends UpdateCompanion<ItemChecklist> {
  final Value<String> id;
  final Value<String> tareaId;
  final Value<int> orden;
  final Value<String> descripcion;
  final Value<String> tipoRespuesta;
  final Value<bool> obligatorio;
  final Value<String?> valor;
  final Value<bool> completado;
  final Value<int> rowid;
  const ItemsChecklistCompanion({
    this.id = const Value.absent(),
    this.tareaId = const Value.absent(),
    this.orden = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.tipoRespuesta = const Value.absent(),
    this.obligatorio = const Value.absent(),
    this.valor = const Value.absent(),
    this.completado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsChecklistCompanion.insert({
    required String id,
    required String tareaId,
    required int orden,
    required String descripcion,
    required String tipoRespuesta,
    this.obligatorio = const Value.absent(),
    this.valor = const Value.absent(),
    this.completado = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tareaId = Value(tareaId),
       orden = Value(orden),
       descripcion = Value(descripcion),
       tipoRespuesta = Value(tipoRespuesta);
  static Insertable<ItemChecklist> custom({
    Expression<String>? id,
    Expression<String>? tareaId,
    Expression<int>? orden,
    Expression<String>? descripcion,
    Expression<String>? tipoRespuesta,
    Expression<bool>? obligatorio,
    Expression<String>? valor,
    Expression<bool>? completado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tareaId != null) 'tarea_id': tareaId,
      if (orden != null) 'orden': orden,
      if (descripcion != null) 'descripcion': descripcion,
      if (tipoRespuesta != null) 'tipo_respuesta': tipoRespuesta,
      if (obligatorio != null) 'obligatorio': obligatorio,
      if (valor != null) 'valor': valor,
      if (completado != null) 'completado': completado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsChecklistCompanion copyWith({
    Value<String>? id,
    Value<String>? tareaId,
    Value<int>? orden,
    Value<String>? descripcion,
    Value<String>? tipoRespuesta,
    Value<bool>? obligatorio,
    Value<String?>? valor,
    Value<bool>? completado,
    Value<int>? rowid,
  }) {
    return ItemsChecklistCompanion(
      id: id ?? this.id,
      tareaId: tareaId ?? this.tareaId,
      orden: orden ?? this.orden,
      descripcion: descripcion ?? this.descripcion,
      tipoRespuesta: tipoRespuesta ?? this.tipoRespuesta,
      obligatorio: obligatorio ?? this.obligatorio,
      valor: valor ?? this.valor,
      completado: completado ?? this.completado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tareaId.present) {
      map['tarea_id'] = Variable<String>(tareaId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (tipoRespuesta.present) {
      map['tipo_respuesta'] = Variable<String>(tipoRespuesta.value);
    }
    if (obligatorio.present) {
      map['obligatorio'] = Variable<bool>(obligatorio.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (completado.present) {
      map['completado'] = Variable<bool>(completado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsChecklistCompanion(')
          ..write('id: $id, ')
          ..write('tareaId: $tareaId, ')
          ..write('orden: $orden, ')
          ..write('descripcion: $descripcion, ')
          ..write('tipoRespuesta: $tipoRespuesta, ')
          ..write('obligatorio: $obligatorio, ')
          ..write('valor: $valor, ')
          ..write('completado: $completado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventosTable extends Eventos with TableInfo<$EventosTable, Evento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tareaIdMeta = const VerificationMeta(
    'tareaId',
  );
  @override
  late final GeneratedColumn<String> tareaId = GeneratedColumn<String>(
    'tarea_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tarea (id)',
    ),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuario (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    check: () => tipo.isIn(const [
      'CREADA',
      'ASIGNADA',
      'INICIADA',
      'ITEM_COMPLETADO',
      'QR_VERIFICADO',
      'EVIDENCIA_ADJUNTA',
      'COMPLETADA',
      'NO_COMPLETADA',
      'VERIFICADA',
      'REASIGNADA',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String>
  payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  ).withConverter<Map<String, Object?>>($EventosTable.$converterpayload);
  static const VerificationMeta _createdAtDeviceMeta = const VerificationMeta(
    'createdAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtDevice =
      GeneratedColumn<DateTime>(
        'created_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedAtServerMeta = const VerificationMeta(
    'receivedAtServer',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAtServer =
      GeneratedColumn<DateTime>(
        'received_at_server',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tareaId,
    usuarioId,
    tipo,
    payload,
    createdAtDevice,
    receivedAtServer,
    latitud,
    longitud,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evento';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tarea_id')) {
      context.handle(
        _tareaIdMeta,
        tareaId.isAcceptableOrUnknown(data['tarea_id']!, _tareaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tareaIdMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('created_at_device')) {
      context.handle(
        _createdAtDeviceMeta,
        createdAtDevice.isAcceptableOrUnknown(
          data['created_at_device']!,
          _createdAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDeviceMeta);
    }
    if (data.containsKey('received_at_server')) {
      context.handle(
        _receivedAtServerMeta,
        receivedAtServer.isAcceptableOrUnknown(
          data['received_at_server']!,
          _receivedAtServerMeta,
        ),
      );
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tareaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tarea_id'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      payload: $EventosTable.$converterpayload.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payload'],
        )!,
      ),
      createdAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_device'],
      )!,
      receivedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at_server'],
      ),
      latitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitud'],
      ),
      longitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitud'],
      ),
    );
  }

  @override
  $EventosTable createAlias(String alias) {
    return $EventosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?>
  $converterpayload = conversorJson;
}

class Evento extends DataClass implements Insertable<Evento> {
  final String id;
  final String tareaId;
  final String usuarioId;
  final String tipo;
  final Map<String, Object?> payload;
  final DateTime createdAtDevice;
  final DateTime? receivedAtServer;
  final double? latitud;
  final double? longitud;
  const Evento({
    required this.id,
    required this.tareaId,
    required this.usuarioId,
    required this.tipo,
    required this.payload,
    required this.createdAtDevice,
    this.receivedAtServer,
    this.latitud,
    this.longitud,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tarea_id'] = Variable<String>(tareaId);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['tipo'] = Variable<String>(tipo);
    {
      map['payload'] = Variable<String>(
        $EventosTable.$converterpayload.toSql(payload),
      );
    }
    map['created_at_device'] = Variable<DateTime>(createdAtDevice);
    if (!nullToAbsent || receivedAtServer != null) {
      map['received_at_server'] = Variable<DateTime>(receivedAtServer);
    }
    if (!nullToAbsent || latitud != null) {
      map['latitud'] = Variable<double>(latitud);
    }
    if (!nullToAbsent || longitud != null) {
      map['longitud'] = Variable<double>(longitud);
    }
    return map;
  }

  EventosCompanion toCompanion(bool nullToAbsent) {
    return EventosCompanion(
      id: Value(id),
      tareaId: Value(tareaId),
      usuarioId: Value(usuarioId),
      tipo: Value(tipo),
      payload: Value(payload),
      createdAtDevice: Value(createdAtDevice),
      receivedAtServer: receivedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAtServer),
      latitud: latitud == null && nullToAbsent
          ? const Value.absent()
          : Value(latitud),
      longitud: longitud == null && nullToAbsent
          ? const Value.absent()
          : Value(longitud),
    );
  }

  factory Evento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evento(
      id: serializer.fromJson<String>(json['id']),
      tareaId: serializer.fromJson<String>(json['tarea_id']),
      usuarioId: serializer.fromJson<String>(json['usuario_id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      payload: $EventosTable.$converterpayload.fromJson(
        serializer.fromJson<Object?>(json['payload']),
      ),
      createdAtDevice: serializer.fromJson<DateTime>(json['created_at_device']),
      receivedAtServer: serializer.fromJson<DateTime?>(
        json['received_at_server'],
      ),
      latitud: serializer.fromJson<double?>(json['latitud']),
      longitud: serializer.fromJson<double?>(json['longitud']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tarea_id': serializer.toJson<String>(tareaId),
      'usuario_id': serializer.toJson<String>(usuarioId),
      'tipo': serializer.toJson<String>(tipo),
      'payload': serializer.toJson<Object?>(
        $EventosTable.$converterpayload.toJson(payload),
      ),
      'created_at_device': serializer.toJson<DateTime>(createdAtDevice),
      'received_at_server': serializer.toJson<DateTime?>(receivedAtServer),
      'latitud': serializer.toJson<double?>(latitud),
      'longitud': serializer.toJson<double?>(longitud),
    };
  }

  Evento copyWith({
    String? id,
    String? tareaId,
    String? usuarioId,
    String? tipo,
    Map<String, Object?>? payload,
    DateTime? createdAtDevice,
    Value<DateTime?> receivedAtServer = const Value.absent(),
    Value<double?> latitud = const Value.absent(),
    Value<double?> longitud = const Value.absent(),
  }) => Evento(
    id: id ?? this.id,
    tareaId: tareaId ?? this.tareaId,
    usuarioId: usuarioId ?? this.usuarioId,
    tipo: tipo ?? this.tipo,
    payload: payload ?? this.payload,
    createdAtDevice: createdAtDevice ?? this.createdAtDevice,
    receivedAtServer: receivedAtServer.present
        ? receivedAtServer.value
        : this.receivedAtServer,
    latitud: latitud.present ? latitud.value : this.latitud,
    longitud: longitud.present ? longitud.value : this.longitud,
  );
  Evento copyWithCompanion(EventosCompanion data) {
    return Evento(
      id: data.id.present ? data.id.value : this.id,
      tareaId: data.tareaId.present ? data.tareaId.value : this.tareaId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAtDevice: data.createdAtDevice.present
          ? data.createdAtDevice.value
          : this.createdAtDevice,
      receivedAtServer: data.receivedAtServer.present
          ? data.receivedAtServer.value
          : this.receivedAtServer,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evento(')
          ..write('id: $id, ')
          ..write('tareaId: $tareaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('tipo: $tipo, ')
          ..write('payload: $payload, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('receivedAtServer: $receivedAtServer, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tareaId,
    usuarioId,
    tipo,
    payload,
    createdAtDevice,
    receivedAtServer,
    latitud,
    longitud,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evento &&
          other.id == this.id &&
          other.tareaId == this.tareaId &&
          other.usuarioId == this.usuarioId &&
          other.tipo == this.tipo &&
          other.payload == this.payload &&
          other.createdAtDevice == this.createdAtDevice &&
          other.receivedAtServer == this.receivedAtServer &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud);
}

class EventosCompanion extends UpdateCompanion<Evento> {
  final Value<String> id;
  final Value<String> tareaId;
  final Value<String> usuarioId;
  final Value<String> tipo;
  final Value<Map<String, Object?>> payload;
  final Value<DateTime> createdAtDevice;
  final Value<DateTime?> receivedAtServer;
  final Value<double?> latitud;
  final Value<double?> longitud;
  final Value<int> rowid;
  const EventosCompanion({
    this.id = const Value.absent(),
    this.tareaId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAtDevice = const Value.absent(),
    this.receivedAtServer = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventosCompanion.insert({
    required String id,
    required String tareaId,
    required String usuarioId,
    required String tipo,
    this.payload = const Value.absent(),
    required DateTime createdAtDevice,
    this.receivedAtServer = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tareaId = Value(tareaId),
       usuarioId = Value(usuarioId),
       tipo = Value(tipo),
       createdAtDevice = Value(createdAtDevice);
  static Insertable<Evento> custom({
    Expression<String>? id,
    Expression<String>? tareaId,
    Expression<String>? usuarioId,
    Expression<String>? tipo,
    Expression<String>? payload,
    Expression<DateTime>? createdAtDevice,
    Expression<DateTime>? receivedAtServer,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tareaId != null) 'tarea_id': tareaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (tipo != null) 'tipo': tipo,
      if (payload != null) 'payload': payload,
      if (createdAtDevice != null) 'created_at_device': createdAtDevice,
      if (receivedAtServer != null) 'received_at_server': receivedAtServer,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventosCompanion copyWith({
    Value<String>? id,
    Value<String>? tareaId,
    Value<String>? usuarioId,
    Value<String>? tipo,
    Value<Map<String, Object?>>? payload,
    Value<DateTime>? createdAtDevice,
    Value<DateTime?>? receivedAtServer,
    Value<double?>? latitud,
    Value<double?>? longitud,
    Value<int>? rowid,
  }) {
    return EventosCompanion(
      id: id ?? this.id,
      tareaId: tareaId ?? this.tareaId,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
      payload: payload ?? this.payload,
      createdAtDevice: createdAtDevice ?? this.createdAtDevice,
      receivedAtServer: receivedAtServer ?? this.receivedAtServer,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tareaId.present) {
      map['tarea_id'] = Variable<String>(tareaId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(
        $EventosTable.$converterpayload.toSql(payload.value),
      );
    }
    if (createdAtDevice.present) {
      map['created_at_device'] = Variable<DateTime>(createdAtDevice.value);
    }
    if (receivedAtServer.present) {
      map['received_at_server'] = Variable<DateTime>(receivedAtServer.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventosCompanion(')
          ..write('id: $id, ')
          ..write('tareaId: $tareaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('tipo: $tipo, ')
          ..write('payload: $payload, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('receivedAtServer: $receivedAtServer, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvidenciasTable extends Evidencias
    with TableInfo<$EvidenciasTable, Evidencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tareaIdMeta = const VerificationMeta(
    'tareaId',
  );
  @override
  late final GeneratedColumn<String> tareaId = GeneratedColumn<String>(
    'tarea_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tarea (id)',
    ),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuario (id)',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    check: () => tipo.isIn(const ['FOTO', 'AUDIO']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rutaLocalMeta = const VerificationMeta(
    'rutaLocal',
  );
  @override
  late final GeneratedColumn<String> rutaLocal = GeneratedColumn<String>(
    'ruta_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rutaRemotaMeta = const VerificationMeta(
    'rutaRemota',
  );
  @override
  late final GeneratedColumn<String> rutaRemota = GeneratedColumn<String>(
    'ruta_remota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tamanioBytesMeta = const VerificationMeta(
    'tamanioBytes',
  );
  @override
  late final GeneratedColumn<int> tamanioBytes = GeneratedColumn<int>(
    'tamanio_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hashSha256Meta = const VerificationMeta(
    'hashSha256',
  );
  @override
  late final GeneratedColumn<String> hashSha256 = GeneratedColumn<String>(
    'hash_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtDeviceMeta = const VerificationMeta(
    'createdAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtDevice =
      GeneratedColumn<DateTime>(
        'created_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _receivedAtServerMeta = const VerificationMeta(
    'receivedAtServer',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAtServer =
      GeneratedColumn<DateTime>(
        'received_at_server',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tareaId,
    usuarioId,
    tipo,
    rutaLocal,
    rutaRemota,
    tamanioBytes,
    hashSha256,
    createdAtDevice,
    receivedAtServer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidencia';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evidencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tarea_id')) {
      context.handle(
        _tareaIdMeta,
        tareaId.isAcceptableOrUnknown(data['tarea_id']!, _tareaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tareaIdMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('ruta_local')) {
      context.handle(
        _rutaLocalMeta,
        rutaLocal.isAcceptableOrUnknown(data['ruta_local']!, _rutaLocalMeta),
      );
    }
    if (data.containsKey('ruta_remota')) {
      context.handle(
        _rutaRemotaMeta,
        rutaRemota.isAcceptableOrUnknown(data['ruta_remota']!, _rutaRemotaMeta),
      );
    }
    if (data.containsKey('tamanio_bytes')) {
      context.handle(
        _tamanioBytesMeta,
        tamanioBytes.isAcceptableOrUnknown(
          data['tamanio_bytes']!,
          _tamanioBytesMeta,
        ),
      );
    }
    if (data.containsKey('hash_sha256')) {
      context.handle(
        _hashSha256Meta,
        hashSha256.isAcceptableOrUnknown(data['hash_sha256']!, _hashSha256Meta),
      );
    } else if (isInserting) {
      context.missing(_hashSha256Meta);
    }
    if (data.containsKey('created_at_device')) {
      context.handle(
        _createdAtDeviceMeta,
        createdAtDevice.isAcceptableOrUnknown(
          data['created_at_device']!,
          _createdAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDeviceMeta);
    }
    if (data.containsKey('received_at_server')) {
      context.handle(
        _receivedAtServerMeta,
        receivedAtServer.isAcceptableOrUnknown(
          data['received_at_server']!,
          _receivedAtServerMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evidencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evidencia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tareaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tarea_id'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      rutaLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruta_local'],
      ),
      rutaRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruta_remota'],
      ),
      tamanioBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tamanio_bytes'],
      ),
      hashSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash_sha256'],
      )!,
      createdAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_device'],
      )!,
      receivedAtServer: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at_server'],
      ),
    );
  }

  @override
  $EvidenciasTable createAlias(String alias) {
    return $EvidenciasTable(attachedDatabase, alias);
  }
}

class Evidencia extends DataClass implements Insertable<Evidencia> {
  final String id;
  final String tareaId;
  final String usuarioId;
  final String tipo;
  final String? rutaLocal;
  final String? rutaRemota;
  final int? tamanioBytes;
  final String hashSha256;
  final DateTime createdAtDevice;
  final DateTime? receivedAtServer;
  const Evidencia({
    required this.id,
    required this.tareaId,
    required this.usuarioId,
    required this.tipo,
    this.rutaLocal,
    this.rutaRemota,
    this.tamanioBytes,
    required this.hashSha256,
    required this.createdAtDevice,
    this.receivedAtServer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tarea_id'] = Variable<String>(tareaId);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || rutaLocal != null) {
      map['ruta_local'] = Variable<String>(rutaLocal);
    }
    if (!nullToAbsent || rutaRemota != null) {
      map['ruta_remota'] = Variable<String>(rutaRemota);
    }
    if (!nullToAbsent || tamanioBytes != null) {
      map['tamanio_bytes'] = Variable<int>(tamanioBytes);
    }
    map['hash_sha256'] = Variable<String>(hashSha256);
    map['created_at_device'] = Variable<DateTime>(createdAtDevice);
    if (!nullToAbsent || receivedAtServer != null) {
      map['received_at_server'] = Variable<DateTime>(receivedAtServer);
    }
    return map;
  }

  EvidenciasCompanion toCompanion(bool nullToAbsent) {
    return EvidenciasCompanion(
      id: Value(id),
      tareaId: Value(tareaId),
      usuarioId: Value(usuarioId),
      tipo: Value(tipo),
      rutaLocal: rutaLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(rutaLocal),
      rutaRemota: rutaRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(rutaRemota),
      tamanioBytes: tamanioBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(tamanioBytes),
      hashSha256: Value(hashSha256),
      createdAtDevice: Value(createdAtDevice),
      receivedAtServer: receivedAtServer == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedAtServer),
    );
  }

  factory Evidencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evidencia(
      id: serializer.fromJson<String>(json['id']),
      tareaId: serializer.fromJson<String>(json['tarea_id']),
      usuarioId: serializer.fromJson<String>(json['usuario_id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      rutaLocal: serializer.fromJson<String?>(json['ruta_local']),
      rutaRemota: serializer.fromJson<String?>(json['ruta_remota']),
      tamanioBytes: serializer.fromJson<int?>(json['tamanio_bytes']),
      hashSha256: serializer.fromJson<String>(json['hash_sha256']),
      createdAtDevice: serializer.fromJson<DateTime>(json['created_at_device']),
      receivedAtServer: serializer.fromJson<DateTime?>(
        json['received_at_server'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tarea_id': serializer.toJson<String>(tareaId),
      'usuario_id': serializer.toJson<String>(usuarioId),
      'tipo': serializer.toJson<String>(tipo),
      'ruta_local': serializer.toJson<String?>(rutaLocal),
      'ruta_remota': serializer.toJson<String?>(rutaRemota),
      'tamanio_bytes': serializer.toJson<int?>(tamanioBytes),
      'hash_sha256': serializer.toJson<String>(hashSha256),
      'created_at_device': serializer.toJson<DateTime>(createdAtDevice),
      'received_at_server': serializer.toJson<DateTime?>(receivedAtServer),
    };
  }

  Evidencia copyWith({
    String? id,
    String? tareaId,
    String? usuarioId,
    String? tipo,
    Value<String?> rutaLocal = const Value.absent(),
    Value<String?> rutaRemota = const Value.absent(),
    Value<int?> tamanioBytes = const Value.absent(),
    String? hashSha256,
    DateTime? createdAtDevice,
    Value<DateTime?> receivedAtServer = const Value.absent(),
  }) => Evidencia(
    id: id ?? this.id,
    tareaId: tareaId ?? this.tareaId,
    usuarioId: usuarioId ?? this.usuarioId,
    tipo: tipo ?? this.tipo,
    rutaLocal: rutaLocal.present ? rutaLocal.value : this.rutaLocal,
    rutaRemota: rutaRemota.present ? rutaRemota.value : this.rutaRemota,
    tamanioBytes: tamanioBytes.present ? tamanioBytes.value : this.tamanioBytes,
    hashSha256: hashSha256 ?? this.hashSha256,
    createdAtDevice: createdAtDevice ?? this.createdAtDevice,
    receivedAtServer: receivedAtServer.present
        ? receivedAtServer.value
        : this.receivedAtServer,
  );
  Evidencia copyWithCompanion(EvidenciasCompanion data) {
    return Evidencia(
      id: data.id.present ? data.id.value : this.id,
      tareaId: data.tareaId.present ? data.tareaId.value : this.tareaId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      rutaLocal: data.rutaLocal.present ? data.rutaLocal.value : this.rutaLocal,
      rutaRemota: data.rutaRemota.present
          ? data.rutaRemota.value
          : this.rutaRemota,
      tamanioBytes: data.tamanioBytes.present
          ? data.tamanioBytes.value
          : this.tamanioBytes,
      hashSha256: data.hashSha256.present
          ? data.hashSha256.value
          : this.hashSha256,
      createdAtDevice: data.createdAtDevice.present
          ? data.createdAtDevice.value
          : this.createdAtDevice,
      receivedAtServer: data.receivedAtServer.present
          ? data.receivedAtServer.value
          : this.receivedAtServer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evidencia(')
          ..write('id: $id, ')
          ..write('tareaId: $tareaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('tipo: $tipo, ')
          ..write('rutaLocal: $rutaLocal, ')
          ..write('rutaRemota: $rutaRemota, ')
          ..write('tamanioBytes: $tamanioBytes, ')
          ..write('hashSha256: $hashSha256, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('receivedAtServer: $receivedAtServer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tareaId,
    usuarioId,
    tipo,
    rutaLocal,
    rutaRemota,
    tamanioBytes,
    hashSha256,
    createdAtDevice,
    receivedAtServer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evidencia &&
          other.id == this.id &&
          other.tareaId == this.tareaId &&
          other.usuarioId == this.usuarioId &&
          other.tipo == this.tipo &&
          other.rutaLocal == this.rutaLocal &&
          other.rutaRemota == this.rutaRemota &&
          other.tamanioBytes == this.tamanioBytes &&
          other.hashSha256 == this.hashSha256 &&
          other.createdAtDevice == this.createdAtDevice &&
          other.receivedAtServer == this.receivedAtServer);
}

class EvidenciasCompanion extends UpdateCompanion<Evidencia> {
  final Value<String> id;
  final Value<String> tareaId;
  final Value<String> usuarioId;
  final Value<String> tipo;
  final Value<String?> rutaLocal;
  final Value<String?> rutaRemota;
  final Value<int?> tamanioBytes;
  final Value<String> hashSha256;
  final Value<DateTime> createdAtDevice;
  final Value<DateTime?> receivedAtServer;
  final Value<int> rowid;
  const EvidenciasCompanion({
    this.id = const Value.absent(),
    this.tareaId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.rutaLocal = const Value.absent(),
    this.rutaRemota = const Value.absent(),
    this.tamanioBytes = const Value.absent(),
    this.hashSha256 = const Value.absent(),
    this.createdAtDevice = const Value.absent(),
    this.receivedAtServer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvidenciasCompanion.insert({
    required String id,
    required String tareaId,
    required String usuarioId,
    required String tipo,
    this.rutaLocal = const Value.absent(),
    this.rutaRemota = const Value.absent(),
    this.tamanioBytes = const Value.absent(),
    required String hashSha256,
    required DateTime createdAtDevice,
    this.receivedAtServer = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tareaId = Value(tareaId),
       usuarioId = Value(usuarioId),
       tipo = Value(tipo),
       hashSha256 = Value(hashSha256),
       createdAtDevice = Value(createdAtDevice);
  static Insertable<Evidencia> custom({
    Expression<String>? id,
    Expression<String>? tareaId,
    Expression<String>? usuarioId,
    Expression<String>? tipo,
    Expression<String>? rutaLocal,
    Expression<String>? rutaRemota,
    Expression<int>? tamanioBytes,
    Expression<String>? hashSha256,
    Expression<DateTime>? createdAtDevice,
    Expression<DateTime>? receivedAtServer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tareaId != null) 'tarea_id': tareaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (tipo != null) 'tipo': tipo,
      if (rutaLocal != null) 'ruta_local': rutaLocal,
      if (rutaRemota != null) 'ruta_remota': rutaRemota,
      if (tamanioBytes != null) 'tamanio_bytes': tamanioBytes,
      if (hashSha256 != null) 'hash_sha256': hashSha256,
      if (createdAtDevice != null) 'created_at_device': createdAtDevice,
      if (receivedAtServer != null) 'received_at_server': receivedAtServer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvidenciasCompanion copyWith({
    Value<String>? id,
    Value<String>? tareaId,
    Value<String>? usuarioId,
    Value<String>? tipo,
    Value<String?>? rutaLocal,
    Value<String?>? rutaRemota,
    Value<int?>? tamanioBytes,
    Value<String>? hashSha256,
    Value<DateTime>? createdAtDevice,
    Value<DateTime?>? receivedAtServer,
    Value<int>? rowid,
  }) {
    return EvidenciasCompanion(
      id: id ?? this.id,
      tareaId: tareaId ?? this.tareaId,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
      rutaLocal: rutaLocal ?? this.rutaLocal,
      rutaRemota: rutaRemota ?? this.rutaRemota,
      tamanioBytes: tamanioBytes ?? this.tamanioBytes,
      hashSha256: hashSha256 ?? this.hashSha256,
      createdAtDevice: createdAtDevice ?? this.createdAtDevice,
      receivedAtServer: receivedAtServer ?? this.receivedAtServer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tareaId.present) {
      map['tarea_id'] = Variable<String>(tareaId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (rutaLocal.present) {
      map['ruta_local'] = Variable<String>(rutaLocal.value);
    }
    if (rutaRemota.present) {
      map['ruta_remota'] = Variable<String>(rutaRemota.value);
    }
    if (tamanioBytes.present) {
      map['tamanio_bytes'] = Variable<int>(tamanioBytes.value);
    }
    if (hashSha256.present) {
      map['hash_sha256'] = Variable<String>(hashSha256.value);
    }
    if (createdAtDevice.present) {
      map['created_at_device'] = Variable<DateTime>(createdAtDevice.value);
    }
    if (receivedAtServer.present) {
      map['received_at_server'] = Variable<DateTime>(receivedAtServer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenciasCompanion(')
          ..write('id: $id, ')
          ..write('tareaId: $tareaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('tipo: $tipo, ')
          ..write('rutaLocal: $rutaLocal, ')
          ..write('rutaRemota: $rutaRemota, ')
          ..write('tamanioBytes: $tamanioBytes, ')
          ..write('hashSha256: $hashSha256, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('receivedAtServer: $receivedAtServer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperacionesPendientesTable extends OperacionesPendientes
    with TableInfo<$OperacionesPendientesTable, OperacionPendiente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperacionesPendientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entidadMeta = const VerificationMeta(
    'entidad',
  );
  @override
  late final GeneratedColumn<String> entidad = GeneratedColumn<String>(
    'entidad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entidadIdMeta = const VerificationMeta(
    'entidadId',
  );
  @override
  late final GeneratedColumn<String> entidadId = GeneratedColumn<String>(
    'entidad_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operacionMeta = const VerificationMeta(
    'operacion',
  );
  @override
  late final GeneratedColumn<String> operacion = GeneratedColumn<String>(
    'operacion',
    aliasedName,
    false,
    check: () => operacion.isIn(const ['INSERT', 'UPDATE', 'SUBIDA']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, Object?>, String>
  payload =
      GeneratedColumn<String>(
        'payload',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, Object?>>(
        $OperacionesPendientesTable.$converterpayload,
      );
  static const VerificationMeta _intentosMeta = const VerificationMeta(
    'intentos',
  );
  @override
  late final GeneratedColumn<int> intentos = GeneratedColumn<int>(
    'intentos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ultimoErrorMeta = const VerificationMeta(
    'ultimoError',
  );
  @override
  late final GeneratedColumn<String> ultimoError = GeneratedColumn<String>(
    'ultimo_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtDeviceMeta = const VerificationMeta(
    'createdAtDevice',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtDevice =
      GeneratedColumn<DateTime>(
        'created_at_device',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    check: () => estado.isIn(const ['PENDIENTE', 'ENVIADO', 'ERROR']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDIENTE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entidad,
    entidadId,
    operacion,
    payload,
    intentos,
    ultimoError,
    createdAtDevice,
    estado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operacion_pendiente';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperacionPendiente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entidad')) {
      context.handle(
        _entidadMeta,
        entidad.isAcceptableOrUnknown(data['entidad']!, _entidadMeta),
      );
    } else if (isInserting) {
      context.missing(_entidadMeta);
    }
    if (data.containsKey('entidad_id')) {
      context.handle(
        _entidadIdMeta,
        entidadId.isAcceptableOrUnknown(data['entidad_id']!, _entidadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entidadIdMeta);
    }
    if (data.containsKey('operacion')) {
      context.handle(
        _operacionMeta,
        operacion.isAcceptableOrUnknown(data['operacion']!, _operacionMeta),
      );
    } else if (isInserting) {
      context.missing(_operacionMeta);
    }
    if (data.containsKey('intentos')) {
      context.handle(
        _intentosMeta,
        intentos.isAcceptableOrUnknown(data['intentos']!, _intentosMeta),
      );
    }
    if (data.containsKey('ultimo_error')) {
      context.handle(
        _ultimoErrorMeta,
        ultimoError.isAcceptableOrUnknown(
          data['ultimo_error']!,
          _ultimoErrorMeta,
        ),
      );
    }
    if (data.containsKey('created_at_device')) {
      context.handle(
        _createdAtDeviceMeta,
        createdAtDevice.isAcceptableOrUnknown(
          data['created_at_device']!,
          _createdAtDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtDeviceMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperacionPendiente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperacionPendiente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entidad'],
      )!,
      entidadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entidad_id'],
      )!,
      operacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operacion'],
      )!,
      payload: $OperacionesPendientesTable.$converterpayload.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payload'],
        )!,
      ),
      intentos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intentos'],
      )!,
      ultimoError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultimo_error'],
      ),
      createdAtDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_device'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
    );
  }

  @override
  $OperacionesPendientesTable createAlias(String alias) {
    return $OperacionesPendientesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Map<String, Object?>, String, Object?>
  $converterpayload = conversorJson;
}

class OperacionPendiente extends DataClass
    implements Insertable<OperacionPendiente> {
  final String id;
  final String entidad;
  final String entidadId;

  /// INSERT o UPDATE (Tabla 14). SUBIDA = archivo de la cola de multimedia
  /// (decisión D4 en docs/trazabilidad.md).
  final String operacion;
  final Map<String, Object?> payload;
  final int intentos;
  final String? ultimoError;
  final DateTime createdAtDevice;
  final String estado;
  const OperacionPendiente({
    required this.id,
    required this.entidad,
    required this.entidadId,
    required this.operacion,
    required this.payload,
    required this.intentos,
    this.ultimoError,
    required this.createdAtDevice,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entidad'] = Variable<String>(entidad);
    map['entidad_id'] = Variable<String>(entidadId);
    map['operacion'] = Variable<String>(operacion);
    {
      map['payload'] = Variable<String>(
        $OperacionesPendientesTable.$converterpayload.toSql(payload),
      );
    }
    map['intentos'] = Variable<int>(intentos);
    if (!nullToAbsent || ultimoError != null) {
      map['ultimo_error'] = Variable<String>(ultimoError);
    }
    map['created_at_device'] = Variable<DateTime>(createdAtDevice);
    map['estado'] = Variable<String>(estado);
    return map;
  }

  OperacionesPendientesCompanion toCompanion(bool nullToAbsent) {
    return OperacionesPendientesCompanion(
      id: Value(id),
      entidad: Value(entidad),
      entidadId: Value(entidadId),
      operacion: Value(operacion),
      payload: Value(payload),
      intentos: Value(intentos),
      ultimoError: ultimoError == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoError),
      createdAtDevice: Value(createdAtDevice),
      estado: Value(estado),
    );
  }

  factory OperacionPendiente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperacionPendiente(
      id: serializer.fromJson<String>(json['id']),
      entidad: serializer.fromJson<String>(json['entidad']),
      entidadId: serializer.fromJson<String>(json['entidad_id']),
      operacion: serializer.fromJson<String>(json['operacion']),
      payload: $OperacionesPendientesTable.$converterpayload.fromJson(
        serializer.fromJson<Object?>(json['payload']),
      ),
      intentos: serializer.fromJson<int>(json['intentos']),
      ultimoError: serializer.fromJson<String?>(json['ultimo_error']),
      createdAtDevice: serializer.fromJson<DateTime>(json['created_at_device']),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entidad': serializer.toJson<String>(entidad),
      'entidad_id': serializer.toJson<String>(entidadId),
      'operacion': serializer.toJson<String>(operacion),
      'payload': serializer.toJson<Object?>(
        $OperacionesPendientesTable.$converterpayload.toJson(payload),
      ),
      'intentos': serializer.toJson<int>(intentos),
      'ultimo_error': serializer.toJson<String?>(ultimoError),
      'created_at_device': serializer.toJson<DateTime>(createdAtDevice),
      'estado': serializer.toJson<String>(estado),
    };
  }

  OperacionPendiente copyWith({
    String? id,
    String? entidad,
    String? entidadId,
    String? operacion,
    Map<String, Object?>? payload,
    int? intentos,
    Value<String?> ultimoError = const Value.absent(),
    DateTime? createdAtDevice,
    String? estado,
  }) => OperacionPendiente(
    id: id ?? this.id,
    entidad: entidad ?? this.entidad,
    entidadId: entidadId ?? this.entidadId,
    operacion: operacion ?? this.operacion,
    payload: payload ?? this.payload,
    intentos: intentos ?? this.intentos,
    ultimoError: ultimoError.present ? ultimoError.value : this.ultimoError,
    createdAtDevice: createdAtDevice ?? this.createdAtDevice,
    estado: estado ?? this.estado,
  );
  OperacionPendiente copyWithCompanion(OperacionesPendientesCompanion data) {
    return OperacionPendiente(
      id: data.id.present ? data.id.value : this.id,
      entidad: data.entidad.present ? data.entidad.value : this.entidad,
      entidadId: data.entidadId.present ? data.entidadId.value : this.entidadId,
      operacion: data.operacion.present ? data.operacion.value : this.operacion,
      payload: data.payload.present ? data.payload.value : this.payload,
      intentos: data.intentos.present ? data.intentos.value : this.intentos,
      ultimoError: data.ultimoError.present
          ? data.ultimoError.value
          : this.ultimoError,
      createdAtDevice: data.createdAtDevice.present
          ? data.createdAtDevice.value
          : this.createdAtDevice,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperacionPendiente(')
          ..write('id: $id, ')
          ..write('entidad: $entidad, ')
          ..write('entidadId: $entidadId, ')
          ..write('operacion: $operacion, ')
          ..write('payload: $payload, ')
          ..write('intentos: $intentos, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entidad,
    entidadId,
    operacion,
    payload,
    intentos,
    ultimoError,
    createdAtDevice,
    estado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperacionPendiente &&
          other.id == this.id &&
          other.entidad == this.entidad &&
          other.entidadId == this.entidadId &&
          other.operacion == this.operacion &&
          other.payload == this.payload &&
          other.intentos == this.intentos &&
          other.ultimoError == this.ultimoError &&
          other.createdAtDevice == this.createdAtDevice &&
          other.estado == this.estado);
}

class OperacionesPendientesCompanion
    extends UpdateCompanion<OperacionPendiente> {
  final Value<String> id;
  final Value<String> entidad;
  final Value<String> entidadId;
  final Value<String> operacion;
  final Value<Map<String, Object?>> payload;
  final Value<int> intentos;
  final Value<String?> ultimoError;
  final Value<DateTime> createdAtDevice;
  final Value<String> estado;
  final Value<int> rowid;
  const OperacionesPendientesCompanion({
    this.id = const Value.absent(),
    this.entidad = const Value.absent(),
    this.entidadId = const Value.absent(),
    this.operacion = const Value.absent(),
    this.payload = const Value.absent(),
    this.intentos = const Value.absent(),
    this.ultimoError = const Value.absent(),
    this.createdAtDevice = const Value.absent(),
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperacionesPendientesCompanion.insert({
    required String id,
    required String entidad,
    required String entidadId,
    required String operacion,
    required Map<String, Object?> payload,
    this.intentos = const Value.absent(),
    this.ultimoError = const Value.absent(),
    required DateTime createdAtDevice,
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entidad = Value(entidad),
       entidadId = Value(entidadId),
       operacion = Value(operacion),
       payload = Value(payload),
       createdAtDevice = Value(createdAtDevice);
  static Insertable<OperacionPendiente> custom({
    Expression<String>? id,
    Expression<String>? entidad,
    Expression<String>? entidadId,
    Expression<String>? operacion,
    Expression<String>? payload,
    Expression<int>? intentos,
    Expression<String>? ultimoError,
    Expression<DateTime>? createdAtDevice,
    Expression<String>? estado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entidad != null) 'entidad': entidad,
      if (entidadId != null) 'entidad_id': entidadId,
      if (operacion != null) 'operacion': operacion,
      if (payload != null) 'payload': payload,
      if (intentos != null) 'intentos': intentos,
      if (ultimoError != null) 'ultimo_error': ultimoError,
      if (createdAtDevice != null) 'created_at_device': createdAtDevice,
      if (estado != null) 'estado': estado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperacionesPendientesCompanion copyWith({
    Value<String>? id,
    Value<String>? entidad,
    Value<String>? entidadId,
    Value<String>? operacion,
    Value<Map<String, Object?>>? payload,
    Value<int>? intentos,
    Value<String?>? ultimoError,
    Value<DateTime>? createdAtDevice,
    Value<String>? estado,
    Value<int>? rowid,
  }) {
    return OperacionesPendientesCompanion(
      id: id ?? this.id,
      entidad: entidad ?? this.entidad,
      entidadId: entidadId ?? this.entidadId,
      operacion: operacion ?? this.operacion,
      payload: payload ?? this.payload,
      intentos: intentos ?? this.intentos,
      ultimoError: ultimoError ?? this.ultimoError,
      createdAtDevice: createdAtDevice ?? this.createdAtDevice,
      estado: estado ?? this.estado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entidad.present) {
      map['entidad'] = Variable<String>(entidad.value);
    }
    if (entidadId.present) {
      map['entidad_id'] = Variable<String>(entidadId.value);
    }
    if (operacion.present) {
      map['operacion'] = Variable<String>(operacion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(
        $OperacionesPendientesTable.$converterpayload.toSql(payload.value),
      );
    }
    if (intentos.present) {
      map['intentos'] = Variable<int>(intentos.value);
    }
    if (ultimoError.present) {
      map['ultimo_error'] = Variable<String>(ultimoError.value);
    }
    if (createdAtDevice.present) {
      map['created_at_device'] = Variable<DateTime>(createdAtDevice.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperacionesPendientesCompanion(')
          ..write('id: $id, ')
          ..write('entidad: $entidad, ')
          ..write('entidadId: $entidadId, ')
          ..write('operacion: $operacion, ')
          ..write('payload: $payload, ')
          ..write('intentos: $intentos, ')
          ..write('ultimoError: $ultimoError, ')
          ..write('createdAtDevice: $createdAtDevice, ')
          ..write('estado: $estado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetadatosTable extends Metadatos
    with TableInfo<$MetadatosTable, Metadato> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetadatosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [clave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metadato';
  @override
  VerificationContext validateIntegrity(
    Insertable<Metadato> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clave};
  @override
  Metadato map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Metadato(
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $MetadatosTable createAlias(String alias) {
    return $MetadatosTable(attachedDatabase, alias);
  }
}

class Metadato extends DataClass implements Insertable<Metadato> {
  final String clave;
  final String valor;
  const Metadato({required this.clave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clave'] = Variable<String>(clave);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  MetadatosCompanion toCompanion(bool nullToAbsent) {
    return MetadatosCompanion(clave: Value(clave), valor: Value(valor));
  }

  factory Metadato.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Metadato(
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  Metadato copyWith({String? clave, String? valor}) =>
      Metadato(clave: clave ?? this.clave, valor: valor ?? this.valor);
  Metadato copyWithCompanion(MetadatosCompanion data) {
    return Metadato(
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Metadato(')
          ..write('clave: $clave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Metadato &&
          other.clave == this.clave &&
          other.valor == this.valor);
}

class MetadatosCompanion extends UpdateCompanion<Metadato> {
  final Value<String> clave;
  final Value<String> valor;
  final Value<int> rowid;
  const MetadatosCompanion({
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetadatosCompanion.insert({
    required String clave,
    required String valor,
    this.rowid = const Value.absent(),
  }) : clave = Value(clave),
       valor = Value(valor);
  static Insertable<Metadato> custom({
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetadatosCompanion copyWith({
    Value<String>? clave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return MetadatosCompanion(
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetadatosCompanion(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDatos extends GeneratedDatabase {
  _$BaseDatos(QueryExecutor e) : super(e);
  $BaseDatosManager get managers => $BaseDatosManager(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $UnidadesProductivasTable unidadesProductivas =
      $UnidadesProductivasTable(this);
  late final $TareasTable tareas = $TareasTable(this);
  late final $ItemsChecklistTable itemsChecklist = $ItemsChecklistTable(this);
  late final $EventosTable eventos = $EventosTable(this);
  late final $EvidenciasTable evidencias = $EvidenciasTable(this);
  late final $OperacionesPendientesTable operacionesPendientes =
      $OperacionesPendientesTable(this);
  late final $MetadatosTable metadatos = $MetadatosTable(this);
  late final Index idxTareaAsignadoFecha = Index(
    'idx_tarea_asignado_fecha',
    'CREATE INDEX idx_tarea_asignado_fecha ON tarea (asignado_id, fecha_programada)',
  );
  late final Index idxEventoTarea = Index(
    'idx_evento_tarea',
    'CREATE INDEX idx_evento_tarea ON evento (tarea_id)',
  );
  late final Index idxOperacionEstadoFecha = Index(
    'idx_operacion_estado_fecha',
    'CREATE INDEX idx_operacion_estado_fecha ON operacion_pendiente (estado, created_at_device)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    usuarios,
    unidadesProductivas,
    tareas,
    itemsChecklist,
    eventos,
    evidencias,
    operacionesPendientes,
    metadatos,
    idxTareaAsignadoFecha,
    idxEventoTarea,
    idxOperacionEstadoFecha,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$UsuariosTableCreateCompanionBuilder = UsuariosCompanion Function({
  required String id,
  Value<String?> authId,
  required String nombre,
  required String telefono,
  required String rol,
  Value<String?> especialidad,
  Value<bool> activo,
  required DateTime createdAtDevice,
  Value<DateTime?> receivedAtServer,
  Value<int> rowid,
});
typedef $$UsuariosTableUpdateCompanionBuilder = UsuariosCompanion Function({
  Value<String> id,
  Value<String?> authId,
  Value<String> nombre,
  Value<String> telefono,
  Value<String> rol,
  Value<String?> especialidad,
  Value<bool> activo,
  Value<DateTime> createdAtDevice,
  Value<DateTime?> receivedAtServer,
  Value<int> rowid,
});

final class $$UsuariosTableReferences
    extends BaseReferences<_$BaseDatos, $UsuariosTable, Usuario> {
  $$UsuariosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TareasTable, List<Tarea>> _tareasCreadasTable(
    _$BaseDatos db,
  ) => MultiTypedResultKey.fromTable(
    db.tareas,
    aliasName: 'usuario__id__tarea__creador_id',
  );

  $$TareasTableProcessedTableManager get tareasCreadas {
    final manager = $$TareasTableTableManager(
      $_db,
      $_db.tareas,
    ).filter((f) => f.creadorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tareasCreadasTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TareasTable, List<Tarea>> _tareasAsignadasTable(
    _$BaseDatos db,
  ) => MultiTypedResultKey.fromTable(
    db.tareas,
    aliasName: 'usuario__id__tarea__asignado_id',
  );

  $$TareasTableProcessedTableManager get tareasAsignadas {
    final manager = $$TareasTableTableManager(
      $_db,
      $_db.tareas,
    ).filter((f) => f.asignadoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tareasAsignadasTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventosTable, List<Evento>> _eventosRefsTable(
    _$BaseDatos db,
  ) => MultiTypedResultKey.fromTable(
    db.eventos,
    aliasName: 'usuario__id__evento__usuario_id',
  );

  $$EventosTableProcessedTableManager get eventosRefs {
    final manager = $$EventosTableTableManager(
      $_db,
      $_db.eventos,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EvidenciasTable, List<Evidencia>>
  _evidenciasRefsTable(_$BaseDatos db) => MultiTypedResultKey.fromTable(
    db.evidencias,
    aliasName: 'usuario__id__evidencia__usuario_id',
  );

  $$EvidenciasTableProcessedTableManager get evidenciasRefs {
    final manager = $$EvidenciasTableTableManager(
      $_db,
      $_db.evidencias,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_evidenciasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsuariosTableFilterComposer
    extends Composer<_$BaseDatos, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authId => $composableBuilder(
    column: $table.authId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get especialidad => $composableBuilder(
    column: $table.especialidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tareasCreadas(
    Expression<bool> Function($$TareasTableFilterComposer f) f,
  ) {
    final $$TareasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.creadorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableFilterComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tareasAsignadas(
    Expression<bool> Function($$TareasTableFilterComposer f) f,
  ) {
    final $$TareasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.asignadoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableFilterComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventosRefs(
    Expression<bool> Function($$EventosTableFilterComposer f) f,
  ) {
    final $$EventosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableFilterComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidenciasRefs(
    Expression<bool> Function($$EvidenciasTableFilterComposer f) f,
  ) {
    final $$EvidenciasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidencias,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenciasTableFilterComposer(
            $db: $db,
            $table: $db.evidencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$BaseDatos, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authId => $composableBuilder(
    column: $table.authId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get especialidad => $composableBuilder(
    column: $table.especialidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$BaseDatos, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authId =>
      $composableBuilder(column: $table.authId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<String> get especialidad => $composableBuilder(
    column: $table.especialidad,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => column,
  );

  Expression<T> tareasCreadas<T extends Object>(
    Expression<T> Function($$TareasTableAnnotationComposer a) f,
  ) {
    final $$TareasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.creadorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableAnnotationComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tareasAsignadas<T extends Object>(
    Expression<T> Function($$TareasTableAnnotationComposer a) f,
  ) {
    final $$TareasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.asignadoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableAnnotationComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventosRefs<T extends Object>(
    Expression<T> Function($$EventosTableAnnotationComposer a) f,
  ) {
    final $$EventosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableAnnotationComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidenciasRefs<T extends Object>(
    Expression<T> Function($$EvidenciasTableAnnotationComposer a) f,
  ) {
    final $$EvidenciasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidencias,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenciasTableAnnotationComposer(
            $db: $db,
            $table: $db.evidencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsuariosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $UsuariosTable,
          Usuario,
          $$UsuariosTableFilterComposer,
          $$UsuariosTableOrderingComposer,
          $$UsuariosTableAnnotationComposer,
          $$UsuariosTableCreateCompanionBuilder,
          $$UsuariosTableUpdateCompanionBuilder,
          (Usuario, $$UsuariosTableReferences),
          Usuario,
          PrefetchHooks Function({
            bool tareasCreadas,
            bool tareasAsignadas,
            bool eventosRefs,
            bool evidenciasRefs,
          })
        > {
  $$UsuariosTableTableManager(_$BaseDatos db, $UsuariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> authId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> telefono = const Value.absent(),
                Value<String> rol = const Value.absent(),
                Value<String?> especialidad = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> createdAtDevice = const Value.absent(),
                Value<DateTime?> receivedAtServer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsuariosCompanion(
                id: id,
                authId: authId,
                nombre: nombre,
                telefono: telefono,
                rol: rol,
                especialidad: especialidad,
                activo: activo,
                createdAtDevice: createdAtDevice,
                receivedAtServer: receivedAtServer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> authId = const Value.absent(),
                required String nombre,
                required String telefono,
                required String rol,
                Value<String?> especialidad = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                required DateTime createdAtDevice,
                Value<DateTime?> receivedAtServer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsuariosCompanion.insert(
                id: id,
                authId: authId,
                nombre: nombre,
                telefono: telefono,
                rol: rol,
                especialidad: especialidad,
                activo: activo,
                createdAtDevice: createdAtDevice,
                receivedAtServer: receivedAtServer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsuariosTable, Usuario>(table),
                  $$UsuariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tareasCreadas = false,
                tareasAsignadas = false,
                eventosRefs = false,
                evidenciasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tareasCreadas) db.tareas,
                    if (tareasAsignadas) db.tareas,
                    if (eventosRefs) db.eventos,
                    if (evidenciasRefs) db.evidencias,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tareasCreadas)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          Tarea,
                          $TareasTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._tareasCreadasTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).tareasCreadas,
                          currentColumn: 'id',
                          referencedColumn: 'creador_id',
                          typedResults: items,
                        ),
                      if (tareasAsignadas)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          Tarea,
                          $TareasTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._tareasAsignadasTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).tareasAsignadas,
                          currentColumn: 'id',
                          referencedColumn: 'asignado_id',
                          typedResults: items,
                        ),
                      if (eventosRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          Evento,
                          $EventosTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._eventosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).eventosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'usuario_id',
                          typedResults: items,
                        ),
                      if (evidenciasRefs)
                        await $_getPrefetchedDataByColumns<
                          Usuario,
                          $UsuariosTable,
                          Evidencia,
                          $EvidenciasTable
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._evidenciasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenciasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'usuario_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsuariosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $UsuariosTable,
      Usuario,
      $$UsuariosTableFilterComposer,
      $$UsuariosTableOrderingComposer,
      $$UsuariosTableAnnotationComposer,
      $$UsuariosTableCreateCompanionBuilder,
      $$UsuariosTableUpdateCompanionBuilder,
      (Usuario, $$UsuariosTableReferences),
      Usuario,
      PrefetchHooks Function({
        bool tareasCreadas,
        bool tareasAsignadas,
        bool eventosRefs,
        bool evidenciasRefs,
      })
    >;
typedef $$UnidadesProductivasTableCreateCompanionBuilder =
    UnidadesProductivasCompanion Function({
      required String id,
      required String nombre,
      required String tipo,
      Value<double?> superficieHa,
      required String codigoQr,
      Value<double?> latitud,
      Value<double?> longitud,
      Value<bool> activa,
      Value<int> rowid,
    });
typedef $$UnidadesProductivasTableUpdateCompanionBuilder =
    UnidadesProductivasCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<String> tipo,
      Value<double?> superficieHa,
      Value<String> codigoQr,
      Value<double?> latitud,
      Value<double?> longitud,
      Value<bool> activa,
      Value<int> rowid,
    });

final class $$UnidadesProductivasTableReferences
    extends
        BaseReferences<
          _$BaseDatos,
          $UnidadesProductivasTable,
          UnidadProductiva
        > {
  $$UnidadesProductivasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TareasTable, List<Tarea>> _tareasRefsTable(
    _$BaseDatos db,
  ) => MultiTypedResultKey.fromTable(
    db.tareas,
    aliasName: 'unidad_productiva__id__tarea__unidad_productiva_id',
  );

  $$TareasTableProcessedTableManager get tareasRefs {
    final manager = $$TareasTableTableManager($_db, $_db.tareas).filter(
      (f) => f.unidadProductivaId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_tareasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnidadesProductivasTableFilterComposer
    extends Composer<_$BaseDatos, $UnidadesProductivasTable> {
  $$UnidadesProductivasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get superficieHa => $composableBuilder(
    column: $table.superficieHa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoQr => $composableBuilder(
    column: $table.codigoQr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activa => $composableBuilder(
    column: $table.activa,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tareasRefs(
    Expression<bool> Function($$TareasTableFilterComposer f) f,
  ) {
    final $$TareasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.unidadProductivaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableFilterComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnidadesProductivasTableOrderingComposer
    extends Composer<_$BaseDatos, $UnidadesProductivasTable> {
  $$UnidadesProductivasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get superficieHa => $composableBuilder(
    column: $table.superficieHa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoQr => $composableBuilder(
    column: $table.codigoQr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activa => $composableBuilder(
    column: $table.activa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnidadesProductivasTableAnnotationComposer
    extends Composer<_$BaseDatos, $UnidadesProductivasTable> {
  $$UnidadesProductivasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get superficieHa => $composableBuilder(
    column: $table.superficieHa,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigoQr =>
      $composableBuilder(column: $table.codigoQr, builder: (column) => column);

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  GeneratedColumn<bool> get activa =>
      $composableBuilder(column: $table.activa, builder: (column) => column);

  Expression<T> tareasRefs<T extends Object>(
    Expression<T> Function($$TareasTableAnnotationComposer a) f,
  ) {
    final $$TareasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.unidadProductivaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableAnnotationComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnidadesProductivasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $UnidadesProductivasTable,
          UnidadProductiva,
          $$UnidadesProductivasTableFilterComposer,
          $$UnidadesProductivasTableOrderingComposer,
          $$UnidadesProductivasTableAnnotationComposer,
          $$UnidadesProductivasTableCreateCompanionBuilder,
          $$UnidadesProductivasTableUpdateCompanionBuilder,
          (UnidadProductiva, $$UnidadesProductivasTableReferences),
          UnidadProductiva,
          PrefetchHooks Function({bool tareasRefs})
        > {
  $$UnidadesProductivasTableTableManager(
    _$BaseDatos db,
    $UnidadesProductivasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnidadesProductivasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnidadesProductivasTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UnidadesProductivasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<double?> superficieHa = const Value.absent(),
                Value<String> codigoQr = const Value.absent(),
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                Value<bool> activa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnidadesProductivasCompanion(
                id: id,
                nombre: nombre,
                tipo: tipo,
                superficieHa: superficieHa,
                codigoQr: codigoQr,
                latitud: latitud,
                longitud: longitud,
                activa: activa,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                required String tipo,
                Value<double?> superficieHa = const Value.absent(),
                required String codigoQr,
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                Value<bool> activa = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnidadesProductivasCompanion.insert(
                id: id,
                nombre: nombre,
                tipo: tipo,
                superficieHa: superficieHa,
                codigoQr: codigoQr,
                latitud: latitud,
                longitud: longitud,
                activa: activa,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UnidadesProductivasTable, UnidadProductiva>(
                    table,
                  ),
                  $$UnidadesProductivasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tareasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tareasRefs) db.tareas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tareasRefs)
                    await $_getPrefetchedDataByColumns<
                      UnidadProductiva,
                      $UnidadesProductivasTable,
                      Tarea,
                      $TareasTable
                    >(
                      currentTable: table,
                      referencedTable: $$UnidadesProductivasTableReferences
                          ._tareasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UnidadesProductivasTableReferences(
                            db,
                            table,
                            p0,
                          ).tareasRefs,
                      currentColumn: 'id',
                      referencedColumn: 'unidad_productiva_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UnidadesProductivasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $UnidadesProductivasTable,
      UnidadProductiva,
      $$UnidadesProductivasTableFilterComposer,
      $$UnidadesProductivasTableOrderingComposer,
      $$UnidadesProductivasTableAnnotationComposer,
      $$UnidadesProductivasTableCreateCompanionBuilder,
      $$UnidadesProductivasTableUpdateCompanionBuilder,
      (UnidadProductiva, $$UnidadesProductivasTableReferences),
      UnidadProductiva,
      PrefetchHooks Function({bool tareasRefs})
    >;
typedef $$TareasTableCreateCompanionBuilder = TareasCompanion Function({
  required String id,
  required String unidadProductivaId,
  required String creadorId,
  required String asignadoId,
  required String tipoLabor,
  Value<String?> descripcion,
  required String fechaProgramada,
  Value<bool> requiereQr,
  Value<String> evidenciaRequerida,
  Value<String> estadoActual,
  required DateTime createdAtDevice,
  Value<DateTime?> receivedAtServer,
  Value<int> rowid,
});
typedef $$TareasTableUpdateCompanionBuilder = TareasCompanion Function({
  Value<String> id,
  Value<String> unidadProductivaId,
  Value<String> creadorId,
  Value<String> asignadoId,
  Value<String> tipoLabor,
  Value<String?> descripcion,
  Value<String> fechaProgramada,
  Value<bool> requiereQr,
  Value<String> evidenciaRequerida,
  Value<String> estadoActual,
  Value<DateTime> createdAtDevice,
  Value<DateTime?> receivedAtServer,
  Value<int> rowid,
});

final class $$TareasTableReferences
    extends BaseReferences<_$BaseDatos, $TareasTable, Tarea> {
  $$TareasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UnidadesProductivasTable _unidadProductivaIdTable(_$BaseDatos db) =>
      db.unidadesProductivas.createAlias(
        'tarea__unidad_productiva_id__unidad_productiva__id',
      );

  $$UnidadesProductivasTableProcessedTableManager get unidadProductivaId {
    final $_column = $_itemColumn<String>('unidad_productiva_id')!;

    final manager = $$UnidadesProductivasTableTableManager(
      $_db,
      $_db.unidadesProductivas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unidadProductivaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _creadorIdTable(_$BaseDatos db) =>
      db.usuarios.createAlias('tarea__creador_id__usuario__id');

  $$UsuariosTableProcessedTableManager get creadorId {
    final $_column = $_itemColumn<String>('creador_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_creadorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _asignadoIdTable(_$BaseDatos db) =>
      db.usuarios.createAlias('tarea__asignado_id__usuario__id');

  $$UsuariosTableProcessedTableManager get asignadoId {
    final $_column = $_itemColumn<String>('asignado_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_asignadoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ItemsChecklistTable, List<ItemChecklist>>
  _itemsChecklistRefsTable(_$BaseDatos db) => MultiTypedResultKey.fromTable(
    db.itemsChecklist,
    aliasName: 'tarea__id__item_checklist__tarea_id',
  );

  $$ItemsChecklistTableProcessedTableManager get itemsChecklistRefs {
    final manager = $$ItemsChecklistTableTableManager(
      $_db,
      $_db.itemsChecklist,
    ).filter((f) => f.tareaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsChecklistRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventosTable, List<Evento>> _eventosRefsTable(
    _$BaseDatos db,
  ) => MultiTypedResultKey.fromTable(
    db.eventos,
    aliasName: 'tarea__id__evento__tarea_id',
  );

  $$EventosTableProcessedTableManager get eventosRefs {
    final manager = $$EventosTableTableManager(
      $_db,
      $_db.eventos,
    ).filter((f) => f.tareaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EvidenciasTable, List<Evidencia>>
  _evidenciasRefsTable(_$BaseDatos db) => MultiTypedResultKey.fromTable(
    db.evidencias,
    aliasName: 'tarea__id__evidencia__tarea_id',
  );

  $$EvidenciasTableProcessedTableManager get evidenciasRefs {
    final manager = $$EvidenciasTableTableManager(
      $_db,
      $_db.evidencias,
    ).filter((f) => f.tareaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_evidenciasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TareasTableFilterComposer extends Composer<_$BaseDatos, $TareasTable> {
  $$TareasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoLabor => $composableBuilder(
    column: $table.tipoLabor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaProgramada => $composableBuilder(
    column: $table.fechaProgramada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiereQr => $composableBuilder(
    column: $table.requiereQr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenciaRequerida => $composableBuilder(
    column: $table.evidenciaRequerida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoActual => $composableBuilder(
    column: $table.estadoActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  $$UnidadesProductivasTableFilterComposer get unidadProductivaId {
    final $$UnidadesProductivasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unidadProductivaId,
      referencedTable: $db.unidadesProductivas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnidadesProductivasTableFilterComposer(
            $db: $db,
            $table: $db.unidadesProductivas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get creadorId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creadorId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get asignadoId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.asignadoId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> itemsChecklistRefs(
    Expression<bool> Function($$ItemsChecklistTableFilterComposer f) f,
  ) {
    final $$ItemsChecklistTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemsChecklist,
      getReferencedColumn: (t) => t.tareaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsChecklistTableFilterComposer(
            $db: $db,
            $table: $db.itemsChecklist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventosRefs(
    Expression<bool> Function($$EventosTableFilterComposer f) f,
  ) {
    final $$EventosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.tareaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableFilterComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidenciasRefs(
    Expression<bool> Function($$EvidenciasTableFilterComposer f) f,
  ) {
    final $$EvidenciasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidencias,
      getReferencedColumn: (t) => t.tareaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenciasTableFilterComposer(
            $db: $db,
            $table: $db.evidencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TareasTableOrderingComposer
    extends Composer<_$BaseDatos, $TareasTable> {
  $$TareasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoLabor => $composableBuilder(
    column: $table.tipoLabor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaProgramada => $composableBuilder(
    column: $table.fechaProgramada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiereQr => $composableBuilder(
    column: $table.requiereQr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenciaRequerida => $composableBuilder(
    column: $table.evidenciaRequerida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoActual => $composableBuilder(
    column: $table.estadoActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  $$UnidadesProductivasTableOrderingComposer get unidadProductivaId {
    final $$UnidadesProductivasTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.unidadProductivaId,
          referencedTable: $db.unidadesProductivas,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UnidadesProductivasTableOrderingComposer(
                $db: $db,
                $table: $db.unidadesProductivas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$UsuariosTableOrderingComposer get creadorId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creadorId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get asignadoId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.asignadoId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TareasTableAnnotationComposer
    extends Composer<_$BaseDatos, $TareasTable> {
  $$TareasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipoLabor =>
      $composableBuilder(column: $table.tipoLabor, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fechaProgramada => $composableBuilder(
    column: $table.fechaProgramada,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requiereQr => $composableBuilder(
    column: $table.requiereQr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenciaRequerida => $composableBuilder(
    column: $table.evidenciaRequerida,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoActual => $composableBuilder(
    column: $table.estadoActual,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => column,
  );

  $$UnidadesProductivasTableAnnotationComposer get unidadProductivaId {
    final $$UnidadesProductivasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.unidadProductivaId,
          referencedTable: $db.unidadesProductivas,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UnidadesProductivasTableAnnotationComposer(
                $db: $db,
                $table: $db.unidadesProductivas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get creadorId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.creadorId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get asignadoId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.asignadoId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> itemsChecklistRefs<T extends Object>(
    Expression<T> Function($$ItemsChecklistTableAnnotationComposer a) f,
  ) {
    final $$ItemsChecklistTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemsChecklist,
      getReferencedColumn: (t) => t.tareaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsChecklistTableAnnotationComposer(
            $db: $db,
            $table: $db.itemsChecklist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventosRefs<T extends Object>(
    Expression<T> Function($$EventosTableAnnotationComposer a) f,
  ) {
    final $$EventosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.tareaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableAnnotationComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidenciasRefs<T extends Object>(
    Expression<T> Function($$EvidenciasTableAnnotationComposer a) f,
  ) {
    final $$EvidenciasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidencias,
      getReferencedColumn: (t) => t.tareaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenciasTableAnnotationComposer(
            $db: $db,
            $table: $db.evidencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TareasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $TareasTable,
          Tarea,
          $$TareasTableFilterComposer,
          $$TareasTableOrderingComposer,
          $$TareasTableAnnotationComposer,
          $$TareasTableCreateCompanionBuilder,
          $$TareasTableUpdateCompanionBuilder,
          (Tarea, $$TareasTableReferences),
          Tarea,
          PrefetchHooks Function({
            bool unidadProductivaId,
            bool creadorId,
            bool asignadoId,
            bool itemsChecklistRefs,
            bool eventosRefs,
            bool evidenciasRefs,
          })
        > {
  $$TareasTableTableManager(_$BaseDatos db, $TareasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TareasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TareasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TareasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> unidadProductivaId = const Value.absent(),
                Value<String> creadorId = const Value.absent(),
                Value<String> asignadoId = const Value.absent(),
                Value<String> tipoLabor = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String> fechaProgramada = const Value.absent(),
                Value<bool> requiereQr = const Value.absent(),
                Value<String> evidenciaRequerida = const Value.absent(),
                Value<String> estadoActual = const Value.absent(),
                Value<DateTime> createdAtDevice = const Value.absent(),
                Value<DateTime?> receivedAtServer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TareasCompanion(
                id: id,
                unidadProductivaId: unidadProductivaId,
                creadorId: creadorId,
                asignadoId: asignadoId,
                tipoLabor: tipoLabor,
                descripcion: descripcion,
                fechaProgramada: fechaProgramada,
                requiereQr: requiereQr,
                evidenciaRequerida: evidenciaRequerida,
                estadoActual: estadoActual,
                createdAtDevice: createdAtDevice,
                receivedAtServer: receivedAtServer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String unidadProductivaId,
                required String creadorId,
                required String asignadoId,
                required String tipoLabor,
                Value<String?> descripcion = const Value.absent(),
                required String fechaProgramada,
                Value<bool> requiereQr = const Value.absent(),
                Value<String> evidenciaRequerida = const Value.absent(),
                Value<String> estadoActual = const Value.absent(),
                required DateTime createdAtDevice,
                Value<DateTime?> receivedAtServer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TareasCompanion.insert(
                id: id,
                unidadProductivaId: unidadProductivaId,
                creadorId: creadorId,
                asignadoId: asignadoId,
                tipoLabor: tipoLabor,
                descripcion: descripcion,
                fechaProgramada: fechaProgramada,
                requiereQr: requiereQr,
                evidenciaRequerida: evidenciaRequerida,
                estadoActual: estadoActual,
                createdAtDevice: createdAtDevice,
                receivedAtServer: receivedAtServer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TareasTable, Tarea>(table),
                  $$TareasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                unidadProductivaId = false,
                creadorId = false,
                asignadoId = false,
                itemsChecklistRefs = false,
                eventosRefs = false,
                evidenciasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (itemsChecklistRefs) db.itemsChecklist,
                    if (eventosRefs) db.eventos,
                    if (evidenciasRefs) db.evidencias,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (unidadProductivaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.unidadProductivaId,
                            referencedTable: $$TareasTableReferences
                                ._unidadProductivaIdTable(db),
                            referencedColumn: $$TareasTableReferences
                                ._unidadProductivaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (creadorId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.creadorId,
                            referencedTable: $$TareasTableReferences
                                ._creadorIdTable(db),
                            referencedColumn: $$TareasTableReferences
                                ._creadorIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (asignadoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.asignadoId,
                            referencedTable: $$TareasTableReferences
                                ._asignadoIdTable(db),
                            referencedColumn: $$TareasTableReferences
                                ._asignadoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (itemsChecklistRefs)
                        await $_getPrefetchedDataByColumns<
                          Tarea,
                          $TareasTable,
                          ItemChecklist,
                          $ItemsChecklistTable
                        >(
                          currentTable: table,
                          referencedTable: $$TareasTableReferences
                              ._itemsChecklistRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TareasTableReferences(
                                db,
                                table,
                                p0,
                              ).itemsChecklistRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tarea_id',
                          typedResults: items,
                        ),
                      if (eventosRefs)
                        await $_getPrefetchedDataByColumns<
                          Tarea,
                          $TareasTable,
                          Evento,
                          $EventosTable
                        >(
                          currentTable: table,
                          referencedTable: $$TareasTableReferences
                              ._eventosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TareasTableReferences(
                                db,
                                table,
                                p0,
                              ).eventosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tarea_id',
                          typedResults: items,
                        ),
                      if (evidenciasRefs)
                        await $_getPrefetchedDataByColumns<
                          Tarea,
                          $TareasTable,
                          Evidencia,
                          $EvidenciasTable
                        >(
                          currentTable: table,
                          referencedTable: $$TareasTableReferences
                              ._evidenciasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TareasTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenciasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'tarea_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TareasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $TareasTable,
      Tarea,
      $$TareasTableFilterComposer,
      $$TareasTableOrderingComposer,
      $$TareasTableAnnotationComposer,
      $$TareasTableCreateCompanionBuilder,
      $$TareasTableUpdateCompanionBuilder,
      (Tarea, $$TareasTableReferences),
      Tarea,
      PrefetchHooks Function({
        bool unidadProductivaId,
        bool creadorId,
        bool asignadoId,
        bool itemsChecklistRefs,
        bool eventosRefs,
        bool evidenciasRefs,
      })
    >;
typedef $$ItemsChecklistTableCreateCompanionBuilder =
    ItemsChecklistCompanion Function({
      required String id,
      required String tareaId,
      required int orden,
      required String descripcion,
      required String tipoRespuesta,
      Value<bool> obligatorio,
      Value<String?> valor,
      Value<bool> completado,
      Value<int> rowid,
    });
typedef $$ItemsChecklistTableUpdateCompanionBuilder =
    ItemsChecklistCompanion Function({
      Value<String> id,
      Value<String> tareaId,
      Value<int> orden,
      Value<String> descripcion,
      Value<String> tipoRespuesta,
      Value<bool> obligatorio,
      Value<String?> valor,
      Value<bool> completado,
      Value<int> rowid,
    });

final class $$ItemsChecklistTableReferences
    extends BaseReferences<_$BaseDatos, $ItemsChecklistTable, ItemChecklist> {
  $$ItemsChecklistTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TareasTable _tareaIdTable(_$BaseDatos db) =>
      db.tareas.createAlias('item_checklist__tarea_id__tarea__id');

  $$TareasTableProcessedTableManager get tareaId {
    final $_column = $_itemColumn<String>('tarea_id')!;

    final manager = $$TareasTableTableManager(
      $_db,
      $_db.tareas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tareaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemsChecklistTableFilterComposer
    extends Composer<_$BaseDatos, $ItemsChecklistTable> {
  $$ItemsChecklistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoRespuesta => $composableBuilder(
    column: $table.tipoRespuesta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get obligatorio => $composableBuilder(
    column: $table.obligatorio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => ColumnFilters(column),
  );

  $$TareasTableFilterComposer get tareaId {
    final $$TareasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableFilterComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsChecklistTableOrderingComposer
    extends Composer<_$BaseDatos, $ItemsChecklistTable> {
  $$ItemsChecklistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoRespuesta => $composableBuilder(
    column: $table.tipoRespuesta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get obligatorio => $composableBuilder(
    column: $table.obligatorio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => ColumnOrderings(column),
  );

  $$TareasTableOrderingComposer get tareaId {
    final $$TareasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableOrderingComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsChecklistTableAnnotationComposer
    extends Composer<_$BaseDatos, $ItemsChecklistTable> {
  $$ItemsChecklistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoRespuesta => $composableBuilder(
    column: $table.tipoRespuesta,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get obligatorio => $composableBuilder(
    column: $table.obligatorio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => column,
  );

  $$TareasTableAnnotationComposer get tareaId {
    final $$TareasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableAnnotationComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsChecklistTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $ItemsChecklistTable,
          ItemChecklist,
          $$ItemsChecklistTableFilterComposer,
          $$ItemsChecklistTableOrderingComposer,
          $$ItemsChecklistTableAnnotationComposer,
          $$ItemsChecklistTableCreateCompanionBuilder,
          $$ItemsChecklistTableUpdateCompanionBuilder,
          (ItemChecklist, $$ItemsChecklistTableReferences),
          ItemChecklist,
          PrefetchHooks Function({bool tareaId})
        > {
  $$ItemsChecklistTableTableManager(_$BaseDatos db, $ItemsChecklistTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsChecklistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsChecklistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsChecklistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tareaId = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<String> tipoRespuesta = const Value.absent(),
                Value<bool> obligatorio = const Value.absent(),
                Value<String?> valor = const Value.absent(),
                Value<bool> completado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsChecklistCompanion(
                id: id,
                tareaId: tareaId,
                orden: orden,
                descripcion: descripcion,
                tipoRespuesta: tipoRespuesta,
                obligatorio: obligatorio,
                valor: valor,
                completado: completado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tareaId,
                required int orden,
                required String descripcion,
                required String tipoRespuesta,
                Value<bool> obligatorio = const Value.absent(),
                Value<String?> valor = const Value.absent(),
                Value<bool> completado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsChecklistCompanion.insert(
                id: id,
                tareaId: tareaId,
                orden: orden,
                descripcion: descripcion,
                tipoRespuesta: tipoRespuesta,
                obligatorio: obligatorio,
                valor: valor,
                completado: completado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsChecklistTable, ItemChecklist>(table),
                  $$ItemsChecklistTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tareaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tareaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tareaId,
                        referencedTable: $$ItemsChecklistTableReferences
                            ._tareaIdTable(db),
                        referencedColumn: $$ItemsChecklistTableReferences
                            ._tareaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItemsChecklistTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $ItemsChecklistTable,
      ItemChecklist,
      $$ItemsChecklistTableFilterComposer,
      $$ItemsChecklistTableOrderingComposer,
      $$ItemsChecklistTableAnnotationComposer,
      $$ItemsChecklistTableCreateCompanionBuilder,
      $$ItemsChecklistTableUpdateCompanionBuilder,
      (ItemChecklist, $$ItemsChecklistTableReferences),
      ItemChecklist,
      PrefetchHooks Function({bool tareaId})
    >;
typedef $$EventosTableCreateCompanionBuilder = EventosCompanion Function({
  required String id,
  required String tareaId,
  required String usuarioId,
  required String tipo,
  Value<Map<String, Object?>> payload,
  required DateTime createdAtDevice,
  Value<DateTime?> receivedAtServer,
  Value<double?> latitud,
  Value<double?> longitud,
  Value<int> rowid,
});
typedef $$EventosTableUpdateCompanionBuilder = EventosCompanion Function({
  Value<String> id,
  Value<String> tareaId,
  Value<String> usuarioId,
  Value<String> tipo,
  Value<Map<String, Object?>> payload,
  Value<DateTime> createdAtDevice,
  Value<DateTime?> receivedAtServer,
  Value<double?> latitud,
  Value<double?> longitud,
  Value<int> rowid,
});

final class $$EventosTableReferences
    extends BaseReferences<_$BaseDatos, $EventosTable, Evento> {
  $$EventosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TareasTable _tareaIdTable(_$BaseDatos db) =>
      db.tareas.createAlias('evento__tarea_id__tarea__id');

  $$TareasTableProcessedTableManager get tareaId {
    final $_column = $_itemColumn<String>('tarea_id')!;

    final manager = $$TareasTableTableManager(
      $_db,
      $_db.tareas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tareaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$BaseDatos db) =>
      db.usuarios.createAlias('evento__usuario_id__usuario__id');

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventosTableFilterComposer
    extends Composer<_$BaseDatos, $EventosTable> {
  $$EventosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, Object?>,
    Map<String, Object>,
    String
  >
  get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnFilters(column),
  );

  $$TareasTableFilterComposer get tareaId {
    final $$TareasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableFilterComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableOrderingComposer
    extends Composer<_$BaseDatos, $EventosTable> {
  $$EventosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnOrderings(column),
  );

  $$TareasTableOrderingComposer get tareaId {
    final $$TareasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableOrderingComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableAnnotationComposer
    extends Composer<_$BaseDatos, $EventosTable> {
  $$EventosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, Object?>, String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  $$TareasTableAnnotationComposer get tareaId {
    final $$TareasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableAnnotationComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $EventosTable,
          Evento,
          $$EventosTableFilterComposer,
          $$EventosTableOrderingComposer,
          $$EventosTableAnnotationComposer,
          $$EventosTableCreateCompanionBuilder,
          $$EventosTableUpdateCompanionBuilder,
          (Evento, $$EventosTableReferences),
          Evento,
          PrefetchHooks Function({bool tareaId, bool usuarioId})
        > {
  $$EventosTableTableManager(_$BaseDatos db, $EventosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tareaId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<Map<String, Object?>> payload = const Value.absent(),
                Value<DateTime> createdAtDevice = const Value.absent(),
                Value<DateTime?> receivedAtServer = const Value.absent(),
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventosCompanion(
                id: id,
                tareaId: tareaId,
                usuarioId: usuarioId,
                tipo: tipo,
                payload: payload,
                createdAtDevice: createdAtDevice,
                receivedAtServer: receivedAtServer,
                latitud: latitud,
                longitud: longitud,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tareaId,
                required String usuarioId,
                required String tipo,
                Value<Map<String, Object?>> payload = const Value.absent(),
                required DateTime createdAtDevice,
                Value<DateTime?> receivedAtServer = const Value.absent(),
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventosCompanion.insert(
                id: id,
                tareaId: tareaId,
                usuarioId: usuarioId,
                tipo: tipo,
                payload: payload,
                createdAtDevice: createdAtDevice,
                receivedAtServer: receivedAtServer,
                latitud: latitud,
                longitud: longitud,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventosTable, Evento>(table),
                  $$EventosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tareaId = false, usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tareaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tareaId,
                        referencedTable: $$EventosTableReferences._tareaIdTable(
                          db,
                        ),
                        referencedColumn: $$EventosTableReferences
                            ._tareaIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (usuarioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.usuarioId,
                        referencedTable: $$EventosTableReferences
                            ._usuarioIdTable(db),
                        referencedColumn: $$EventosTableReferences
                            ._usuarioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EventosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $EventosTable,
      Evento,
      $$EventosTableFilterComposer,
      $$EventosTableOrderingComposer,
      $$EventosTableAnnotationComposer,
      $$EventosTableCreateCompanionBuilder,
      $$EventosTableUpdateCompanionBuilder,
      (Evento, $$EventosTableReferences),
      Evento,
      PrefetchHooks Function({bool tareaId, bool usuarioId})
    >;
typedef $$EvidenciasTableCreateCompanionBuilder = EvidenciasCompanion Function({
  required String id,
  required String tareaId,
  required String usuarioId,
  required String tipo,
  Value<String?> rutaLocal,
  Value<String?> rutaRemota,
  Value<int?> tamanioBytes,
  required String hashSha256,
  required DateTime createdAtDevice,
  Value<DateTime?> receivedAtServer,
  Value<int> rowid,
});
typedef $$EvidenciasTableUpdateCompanionBuilder = EvidenciasCompanion Function({
  Value<String> id,
  Value<String> tareaId,
  Value<String> usuarioId,
  Value<String> tipo,
  Value<String?> rutaLocal,
  Value<String?> rutaRemota,
  Value<int?> tamanioBytes,
  Value<String> hashSha256,
  Value<DateTime> createdAtDevice,
  Value<DateTime?> receivedAtServer,
  Value<int> rowid,
});

final class $$EvidenciasTableReferences
    extends BaseReferences<_$BaseDatos, $EvidenciasTable, Evidencia> {
  $$EvidenciasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TareasTable _tareaIdTable(_$BaseDatos db) =>
      db.tareas.createAlias('evidencia__tarea_id__tarea__id');

  $$TareasTableProcessedTableManager get tareaId {
    final $_column = $_itemColumn<String>('tarea_id')!;

    final manager = $$TareasTableTableManager(
      $_db,
      $_db.tareas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tareaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$BaseDatos db) =>
      db.usuarios.createAlias('evidencia__usuario_id__usuario__id');

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EvidenciasTableFilterComposer
    extends Composer<_$BaseDatos, $EvidenciasTable> {
  $$EvidenciasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rutaLocal => $composableBuilder(
    column: $table.rutaLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rutaRemota => $composableBuilder(
    column: $table.rutaRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tamanioBytes => $composableBuilder(
    column: $table.tamanioBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => ColumnFilters(column),
  );

  $$TareasTableFilterComposer get tareaId {
    final $$TareasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableFilterComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenciasTableOrderingComposer
    extends Composer<_$BaseDatos, $EvidenciasTable> {
  $$EvidenciasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rutaLocal => $composableBuilder(
    column: $table.rutaLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rutaRemota => $composableBuilder(
    column: $table.rutaRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tamanioBytes => $composableBuilder(
    column: $table.tamanioBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => ColumnOrderings(column),
  );

  $$TareasTableOrderingComposer get tareaId {
    final $$TareasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableOrderingComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenciasTableAnnotationComposer
    extends Composer<_$BaseDatos, $EvidenciasTable> {
  $$EvidenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get rutaLocal =>
      $composableBuilder(column: $table.rutaLocal, builder: (column) => column);

  GeneratedColumn<String> get rutaRemota => $composableBuilder(
    column: $table.rutaRemota,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tamanioBytes => $composableBuilder(
    column: $table.tamanioBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hashSha256 => $composableBuilder(
    column: $table.hashSha256,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAtServer => $composableBuilder(
    column: $table.receivedAtServer,
    builder: (column) => column,
  );

  $$TareasTableAnnotationComposer get tareaId {
    final $$TareasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tareaId,
      referencedTable: $db.tareas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TareasTableAnnotationComposer(
            $db: $db,
            $table: $db.tareas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenciasTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $EvidenciasTable,
          Evidencia,
          $$EvidenciasTableFilterComposer,
          $$EvidenciasTableOrderingComposer,
          $$EvidenciasTableAnnotationComposer,
          $$EvidenciasTableCreateCompanionBuilder,
          $$EvidenciasTableUpdateCompanionBuilder,
          (Evidencia, $$EvidenciasTableReferences),
          Evidencia,
          PrefetchHooks Function({bool tareaId, bool usuarioId})
        > {
  $$EvidenciasTableTableManager(_$BaseDatos db, $EvidenciasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tareaId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> rutaLocal = const Value.absent(),
                Value<String?> rutaRemota = const Value.absent(),
                Value<int?> tamanioBytes = const Value.absent(),
                Value<String> hashSha256 = const Value.absent(),
                Value<DateTime> createdAtDevice = const Value.absent(),
                Value<DateTime?> receivedAtServer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidenciasCompanion(
                id: id,
                tareaId: tareaId,
                usuarioId: usuarioId,
                tipo: tipo,
                rutaLocal: rutaLocal,
                rutaRemota: rutaRemota,
                tamanioBytes: tamanioBytes,
                hashSha256: hashSha256,
                createdAtDevice: createdAtDevice,
                receivedAtServer: receivedAtServer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tareaId,
                required String usuarioId,
                required String tipo,
                Value<String?> rutaLocal = const Value.absent(),
                Value<String?> rutaRemota = const Value.absent(),
                Value<int?> tamanioBytes = const Value.absent(),
                required String hashSha256,
                required DateTime createdAtDevice,
                Value<DateTime?> receivedAtServer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvidenciasCompanion.insert(
                id: id,
                tareaId: tareaId,
                usuarioId: usuarioId,
                tipo: tipo,
                rutaLocal: rutaLocal,
                rutaRemota: rutaRemota,
                tamanioBytes: tamanioBytes,
                hashSha256: hashSha256,
                createdAtDevice: createdAtDevice,
                receivedAtServer: receivedAtServer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EvidenciasTable, Evidencia>(table),
                  $$EvidenciasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tareaId = false, usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tareaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tareaId,
                        referencedTable: $$EvidenciasTableReferences
                            ._tareaIdTable(db),
                        referencedColumn: $$EvidenciasTableReferences
                            ._tareaIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (usuarioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.usuarioId,
                        referencedTable: $$EvidenciasTableReferences
                            ._usuarioIdTable(db),
                        referencedColumn: $$EvidenciasTableReferences
                            ._usuarioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EvidenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $EvidenciasTable,
      Evidencia,
      $$EvidenciasTableFilterComposer,
      $$EvidenciasTableOrderingComposer,
      $$EvidenciasTableAnnotationComposer,
      $$EvidenciasTableCreateCompanionBuilder,
      $$EvidenciasTableUpdateCompanionBuilder,
      (Evidencia, $$EvidenciasTableReferences),
      Evidencia,
      PrefetchHooks Function({bool tareaId, bool usuarioId})
    >;
typedef $$OperacionesPendientesTableCreateCompanionBuilder =
    OperacionesPendientesCompanion Function({
      required String id,
      required String entidad,
      required String entidadId,
      required String operacion,
      required Map<String, Object?> payload,
      Value<int> intentos,
      Value<String?> ultimoError,
      required DateTime createdAtDevice,
      Value<String> estado,
      Value<int> rowid,
    });
typedef $$OperacionesPendientesTableUpdateCompanionBuilder =
    OperacionesPendientesCompanion Function({
      Value<String> id,
      Value<String> entidad,
      Value<String> entidadId,
      Value<String> operacion,
      Value<Map<String, Object?>> payload,
      Value<int> intentos,
      Value<String?> ultimoError,
      Value<DateTime> createdAtDevice,
      Value<String> estado,
      Value<int> rowid,
    });

class $$OperacionesPendientesTableFilterComposer
    extends Composer<_$BaseDatos, $OperacionesPendientesTable> {
  $$OperacionesPendientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entidad => $composableBuilder(
    column: $table.entidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entidadId => $composableBuilder(
    column: $table.entidadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operacion => $composableBuilder(
    column: $table.operacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, Object?>,
    Map<String, Object>,
    String
  >
  get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OperacionesPendientesTableOrderingComposer
    extends Composer<_$BaseDatos, $OperacionesPendientesTable> {
  $$OperacionesPendientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entidad => $composableBuilder(
    column: $table.entidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entidadId => $composableBuilder(
    column: $table.entidadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operacion => $composableBuilder(
    column: $table.operacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OperacionesPendientesTableAnnotationComposer
    extends Composer<_$BaseDatos, $OperacionesPendientesTable> {
  $$OperacionesPendientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entidad =>
      $composableBuilder(column: $table.entidad, builder: (column) => column);

  GeneratedColumn<String> get entidadId =>
      $composableBuilder(column: $table.entidadId, builder: (column) => column);

  GeneratedColumn<String> get operacion =>
      $composableBuilder(column: $table.operacion, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, Object?>, String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get intentos =>
      $composableBuilder(column: $table.intentos, builder: (column) => column);

  GeneratedColumn<String> get ultimoError => $composableBuilder(
    column: $table.ultimoError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtDevice => $composableBuilder(
    column: $table.createdAtDevice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$OperacionesPendientesTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $OperacionesPendientesTable,
          OperacionPendiente,
          $$OperacionesPendientesTableFilterComposer,
          $$OperacionesPendientesTableOrderingComposer,
          $$OperacionesPendientesTableAnnotationComposer,
          $$OperacionesPendientesTableCreateCompanionBuilder,
          $$OperacionesPendientesTableUpdateCompanionBuilder,
          (
            OperacionPendiente,
            BaseReferences<
              _$BaseDatos,
              $OperacionesPendientesTable,
              OperacionPendiente
            >,
          ),
          OperacionPendiente,
          PrefetchHooks Function()
        > {
  $$OperacionesPendientesTableTableManager(
    _$BaseDatos db,
    $OperacionesPendientesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperacionesPendientesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OperacionesPendientesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OperacionesPendientesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entidad = const Value.absent(),
                Value<String> entidadId = const Value.absent(),
                Value<String> operacion = const Value.absent(),
                Value<Map<String, Object?>> payload = const Value.absent(),
                Value<int> intentos = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                Value<DateTime> createdAtDevice = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperacionesPendientesCompanion(
                id: id,
                entidad: entidad,
                entidadId: entidadId,
                operacion: operacion,
                payload: payload,
                intentos: intentos,
                ultimoError: ultimoError,
                createdAtDevice: createdAtDevice,
                estado: estado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entidad,
                required String entidadId,
                required String operacion,
                required Map<String, Object?> payload,
                Value<int> intentos = const Value.absent(),
                Value<String?> ultimoError = const Value.absent(),
                required DateTime createdAtDevice,
                Value<String> estado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperacionesPendientesCompanion.insert(
                id: id,
                entidad: entidad,
                entidadId: entidadId,
                operacion: operacion,
                payload: payload,
                intentos: intentos,
                ultimoError: ultimoError,
                createdAtDevice: createdAtDevice,
                estado: estado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OperacionesPendientesTable, OperacionPendiente>(
                    table,
                  ),
                  BaseReferences<
                    _$BaseDatos,
                    $OperacionesPendientesTable,
                    OperacionPendiente
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OperacionesPendientesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $OperacionesPendientesTable,
      OperacionPendiente,
      $$OperacionesPendientesTableFilterComposer,
      $$OperacionesPendientesTableOrderingComposer,
      $$OperacionesPendientesTableAnnotationComposer,
      $$OperacionesPendientesTableCreateCompanionBuilder,
      $$OperacionesPendientesTableUpdateCompanionBuilder,
      (
        OperacionPendiente,
        BaseReferences<
          _$BaseDatos,
          $OperacionesPendientesTable,
          OperacionPendiente
        >,
      ),
      OperacionPendiente,
      PrefetchHooks Function()
    >;
typedef $$MetadatosTableCreateCompanionBuilder = MetadatosCompanion Function({
  required String clave,
  required String valor,
  Value<int> rowid,
});
typedef $$MetadatosTableUpdateCompanionBuilder = MetadatosCompanion Function({
  Value<String> clave,
  Value<String> valor,
  Value<int> rowid,
});

class $$MetadatosTableFilterComposer
    extends Composer<_$BaseDatos, $MetadatosTable> {
  $$MetadatosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetadatosTableOrderingComposer
    extends Composer<_$BaseDatos, $MetadatosTable> {
  $$MetadatosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetadatosTableAnnotationComposer
    extends Composer<_$BaseDatos, $MetadatosTable> {
  $$MetadatosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$MetadatosTableTableManager
    extends
        RootTableManager<
          _$BaseDatos,
          $MetadatosTable,
          Metadato,
          $$MetadatosTableFilterComposer,
          $$MetadatosTableOrderingComposer,
          $$MetadatosTableAnnotationComposer,
          $$MetadatosTableCreateCompanionBuilder,
          $$MetadatosTableUpdateCompanionBuilder,
          (Metadato, BaseReferences<_$BaseDatos, $MetadatosTable, Metadato>),
          Metadato,
          PrefetchHooks Function()
        > {
  $$MetadatosTableTableManager(_$BaseDatos db, $MetadatosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetadatosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetadatosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetadatosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> clave = const Value.absent(),
            Value<String> valor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetadatosCompanion(clave: clave, valor: valor, rowid: rowid),
          createCompanionCallback:
              ({
                required String clave,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => MetadatosCompanion.insert(
                clave: clave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetadatosTable, Metadato>(table),
                  BaseReferences<_$BaseDatos, $MetadatosTable, Metadato>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetadatosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDatos,
      $MetadatosTable,
      Metadato,
      $$MetadatosTableFilterComposer,
      $$MetadatosTableOrderingComposer,
      $$MetadatosTableAnnotationComposer,
      $$MetadatosTableCreateCompanionBuilder,
      $$MetadatosTableUpdateCompanionBuilder,
      (Metadato, BaseReferences<_$BaseDatos, $MetadatosTable, Metadato>),
      Metadato,
      PrefetchHooks Function()
    >;

class $BaseDatosManager {
  final _$BaseDatos _db;
  $BaseDatosManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$UnidadesProductivasTableTableManager get unidadesProductivas =>
      $$UnidadesProductivasTableTableManager(_db, _db.unidadesProductivas);
  $$TareasTableTableManager get tareas =>
      $$TareasTableTableManager(_db, _db.tareas);
  $$ItemsChecklistTableTableManager get itemsChecklist =>
      $$ItemsChecklistTableTableManager(_db, _db.itemsChecklist);
  $$EventosTableTableManager get eventos =>
      $$EventosTableTableManager(_db, _db.eventos);
  $$EvidenciasTableTableManager get evidencias =>
      $$EvidenciasTableTableManager(_db, _db.evidencias);
  $$OperacionesPendientesTableTableManager get operacionesPendientes =>
      $$OperacionesPendientesTableTableManager(_db, _db.operacionesPendientes);
  $$MetadatosTableTableManager get metadatos =>
      $$MetadatosTableTableManager(_db, _db.metadatos);
}
