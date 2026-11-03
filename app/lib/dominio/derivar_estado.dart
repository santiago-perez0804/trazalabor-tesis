import 'tipo_evento.dart';

/// Evento mínimo que necesita el dominio para derivar el estado.
/// Se mantiene desacoplado de Drift: la capa de repositorio lo construye.
class EventoDominio {
  const EventoDominio({
    required this.tipo,
    required this.creadoEnDispositivo,
    this.payload = const {},
  });

  final TipoEvento tipo;
  final DateTime creadoEnDispositivo;
  final Map<String, dynamic> payload;
}

/// Etapa del ciclo de vida: desempata eventos con la misma hora del
/// dispositivo (p. ej. CREADA y ASIGNADA se registran juntas).
/// La función SQL `rango_evento()` usa exactamente los mismos valores.
int rangoEvento(TipoEvento tipo) => switch (tipo) {
      TipoEvento.creada => 0,
      TipoEvento.asignada => 1,
      TipoEvento.iniciada => 2,
      TipoEvento.itemCompletado ||
      TipoEvento.qrVerificado ||
      TipoEvento.evidenciaAdjunta =>
        3,
      TipoEvento.completada || TipoEvento.noCompletada => 4,
      TipoEvento.verificada || TipoEvento.reasignada => 5,
    };

/// Orden canónico de la bitácora: hora del dispositivo y, a igual hora,
/// etapa del ciclo. El ordenamiento de Dart es estable.
List<EventoDominio> ordenarEventos(Iterable<EventoDominio> eventos) =>
    eventos.toList()
      ..sort((a, b) {
        final porHora = a.creadoEnDispositivo.compareTo(b.creadoEnDispositivo);
        return porHora != 0
            ? porHora
            : rangoEvento(a.tipo).compareTo(rangoEvento(b.tipo));
      });

/// Deriva el estado de una tarea a partir de su secuencia de eventos
/// (event sourcing: el estado vigente sale de la secuencia completa).
///
/// - Los eventos se ordenan con [ordenarEventos].
/// - `ITEM_COMPLETADO`, `QR_VERIFICADO` y `EVIDENCIA_ADJUNTA` no cambian el
///   estado: son hechos dentro de la ejecución.
/// - `REASIGNADA` reinicia el ciclo: la tarea vuelve a `ASIGNADA`.
/// - Sin eventos de estado, la tarea figura como `CREADA`.
EstadoTarea derivarEstado(Iterable<EventoDominio> eventos) {
  var estado = EstadoTarea.creada;
  for (final e in ordenarEventos(eventos)) {
    switch (e.tipo) {
      case TipoEvento.creada:
        estado = EstadoTarea.creada;
      case TipoEvento.asignada:
      case TipoEvento.reasignada:
        estado = EstadoTarea.asignada;
      case TipoEvento.iniciada:
        estado = EstadoTarea.iniciada;
      case TipoEvento.completada:
        estado = EstadoTarea.completada;
      case TipoEvento.noCompletada:
        estado = EstadoTarea.noCompletada;
      case TipoEvento.verificada:
        estado = EstadoTarea.verificada;
      case TipoEvento.itemCompletado:
      case TipoEvento.qrVerificado:
      case TipoEvento.evidenciaAdjunta:
        break;
    }
  }
  return estado;
}

/// Eventos posteriores al último `REASIGNADA`: los ítems y la evidencia se
/// proyectan solo con ellos, porque una reasignación reinicia la ejecución.
List<EventoDominio> eventosDelCicloVigente(Iterable<EventoDominio> eventos) {
  final ordenados = ordenarEventos(eventos);
  final ultima =
      ordenados.lastIndexWhere((e) => e.tipo == TipoEvento.reasignada);
  return ultima < 0 ? ordenados : ordenados.sublist(ultima + 1);
}
