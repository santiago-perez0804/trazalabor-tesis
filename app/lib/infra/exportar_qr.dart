import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Genera la imagen del código QR de una unidad productiva, apta para
/// imprimir (HU-003 c2, T-11): fondo blanco, el código y debajo el nombre.
Future<List<int>> imagenQrImprimible({
  required String codigo,
  required String nombre,
  required String detalle,
}) async {
  const ancho = 1200.0;
  const margen = 100.0;
  const ladoQr = ancho - 2 * margen;
  const alto = ancho + 260;

  final grabador = ui.PictureRecorder();
  final lienzo = Canvas(grabador)
    ..drawRect(const Rect.fromLTWH(0, 0, ancho, alto),
        Paint()..color = const Color(0xFFFFFFFF));

  // Corrección de errores alta: el código se sigue leyendo aunque la
  // etiqueta impresa se manche o se raye a la intemperie.
  final qr = QrPainter(
    data: codigo,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
    gapless: true,
  );
  lienzo
    ..save()
    ..translate(margen, margen);
  qr.paint(lienzo, const Size(ladoQr, ladoQr));
  lienzo.restore();

  void texto(String contenido, double y, double tamanio, FontWeight peso) {
    final pintor = TextPainter(
      text: TextSpan(
        text: contenido,
        style: TextStyle(
            color: const Color(0xFF000000), fontSize: tamanio, fontWeight: peso),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: ancho - 2 * margen);
    pintor.paint(lienzo, Offset((ancho - pintor.width) / 2, y));
  }

  texto(nombre, ancho + 10, 84, FontWeight.w700);
  texto(detalle, ancho + 120, 52, FontWeight.w400);

  final imagen =
      await grabador.endRecording().toImage(ancho.toInt(), alto.toInt());
  final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
  return datos!.buffer.asUint8List();
}

/// Guarda la imagen en el directorio temporal y abre el menú de compartir del
/// sistema (imprimir, guardar en archivos, enviar por mensajería).
Future<void> compartirQr({
  required String codigo,
  required String nombre,
  required String detalle,
}) async {
  final bytes =
      await imagenQrImprimible(codigo: codigo, nombre: nombre, detalle: detalle);
  final carpeta = await getTemporaryDirectory();
  final seguro = nombre.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
  final archivo = File('${carpeta.path}/QR_$seguro.png');
  await archivo.writeAsBytes(bytes, flush: true);
  await SharePlus.instance.share(ShareParams(
    files: [XFile(archivo.path, mimeType: 'image/png')],
    title: 'Código QR de $nombre',
    text: 'Código QR de $nombre para imprimir',
  ));
}
