import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/validar_cierre.dart';

void main() {
  const producto = ItemDominio(
    descripcion: 'Producto aplicado',
    obligatorio: true,
    completado: true,
  );
  const dosis = ItemDominio(
    descripcion: 'Dosis (l/ha)',
    obligatorio: true,
    completado: false,
  );
  const opcional = ItemDominio(
    descripcion: 'Registrar temperatura',
    obligatorio: false,
    completado: false,
  );

  test('con todo completo se puede cerrar como COMPLETADA', () {
    final r = validarCierre(
      items: const [producto, opcional],
      evidenciaRequerida: EvidenciaRequerida.fotoYAudio,
      requiereQr: true,
      fotos: 1,
      audios: 1,
      qrVerificado: true,
    );
    expect(r.puedeCompletar, isTrue);
  });

  test('un ítem obligatorio sin completar impide completar (HU-007 c2)', () {
    final r = validarCierre(
      items: const [producto, dosis],
      evidenciaRequerida: EvidenciaRequerida.ninguna,
      requiereQr: false,
      fotos: 0,
      audios: 0,
      qrVerificado: false,
    );
    expect(r.puedeCompletar, isFalse);
    expect(r.faltantes, ['Falta completar: Dosis (l/ha)']);
  });

  test('FOTO_Y_AUDIO exige ambas evidencias', () {
    final r = validarCierre(
      items: const [producto],
      evidenciaRequerida: EvidenciaRequerida.fotoYAudio,
      requiereQr: false,
      fotos: 1,
      audios: 0,
      qrVerificado: false,
    );
    expect(r.faltantes, ['Falta grabar un audio']);
  });

  test('si requiere QR y no se verificó, no se puede completar', () {
    final r = validarCierre(
      items: const [producto],
      evidenciaRequerida: EvidenciaRequerida.ninguna,
      requiereQr: true,
      fotos: 0,
      audios: 0,
      qrVerificado: false,
    );
    expect(r.faltantes, ['Falta escanear el código QR del lugar']);
  });

  test('EvidenciaRequerida se lee desde el texto de la tesis', () {
    expect(EvidenciaRequerida.desdeValor('FOTO_Y_AUDIO'),
        EvidenciaRequerida.fotoYAudio);
    expect(EvidenciaRequerida.foto.pideAudio, isFalse);
  });
}
