import 'package:drift/drift.dart';

import '../dominio/derivar_estado.dart';
import '../dominio/tipo_evento.dart';
import 'base_datos.dart';
import 'fabrica_eventos.dart';
import 'serializador_postgrest.dart';

enum TipoOperacion {
  insert('INSERT'),
  update('UPDATE');

  const TipoOperacion(this.valor);
  final String valor;
}

/// Alta o modificación de una entidad de negocio (no eventos).
class CambioEntidad<T extends Table, D extends DataClass> {
  const CambioEntidad(
    this.tabla,
    this.fila, {
    this.operacion = TipoOperacion.insert,
  });

  final TableInfo<T, D> tabla;

  /// Fila completa (data class de Drift): se guarda y se serializa al payload.
  final D fila;
  final TipoOperacion operacion;
}

/// Archivo de evidencia para la cola de multimedia (decisión D4): se encola
/// como `operacion = 'SUBIDA'` y se procesa aparte de los eventos (HU-011 c3).
class SubidaArchivo {
  const SubidaArchivo({
    required this.evidenciaId,
    required this.rutaLocal,
    required this.rutaRemota,
    required this.tipoContenido,
    required this.hashSha256,
  });

  final String evidenciaId;
  final String rutaLocal;

  /// Ruta en el bucket `evidencias`: `<tarea_id>/<evidencia_id>.<ext>`.
  final String rutaRemota;
  final String tipoContenido;
  final String hashSha256;
}

/// Una acción de negocio: entidades que cambian + eventos de la bitácora
/// + archivos a subir.
class Accion {
  const Accion({
    this.cambios = const [],
    this.eventos = const [],
    this.subidas = const [],
  });

  final List<CambioEntidad> cambios;
  final List<Evento> eventos;
  final List<SubidaArchivo> subidas;
}

/// Columnas que nunca viajan al servidor: las fija el servidor
/// (`received_at_server`, `auth_id`) o solo tienen sentido en el dispositivo.
const _columnasSoloLocales = <String, Set<String>>{
  '*': {'received_at_server'},
  'usuario': {'auth_id'},
  'evidencia': {'ruta_local'},
};

const _serializador = SerializadorPostgrest();

extension RegistrarAccion on BaseDatos {
  /// HU-004 c2: la entidad, el evento y la operación pendiente se escriben en
  /// **una misma transacción**. Si cualquier paso falla, no queda nada escrito.
  Future<void> registrarAccion(Accion accion) {
    return transaction(() async {
      final ahora = DateTime.now();

      for (final cambio in accion.cambios) {
        await into(cambio.tabla)
            .insertOnConflictUpdate(cambio.fila as Insertable<DataClass>);
        await _encolar(
          entidad: cambio.tabla.actualTableName,
          payload: cambio.fila.toJson(serializer: _serializador),
          operacion: cambio.operacion.valor,
          ahora: ahora,
        );
      }

      for (final evento in accion.eventos) {
        // Insert simple: un id repetido es un error, nunca un reemplazo.
        await into(eventos).insert(evento);
        await _encolar(
          entidad: eventos.actualTableName,
          payload: evento.toJson(serializer: _serializador),
          operacion: TipoOperacion.insert.valor,
          ahora: ahora,
        );
      }

      for (final subida in accion.subidas) {
        await into(operacionesPendientes).insert(
          OperacionesPendientesCompanion.insert(
            id: nuevoId(),
            entidad: evidencias.actualTableName,
            entidadId: subida.evidenciaId,
            operacion: 'SUBIDA',
            payload: {
              'ruta_local': subida.rutaLocal,
              'ruta_remota': subida.rutaRemota,
              'tipo_contenido': subida.tipoContenido,
              'hash_sha256': subida.hashSha256,
            },
            createdAtDevice: ahora,
          ),
        );
      }

      final tareasAfectadas = accion.eventos.map((e) => e.tareaId).toSet();
      for (final tareaId in tareasAfectadas) {
        await proyectarTarea(tareaId);
      }
    });
  }

  Future<void> _encolar({
    required String entidad,
    required Map<String, dynamic> payload,
    required String operacion,
    required DateTime ahora,
  }) {
    final limpio = Map<String, Object?>.from(payload)
      ..removeWhere((k, _) =>
          _columnasSoloLocales['*']!.contains(k) ||
          (_columnasSoloLocales[entidad]?.contains(k) ?? false));

    return into(operacionesPendientes).insert(
      OperacionesPendientesCompanion.insert(
        id: nuevoId(),
        entidad: entidad,
        entidadId: limpio['id']! as String,
        operacion: operacion,
        payload: limpio,
        createdAtDevice: ahora,
      ),
    );
  }

  /// Recalcula las proyecciones locales de una tarea a partir de sus eventos.
  /// No se encola: el servidor hace el mismo cálculo con un trigger.
  Future<void> proyectarTarea(String tareaId) async {
    final filas = await (select(eventos)
          ..where((e) => e.tareaId.equals(tareaId))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAtDevice)]))
        .get();
    final dominio = ordenarEventos(filas.map((e) => EventoDominio(
          tipo: TipoEvento.desdeValor(e.tipo),
          creadoEnDispositivo: e.createdAtDevice,
          payload: e.payload,
        )));

    // Estado y, si hubo reasignación, el nuevo asignado.
    final ultimaReasignacion = dominio.lastWhereOrNull(
      (e) => e.tipo == TipoEvento.reasignada,
    );
    final nuevoAsignado =
        ultimaReasignacion?.payload['nuevo_asignado_id'] as String?;
    await (update(tareas)..where((t) => t.id.equals(tareaId))).write(
      TareasCompanion(
        estadoActual: Value(derivarEstado(dominio).valor),
        asignadoId:
            nuevoAsignado == null ? const Value.absent() : Value(nuevoAsignado),
      ),
    );

    // Ítems: se reinician y se aplican los ITEM_COMPLETADO del ciclo vigente.
    await (update(itemsChecklist)..where((i) => i.tareaId.equals(tareaId)))
        .write(const ItemsChecklistCompanion(
      valor: Value(null),
      completado: Value(false),
    ));
    for (final e in eventosDelCicloVigente(dominio)) {
      if (e.tipo != TipoEvento.itemCompletado) continue;
      final itemId = e.payload['item_id'] as String?;
      if (itemId == null) continue;
      await (update(itemsChecklist)..where((i) => i.id.equals(itemId))).write(
        ItemsChecklistCompanion(
          valor: Value(e.payload['valor']?.toString()),
          completado: const Value(true),
        ),
      );
    }
  }
}

extension<E> on List<E> {
  E? lastWhereOrNull(bool Function(E) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}
