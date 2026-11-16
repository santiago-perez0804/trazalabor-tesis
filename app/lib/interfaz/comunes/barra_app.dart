import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../control_sincronizacion.dart';
import '../proveedores.dart';
import '../tema.dart';
import 'indicador_conexion.dart';

/// "Sábado 7 de noviembre", para el subtítulo de las pantallas de inicio.
String fechaLarga(DateTime fecha) {
  final t = DateFormat("EEEE d 'de' MMMM", 'es').format(fecha);
  return t[0].toUpperCase() + t.substring(1);
}

/// Barra superior de la Figura 5: título, subtítulo opcional y, debajo, la
/// franja permanente de conexión y envío (decisión D34).
class BarraApp extends StatelessWidget implements PreferredSizeWidget {
  const BarraApp({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.acciones = const [],
    this.inferior,
    this.conFranja = true,
  });

  final String titulo;
  final String? subtitulo;
  final List<Widget> acciones;

  /// Pestañas u otro contenido que va entre la barra y la franja.
  final PreferredSizeWidget? inferior;
  final bool conFranja;

  static const _altoBarra = 64.0;

  @override
  Size get preferredSize => Size.fromHeight(
    _altoBarra +
        (inferior?.preferredSize.height ?? 0) +
        (conFranja ? FranjaConexion.alto : 0),
  );

  @override
  Widget build(BuildContext context) {
    final abajo = [?inferior, if (conFranja) const FranjaConexion()];
    return AppBar(
      toolbarHeight: _altoBarra,
      titleSpacing: Navigator.of(context).canPop() ? 0 : 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitulo != null)
            Text(
              subtitulo!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFFE2ECE5),
              ),
            ),
        ],
      ),
      actions: acciones,
      bottom: abajo.isEmpty
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(preferredSize.height - _altoBarra),
              child: Column(children: abajo),
            ),
    );
  }
}

/// Franja de estado bajo la barra (Figura 5): con o sin señal y cuánto queda
/// por enviar. Al tocarla se abre "Para enviar" (pantalla H).
class FranjaConexion extends ConsumerWidget {
  const FranjaConexion({super.key});

  static const alto = 36.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enLinea = ref.watch(hayConexionProvider).value ?? false;
    final grupos = ref.watch(porEnviarProvider).value ?? const [];
    final cosas = grupos.fold<int>(0, (s, g) => s + g.tarjetas);
    final enviando = ref.watch(controlSincronizacionProvider).sincronizando;

    final texto = switch ((enLinea, cosas)) {
      (false, 0) => 'Sin señal · se guarda en el teléfono',
      (false, 1) => 'Sin señal · 1 cosa guardada',
      (false, _) => 'Sin señal · $cosas cosas guardadas',
      (true, 0) => 'Con señal · todo enviado',
      _ when enviando => 'Con señal · enviando…',
      (true, 1) => 'Con señal · 1 cosa para enviar',
      (true, _) => 'Con señal · $cosas cosas para enviar',
    };
    final color = enLinea
        ? ColoresTrazaLabor.verdeCampo
        : ColoresTrazaLabor.pendiente;
    final puedeAbrir = GoRouter.maybeOf(context) != null;

    return Material(
      color: enLinea
          ? ColoresTrazaLabor.franjaConSenal
          : ColoresTrazaLabor.franjaSinSenal,
      child: InkWell(
        onTap: puedeAbrir ? () => context.push('/envios') : null,
        child: Semantics(
          liveRegion: true,
          button: puedeAbrir,
          child: SizedBox(
            height: alto,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Icon(
                    enLinea ? Icons.wifi : Icons.wifi_off,
                    size: 18,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      texto,
                      key: const ValueKey('franja-conexion'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  if (cosas > 0 && puedeAbrir)
                    Icon(Icons.chevron_right, size: 20, color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
