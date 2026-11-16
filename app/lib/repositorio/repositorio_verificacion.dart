import 'package:drift/drift.dart';

import '../dominio/catalogos.dart';
import '../dominio/tipo_evento.dart';
import '../dominio/validar_labor.dart';
import '../dominio/validar_verificacion.dart';
import 'base_datos.dart';
import 'fabrica_eventos.dart';
import 'registrar_accion.dart';
import 'repositorio_ejecucion.dart';

/// Una labor en las listas del encargado (Por verificar / Historial).
class LaborResumen {
  const LaborResumen({
    required this.tarea,
    required this.unidadNombre,
    required this.trabajadorNombre,
    required this.ultimoMovimiento,
  });

  final Tarea tarea;
  final String unidadNombre;
  final String trabajadorNombre;

  /// Hora (del dispositivo) del último evento de la labor.
  final DateTime? ultimoMovimiento;

  TipoLabor get tipoLabor => TipoLabor.desdeValor(tarea.tipoLabor);
  EstadoTarea get estado => EstadoTarea.desdeValor(tarea.estadoActual);
}

/// Filtros del historial (HU-013 c1). `null` = todos.
class FiltroHistorial {
  const FiltroHistorial({
    this.unidadId,
    this.trabajadorId,
    this.desde,
    this.hasta,
  });

  final String? unidadId;
  final String? trabajadorId;
  final DateTime? desde;
  final DateTime? hasta;

  @override
  bool operator ==(Object other) =>
      other is FiltroHistorial &&
      other.unidadId == unidadId &&
      other.trabajadorId == trabajadorId &&
      other.desde == desde &&
      other.hasta == hasta;

  @override
  int get hashCode => Object.hash(unidadId, trabajadorId, desde, hasta);
}

/// Un evento de la cronología, con quién lo registró.
class EventoCronologia {
  const EventoCronologia({required this.evento, required this.autor});
  final Evento evento;
  final String autor;
  TipoEvento get tipo => TipoEvento.desdeValor(evento.tipo);
}

/// Todo lo que muestra el detalle de verificación (HU-012 c1, HU-013 c2).
class DetalleVerificacion {
  const DetalleVerificacion({
    required this.detalle,
    required this.trabajadorNombre,
    required this.cronologia,
    required this.todasLasEvidencias,
    this.nombres = const {},
  });

  /// Nombre de cada usuario por id, para las frases de la cronología.
  final Map<String, String> nombres;

  /// Ítems, evidencias del ciclo vigente y QR (la misma vista que usa el
  /// trabajador).
  final DetalleTarea detalle;
  final String trabajadorNombre;

  /// Secuencia completa de eventos, en orden.
  final List<EventoCronologia> cronologia;

  /// Evidencias de todos los ciclos (para el historial).
  final List<Evidencia> todasLasEvidencias;

  Tarea get tarea => detalle.tarea;
  EstadoTarea get estado => detalle.estado;

  /// El cierre llegó al servidor (HU-012 c1: "COMPLETADA y sincronizada").
  bool get cierreSincronizado {
    for (final e in cronologia.reversed) {
      if (e.tipo == TipoEvento.completada ||
          e.tipo == TipoEvento.noCompletada) {
        return e.evento.receivedAtServer != null;
      }
    }
    return false;
  }
}

