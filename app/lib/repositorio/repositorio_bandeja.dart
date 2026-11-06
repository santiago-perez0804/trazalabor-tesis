import 'package:drift/drift.dart';

import 'base_datos.dart';

/// Consultas sobre la bandeja de salida (`operacion_pendiente`).
class RepositorioBandeja {
  RepositorioBandeja(this._db);

  final BaseDatos _db;

  /// Operaciones que todavía no confirmó el servidor. Alimenta el contador
  /// siempre visible de la interfaz (decisión D21).
  Stream<int> observarPendientes() {
    final t = _db.operacionesPendientes;
    final cantidad = t.id.count();
    final consulta = _db.selectOnly(t)
      ..addColumns([cantidad])
      ..where(t.estado.equals('ENVIADO').not());
    return consulta.watchSingle().map((fila) => fila.read(cantidad) ?? 0);
  }
}
