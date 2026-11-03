import 'package:uuid/uuid.dart';

import '../dominio/tipo_evento.dart';
import 'base_datos.dart';

const _uuid = Uuid();

/// UUID v4 generado en el dispositivo (RFC 9562): permite crear registros sin
/// conexión y reenviarlos de forma idempotente.
String nuevoId() => _uuid.v4();

/// Construye un evento listo para `registrarAccion`. La hora es la del
/// dispositivo; `received_at_server` queda vacía hasta que la informe el servidor.
Evento nuevoEvento({
  required String tareaId,
  required String usuarioId,
  required TipoEvento tipo,
  Map<String, Object?> payload = const {},
  double? latitud,
  double? longitud,
  DateTime? ahora,
}) =>
    Evento(
      id: nuevoId(),
      tareaId: tareaId,
      usuarioId: usuarioId,
      tipo: tipo.valor,
      payload: payload,
      createdAtDevice: ahora ?? DateTime.now(),
      latitud: latitud,
      longitud: longitud,
    );
