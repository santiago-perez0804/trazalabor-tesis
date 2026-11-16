import 'tipo_evento.dart';

/// Reglas de la verificación del encargado (HU-012). Devuelven el motivo del
/// rechazo, o `null` si la acción es válida.

/// c2: solo se aprueba una labor cerrada como completada.
String? motivoNoAprobable(EstadoTarea estado) => switch (estado) {
  EstadoTarea.completada => null,
  EstadoTarea.verificada => 'La labor ya está verificada.',
  EstadoTarea.noCompletada =>
    'Quedó no completada: reasignala para que se vuelva a hacer.',
  _ => 'La labor todavía no se cerró.',
};

/// c3: se reasigna una labor cerrada que no es conforme o quedó NO_COMPLETADA.
String? motivoNoReasignable(
  EstadoTarea estado, {
  required String? nuevoTrabajadorId,
  required String motivo,
}) {
  if (estado != EstadoTarea.completada && estado != EstadoTarea.noCompletada) {
    return estado == EstadoTarea.verificada
        ? 'La labor ya está verificada.'
        : 'La labor todavía no se cerró.';
  }
  if (nuevoTrabajadorId == null) return 'Elegí a quién se la reasignás.';
  if (motivo.trim().isEmpty) return 'Escribí el motivo de la reasignación.';
  return null;
}

/// Etiqueta llana de cada evento para la cronología (pantalla E).
String etiquetaEvento(TipoEvento tipo) => switch (tipo) {
  TipoEvento.creada => 'Creada',
  TipoEvento.asignada => 'Asignada',
  TipoEvento.iniciada => 'Iniciada',
  TipoEvento.itemCompletado => 'Ítem completado',
  TipoEvento.qrVerificado => 'QR verificado',
  TipoEvento.evidenciaAdjunta => 'Evidencia adjunta',
  TipoEvento.completada => 'Completada',
  TipoEvento.noCompletada => 'No completada',
  TipoEvento.verificada => 'Verificada',
  TipoEvento.reasignada => 'Reasignada',
};

/// Etiqueta del estado de una labor para listas e historial.
String etiquetaEstado(EstadoTarea estado) => switch (estado) {
  EstadoTarea.creada => 'Creada',
  EstadoTarea.asignada => 'Por hacer',
  EstadoTarea.iniciada => 'Empezada',
  EstadoTarea.completada => 'Terminada, falta tu revisión',
  EstadoTarea.noCompletada => 'No terminada, falta tu revisión',
  EstadoTarea.verificada => 'Aprobada',
};

/// Frase llana de un evento para "Qué pasó" (pantalla E de la Figura 5):
/// "Empezó la labor", "Leyó el código QR del Lote 7", "Cargó Dosis: 1,5".
/// [item] y [persona] traducen ids a nombres; si no se conocen, se omiten.
String fraseEvento({
  required TipoEvento tipo,
  required Map<String, Object?> payload,
  required String unidad,
  String? Function(String id)? item,
  String? Function(String id)? persona,
}) {
  String? nombre(Object? id) => id is String ? persona?.call(id) : null;
  switch (tipo) {
    case TipoEvento.creada:
      return 'Creó la labor';
    case TipoEvento.asignada:
      final a = nombre(payload['asignado_id']);
      return a == null ? 'Asignó la labor' : 'Se la asignó a $a';
    case TipoEvento.iniciada:
      return 'Empezó la labor';
    case TipoEvento.itemCompletado:
      final id = payload['item_id'];
      final desc = (id is String ? item?.call(id) : null) ?? 'un ítem';
      final valor = payload['valor']?.toString();
      if (valor == null || valor == 'SI') return 'Marcó: $desc';
      final numero = RegExp(r'^-?\d+(\.\d+)?$').hasMatch(valor);
      return 'Cargó $desc: ${numero ? valor.replaceAll('.', ',') : valor}';
    case TipoEvento.qrVerificado:
      return 'Leyó el código QR de $unidad';
    case TipoEvento.evidenciaAdjunta:
      return payload['tipo'] == 'AUDIO' ? 'Grabó un audio' : 'Sacó una foto';
    case TipoEvento.completada:
      return 'Terminó la labor';
    case TipoEvento.noCompletada:
      final m = payload['motivo'];
      return m is String && m.isNotEmpty
          ? 'No pudo terminar: $m'
          : 'No pudo terminar (contó el motivo en un audio)';
    case TipoEvento.verificada:
      return 'Aprobó la labor';
    case TipoEvento.reasignada:
      final a = nombre(payload['nuevo_asignado_id']);
      final m = payload['motivo'];
      return [
        a == null ? 'Reasignó la labor' : 'Se la reasignó a $a',
        if (m is String && m.isNotEmpty) m,
      ].join(': ');
  }
}
