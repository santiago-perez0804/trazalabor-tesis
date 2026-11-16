import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../dominio/catalogos.dart';
import '../../infra/exportar_qr.dart';
import '../../repositorio/base_datos.dart';
import '../comunes/barra_app.dart';
import '../proveedores.dart';
import '../tema.dart';

/// "Lotes y lugares" (pantalla G de la Figura 5, HU-003, T-10, T-11):
/// unidades productivas con su código QR listo para imprimir.
class PantallaUnidades extends ConsumerWidget {
  const PantallaUnidades({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidades = ref.watch(unidadesProvider).value ?? const [];
    final destacada = unidades.where((u) => u.activa).firstOrNull;
    return Scaffold(
      appBar: const BarraApp(
        titulo: 'Lotes y lugares',
        subtitulo: 'Unidades productivas y sus códigos QR',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (unidades.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Todavía no hay lotes ni lugares cargados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          if (destacada != null) _TarjetaQr(destacada),
          for (final u in unidades)
            if (u != destacada) _FilaUnidad(u),
          const SizedBox(height: 8),
          const Text(
            'Pegá cada código en la entrada del lugar. El trabajador lo '
            'escanea al llegar.',
            style: TextStyle(
              fontSize: 15,
              color: ColoresTrazaLabor.textoSecundario,
            ),
          ),
          const SizedBox(height: 16),
          _BotonPunteado(
            key: const ValueKey('boton-agregar-unidad'),
            texto: 'Agregar lote o lugar',
            onTap: () => context.push('/encargado/unidades/nueva'),
          ),
        ],
      ),
    );
  }
}

String _detalle(UnidadProductiva u) => [
  TipoUnidad.desdeValor(u.tipo).etiqueta,
  if (u.superficieHa != null) '${formatearHectareas(u.superficieHa!)} ha',
  if (!u.activa) 'Desactivada',
].join(' · ');

Future<void> _imprimir(UnidadProductiva u) =>
    compartirQr(codigo: u.codigoQr, nombre: u.nombre, detalle: _detalle(u));

/// La primera unidad, con su código QR a la vista y el botón "Imprimir".
class _TarjetaQr extends StatelessWidget {
  const _TarjetaQr(this.u);
  final UnidadProductiva u;

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: ColoresTrazaLabor.verdeCampo, width: 2.5),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/encargado/unidades/${u.id}'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ColoresTrazaLabor.borde),
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: u.codigoQr,
                size: 112,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(_detalle(u), style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () => _imprimir(u),
                    icon: const Icon(Icons.print_outlined, size: 20),
                    label: const Text('Imprimir'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FilaUnidad extends StatelessWidget {
  const _FilaUnidad(this.u);
  final UnidadProductiva u;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/encargado/unidades/${u.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _detalle(u),
                    style: TextStyle(
                      fontSize: 15,
                      color: u.activa
                          ? ColoresTrazaLabor.textoSecundario
                          : ColoresTrazaLabor.sinConexion,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.outlined(
              tooltip: 'Imprimir el código QR',
              onPressed: () => _imprimir(u),
              icon: const Icon(Icons.qr_code_2),
              style: IconButton.styleFrom(
                minimumSize: const Size(52, 52),
                foregroundColor: ColoresTrazaLabor.verdeCampo,
                side: const BorderSide(
                  color: ColoresTrazaLabor.verdeCampo,
                  width: 1.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Botón con borde punteado para agregar ("+ Agregar lote o lugar").
class _BotonPunteado extends StatelessWidget {
  const _BotonPunteado({super.key, required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BordePunteado(),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: ColoresTrazaLabor.verdeCampo),
            const SizedBox(width: 8),
            Text(
              texto,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ColoresTrazaLabor.verdeCampo,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BordePunteado extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = ColoresTrazaLabor.verdeCampo
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final camino = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      );
    for (final m in camino.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 12) {
        canvas.drawPath(m.extractPath(d, d + 7), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 12.5 → "12,5"; 40.0 → "40".
String formatearHectareas(double ha) {
  final texto = ha == ha.roundToDouble()
      ? ha.toStringAsFixed(0)
      : ha.toString();
  return texto.replaceAll('.', ',');
}
