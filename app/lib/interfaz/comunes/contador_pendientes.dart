import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proveedores.dart';
import '../tema.dart';

/// Cantidad de operaciones guardadas en el teléfono que el servidor todavía
/// no confirmó (pantalla B de la Figura 5: "N operaciones pendientes").
/// Se muestra siempre, junto al indicador de conexión.
class ContadorPendientes extends ConsumerWidget {
  const ContadorPendientes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(pendientesProvider).value ?? 0;
    final (icono, texto, color) = n == 0
        ? (Icons.check_circle_outline, 'Todo enviado', ColoresTrazaLabor.enLinea)
        : (
            Icons.sync,
            n == 1
                ? '1 operación pendiente de envío'
                : '$n operaciones pendientes de envío',
            ColoresTrazaLabor.pendiente
          );
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(icono, size: 20, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(texto,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}
