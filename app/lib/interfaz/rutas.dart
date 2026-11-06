import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'encargado/pantalla_inicio_encargado.dart';
import 'ingreso/pantalla_ingreso.dart';
import 'proveedores.dart';
import 'trabajador/pantalla_inicio_trabajador.dart';

/// Navegación por rol: cada perfil solo llega a sus pantallas
/// (la misma regla se aplica en la base con RLS).
final routerProvider = Provider<GoRouter>((ref) {
  final aviso = ValueNotifier<int>(0);
  ref.listen(sesionProvider, (_, _) => aviso.value++);
  ref.onDispose(aviso.dispose);

  return GoRouter(
    initialLocation: '/ingreso',
    refreshListenable: aviso,
    redirect: (context, estado) {
      final ruta = estado.matchedLocation;
      switch (ref.read(sesionProvider)) {
        case SinSesion():
          return ruta == '/ingreso' ? null : '/ingreso';
        case ConSesion(:final perfil):
          final inicio = perfil.esEncargado ? '/encargado' : '/trabajador';
          return ruta.startsWith(inicio) ? null : inicio;
      }
    },
    routes: [
      GoRoute(path: '/ingreso', builder: (_, _) => const PantallaIngreso()),
      GoRoute(
          path: '/encargado',
          builder: (_, _) => const PantallaInicioEncargado()),
      GoRoute(
          path: '/trabajador',
          builder: (_, _) => const PantallaInicioTrabajador()),
    ],
  );
});
