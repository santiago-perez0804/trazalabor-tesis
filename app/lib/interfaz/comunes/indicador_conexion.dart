import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tema.dart';

/// Estado de la red del dispositivo. Solo indica si hay una interfaz de red
/// activa; el motor de sincronización confirma el acceso real al servidor.
final hayConexionProvider = StreamProvider<bool>((ref) async* {
  final conectividad = Connectivity();
  bool conectado(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);

  yield conectado(await conectividad.checkConnectivity());
  yield* conectividad.onConnectivityChanged.map(conectado);
});

/// Indicador permanente del estado de conexión (criterio de diseño de la
/// tesis, "Prototipos de interfaces"). Se muestra en todas las pantallas.
class IndicadorConexion extends ConsumerWidget {
  const IndicadorConexion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enLinea = ref.watch(hayConexionProvider).value ?? false;
    final color =
        enLinea ? ColoresTrazaLabor.enLinea : ColoresTrazaLabor.sinConexion;

    return Semantics(
      liveRegion: true,
      label: enLinea ? 'En línea' : 'Sin conexión',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enLinea ? Icons.cloud_done : Icons.cloud_off,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              enLinea ? 'En línea' : 'Sin conexión',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
