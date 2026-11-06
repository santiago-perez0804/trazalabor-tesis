/// Reglas de acceso de la sección Seguridad de la tesis.
library;

const longitudPin = 6;

/// Valida un PIN nuevo. Devuelve el motivo del rechazo o `null` si es válido.
///
/// - seis dígitos;
/// - no puede ser un único dígito repetido (111111);
/// - no puede ser una secuencia consecutiva ascendente o descendente
///   (123456, 654321, 345678…).
String? validarPinNuevo(String pin) {
  if (pin.length != longitudPin || !RegExp(r'^\d+$').hasMatch(pin)) {
    return 'El PIN tiene que tener $longitudPin números.';
  }
  final digitos = pin.codeUnits.map((c) => c - 48).toList();
  if (digitos.toSet().length == 1) {
    return 'No puede ser el mismo número repetido.';
  }
  bool consecutiva(int paso) {
    for (var i = 1; i < digitos.length; i++) {
      if (digitos[i] - digitos[i - 1] != paso) return false;
    }
    return true;
  }

  if (consecutiva(1) || consecutiva(-1)) {
    return 'No puede ser una serie de números seguidos.';
  }
  return null;
}

/// Deja solo los dígitos del teléfono: es la forma en que se guarda en
/// `usuario.telefono` y con la que se compara en el servidor.
String normalizarTelefono(String telefono) =>
    telefono.replaceAll(RegExp(r'\D'), '');

/// Validación mínima del teléfono ingresado (código de área + número).
String? validarTelefono(String telefono) {
  final digitos = normalizarTelefono(telefono);
  if (digitos.length < 8 || digitos.length > 15) {
    return 'Revisá el número: tiene que tener entre 8 y 15 dígitos.';
  }
  return null;
}

/// La cuenta de Supabase Auth se registra con un identificador derivado del
/// teléfono (el login por SMS requiere un proveedor pago). El PIN cumple la
/// función de contraseña.
String emailDesdeTelefono(String telefono) =>
    '${normalizarTelefono(telefono)}@trazalabor.local';
