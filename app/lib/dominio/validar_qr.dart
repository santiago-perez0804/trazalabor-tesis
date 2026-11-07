/// Verificación de presencia con el código QR de la unidad (HU-009).
library;

/// Prefijo del texto codificado en el QR de cada unidad (decisión D18).
const prefijoQr = 'TRAZALABOR:UP:';

sealed class ResultadoQr {
  const ResultadoQr();
}

/// El código leído es el de la unidad asignada (HU-009 c1).
class QrCoincide extends ResultadoQr {
  const QrCoincide();
}

/// Es el código de otra unidad del establecimiento (HU-009 c2).
class QrDeOtraUnidad extends ResultadoQr {
  const QrDeOtraUnidad(this.nombre);

  /// Nombre de la unidad leída, si está en el teléfono.
  final String? nombre;
}

/// No es un código de TrazaLabor (otro QR cualquiera).
class QrAjeno extends ResultadoQr {
  const QrAjeno();
}

/// Compara la lectura con el código esperado. Se resuelve en el dispositivo,
/// sin conexión (HU-009 c3). [nombresPorCodigo] permite decir qué unidad se
/// escaneó por error.
ResultadoQr compararQr({
  required String leido,
  required String esperado,
  Map<String, String> nombresPorCodigo = const {},
}) {
  final codigo = leido.trim();
  if (codigo == esperado) return const QrCoincide();
  if (!codigo.startsWith(prefijoQr)) return const QrAjeno();
  return QrDeOtraUnidad(nombresPorCodigo[codigo]);
}

/// Mensaje en lenguaje llano para lo que no coincide.
String explicarQr(ResultadoQr r, {required String unidadEsperada}) =>
    switch (r) {
      QrCoincide() => 'Código verificado: $unidadEsperada.',
      QrDeOtraUnidad(:final nombre) =>
        nombre == null
            ? 'Ese código es de otra unidad, no de $unidadEsperada. '
                  'Buscá el cartel de $unidadEsperada.'
            : 'Ese código es de $nombre, no de $unidadEsperada. '
                  'Buscá el cartel de $unidadEsperada.',
      QrAjeno() =>
        'Ese código no es de TrazaLabor. Buscá el cartel de $unidadEsperada.',
    };
