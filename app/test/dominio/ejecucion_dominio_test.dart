import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/estado_bandeja.dart';
import 'package:trazalabor/dominio/tipo_evento.dart';
import 'package:trazalabor/dominio/validar_qr.dart';
import 'package:trazalabor/dominio/valor_item.dart';

void main() {
  group('QR (HU-009)', () {
    const lote7 = '${prefijoQr}lote-7';
    const potrero = '${prefijoQr}potrero-2';

    test('el código de la unidad asignada coincide (c1)', () {
      expect(compararQr(leido: ' $lote7 ', esperado: lote7), isA<QrCoincide>());
    });

    test('el de otra unidad se informa con su nombre y no coincide (c2)', () {
      final r = compararQr(
        leido: potrero,
        esperado: lote7,
        nombresPorCodigo: {potrero: 'Potrero 2'},
      );
      expect(r, isA<QrDeOtraUnidad>());
      expect(
        explicarQr(r, unidadEsperada: 'Lote 7'),
        'Ese código es de Potrero 2, no de Lote 7. Buscá el cartel de Lote 7.',
      );
    });

    test('un QR cualquiera no es de TrazaLabor', () {
      final r = compararQr(leido: 'https://ejemplo.com', esperado: lote7);
      expect(r, isA<QrAjeno>());
    });
  });

  group('respuesta de un ítem', () {
    test('número con coma decimal', () {
      expect(validarValorItem(TipoRespuesta.numero, '2,5'), isNull);
      expect(normalizarValorItem(TipoRespuesta.numero, '2,5'), '2.5');
      expect(validarValorItem(TipoRespuesta.numero, 'mucho'), isNotNull);
    });

    test('texto no vacío; tildar no pide valor', () {
      expect(validarValorItem(TipoRespuesta.texto, '  '), isNotNull);
      expect(
        normalizarValorItem(TipoRespuesta.texto, ' Glifosato '),
        'Glifosato',
      );
      expect(validarValorItem(TipoRespuesta.check, null), isNull);
      expect(normalizarValorItem(TipoRespuesta.check, null), 'SI');
    });
  });

  test('estado de la bandeja (pantalla B)', () {
    expect(
      estadoBandeja(EstadoTarea.asignada, porEnviar: true).etiqueta,
      'Por hacer · tocá para empezar',
    );
    expect(
      estadoBandeja(EstadoTarea.iniciada, porEnviar: true).etiqueta,
      'Empezada',
    );
    expect(
      estadoBandeja(EstadoTarea.completada, porEnviar: true).etiqueta,
      'Terminada · se envía con señal',
    );
    expect(
      estadoBandeja(EstadoTarea.completada, porEnviar: false).etiqueta,
      'Terminada · enviada',
    );
    expect(admiteEjecucion(EstadoTarea.completada), isFalse);
    expect(admiteEjecucion(EstadoTarea.iniciada), isTrue);
  });
}
