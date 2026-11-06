import 'catalogos.dart';
import 'validar_cierre.dart';

/// Ítem de la lista de verificación mientras el encargado arma la labor.
class ItemBorrador {
  const ItemBorrador({
    required this.descripcion,
    this.tipoRespuesta = TipoRespuesta.check,
    this.obligatorio = true,
    this.fijo = false,
  });

  final String descripcion;
  final TipoRespuesta tipoRespuesta;
  final bool obligatorio;

  /// Exigido por la tesis para este tipo de labor: no se puede quitar ni
  /// volver opcional (HU-005 c2).
  final bool fijo;

  ItemBorrador copiarCon({
    String? descripcion,
    TipoRespuesta? tipoRespuesta,
    bool? obligatorio,
  }) =>
      ItemBorrador(
        descripcion: descripcion ?? this.descripcion,
        tipoRespuesta: tipoRespuesta ?? this.tipoRespuesta,
        obligatorio: fijo ? true : (obligatorio ?? this.obligatorio),
        fijo: fijo,
      );
}

/// Plantilla de un tipo de labor (T-14): ítems iniciales y requisitos sugeridos.
class PlantillaLabor {
  const PlantillaLabor({
    required this.items,
    this.evidencia = EvidenciaRequerida.ninguna,
    this.requiereQr = false,
  });

  final List<ItemBorrador> items;
  final EvidenciaRequerida evidencia;
  final bool requiereQr;
}

/// Ítems obligatorios de una aplicación fitosanitaria (HU-005 c2):
/// producto, dosis, lote y condiciones meteorológicas.
const itemsFitosanitarios = [
  ItemBorrador(
      descripcion: 'Producto aplicado',
      tipoRespuesta: TipoRespuesta.texto,
      fijo: true),
  ItemBorrador(
      descripcion: 'Dosis (litros o kilos por hectárea)',
      tipoRespuesta: TipoRespuesta.numero,
      fijo: true),
  ItemBorrador(
      descripcion: 'Lote del producto',
      tipoRespuesta: TipoRespuesta.texto,
      fijo: true),
  ItemBorrador(
      descripcion: 'Condiciones meteorológicas (viento, temperatura, humedad)',
      tipoRespuesta: TipoRespuesta.texto,
      fijo: true),
];

/// La tesis fija solo la plantilla fitosanitaria; las demás son sugerencias
/// editables (decisión D19 en docs/trazabilidad.md).
PlantillaLabor plantillaPara(TipoLabor tipo) => switch (tipo) {
      TipoLabor.aplicacionFitosanitaria => const PlantillaLabor(
          items: itemsFitosanitarios,
          evidencia: EvidenciaRequerida.foto,
          requiereQr: true,
        ),
      TipoLabor.siembra => const PlantillaLabor(
          items: [
            ItemBorrador(
                descripcion: 'Cultivo y variedad',
                tipoRespuesta: TipoRespuesta.texto),
            ItemBorrador(
                descripcion: 'Densidad de siembra (kilos por hectárea)',
                tipoRespuesta: TipoRespuesta.numero),
            ItemBorrador(
                descripcion: 'Hectáreas sembradas',
                tipoRespuesta: TipoRespuesta.numero,
                obligatorio: false),
          ],
          evidencia: EvidenciaRequerida.foto,
          requiereQr: true,
        ),
      TipoLabor.sanidadAnimal => const PlantillaLabor(
          items: [
            ItemBorrador(
                descripcion: 'Producto o vacuna',
                tipoRespuesta: TipoRespuesta.texto),
            ItemBorrador(
                descripcion: 'Cantidad de animales tratados',
                tipoRespuesta: TipoRespuesta.numero),
            ItemBorrador(
                descripcion: 'Lote del producto',
                tipoRespuesta: TipoRespuesta.texto,
                obligatorio: false),
          ],
          evidencia: EvidenciaRequerida.foto,
        ),
      TipoLabor.mantenimiento => const PlantillaLabor(
          items: [
            ItemBorrador(
                descripcion: 'Equipo o instalación revisada',
                tipoRespuesta: TipoRespuesta.texto),
            ItemBorrador(descripcion: 'Trabajo terminado'),
          ],
          evidencia: EvidenciaRequerida.foto,
        ),
      TipoLabor.general => const PlantillaLabor(
          items: [ItemBorrador(descripcion: 'Labor realizada')],
        ),
    };
