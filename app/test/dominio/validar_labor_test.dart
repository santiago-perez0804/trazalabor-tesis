import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/plantillas_labor.dart';
import 'package:trazalabor/dominio/validar_altas.dart';
import 'package:trazalabor/dominio/validar_labor.dart';

void main() {
  BorradorLabor completa({
    TipoLabor tipo = TipoLabor.general,
    List<ItemBorrador>? items,
  }) =>
      BorradorLabor(
        unidadProductivaId: 'up-1',
        asignadoId: 'u-1',
        tipoLabor: tipo,
        fechaProgramada: DateTime(2026, 11, 6),
        items: items ?? plantillaPara(tipo).items,
      );

  group('plantillas (T-14)', () {
    test('aplicación fitosanitaria: producto, dosis, lote y clima obligatorios (HU-005 c2)',
        () {
      final p = plantillaPara(TipoLabor.aplicacionFitosanitaria);
      final textos = p.items.map((i) => i.descripcion.toLowerCase()).join(' | ');
      for (final palabra in ['producto', 'dosis', 'lote', 'meteorológicas']) {
        expect(textos, contains(palabra));
      }
      expect(p.items.every((i) => i.obligatorio && i.fijo), isTrue);
      expect(p.items.firstWhere((i) => i.descripcion.startsWith('Dosis')).tipoRespuesta,
          TipoRespuesta.numero);
    });

    test('todos los tipos de labor tienen al menos un ítem', () {
      for (final t in TipoLabor.values) {
        expect(plantillaPara(t).items, isNotEmpty, reason: t.valor);
      }
    });

    test('un ítem fijo no se puede volver opcional', () {
      final fijo = itemsFitosanitarios.first.copiarCon(obligatorio: false);
      expect(fijo.obligatorio, isTrue);
    });
  });

  group('validarLabor (HU-005 c3)', () {
    test('una labor completa no tiene faltantes', () {
      for (final t in TipoLabor.values) {
        expect(validarLabor(completa(tipo: t)), isEmpty, reason: t.valor);
      }
    });

    test('indica cada campo faltante', () {
      final f = validarLabor(const BorradorLabor());
      expect(f, contains('Elegí la unidad productiva.'));
      expect(f, contains('Elegí el trabajador.'));
      expect(f, contains('Elegí el tipo de labor.'));
      expect(f, contains('Elegí la fecha.'));
      expect(f, contains('Agregá al menos un ítem a la lista de verificación.'));
    });

    test('un ítem sin texto se señala por su número', () {
      final f = validarLabor(completa(items: const [
        ItemBorrador(descripcion: 'Revisar alambrado'),
        ItemBorrador(descripcion: '  '),
      ]));
      expect(f, ['Escribí el ítem 2 de la lista o quitalo.']);
    });

    test('fitosanitaria sin uno de sus ítems obligatorios no se puede confirmar',
        () {
      final sinClima = itemsFitosanitarios.take(3).toList();
      final f = validarLabor(
          completa(tipo: TipoLabor.aplicacionFitosanitaria, items: sinClima));
      expect(f.single, startsWith('Falta el ítem obligatorio: Condiciones'));
    });
  });

  group('altas', () {
    test('trabajador: nombre y teléfono', () {
      expect(validarTrabajador(nombre: 'Juan P.', telefono: '351 000-0002'), isEmpty);
      final e = validarTrabajador(nombre: ' ', telefono: '123');
      expect(e.keys, containsAll(['nombre', 'telefono']));
    });

    test('unidad: superficie con coma decimal', () {
      expect(
          validarUnidad(nombre: 'Lote 7', tipo: 'LOTE', superficie: '12,5'), isEmpty);
      expect(leerDecimal('12,5'), 12.5);
      final e = validarUnidad(nombre: '', tipo: null, superficie: 'mucho');
      expect(e.keys, containsAll(['nombre', 'tipo', 'superficie']));
      expect(validarUnidad(nombre: 'X', tipo: 'LOTE', superficie: '0'),
          contains('superficie'));
    });
  });

  test('la fecha se guarda como AAAA-MM-DD', () {
    expect(fechaComoTexto(DateTime(2026, 11, 6, 23, 59)), '2026-11-06');
  });
}
