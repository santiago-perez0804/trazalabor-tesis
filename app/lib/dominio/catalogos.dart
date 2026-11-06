/// Valores fijos de la Tabla 14 con su nombre para mostrar en pantalla
/// (decisión D8 en docs/trazabilidad.md: se guardan en mayúsculas).
library;

/// `unidad_productiva.tipo`: lote, potrero o instalación.
enum TipoUnidad {
  lote('LOTE', 'Lote'),
  potrero('POTRERO', 'Potrero'),
  instalacion('INSTALACION', 'Instalación');

  const TipoUnidad(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static TipoUnidad desdeValor(String valor) =>
      TipoUnidad.values.firstWhere((t) => t.valor == valor);
}

/// `tarea.tipo_labor`.
enum TipoLabor {
  general('GENERAL', 'General'),
  siembra('SIEMBRA', 'Siembra'),
  aplicacionFitosanitaria('APLICACION_FITOSANITARIA', 'Aplicación fitosanitaria'),
  sanidadAnimal('SANIDAD_ANIMAL', 'Sanidad animal'),
  mantenimiento('MANTENIMIENTO', 'Mantenimiento');

  const TipoLabor(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static TipoLabor desdeValor(String valor) =>
      TipoLabor.values.firstWhere((t) => t.valor == valor);
}

/// `item_checklist.tipo_respuesta`.
enum TipoRespuesta {
  check('CHECK', 'Tildar'),
  numero('NUMERO', 'Número'),
  texto('TEXTO', 'Texto');

  const TipoRespuesta(this.valor, this.etiqueta);

  final String valor;
  final String etiqueta;

  static TipoRespuesta desdeValor(String valor) =>
      TipoRespuesta.values.firstWhere((t) => t.valor == valor);
}

/// Puestos sugeridos para `usuario.especialidad` (Tabla 14). Es texto libre:
/// estas opciones solo agilizan la carga.
const especialidadesSugeridas = ['Peón general', 'Tambero', 'Tractorista'];
