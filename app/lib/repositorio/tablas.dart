// Los CHECK de Drift se escriben referenciando la propia columna
// (`text().check(rol.isIn(...))`); drift_dev los lee sin ejecutarlos.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

/// Tablas de la Tabla 14 de la tesis (modelo-de-datos.md).
///
/// Los nombres SQL son exactamente los de la tesis, en snake_case singular.
/// Los UUID se guardan como TEXT. Las fechas, como texto ISO-8601
/// (`store_date_time_values_as_text` en build.yaml).

/// JSON guardado como TEXT que en `toJson()` sale como objeto (no como string),
/// para que PostgREST lo reciba como `jsonb`.
final conversorJson = TypeConverter.json2<Map<String, Object?>>(
  fromJson: (json) => Map<String, Object?>.from(json as Map),
);

@DataClassName('Usuario')
class Usuarios extends Table {
  @override
  String get tableName => 'usuario';

  TextColumn get id => text()();
  TextColumn get authId => text().nullable()();
  TextColumn get nombre => text()();
  TextColumn get telefono => text().unique()();
  TextColumn get rol => text().check(rol.isIn(const ['ENCARGADO', 'TRABAJADOR']))();
  TextColumn get especialidad => text().nullable()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAtDevice => dateTime()();
  DateTimeColumn get receivedAtServer => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UnidadProductiva')
class UnidadesProductivas extends Table {
  @override
  String get tableName => 'unidad_productiva';

  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get tipo =>
      text().check(tipo.isIn(const ['LOTE', 'POTRERO', 'INSTALACION']))();
  RealColumn get superficieHa => real().nullable()();
  TextColumn get codigoQr => text().unique()();
  RealColumn get latitud => real().nullable()();
  RealColumn get longitud => real().nullable()();
  BoolColumn get activa => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Tarea')
@TableIndex(name: 'idx_tarea_asignado_fecha', columns: {#asignadoId, #fechaProgramada})
class Tareas extends Table {
  @override
  String get tableName => 'tarea';

  TextColumn get id => text()();
  TextColumn get unidadProductivaId =>
      text().references(UnidadesProductivas, #id)();
  @ReferenceName('tareasCreadas')
  TextColumn get creadorId => text().references(Usuarios, #id)();
  @ReferenceName('tareasAsignadas')
  TextColumn get asignadoId => text().references(Usuarios, #id)();
  TextColumn get tipoLabor => text().check(tipoLabor.isIn(const [
        'GENERAL',
        'SIEMBRA',
        'APLICACION_FITOSANITARIA',
        'SANIDAD_ANIMAL',
        'MANTENIMIENTO',
      ]))();
  TextColumn get descripcion => text().nullable()();

  /// Fecha sin hora, 'AAAA-MM-DD' (tipo `date` en Postgres).
  TextColumn get fechaProgramada => text()();
  BoolColumn get requiereQr => boolean().withDefault(const Constant(false))();
  TextColumn get evidenciaRequerida => text()
      .withDefault(const Constant('NINGUNA'))
      .check(evidenciaRequerida
          .isIn(const ['NINGUNA', 'FOTO', 'AUDIO', 'FOTO_Y_AUDIO']))();

  /// Proyección del último evento de estado (ver dominio/derivar_estado.dart).
  TextColumn get estadoActual => text()
      .withDefault(const Constant('CREADA'))
      .check(estadoActual.isIn(const [
        'CREADA',
        'ASIGNADA',
        'INICIADA',
        'COMPLETADA',
        'NO_COMPLETADA',
        'VERIFICADA',
      ]))();
  DateTimeColumn get createdAtDevice => dateTime()();
  DateTimeColumn get receivedAtServer => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ItemChecklist')
class ItemsChecklist extends Table {
  @override
  String get tableName => 'item_checklist';

  TextColumn get id => text()();
  TextColumn get tareaId => text().references(Tareas, #id)();
  IntColumn get orden => integer()();
  TextColumn get descripcion => text()();
  TextColumn get tipoRespuesta => text()
      .check(tipoRespuesta.isIn(const ['CHECK', 'NUMERO', 'TEXTO']))();
  BoolColumn get obligatorio => boolean().withDefault(const Constant(false))();
  TextColumn get valor => text().nullable()();
  BoolColumn get completado => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Bitácora de solo adición: nunca se actualiza ni se borra
/// (única excepción: completar `received_at_server` cuando lo informa el servidor).
@DataClassName('Evento')
@TableIndex(name: 'idx_evento_tarea', columns: {#tareaId})
class Eventos extends Table {
  @override
  String get tableName => 'evento';

  TextColumn get id => text()();
  TextColumn get tareaId => text().references(Tareas, #id)();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  TextColumn get tipo => text().check(tipo.isIn(const [
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
      ]))();
  TextColumn get payload => text()
      .map(conversorJson)
      .withDefault(const Constant('{}'))();
  DateTimeColumn get createdAtDevice => dateTime()();
  DateTimeColumn get receivedAtServer => dateTime().nullable()();
  RealColumn get latitud => real().nullable()();
  RealColumn get longitud => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Evidencia')
class Evidencias extends Table {
  @override
  String get tableName => 'evidencia';

  TextColumn get id => text()();
  TextColumn get tareaId => text().references(Tareas, #id)();
  TextColumn get usuarioId => text().references(Usuarios, #id)();
  TextColumn get tipo => text().check(tipo.isIn(const ['FOTO', 'AUDIO']))();
  TextColumn get rutaLocal => text().nullable()();
  TextColumn get rutaRemota => text().nullable()();
  IntColumn get tamanioBytes => integer().nullable()();
  TextColumn get hashSha256 => text()();
  DateTimeColumn get createdAtDevice => dateTime()();
  DateTimeColumn get receivedAtServer => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Bandeja de salida transaccional. Existe solo en el dispositivo.
@DataClassName('OperacionPendiente')
@TableIndex(
    name: 'idx_operacion_estado_fecha', columns: {#estado, #createdAtDevice})
class OperacionesPendientes extends Table {
  @override
  String get tableName => 'operacion_pendiente';

  TextColumn get id => text()();
  TextColumn get entidad => text()();
  TextColumn get entidadId => text()();

  /// INSERT o UPDATE (Tabla 14). SUBIDA = archivo de la cola de multimedia
  /// (decisión D4 en docs/trazabilidad.md).
  TextColumn get operacion =>
      text().check(operacion.isIn(const ['INSERT', 'UPDATE', 'SUBIDA']))();
  TextColumn get payload => text().map(conversorJson)();
  IntColumn get intentos => integer().withDefault(const Constant(0))();
  TextColumn get ultimoError => text().nullable()();
  DateTimeColumn get createdAtDevice => dateTime()();
  TextColumn get estado => text()
      .withDefault(const Constant('PENDIENTE'))
      .check(estado.isIn(const ['PENDIENTE', 'ENVIADO', 'ERROR']))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Clave-valor local (cursor de sincronización, etc.). Decisión D2.
@DataClassName('Metadato')
class Metadatos extends Table {
  @override
  String get tableName => 'metadato';

  TextColumn get clave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {clave};
}
