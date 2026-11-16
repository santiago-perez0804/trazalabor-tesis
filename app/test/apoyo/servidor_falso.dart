import 'dart:typed_data';

import 'package:trazalabor/sincronizacion/servidor.dart';

/// Servidor central simulado para las pruebas de sincronización (T-31):
/// tablas en memoria, `received_at_server` puesto por el "servidor" y cortes
/// de conexión a pedido.
class ServidorFalso implements Servidor {
  ServidorFalso({this.authIdActual = 'auth-1'});

  @override
  String? authIdActual;

  /// tabla → id → fila.
  final tablas = <String, Map<String, Map<String, Object?>>>{};
  final archivos = <String, Uint8List>{};

  /// Cantidad de llamadas que se aceptan, desde ahora, antes de "cortar la
  /// señal"; `null` = sin corte.
  int? get cortarDespuesDe => _corte;
  set cortarDespuesDe(int? n) {
    _corte = n;
    _llamadas = 0;
  }

  int? _corte;
  int _llamadas = 0;
  bool fallarArchivos = false;
  int upserts = 0;

  DateTime _reloj = DateTime.utc(2026, 11, 7, 10);

  void _red() {
    final limite = _corte;
    if (limite != null && _llamadas >= limite) {
      throw Exception('Sin conexión (simulado)');
    }
    _llamadas++;
  }

  /// Restablece la "señal".
  void reconectar() {
    cortarDespuesDe = null;
  }

  @override
  Future<void> upsert(
    String tabla,
    Map<String, Object?> fila, {
    required bool ignorarDuplicados,
  }) async {
    _red();
    upserts++;
    final t = tablas.putIfAbsent(tabla, () => {});
    final id = fila['id']! as String;
    if (t.containsKey(id) && ignorarDuplicados) return;
    _reloj = _reloj.add(const Duration(seconds: 1));
    t[id] = {
      ...fila,
      if (tabla != 'unidad_productiva' && tabla != 'item_checklist')
        'received_at_server': _reloj.toIso8601String(),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> leer(
    String tabla, {
    DateTime? recibidoDesde,
    String? columna,
    List<String>? valores,
  }) async {
    _red();
    return [
      for (final f in (tablas[tabla] ?? const {}).values)
        if ((recibidoDesde == null ||
                !DateTime.parse(f['received_at_server']! as String)
                    .isBefore(recibidoDesde)) &&
            (columna == null || valores!.contains(f[columna])))
          Map<String, dynamic>.from(f),
    ];
  }

  @override
  Future<void> subirArchivo(
    String ruta,
    Uint8List bytes,
    String tipoContenido,
  ) async {
    _red();
    if (fallarArchivos) throw Exception('Subida interrumpida (simulado)');
    archivos[ruta] = bytes;
  }

  @override
  Future<Uint8List> bajarArchivo(String ruta) async {
    _red();
    return archivos[ruta]!;
  }
}
