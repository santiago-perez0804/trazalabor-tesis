import 'catalogos.dart';
import 'validar_altas.dart';

/// Valida la respuesta de un ítem de la lista según su tipo (HU-007).
/// Devuelve el motivo del rechazo o `null` si es válida.
String? validarValorItem(TipoRespuesta tipo, String? valor) {
  final texto = valor?.trim() ?? '';
  return switch (tipo) {
    TipoRespuesta.check => null,
    TipoRespuesta.numero =>
      leerDecimal(texto) == null
          ? 'Escribí un número (por ejemplo, 2,5).'
          : null,
    TipoRespuesta.texto => texto.isEmpty ? 'Escribí la respuesta.' : null,
  };
}

/// Valor que se guarda en el evento: los números con punto decimal, el resto
/// tal cual. Un CHECK se guarda como "SI".
String normalizarValorItem(TipoRespuesta tipo, String? valor) => switch (tipo) {
  TipoRespuesta.check => 'SI',
  TipoRespuesta.numero => leerDecimal(valor ?? '')!.toString(),
  TipoRespuesta.texto => valor!.trim(),
};
