import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proveedores.dart';
import '../tema.dart';
import 'indicador_conexion.dart';

/// Encabezado común de las pantallas con sesión: saludo, estado de conexión y,
/// si se ingresó sin señal, el aviso de que lo registrado se enviará después.
class EncabezadoSesion extends ConsumerWidget {
  const EncabezadoSesion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionProvider);
    if (sesion is! ConSesion) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Hola, ${sesion.perfil.nombreCorto}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            const IndicadorConexion(),
          ],
        ),
        if (sesion.sinConexion)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Entraste sin conexión. Lo que registres queda guardado en el teléfono '
              'y se envía cuando haya señal.',
              style: TextStyle(fontSize: 15, color: ColoresTrazaLabor.pendiente),
            ),
          ),
      ],
    );
  }
}

/// Botón de cerrar sesión para la barra superior.
class BotonSalir extends ConsumerWidget {
  const BotonSalir({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        tooltip: 'Cerrar sesión',
        icon: const Icon(Icons.logout),
        onPressed: () => ref.read(sesionProvider.notifier).salir(),
      );
}
