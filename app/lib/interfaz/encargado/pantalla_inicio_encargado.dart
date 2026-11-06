import 'package:flutter/material.dart';

import '../comunes/barra_sesion.dart';

/// Inicio del encargado. Las secciones se habilitan a medida que se
/// implementan sus historias (HU-002, HU-003, HU-005, HU-012, HU-013).
class PantallaInicioEncargado extends StatelessWidget {
  const PantallaInicioEncargado({super.key});

  @override
  Widget build(BuildContext context) {
    const secciones = [
      (Icons.people_alt_outlined, 'Trabajadores'),
      (Icons.grid_view, 'Unidades productivas'),
      (Icons.add_task, 'Nueva labor'),
      (Icons.fact_check_outlined, 'Verificación e historial'),
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
          for (final (icono, titulo) in secciones)
            Card(
              child: ListTile(
                minTileHeight: 64,
                leading: Icon(icono, size: 30),
                title: Text(titulo, style: const TextStyle(fontSize: 18)),
                subtitle: const Text('Próximamente'),
                enabled: false,
              ),
            ),
        ],
      ),
    );
  }
}
