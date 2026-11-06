/// Bloqueo temporal por PIN incorrecto (HU-001 c2): cinco intentos fallidos
/// consecutivos bloquean el acceso durante quince minutos. Funciona también
/// sin conexión porque se evalúa en el dispositivo.
class ControlIntentos {
  const ControlIntentos({this.fallos = 0, this.bloqueadoHasta});

  static const maximoFallos = 5;
  static const duracionBloqueo = Duration(minutes: 15);

  final int fallos;
  final DateTime? bloqueadoHasta;

  bool estaBloqueado(DateTime ahora) =>
      bloqueadoHasta != null && ahora.isBefore(bloqueadoHasta!);

  /// Minutos que faltan para desbloquear (redondeado hacia arriba).
  int minutosRestantes(DateTime ahora) {
    if (!estaBloqueado(ahora)) return 0;
    final segundos = bloqueadoHasta!.difference(ahora).inSeconds;
    return (segundos / 60).ceil();
  }

  ControlIntentos registrarFallo(DateTime ahora) {
    // Si el bloqueo anterior ya venció, se empieza a contar de nuevo.
    final previos = bloqueadoHasta != null && !estaBloqueado(ahora) ? 0 : fallos;
    final total = previos + 1;
    return total >= maximoFallos
        ? ControlIntentos(fallos: 0, bloqueadoHasta: ahora.add(duracionBloqueo))
        : ControlIntentos(fallos: total);
  }

  ControlIntentos registrarExito() => const ControlIntentos();

  Map<String, Object?> aJson() => {
        'fallos': fallos,
        'bloqueado_hasta': bloqueadoHasta?.toUtc().toIso8601String(),
      };

  factory ControlIntentos.desdeJson(Map<String, Object?> json) =>
      ControlIntentos(
        fallos: (json['fallos'] as num?)?.toInt() ?? 0,
        bloqueadoHasta: json['bloqueado_hasta'] == null
            ? null
            : DateTime.parse(json['bloqueado_hasta']! as String),
      );
}
