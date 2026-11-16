import 'package:drift/drift.dart';

import '../repositorio/base_datos.dart';
import 'servidor.dart';

/// Resultado de una pasada de envío.
class ResultadoEnvio {
  const ResultadoEnvio({required this.enviadas, this.error});

  final int enviadas;

  /// Motivo del fallo que detuvo el envío, o `null` si salió todo.
  final String? error;

  bool get completo => error == null;
}

/// Envía la bandeja de salida (`operacion_pendiente`) al servidor (HU-011 c1 y
/// c2, T-24):
/// - en el orden en que se registraron;
/// - con upsert por `id`, así reenviar algo ya recibido no lo duplica;
/// - cada operación pasa a ENVIADO solo cuando el servidor confirma;
/// - ante el primer fallo se detiene: lo que sigue puede depender de esa
///   operación (por ejemplo, un evento de una tarea que todavía no llegó).
///
/// Los archivos (`SUBIDA`) no pasan por acá: van por la cola de multimedia,
/// que nunca frena a los eventos (HU-011 c3).
class MotorEnvio {
  MotorEnvio(this._db, this._servidor);

  final BaseDatos _db;
  final Servidor _servidor;

  /// Tablas sin modificación desde el cliente: un id repetido se ignora
  /// (bitácora de solo adición y altas que hace una sola vez el encargado).
  static const _soloAlta = {'evento', 'evidencia', 'tarea', 'item_checklist'};

  Future<ResultadoEnvio> enviar() async {
    final t = _db.operacionesPendientes;
    final pendientes =
        await (_db.select(t)
              ..where((o) => o.estado.isNotValue('ENVIADO'))
              ..where((o) => o.operacion.isNotValue('SUBIDA'))
              ..orderBy([
                (o) => OrderingTerm.asc(o.createdAtDevice),
                // Las operaciones de una misma acción comparten la hora: el orden
                // de inserción respeta las dependencias (tarea → ítems → eventos).
                (_) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
              ]))
            .get();

    var enviadas = 0;
    for (final op in pendientes) {
      try {
        await _servidor.upsert(
          op.entidad,
          op.payload,
          ignorarDuplicados: _soloAlta.contains(op.entidad),
        );
      } catch (e) {
        final motivo = _resumir(e);
        await (_db.update(t)..where((o) => o.id.equals(op.id))).write(
          OperacionesPendientesCompanion(
            estado: const Value('ERROR'),
            intentos: Value(op.intentos + 1),
            ultimoError: Value(motivo),
          ),
        );
        return ResultadoEnvio(enviadas: enviadas, error: motivo);
      }
      await (_db.update(t)..where((o) => o.id.equals(op.id))).write(
        const OperacionesPendientesCompanion(
          estado: Value('ENVIADO'),
          ultimoError: Value(null),
        ),
      );
      enviadas++;
    }
    return ResultadoEnvio(enviadas: enviadas);
  }
}

/// Texto corto del error para `ultimo_error` (registro de errores, T-24).
String _resumir(Object e) {
  final texto = e.toString();
  return texto.length > 300 ? texto.substring(0, 300) : texto;
}
