import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../tema.dart';

/// Cámara a pantalla completa para leer el QR del lugar (HU-009, T-20).
/// La lectura es local: no necesita conexión. Devuelve el texto del primer
/// código leído, o `null` si el trabajador vuelve atrás.
class EscanerQr extends StatefulWidget {
  const EscanerQr({super.key, required this.unidad});

  /// Nombre de la unidad que se espera, para la indicación en pantalla.
  final String unidad;

  @override
  State<EscanerQr> createState() => _EscanerQrState();
}

class _EscanerQrState extends State<EscanerQr> {
  final _controlador = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _leido = false;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _alDetectar(BarcodeCapture captura) {
    if (_leido) return;
    final texto = captura.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (texto == null) return;
    _leido = true;
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear código del lugar'),
        actions: [
          IconButton(
            tooltip: 'Linterna',
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: _controlador.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controlador,
            onDetect: _alDetectar,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo abrir la cámara. Revisá que la aplicación '
                  'tenga permiso para usarla.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColoresTrazaLabor.verdeOscuro.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Apuntá al cartel de ${widget.unidad}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
