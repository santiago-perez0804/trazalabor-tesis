import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proveedores.dart';

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
