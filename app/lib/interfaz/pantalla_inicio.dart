import 'package:flutter/material.dart';

import 'comunes/indicador_conexion.dart';

/// Pantalla inicial provisoria. Se reemplaza por el inicio de sesión y la
/// navegación por rol (HU-001).
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrazaLabor')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Trazabilidad de labores rurales con operación sin conexión',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Spacer(),
            Align(alignment: Alignment.centerRight, child: IndicadorConexion()),
          ],
        ),
      ),
    );
  }
}
