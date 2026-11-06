import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../comunes/barra_sesion.dart';
import '../tema.dart';

/// "Mis tareas de hoy" (pantalla B de la Figura 5). La bandeja reactiva de
/// labores llega con HU-006.
class PantallaInicioTrabajador extends StatelessWidget {
  const PantallaInicioTrabajador({super.key});

  @override
  Widget build(BuildContext context) {
    final hoy = DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas de hoy'),
        actions: const [BotonSalir()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const EncabezadoSesion(),
          const SizedBox(height: 8),
          Text(hoy[0].toUpperCase() + hoy.substring(1),
              style: const TextStyle(
                  fontSize: 16, color: ColoresTrazaLabor.textoSecundario)),
          const SizedBox(height: 40),
          const Icon(Icons.inbox_outlined,
              size: 56, color: ColoresTrazaLabor.textoSecundario),
          const SizedBox(height: 12),
          const Text('No tenés labores asignadas para hoy.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
