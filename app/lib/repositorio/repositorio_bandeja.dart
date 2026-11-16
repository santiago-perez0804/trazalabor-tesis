import 'package:drift/drift.dart';

import '../dominio/catalogos.dart';
import '../dominio/tipo_evento.dart';
import 'base_datos.dart';

/// Lo que una labor (o las altas del encargado) tiene guardado en el teléfono
/// a la espera de confirmación del servidor (pantalla H, "Para enviar").
class GrupoPorEnviar {
  const GrupoPorEnviar({
    required this.tareaId,
    required this.unidadNombre,
    required this.tipoLabor,
    required this.estado,
    required this.cambios,
    required this.archivos,
    required this.archivosEnviados,
    required this.fotos,
    required this.audios,
    required this.conError,
  });

  /// `null` = altas y cambios de trabajadores o unidades.
  final String? tareaId;
  final String? unidadNombre;
  final TipoLabor? tipoLabor;
  final EstadoTarea? estado;

  /// Eventos y registros sin confirmar (sin contar archivos).
  final int cambios;

  /// Fotos y audios de la labor y cuántos ya subieron.
  final int archivos;
  final int archivosEnviados;

  /// Fotos y audios que todavía faltan subir.
  final int fotos;
  final int audios;
  final bool conError;

  int get archivosPendientes => archivos - archivosEnviados;

  /// Cuántas tarjetas ocupa en "Para enviar": los cambios y los archivos van
  /// por separado, porque los archivos viajan por su propia cola.
  int get tarjetas => (cambios > 0 ? 1 : 0) + (archivosPendientes > 0 ? 1 : 0);
}

/// Consultas sobre la bandeja de salida (`operacion_pendiente`).
class RepositorioBandeja {
  RepositorioBandeja(this._db);

  final BaseDatos _db;

  /// Operaciones que todavía no confirmó el servidor (decisión D21).
  Stream<int> observarPendientes() {
    final t = _db.operacionesPendientes;
    final cantidad = t.id.count();
    final consulta = _db.selectOnly(t)
      ..addColumns([cantidad])
      ..where(t.estado.equals('ENVIADO').not());
    return consulta.watchSingle().map((fila) => fila.read(cantidad) ?? 0);
  }

  /// Lo pendiente agrupado por labor (pantalla H, decisión D33). El avance
  /// de los archivos se cuenta por archivo subido.
  Stream<List<GrupoPorEnviar>> observarPorEnviar() {
    return _db
        .customSelect(
          '''
WITH ops AS (
  SELECT o.estado, o.operacion, o.entidad_id,
    CASE o.entidad
      WHEN 'tarea' THEN o.entidad_id
      WHEN 'evento' THEN (SELECT e.tarea_id FROM evento e WHERE e.id = o.entidad_id)
      WHEN 'item_checklist' THEN (SELECT i.tarea_id FROM item_checklist i WHERE i.id = o.entidad_id)
      WHEN 'evidencia' THEN (SELECT v.tarea_id FROM evidencia v WHERE v.id = o.entidad_id)
    END AS tarea_id
  FROM operacion_pendiente o
)
SELECT ops.tarea_id, u.nombre AS unidad_nombre, t.tipo_labor, t.estado_actual,
  SUM(CASE WHEN ops.estado <> 'ENVIADO' AND ops.operacion <> 'SUBIDA' THEN 1 ELSE 0 END) AS cambios,
  SUM(CASE WHEN ops.operacion = 'SUBIDA' THEN 1 ELSE 0 END) AS archivos,
  SUM(CASE WHEN ops.operacion = 'SUBIDA' AND ops.estado = 'ENVIADO' THEN 1 ELSE 0 END) AS archivos_enviados,
  SUM(CASE WHEN ops.operacion = 'SUBIDA' AND ops.estado <> 'ENVIADO'
            AND (SELECT v.tipo FROM evidencia v WHERE v.id = ops.entidad_id) = 'FOTO' THEN 1 ELSE 0 END) AS fotos,
  SUM(CASE WHEN ops.operacion = 'SUBIDA' AND ops.estado <> 'ENVIADO'
            AND (SELECT v.tipo FROM evidencia v WHERE v.id = ops.entidad_id) = 'AUDIO' THEN 1 ELSE 0 END) AS audios,
  SUM(CASE WHEN ops.estado = 'ERROR' THEN 1 ELSE 0 END) AS con_error
FROM ops
LEFT JOIN tarea t ON t.id = ops.tarea_id
LEFT JOIN unidad_productiva u ON u.id = t.unidad_productiva_id
GROUP BY ops.tarea_id
HAVING SUM(CASE WHEN ops.estado <> 'ENVIADO' THEN 1 ELSE 0 END) > 0
ORDER BY ops.tarea_id IS NULL, u.nombre
''',
          readsFrom: {
            _db.operacionesPendientes,
            _db.tareas,
            _db.unidadesProductivas,
            _db.eventos,
            _db.evidencias,
            _db.itemsChecklist,
          },
        )
        .watch()
        .map(
          (filas) => [
            for (final f in filas)
              GrupoPorEnviar(
                tareaId: f.readNullable<String>('tarea_id'),
                unidadNombre: f.readNullable<String>('unidad_nombre'),
                tipoLabor: _o(
                  f.readNullable<String>('tipo_labor'),
                  TipoLabor.desdeValor,
                ),
                estado: _o(
                  f.readNullable<String>('estado_actual'),
                  EstadoTarea.desdeValor,
                ),
                cambios: f.read<int>('cambios'),
                archivos: f.read<int>('archivos'),
                archivosEnviados: f.read<int>('archivos_enviados'),
                fotos: f.read<int>('fotos'),
                audios: f.read<int>('audios'),
                conError: f.read<int>('con_error') > 0,
              ),
          ],
        );
  }

  static T? _o<T>(String? v, T Function(String) f) => v == null ? null : f(v);
}
