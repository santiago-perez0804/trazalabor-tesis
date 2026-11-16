import 'package:drift/drift.dart';

import '../repositorio/base_datos.dart';
import '../repositorio/registrar_accion.dart';
import '../repositorio/serializador_postgrest.dart';
import 'servidor.dart';

/// Lo que trajo una descarga.
class ResultadoDescarga {
  const ResultadoDescarga({
    required this.filas,
    required this.tareasNuevasAsignadas,
  });

  /// Cantidad de filas recibidas (todas las tablas).
  final int filas;

  /// Labores que este teléfono no tenía y que quedaron asignadas al usuario
  /// de la sesión: disparan el aviso de nueva asignación (HU-010).
  final List<String> tareasNuevasAsignadas;
}

/// Trae del servidor lo que el teléfono todavía no tiene (T-26): nuevas
/// asignaciones para el trabajador; altas, cierres y evidencias para el
/// encargado. Las RLS del servidor deciden qué ve cada rol.
///
/// - Cursor por tabla en `metadato` (`cursor:<tabla>`): el mayor
///   `received_at_server` recibido. Se vuelve a pedir desde unos minutos antes
///   para no perder filas de transacciones que confirmaron tarde; las
///   repetidas se ignoran.
/// - Las tareas que el teléfono no tenía se traen completas: ítems, eventos y
///   evidencias (cubre también una labor reasignada a este trabajador).
/// - Eventos y evidencias: se insertan solo si no existen; si ya estaban (los
///   envió este teléfono), solo se completa `received_at_server`
///   (única excepción local del invariante de solo adición).
/// - Lo que todavía tiene cambios sin enviar no se pisa: manda el teléfono.
/// - Al final se recalculan las proyecciones a partir de los eventos.
class Descarga {
  Descarga(this._db, this._servidor);

  final BaseDatos _db;
  final Servidor _servidor;

  static const _ser = SerializadorPostgrest();
  static const _solape = Duration(minutes: 5);

  Future<ResultadoDescarga> descargar({required String usuarioId}) async {
    // Lecturas primero (con red); después, una sola transacción local.
    final usuarios = await _leerDesdeCursor('usuario');
    final unidades = await _servidor.leer('unidad_productiva');
    final tareas = await _leerDesdeCursor('tarea');

    final idsLocales = {
      for (final t in await _db.select(_db.tareas).get()) t.id,
    };
    final idsNuevas = [
      for (final t in tareas)
        if (!idsLocales.contains(t['id'])) t['id'] as String,
    ];

    final items = idsNuevas.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _servidor.leer(
            'item_checklist',
            columna: 'tarea_id',
            valores: idsNuevas,
          );
    final eventos = <String, Map<String, dynamic>>{
      for (final e in await _leerDesdeCursor('evento')) e['id'] as String: e,
      if (idsNuevas.isNotEmpty)
        for (final e in await _servidor.leer(
          'evento',
          columna: 'tarea_id',
          valores: idsNuevas,
        ))
          e['id'] as String: e,
    };
    final evidencias = <String, Map<String, dynamic>>{
      for (final v in await _leerDesdeCursor('evidencia')) v['id'] as String: v,
      if (idsNuevas.isNotEmpty)
        for (final v in await _servidor.leer(
          'evidencia',
          columna: 'tarea_id',
          valores: idsNuevas,
        ))
          v['id'] as String: v,
    };

    final afectadas = <String>{};
    await _db.transaction(() async {
      final conCambios = await _idsConCambiosSinEnviar();

      for (final j in usuarios) {
        if (conCambios.contains(j['id'])) continue;
        await _db
            .into(_db.usuarios)
            .insertOnConflictUpdate(Usuario.fromJson(j, serializer: _ser));
      }
      for (final j in unidades) {
        if (conCambios.contains(j['id'])) continue;
        await _db
            .into(_db.unidadesProductivas)
            .insertOnConflictUpdate(
              UnidadProductiva.fromJson(j, serializer: _ser),
            );
      }
      for (final j in tareas) {
        if (conCambios.contains(j['id'])) continue;
        final t = Tarea.fromJson(j, serializer: _ser);
        await _asegurarUsuario(t.creadorId);
        await _asegurarUsuario(t.asignadoId);
        await _db.into(_db.tareas).insertOnConflictUpdate(t);
        afectadas.add(t.id);
      }
      for (final j in items) {
        await _db
            .into(_db.itemsChecklist)
            .insert(
              ItemChecklist.fromJson(j, serializer: _ser),
              mode: InsertMode.insertOrIgnore,
            );
      }
      for (final j in eventos.values) {
        final e = Evento.fromJson(j, serializer: _ser);
        if (!await _existeTarea(e.tareaId)) continue;
        await _asegurarUsuario(e.usuarioId);
        await _db.into(_db.eventos).insert(e, mode: InsertMode.insertOrIgnore);
        await (_db.update(
          _db.eventos,
        )..where((x) => x.id.equals(e.id) & x.receivedAtServer.isNull())).write(
          EventosCompanion(receivedAtServer: Value(e.receivedAtServer)),
        );
        afectadas.add(e.tareaId);
      }
      for (final j in evidencias.values) {
        final v = Evidencia.fromJson(j, serializer: _ser);
        if (!await _existeTarea(v.tareaId)) continue;
        await _asegurarUsuario(v.usuarioId);
        await _db
            .into(_db.evidencias)
            .insert(v, mode: InsertMode.insertOrIgnore);
        await (_db.update(
          _db.evidencias,
        )..where((x) => x.id.equals(v.id) & x.receivedAtServer.isNull())).write(
          EvidenciasCompanion(receivedAtServer: Value(v.receivedAtServer)),
        );
      }

      for (final id in afectadas) {
        await _db.proyectarTarea(id);
      }

      await _guardarCursor('usuario', usuarios);
      await _guardarCursor('tarea', tareas);
      await _guardarCursor('evento', eventos.values);
      await _guardarCursor('evidencia', evidencias.values);
    });

    final nuevasAsignadas = idsNuevas.isEmpty
        ? const <String>[]
        : [
            for (final t
                in await (_db.select(_db.tareas)..where(
                      (t) =>
                          t.id.isIn(idsNuevas) &
                          t.asignadoId.equals(usuarioId) &
                          t.estadoActual.equals('ASIGNADA'),
                    ))
                    .get())
              t.id,
          ];

    return ResultadoDescarga(
      filas:
          usuarios.length +
          unidades.length +
          tareas.length +
          items.length +
          eventos.length +
          evidencias.length,
      tareasNuevasAsignadas: nuevasAsignadas,
    );
  }

