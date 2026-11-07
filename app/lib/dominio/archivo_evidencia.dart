/// `evidencia.tipo`.
enum TipoEvidencia {
  foto('FOTO', 'jpg', 'image/jpeg'),
  audio('AUDIO', 'm4a', 'audio/mp4');

  const TipoEvidencia(this.valor, this.extension, this.tipoContenido);

  final String valor;
  final String extension;
  final String tipoContenido;

  static TipoEvidencia desdeValor(String valor) =>
      TipoEvidencia.values.firstWhere((t) => t.valor == valor);
}

/// Archivo ya comprimido y guardado en el teléfono, listo para registrarse
/// como evidencia (HU-008 c1).
class ArchivoEvidencia {
  const ArchivoEvidencia({
    required this.id,
    required this.tipo,
    required this.rutaLocal,
    required this.tamanioBytes,
    required this.hashSha256,
  });

  /// UUID de la evidencia; también nombra el archivo.
  final String id;
  final TipoEvidencia tipo;
  final String rutaLocal;
  final int tamanioBytes;

  /// Huella del archivo para verificar su integridad al recibirlo.
  final String hashSha256;

  /// Ruta de destino en el bucket `evidencias`: una carpeta por tarea, como
  /// exigen las políticas de Storage.
  String rutaRemota(String tareaId) => '$tareaId/$id.${tipo.extension}';
}
