/// Ítem de la lista de verificación, tal como lo necesita la regla de cierre.
class ItemDominio {
  const ItemDominio({
    required this.descripcion,
    required this.obligatorio,
    required this.completado,
  });

  final String descripcion;
  final bool obligatorio;
  final bool completado;
}

enum EvidenciaRequerida {
  ninguna('NINGUNA'),
  foto('FOTO'),
  audio('AUDIO'),
  fotoYAudio('FOTO_Y_AUDIO');

  const EvidenciaRequerida(this.valor);

  final String valor;

  bool get pideFoto => this == foto || this == fotoYAudio;
  bool get pideAudio => this == audio || this == fotoYAudio;

  static EvidenciaRequerida desdeValor(String valor) =>
      EvidenciaRequerida.values.firstWhere((e) => e.valor == valor);
}

/// Resultado de validar si una labor puede cerrarse como COMPLETADA.
class ResultadoCierre {
  const ResultadoCierre(this.faltantes);

  /// Mensajes en lenguaje llano de lo que falta (HU-007 c2).
  final List<String> faltantes;

  bool get puedeCompletar => faltantes.isEmpty;
}

/// HU-007 criterio 2: no se puede cerrar como completada si faltan ítems
/// obligatorios, la evidencia requerida o la verificación por QR. En ese caso
/// solo queda cerrar como NO_COMPLETADA con motivo.
ResultadoCierre validarCierre({
  required Iterable<ItemDominio> items,
  required EvidenciaRequerida evidenciaRequerida,
  required bool requiereQr,
  required int fotos,
  required int audios,
  required bool qrVerificado,
}) {
  final faltantes = <String>[];

  for (final item in items) {
    if (item.obligatorio && !item.completado) {
      faltantes.add('Falta completar: ${item.descripcion}');
    }
  }
  if (evidenciaRequerida.pideFoto && fotos == 0) {
    faltantes.add('Falta sacar una foto');
  }
  if (evidenciaRequerida.pideAudio && audios == 0) {
    faltantes.add('Falta grabar un audio');
  }
  if (requiereQr && !qrVerificado) {
    faltantes.add('Falta escanear el código QR del lugar');
  }
  return ResultadoCierre(faltantes);
}
