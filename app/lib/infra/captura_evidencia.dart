import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../dominio/archivo_evidencia.dart';

const _uuid = Uuid();

/// Carpeta local de la evidencia de una tarea:
/// `<documentos>/evidencias/<tarea_id>/` (decisión D25).
Future<Directory> _carpeta(String tareaId) async {
  final docs = await getApplicationDocumentsDirectory();
  return Directory('${docs.path}/evidencias/$tareaId').create(recursive: true);
}

/// Huella SHA-256 del archivo (T-19), fuera del hilo de la interfaz.
Future<String> huellaSha256(String ruta) => Isolate.run(
  () async => sha256.convert(await File(ruta).readAsBytes()).toString(),
);

Future<ArchivoEvidencia> _registrar(
  String id,
  TipoEvidencia tipo,
  File archivo,
) async {
  return ArchivoEvidencia(
    id: id,
    tipo: tipo,
    rutaLocal: archivo.path,
    tamanioBytes: await archivo.length(),
    hashSha256: await huellaSha256(archivo.path),
  );
}

/// HU-008 c1 (T-18): saca la foto con la cámara, la comprime a JPEG
/// (lado mayor ~1280 px, calidad 70) y la guarda en el teléfono.
/// Devuelve `null` si el trabajador cancela.
Future<ArchivoEvidencia?> tomarFoto(String tareaId) async {
  final original = await ImagePicker().pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.rear,
  );
  if (original == null) return null;

  final id = _uuid.v4();
  final destino =
      '${(await _carpeta(tareaId)).path}/$id.${TipoEvidencia.foto.extension}';
  final comprimida = await FlutterImageCompress.compressAndGetFile(
    original.path,
    destino,
    minWidth: 1280,
    minHeight: 1280,
    quality: 70,
  );
  // Si la compresión falla se conserva la foto original, copiada al destino.
  final archivo = comprimida == null
      ? await File(original.path).copy(destino)
      : File(comprimida.path);
  try {
    await File(original.path).delete();
  } catch (_) {
    // El archivo temporal de la cámara puede no existir ya.
  }
  return _registrar(id, TipoEvidencia.foto, archivo);
}

/// Grabación de audio (HU-008 c2): AAC mono de bajo bitrate, liviano para
/// enviar con poca señal.
class GrabadorAudio {
  final _grabador = AudioRecorder();
  String? _id;
  String? _ruta;

  bool get grabando => _ruta != null;

  /// Devuelve `false` si no hay permiso de micrófono.
  Future<bool> empezar(String tareaId) async {
    if (!await _grabador.hasPermission()) return false;
    _id = _uuid.v4();
    _ruta =
        '${(await _carpeta(tareaId)).path}/$_id.${TipoEvidencia.audio.extension}';
    await _grabador.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 32000,
        sampleRate: 22050,
        numChannels: 1,
      ),
      path: _ruta!,
    );
    return true;
  }

  Future<ArchivoEvidencia?> terminar() async {
    final ruta = await _grabador.stop();
    final id = _id;
    _id = null;
    _ruta = null;
    if (ruta == null || id == null) return null;
    return _registrar(id, TipoEvidencia.audio, File(ruta));
  }

  Future<void> cancelar() async {
    await _grabador.cancel();
    _id = null;
    _ruta = null;
  }

  Future<void> dispose() => _grabador.dispose();
}
