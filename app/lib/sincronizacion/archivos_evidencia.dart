import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../repositorio/base_datos.dart';
import 'servidor.dart';

/// Trae al teléfono del encargado las fotos y audios de una labor para
/// verificarla (HU-012 c1, decisión D30). Al recibir cada archivo se
/// verifica su huella SHA-256 contra la registrada por el trabajador.
class ArchivosEvidencia {
  ArchivosEvidencia(this._db, this._servidor, this._carpetaBase);

  final BaseDatos _db;
  final Servidor? _servidor;

  /// Devuelve la carpeta de documentos de la app (`path_provider`).
  final Future<String> Function() _carpetaBase;

  /// Ruta local del archivo, bajándolo si hace falta. `null` si todavía no
  /// está disponible (sin conexión o aún no subido por el trabajador).
  /// Lanza [StateError] si la huella no coincide.
  Future<String?> rutaLocal(Evidencia v) async {
    final actual = v.rutaLocal;
    if (actual != null && await File(actual).exists()) return actual;
    final servidor = _servidor;
    final remota = v.rutaRemota;
    if (servidor == null || remota == null) return null;

    final Uint8List bytes;
    try {
      bytes = await servidor.bajarArchivo(remota);
    } catch (_) {
      return null;
    }
    if (sha256.convert(bytes).toString() != v.hashSha256) {
      throw StateError('El archivo recibido no coincide con su huella.');
    }
    final archivo = File('${await _carpetaBase()}/evidencias/$remota');
    await archivo.parent.create(recursive: true);
    await archivo.writeAsBytes(bytes, flush: true);
    // `ruta_local` es solo del dispositivo: no se encola ni viaja al servidor.
    await (_db.update(_db.evidencias)..where((e) => e.id.equals(v.id))).write(
      EvidenciasCompanion(rutaLocal: Value(archivo.path)),
    );
    return archivo.path;
  }
}
