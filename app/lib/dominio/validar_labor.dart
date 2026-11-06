import 'catalogos.dart';
import 'plantillas_labor.dart';
import 'validar_cierre.dart';

/// Datos de la pantalla "Nueva labor" (pantalla A de la Figura 5).
class BorradorLabor {
  const BorradorLabor({
    this.unidadProductivaId,
    this.asignadoId,
    this.tipoLabor,
    this.fechaProgramada,
    this.descripcion = '',
    this.items = const [],
    this.evidencia = EvidenciaRequerida.ninguna,
    this.requiereQr = false,
  });

  final String? unidadProductivaId;
  final String? asignadoId;
  final TipoLabor? tipoLabor;
  final DateTime? fechaProgramada;
  final String descripcion;
  final List<ItemBorrador> items;
  final EvidenciaRequerida evidencia;
  final bool requiereQr;
}

/// HU-005 c3: si falta un dato obligatorio no se puede confirmar, y se indica
/// cuál falta. Devuelve los faltantes en lenguaje llano; vacío si está completo.
List<String> validarLabor(BorradorLabor b) {
  final faltantes = <String>[];
  if (b.unidadProductivaId == null) faltantes.add('Elegí la unidad productiva.');
  if (b.asignadoId == null) faltantes.add('Elegí el trabajador.');
  if (b.tipoLabor == null) faltantes.add('Elegí el tipo de labor.');
  if (b.fechaProgramada == null) faltantes.add('Elegí la fecha.');

  final items = b.items;
  if (items.isEmpty) {
    faltantes.add('Agregá al menos un ítem a la lista de verificación.');
  }
  for (var i = 0; i < items.length; i++) {
    if (items[i].descripcion.trim().isEmpty) {
      faltantes.add('Escribí el ítem ${i + 1} de la lista o quitalo.');
    }
  }

  // HU-005 c2: la aplicación fitosanitaria lleva sus cuatro ítems obligatorios.
  if (b.tipoLabor == TipoLabor.aplicacionFitosanitaria) {
    for (final requerido in itemsFitosanitarios) {
      final esta = items.any((i) =>
          i.descripcion == requerido.descripcion && i.obligatorio);
      if (!esta) {
        faltantes.add('Falta el ítem obligatorio: ${requerido.descripcion}.');
      }
    }
  }
  return faltantes;
}

/// `fecha_programada` como texto 'AAAA-MM-DD' (decisión D7).
String fechaComoTexto(DateTime fecha) =>
    '${fecha.year.toString().padLeft(4, '0')}-'
    '${fecha.month.toString().padLeft(2, '0')}-'
    '${fecha.day.toString().padLeft(2, '0')}';
