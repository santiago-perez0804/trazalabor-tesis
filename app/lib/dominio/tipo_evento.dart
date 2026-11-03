/// Tipos de evento de la bitácora (Tabla 14, entidad Evento).
/// Los nombres son exactamente los de la tesis: se guardan como texto.
enum TipoEvento {
  creada('CREADA'),
  asignada('ASIGNADA'),
  iniciada('INICIADA'),
  itemCompletado('ITEM_COMPLETADO'),
  qrVerificado('QR_VERIFICADO'),
  evidenciaAdjunta('EVIDENCIA_ADJUNTA'),
  completada('COMPLETADA'),
  noCompletada('NO_COMPLETADA'),
  verificada('VERIFICADA'),
  reasignada('REASIGNADA');

  const TipoEvento(this.valor);

  /// Texto almacenado en la columna `evento.tipo`.
  final String valor;

  static TipoEvento desdeValor(String valor) => TipoEvento.values.firstWhere(
        (t) => t.valor == valor,
        orElse: () => throw ArgumentError('Tipo de evento desconocido: $valor'),
      );
}

/// Estado de una tarea, derivado de la secuencia de eventos.
/// `tarea.estado_actual` guarda el `valor` como proyección.
enum EstadoTarea {
  creada('CREADA'),
  asignada('ASIGNADA'),
  iniciada('INICIADA'),
  completada('COMPLETADA'),
  noCompletada('NO_COMPLETADA'),
  verificada('VERIFICADA');

  const EstadoTarea(this.valor);

  final String valor;

  static EstadoTarea desdeValor(String valor) => EstadoTarea.values.firstWhere(
        (e) => e.valor == valor,
        orElse: () => throw ArgumentError('Estado desconocido: $valor'),
      );
}