/// Verificación e historial del encargado (HU-012, HU-013, T-27 a T-30).
/// Lee siempre de la base local; lo que hizo el trabajador llega por la
/// sincronización.
class RepositorioVerificacion {
  RepositorioVerificacion(this._db, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;

  final BaseDatos _db;
  final DateTime Function() _reloj;

  static const _consultaBase = '''
SELECT t.*, u.nombre AS unidad_nombre, w.nombre AS trabajador_nombre,
       (SELECT MAX(e.created_at_device) FROM evento e WHERE e.tarea_id = t.id)
         AS ultimo_movimiento
  FROM tarea t
  JOIN unidad_productiva u ON u.id = t.unidad_productiva_id
  JOIN usuario w ON w.id = t.asignado_id
''';

  /// Labores cerradas por el trabajador que esperan la revisión.
  Stream<List<LaborResumen>> observarPorVerificar() => _observar(
    '$_consultaBase WHERE t.estado_actual IN (\'COMPLETADA\', \'NO_COMPLETADA\') '
    'ORDER BY ultimo_movimiento DESC',
    const [],
  );

  /// HU-013 c1: labores por unidad, trabajador y período (fecha programada).
  Stream<List<LaborResumen>> observarHistorial(FiltroHistorial f) {
    final condiciones = <String>[];
    final variables = <Variable>[];
    if (f.unidadId != null) {
      condiciones.add('t.unidad_productiva_id = ?');
      variables.add(Variable.withString(f.unidadId!));
    }
    if (f.trabajadorId != null) {
      condiciones.add('t.asignado_id = ?');
      variables.add(Variable.withString(f.trabajadorId!));
    }
    if (f.desde != null) {
      condiciones.add('t.fecha_programada >= ?');
      variables.add(Variable.withString(fechaComoTexto(f.desde!)));
    }
    if (f.hasta != null) {
      condiciones.add('t.fecha_programada <= ?');
      variables.add(Variable.withString(fechaComoTexto(f.hasta!)));
    }
    final donde = condiciones.isEmpty
        ? ''
        : 'WHERE ${condiciones.join(' AND ')} ';
    return _observar(
      '$_consultaBase $donde'
      'ORDER BY t.fecha_programada DESC, ultimo_movimiento DESC',
      variables,
    );
  }

  Stream<List<LaborResumen>> _observar(String sql, List<Variable> variables) =>
      _db
          .customSelect(
            sql,
            variables: variables,
            readsFrom: {
              _db.tareas,
              _db.unidadesProductivas,
              _db.usuarios,
              _db.eventos,
            },
          )
          .watch()
          .asyncMap(
            (filas) async => [
              for (final f in filas)
                LaborResumen(
                  tarea: await _db.tareas.mapFromRow(f),
                  unidadNombre: f.read<String>('unidad_nombre'),
                  trabajadorNombre: f.read<String>('trabajador_nombre'),
                  ultimoMovimiento: _leerFecha(
                    f.readNullable<String>('ultimo_movimiento'),
                  ),
                ),
            ],
          );

  static DateTime? _leerFecha(String? texto) =>
      texto == null ? null : DateTime.tryParse(texto)?.toLocal();

  Stream<DetalleVerificacion?> observarDetalle(String tareaId) async* {
    yield await leerDetalle(tareaId);
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.tareas,
        _db.itemsChecklist,
        _db.eventos,
        _db.evidencias,
        _db.usuarios,
      ]),
    )) {
      yield await leerDetalle(tareaId);
    }
  }

  Future<DetalleVerificacion?> leerDetalle(String tareaId) async {
    final detalle = await RepositorioEjecucion(_db).leerDetalle(tareaId);
    if (detalle == null) return null;
    final usuarios = {
      for (final u in await _db.select(_db.usuarios).get()) u.id: u.nombre,
    };
    final eventos =
        await (_db.select(_db.eventos)
              ..where((e) => e.tareaId.equals(tareaId))
              ..orderBy([(e) => OrderingTerm.asc(e.createdAtDevice)]))
            .get();
    final todas =
        await (_db.select(_db.evidencias)
              ..where((v) => v.tareaId.equals(tareaId))
              ..orderBy([(v) => OrderingTerm.asc(v.createdAtDevice)]))
            .get();
    return DetalleVerificacion(
      detalle: detalle,
      trabajadorNombre: usuarios[detalle.tarea.asignadoId] ?? '—',
      cronologia: [
        for (final e in eventos)
          EventoCronologia(evento: e, autor: usuarios[e.usuarioId] ?? '—'),
      ],
      todasLasEvidencias: todas,
      nombres: usuarios,
    );
  }

  /// HU-012 c2: se registra VERIFICADA y la labor pasa al historial.
  Future<void> aprobar(String tareaId, {required String encargadoId}) async {
    final d = await _leer(tareaId);
    final motivo = motivoNoAprobable(d.estado);
    if (motivo != null) throw AccionRechazada(motivo);
    await _db.registrarAccion(
      Accion(
        eventos: [
          nuevoEvento(
            tareaId: tareaId,
            usuarioId: encargadoId,
            tipo: TipoEvento.verificada,
            ahora: _reloj(),
          ),
        ],
      ),
    );
  }

  /// HU-012 c3: REASIGNADA con el nuevo trabajador y el motivo. Los eventos
  /// anteriores no se tocan: la labor vuelve a ASIGNADA por proyección.
  Future<void> reasignar(
    String tareaId, {
    required String encargadoId,
    required String? nuevoTrabajadorId,
    required String motivo,
  }) async {
    final d = await _leer(tareaId);
    final rechazo = motivoNoReasignable(
      d.estado,
      nuevoTrabajadorId: nuevoTrabajadorId,
      motivo: motivo,
    );
    if (rechazo != null) throw AccionRechazada(rechazo);
    await _db.registrarAccion(
      Accion(
        eventos: [
          nuevoEvento(
            tareaId: tareaId,
            usuarioId: encargadoId,
            tipo: TipoEvento.reasignada,
            payload: {
              'nuevo_asignado_id': nuevoTrabajadorId,
              'motivo': motivo.trim(),
            },
            ahora: _reloj(),
          ),
        ],
      ),
    );
  }

  Future<DetalleTarea> _leer(String tareaId) async {
    final d = await RepositorioEjecucion(_db).leerDetalle(tareaId);
    if (d == null) throw const AccionRechazada('La labor no existe.');
    return d;
  }
}
