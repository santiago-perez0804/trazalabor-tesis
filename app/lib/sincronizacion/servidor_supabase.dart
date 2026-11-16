import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'servidor.dart';

/// [Servidor] sobre Supabase (PostgREST + Storage). Las políticas RLS del
/// servidor deciden qué puede enviar y leer cada rol.
class ServidorSupabase implements Servidor {
  ServidorSupabase(this._cliente);

  final SupabaseClient _cliente;
  static const _bucket = 'evidencias';
  static const _limite = Duration(seconds: 20);

  @override
  String? get authIdActual => _cliente.auth.currentUser?.id;

  @override
  Future<void> upsert(
    String tabla,
    Map<String, Object?> fila, {
    required bool ignorarDuplicados,
  }) => _cliente
      .from(tabla)
      .upsert(fila, onConflict: 'id', ignoreDuplicates: ignorarDuplicados)
      .timeout(_limite);

  @override
  Future<List<Map<String, dynamic>>> leer(
    String tabla, {
    DateTime? recibidoDesde,
    String? columna,
    List<String>? valores,
  }) async {
    var consulta = _cliente.from(tabla).select();
    if (recibidoDesde != null) {
      consulta = consulta.gte(
        'received_at_server',
        recibidoDesde.toUtc().toIso8601String(),
      );
    }
    if (columna != null && valores != null) {
      consulta = consulta.inFilter(columna, valores);
    }
    return await consulta.timeout(_limite);
  }

  @override
  Future<void> subirArchivo(
    String ruta,
    Uint8List bytes,
    String tipoContenido,
  ) async {
    final almacen = _cliente.storage.from(_bucket);
    try {
      final firmada = await almacen
          .createSignedUploadUrl(ruta)
          .timeout(_limite);
      await almacen
          .uploadBinaryToSignedUrl(
            firmada.path,
            firmada.token,
            bytes,
            FileOptions(contentType: tipoContenido),
          )
          .timeout(const Duration(minutes: 2));
    } on StorageException catch (e) {
      // Reintento de un archivo que ya llegó: cuenta como subido (HU-011 c2).
      if (_yaExiste(e)) return;
      rethrow;
    }
  }

  static bool _yaExiste(StorageException e) =>
      e.statusCode == '409' ||
      e.error == 'Duplicate' ||
      e.message.toLowerCase().contains('already exists');

  @override
  Future<Uint8List> bajarArchivo(String ruta) =>
      _cliente.storage.from(_bucket).download(ruta).timeout(_limite);
}
