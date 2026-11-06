import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../comunes/barra_sesion.dart';

/// Inicio del encargado. Las secciones se habilitan a medida que se
/// implementan sus historias (HU-002, HU-003, HU-005, HU-012, HU-013).
class PantallaInicioEncargado extends StatelessWidget {
  const PantallaInicioEncargado({super.key});

  @override
  Widget build(BuildContext context) {
    const secciones = [
      (Icons.add_task, 'Nueva labor', 'Asignar una labor con su lista',
          '/encargado/labores/nueva'),
      (Icons.people_alt_outlined, 'Trabajadores', 'Altas, cambios y PIN',
          '/encargado/trabajadores'),
      (Icons.grid_view, 'Unidades productivas', 'Lotes, potreros y sus QR',
          '/encargado/unidades'),
      (Icons.fact_check_outlined, 'Verificación e historial', 'Próximamente',
          null),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encargado'),
        actions: const [BotonSalir()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const EncabezadoSesion(),
          const SizedBox(height: 20),
          for (final (icono, titulo, detalle, ruta) in secciones)
            Card(
              child: ListTile(
                minTileHeight: 72,
                leading: Icon(icono, size: 30),
                title: Text(titulo, style: const TextStyle(fontSize: 18)),
                subtitle: Text(detalle, style: const TextStyle(fontSize: 15)),
                trailing: ruta == null ? null : const Icon(Icons.chevron_right),
                enabled: ruta != null,
                onTap: ruta == null ? null : () => context.push(ruta),
              ),
            ),
        ],
      ),
    );
  }
}
