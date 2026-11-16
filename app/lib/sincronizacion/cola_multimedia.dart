import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../repositorio/base_datos.dart';
import 'servidor.dart';

/// Resultado de una pasada de la cola de multimedia.
class ResultadoSubidas {
  const ResultadoSubidas({required this.subidas, required this.fallidas});
  final int subidas;
  final int fallidas;
}

/// Cola separada para fotos y audios (decisión D4, HU-011 c3, T-25). Corre
/// después del envío de eventos y nunca lo bloquea: si un archivo falla, se
/// reintenta en la próxima pasada y se sigue con el siguiente.
class ColaMultimedia {
  ColaMultimedia(this._db, this._servidor);

  final BaseDatos _db;
  final Servidor _servidor;

  Future<ResultadoSubidas> procesar() async {
    final t = _db.operacionesPendientes;
    final subidas =
        await (_db.select(t)
              ..where((o) => o.estado.isNotValue('ENVIADO'))
              ..where((o) => o.operacion.equals('SUBIDA'))
              ..orderBy([(o) => OrderingTerm.asc(o.createdAtDevice)]))
            .get();

    var ok = 0;
    var fallidas = 0;
    for (final op in subidas) {
      try {
        await _subir(op);
      } catch (e) {
        fallidas++;
        await (_db.update(t)..where((o) => o.id.equals(op.id))).write(
          OperacionesPendientesCompanion(
            estado: const Value('ERROR'),
            intentos: Value(op.intentos + 1),
            ultimoError: Value(e.toString()),
          ),
        );
        continue;
      }
      ok++;
      await (_db.update(t)..where((o) => o.id.equals(op.id))).write(
        const OperacionesPendientesCompanion(
          estado: Value('ENVIADO'),
          ultimoError: Value(null),
        ),
      );
    }
    return ResultadoSubidas(subidas: ok, fallidas: fallidas);
  }

  Future<void> _subir(OperacionPendiente op) async {
    final p = op.payload;
    final bytes = await File(p['ruta_local']! as String).readAsBytes();
    // Integridad: el archivo tiene que ser el mismo que se registró.
    final huella = sha256.convert(bytes).toString();
    if (huella != p['hash_sha256']) {
      throw StateError(
        'El archivo cambió desde que se registró (huella distinta).',
      );
    }
    await _servidor.subirArchivo(
      p['ruta_remota']! as String,
      bytes,
      p['tipo_contenido']! as String,
    );
  }
}
