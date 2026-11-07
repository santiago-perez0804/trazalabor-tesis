import 'package:drift/drift.dart';

import '../dominio/archivo_evidencia.dart';
import '../dominio/catalogos.dart';
import '../dominio/derivar_estado.dart';
import '../dominio/estado_bandeja.dart';
import '../dominio/tipo_evento.dart';
import '../dominio/validar_cierre.dart';
import '../dominio/validar_labor.dart';
import '../dominio/validar_qr.dart';
import '../dominio/valor_item.dart';
import 'base_datos.dart';
import 'fabrica_eventos.dart';
import 'registrar_accion.dart';

/// La acción no se registró; `mensaje` se puede mostrar tal cual.
class AccionRechazada implements Exception {
  const AccionRechazada(this.mensaje, {this.faltantes = const []});
  final String mensaje;
  final List<String> faltantes;

  @override
  String toString() => mensaje;
}

/// Una labor en "Mis tareas de hoy" (pantalla B).
class TareaBandeja {
  const TareaBandeja({
    required this.tarea,
    required this.unidadNombre,
    required this.estado,
  });

  final Tarea tarea;
  final String unidadNombre;
  final EstadoBandeja estado;

  TipoLabor get tipoLabor => TipoLabor.desdeValor(tarea.tipoLabor);
}

/// Todo lo que muestran las pantallas de ejecución y cierre (C y D).
class DetalleTarea {
  const DetalleTarea({
    required this.tarea,
    required this.unidad,
    required this.items,
    required this.evidencias,
    required this.qrVerificado,
  });

  final Tarea tarea;
  final UnidadProductiva unidad;
  final List<ItemChecklist> items;

  /// Evidencias del ciclo vigente (después de la última reasignación).
  final List<Evidencia> evidencias;
  final bool qrVerificado;

  EstadoTarea get estado => EstadoTarea.desdeValor(tarea.estadoActual);
  bool get admiteEjecucion => estado.admiteEjecucionLocal;
  int get completados => items.where((i) => i.completado).length;
  int get fotos => evidencias.where((e) => e.tipo == 'FOTO').length;
  int get audios => evidencias.where((e) => e.tipo == 'AUDIO').length;
  EvidenciaRequerida get evidenciaRequerida =>
      EvidenciaRequerida.desdeValor(tarea.evidenciaRequerida);

  /// HU-007 c2: qué falta para cerrar como completada.
  ResultadoCierre validarCierreActual() => validarCierre(
    items: items.map(
      (i) => ItemDominio(
        descripcion: i.descripcion,
        obligatorio: i.obligatorio,
        completado: i.completado,
      ),
    ),
    evidenciaRequerida: evidenciaRequerida,
    requiereQr: tarea.requiereQr,
    fotos: fotos,
    audios: audios,
    qrVerificado: qrVerificado,
  );
}

extension on EstadoTarea {
  bool get admiteEjecucionLocal => admiteEjecucion(this);
}