  Future<List<Map<String, dynamic>>> _leerDesdeCursor(String tabla) async {
    final cursor = await _cursor(tabla);
    return _servidor.leer(tabla, recibidoDesde: cursor?.subtract(_solape));
  }

  Future<DateTime?> _cursor(String tabla) async {
    final fila = await (_db.select(
      _db.metadatos,
    )..where((m) => m.clave.equals('cursor:$tabla'))).getSingleOrNull();
    return fila == null ? null : DateTime.parse(fila.valor);
  }

  Future<void> _guardarCursor(
    String tabla,
    Iterable<Map<String, dynamic>> filas,
  ) async {
    DateTime? mayor = await _cursor(tabla);
    for (final f in filas) {
      final r = f['received_at_server'];
      if (r == null) continue;
      final fecha = DateTime.parse(r as String);
      if (mayor == null || fecha.isAfter(mayor)) mayor = fecha;
    }
    if (mayor == null) return;
    await _db
        .into(_db.metadatos)
        .insertOnConflictUpdate(
          Metadato(
            clave: 'cursor:$tabla',
            valor: mayor.toUtc().toIso8601String(),
          ),
        );
  }

  /// Entidades con operaciones que el servidor todavía no confirmó.
  Future<Set<String>> _idsConCambiosSinEnviar() async {
    final t = _db.operacionesPendientes;
    final filas =
        await (_db.selectOnly(t)
              ..addColumns([t.entidadId])
              ..where(t.estado.isNotValue('ENVIADO')))
            .get();
    return {for (final f in filas) f.read(t.entidadId)!};
  }

  Future<bool> _existeTarea(String id) async =>
      await (_db.select(
        _db.tareas,
      )..where((t) => t.id.equals(id))).getSingleOrNull() !=
      null;

  /// Un trabajador solo ve su propia fila y la de los encargados. Si una labor
  /// reasignada trae eventos de otro trabajador, se guarda una referencia
  /// mínima para no romper la integridad local.
  Future<void> _asegurarUsuario(String id) async {
    final existe =
        await (_db.select(
          _db.usuarios,
        )..where((u) => u.id.equals(id))).getSingleOrNull() !=
        null;
    if (existe) return;
    await _db
        .into(_db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: id,
            nombre: 'Otro trabajador',
            telefono: 'sin-datos:$id',
            rol: 'TRABAJADOR',
            createdAtDevice: DateTime.now(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }
}
