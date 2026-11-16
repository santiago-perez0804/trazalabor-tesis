import 'dart:typed_data';

/// Lo que la sincronización necesita del servidor central. Es una interfaz
/// para poder probar el motor con cortes de conexión simulados (T-31) sin
/// depender de Supabase.
abstract interface class Servidor {
  /// `auth_id` del usuario autenticado en el servidor, o `null` si no hay
  /// sesión remota.
  String? get authIdActual;

  /// Alta idempotente por `id` (invariante 7). Con [ignorarDuplicados] un id
  /// existente no se toca (eventos, evidencia); si no, se actualiza.
  Future<void> upsert(
    String tabla,
    Map<String, Object?> fila, {
    required bool ignorarDuplicados,
  });

  /// Filas de [tabla] con `received_at_server` posterior a [recibidoDesde]
  /// (todas si es `null`), o las que tienen [columna] en [valores].
  Future<List<Map<String, dynamic>>> leer(
    String tabla, {
    DateTime? recibidoDesde,
    String? columna,
    List<String>? valores,
  });

  /// Sube un archivo con una dirección prefirmada de validez temporal (T-25).
  /// Si el archivo ya estaba subido (reintento), no es un error.
  Future<void> subirArchivo(String ruta, Uint8List bytes, String tipoContenido);

  Future<Uint8List> bajarArchivo(String ruta);
}
