import 'package:drift/drift.dart';

/// Serializa filas de Drift al formato que espera PostgREST:
/// fechas en UTC ISO-8601 (con `Z`), así `timestamptz` no depende de la
/// zona horaria de la sesión de Postgres.
class SerializadorPostgrest extends ValueSerializer {
  const SerializadorPostgrest();

  static const _base =
      ValueSerializer.defaults(serializeDateTimeValuesAsString: true);

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    return _base.toJson<T>(value);
  }

  @override
  T fromJson<T>(dynamic json) => _base.fromJson<T>(json);
}