/// Ejecución de labores por el trabajador, con o sin conexión
/// (HU-006 a HU-009, T-15 a T-20). Cada acción es una transacción de
/// `registrarAccion`: evento(s) + operación(es) pendiente(s).
class RepositorioEjecucion {
  RepositorioEjecucion(this._db, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;

  final BaseDatos _db;
  final DateTime Function() _reloj;

  // ---------------------------------------------------------------------------
  // Consultas
  // ---------------------------------------------------------------------------

  /// HU-006 c1 y c2: las labores del día del trabajador, más las de días
  /// anteriores que siguen abiertas o que todavía tienen algo por enviar
  /// (decisión D23; HU-007 c3: una labor cerrada sin conexión sigue a la vista
  /// como pendiente de envío). Se lee siempre de la base local, así que
  /// funciona igual sin conexión.
  Stream<List<TareaBandeja>> observarTareasDelDia(
    String usuarioId,
    DateTime hoy,
  ) {
    return _db
        .customSelect(
          '''
SELECT * FROM (
SELECT t.*, u.nombre AS unidad_nombre,
  EXISTS (
    SELECT 1 FROM operacion_pendiente o
     WHERE o.estado <> 'ENVIADO'
       AND (o.entidad_id = t.id
         OR o.entidad_id IN (SELECT e.id FROM evento e WHERE e.tarea_id = t.id)
         OR o.entidad_id IN (SELECT v.id FROM evidencia v WHERE v.tarea_id = t.id)
         OR o.entidad_id IN (SELECT i.id FROM item_checklist i WHERE i.tarea_id = t.id))
  ) AS por_enviar
  FROM tarea t
  JOIN unidad_productiva u ON u.id = t.unidad_productiva_id
 WHERE t.asignado_id = ?1 AND t.fecha_programada <= ?2
)
 WHERE fecha_programada = ?2
    OR estado_actual IN ('ASIGNADA', 'INICIADA')
    OR por_enviar
 ORDER BY CASE estado_actual WHEN 'INICIADA' THEN 0 WHEN 'ASIGNADA' THEN 1 ELSE 2 END,
          fecha_programada, created_at_device
''',
          variables: [
            Variable.withString(usuarioId),
            Variable.withString(fechaComoTexto(hoy)),
          ],
          readsFrom: {
            _db.tareas,
            _db.unidadesProductivas,
            _db.operacionesPendientes,
            _db.eventos,
            _db.evidencias,
            _db.itemsChecklist,
          },
        )
        .watch()
        .asyncMap(
          (filas) async => [for (final f in filas) await _aTareaBandeja(f)],
        );
  }

  Future<TareaBandeja> _aTareaBandeja(QueryRow f) async {
    final tarea = await _db.tareas.mapFromRow(f);
    return TareaBandeja(
      tarea: tarea,
      unidadNombre: f.read<String>('unidad_nombre'),
      estado: estadoBandeja(
        EstadoTarea.desdeValor(tarea.estadoActual),
        porEnviar: f.read<bool>('por_enviar'),
      ),
    );
  }

  /// HU-006 c3: lista de verificación, evidencia requerida y lo registrado.
  /// Se vuelve a leer cada vez que cambia alguna de las tablas involucradas.
  Stream<DetalleTarea?> observarDetalle(String tareaId) async* {
    yield await leerDetalle(tareaId);
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.tareas,
        _db.itemsChecklist,
        _db.eventos,
        _db.evidencias,
      ]),
    )) {
      yield await leerDetalle(tareaId);
    }
  }

  Future<DetalleTarea?> leerDetalle(String tareaId) async {
    final tarea = await (_db.select(
      _db.tareas,
    )..where((t) => t.id.equals(tareaId))).getSingleOrNull();
    if (tarea == null) return null;
    final unidad = await (_db.select(
      _db.unidadesProductivas,
    )..where((u) => u.id.equals(tarea.unidadProductivaId))).getSingle();
    final items =
        await (_db.select(_db.itemsChecklist)
              ..where((i) => i.tareaId.equals(tareaId))
              ..orderBy([(i) => OrderingTerm.asc(i.orden)]))
            .get();
    final eventos = await (_db.select(
      _db.eventos,
    )..where((e) => e.tareaId.equals(tareaId))).get();
    final ciclo = eventosDelCicloVigente(
      ordenarEventos(
        eventos.map(
          (e) => EventoDominio(
            tipo: TipoEvento.desdeValor(e.tipo),
            creadoEnDispositivo: e.createdAtDevice,
            payload: e.payload,
          ),
        ),
      ),
    );
    // La evidencia anterior a la última reasignación pertenece al ciclo previo.
    DateTime? reasignadaEn;
    for (final e in eventos) {
      if (e.tipo == TipoEvento.reasignada.valor &&
          (reasignadaEn == null || e.createdAtDevice.isAfter(reasignadaEn))) {
        reasignadaEn = e.createdAtDevice;
      }
    }

    final evidencias =
        await (_db.select(_db.evidencias)
              ..where((v) => v.tareaId.equals(tareaId))
              ..orderBy([(v) => OrderingTerm.asc(v.createdAtDevice)]))
            .get();
    return DetalleTarea(
      tarea: tarea,
      unidad: unidad,
      items: items,
      evidencias: [
        for (final v in evidencias)
          if (reasignadaEn == null || v.createdAtDevice.isAfter(reasignadaEn))
            v,
      ],
      qrVerificado: ciclo.any((e) => e.tipo == TipoEvento.qrVerificado),
    );
  }

  // ---------------------------------------------------------------------------
  // Acciones del trabajador
  // ---------------------------------------------------------------------------

  /// HU-007 c1: se registra INICIADA.
  Future<void> iniciar(String tareaId, {required String usuarioId}) async {
    final detalle = await _abierta(tareaId);
    if (detalle.estado == EstadoTarea.iniciada) return;
    await _db.registrarAccion(
      Accion(
        eventos: [
          nuevoEvento(
            tareaId: tareaId,
            usuarioId: usuarioId,
            tipo: TipoEvento.iniciada,
            ahora: _reloj(),
          ),
        ],
      ),
    );
  }

  /// HU-007 c1: ITEM_COMPLETADO con el valor. Si la labor no estaba
  /// iniciada, se inicia en la misma transacción (decisión D22).
  Future<void> completarItem(
    String tareaId,
    String itemId,
    String? valor, {
    required String usuarioId,
  }) async {
    final detalle = await _abierta(tareaId);
    final item = detalle.items.firstWhere((i) => i.id == itemId);
    final tipo = TipoRespuesta.desdeValor(item.tipoRespuesta);
    final motivo = validarValorItem(tipo, valor);
    if (motivo != null) throw AccionRechazada(motivo);

    final ahora = _reloj();
    await _db.registrarAccion(
      Accion(
        eventos: [
          ..._inicioSiHaceFalta(detalle, usuarioId, ahora),
          nuevoEvento(
            tareaId: tareaId,
            usuarioId: usuarioId,
            tipo: TipoEvento.itemCompletado,
            payload: {
              'item_id': itemId,
              'valor': normalizarValorItem(tipo, valor),
            },
            ahora: ahora,
          ),
        ],
      ),
    );
  }

  /// HU-009: compara la lectura con el código de la unidad asignada, en el
  /// dispositivo (c3). Solo si coincide se registra QR_VERIFICADO (c1); si
  /// no, se devuelve el resultado y no se registra nada (c2).
  Future<ResultadoQr> verificarQr(
    String tareaId,
    String leido, {
    required String usuarioId,
  }) async {
    final detalle = await _abierta(tareaId);
    final unidades = await _db.select(_db.unidadesProductivas).get();
    final resultado = compararQr(
      leido: leido,
      esperado: detalle.unidad.codigoQr,
      nombresPorCodigo: {for (final u in unidades) u.codigoQr: u.nombre},
    );
    if (resultado is! QrCoincide) return resultado;

    final ahora = _reloj();
    await _db.registrarAccion(
      Accion(
        eventos: [
          ..._inicioSiHaceFalta(detalle, usuarioId, ahora),
          nuevoEvento(
            tareaId: tareaId,
            usuarioId: usuarioId,
            tipo: TipoEvento.qrVerificado,
            payload: {'codigo_qr': detalle.unidad.codigoQr},
            ahora: ahora,
          ),
        ],
      ),
    );
    return resultado;
  }

  /// HU-008 c1 y c3: la fila de evidencia, el evento EVIDENCIA_ADJUNTA y la
  /// subida del archivo a la cola de multimedia, en una sola transacción.
  Future<void> adjuntarEvidencia(
    String tareaId,
    ArchivoEvidencia archivo, {
    required String usuarioId,
  }) async {
    final detalle = await _abierta(tareaId);
    final ahora = _reloj();
    final rutaRemota = archivo.rutaRemota(tareaId);
    await _db.registrarAccion(
      Accion(
        cambios: [
          CambioEntidad(
            _db.evidencias,
            Evidencia(
              id: archivo.id,
              tareaId: tareaId,
              usuarioId: usuarioId,
              tipo: archivo.tipo.valor,
              rutaLocal: archivo.rutaLocal,
              rutaRemota: rutaRemota,
              tamanioBytes: archivo.tamanioBytes,
              hashSha256: archivo.hashSha256,
              createdAtDevice: ahora,
            ),
          ),
        ],
        eventos: [
          ..._inicioSiHaceFalta(detalle, usuarioId, ahora),
          nuevoEvento(
            tareaId: tareaId,
            usuarioId: usuarioId,
            tipo: TipoEvento.evidenciaAdjunta,
            payload: {'evidencia_id': archivo.id, 'tipo': archivo.tipo.valor},
            ahora: ahora,
          ),
        ],
        subidas: [
          SubidaArchivo(
            evidenciaId: archivo.id,
            rutaLocal: archivo.rutaLocal,
            rutaRemota: rutaRemota,
            tipoContenido: archivo.tipo.tipoContenido,
            hashSha256: archivo.hashSha256,
          ),
        ],
      ),
    );
  }

  /// HU-007 c2: solo se cierra como completada si no falta nada.
  Future<void> cerrarCompletada(
    String tareaId, {
    required String usuarioId,
  }) async {
    final detalle = await _abierta(tareaId);
    final cierre = detalle.validarCierreActual();
    if (!cierre.puedeCompletar) {
      throw AccionRechazada(
        'Todavía no se puede cerrar como completada.',
        faltantes: cierre.faltantes,
      );
    }
    final ahora = _reloj();
    await _db.registrarAccion(
      Accion(
        eventos: [
          ..._inicioSiHaceFalta(detalle, usuarioId, ahora),
          nuevoEvento(
            tareaId: tareaId,
            usuarioId: usuarioId,
            tipo: TipoEvento.completada,
            ahora: ahora,
          ),
        ],
      ),
    );
  }

  /// HU-007 c2: cierre como NO_COMPLETADA con el motivo por texto o por audio
  /// (el audio ya adjuntado como evidencia).
  Future<void> cerrarNoCompletada(
    String tareaId, {
    required String usuarioId,
    String? motivo,
    String? motivoAudioId,
  }) async {
    await _abierta(tareaId);
    final texto = motivo?.trim() ?? '';
    if (texto.isEmpty && motivoAudioId == null) {
      throw const AccionRechazada(
        'Contá el motivo: grabá un audio o escribilo.',
      );
    }
    await _db.registrarAccion(
      Accion(
        eventos: [
          nuevoEvento(
            tareaId: tareaId,
            usuarioId: usuarioId,
            tipo: TipoEvento.noCompletada,
            payload: {
              if (texto.isNotEmpty) 'motivo': texto,
              'motivo_audio_id': ?motivoAudioId,
            },
            ahora: _reloj(),
          ),
        ],
      ),
    );
  }

  Future<DetalleTarea> _abierta(String tareaId) async {
    final detalle = await leerDetalle(tareaId);
    if (detalle == null) throw const AccionRechazada('La labor no existe.');
    if (!detalle.admiteEjecucion) {
      throw const AccionRechazada('Esta labor ya está cerrada.');
    }
    return detalle;
  }

  List<Evento> _inicioSiHaceFalta(
    DetalleTarea detalle,
    String usuarioId,
    DateTime ahora,
  ) => detalle.estado == EstadoTarea.asignada
      ? [
          nuevoEvento(
            tareaId: detalle.tarea.id,
            usuarioId: usuarioId,
            tipo: TipoEvento.iniciada,
            ahora: ahora,
          ),
        ]
      : const [];
}
