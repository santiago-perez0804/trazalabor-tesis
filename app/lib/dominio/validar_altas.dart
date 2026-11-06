/// Validaciones de los formularios del encargado (HU-002, HU-003).
/// Devuelven un mapa campo → motivo; vacío si está todo bien.
library;

import 'pin.dart';

Map<String, String> validarTrabajador({
  required String nombre,
  required String telefono,
}) {
  final errores = <String, String>{};
  if (nombre.trim().length < 2) {
    errores['nombre'] = 'Escribí el nombre y apellido.';
  }
  final motivoTelefono = validarTelefono(telefono);
  if (motivoTelefono != null) errores['telefono'] = motivoTelefono;
  return errores;
}

Map<String, String> validarUnidad({
  required String nombre,
  required String? tipo,
  required String superficie,
}) {
  final errores = <String, String>{};
  if (nombre.trim().isEmpty) {
    errores['nombre'] = 'Escribí el nombre de la unidad (por ejemplo, Lote 7).';
  }
  if (tipo == null) errores['tipo'] = 'Elegí el tipo de unidad.';
  final ha = leerDecimal(superficie);
  if (ha == null || ha <= 0) {
    errores['superficie'] = 'Escribí la superficie en hectáreas (por ejemplo, 12,5).';
  }
  return errores;
}

/// Lee un número escrito como se acostumbra en Argentina ("12,5") o con punto.
double? leerDecimal(String texto) =>
    double.tryParse(texto.trim().replaceAll(',', '.'));
