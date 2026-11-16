import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'comunes/pantalla_envios.dart';
import 'encargado/formulario_trabajador.dart';
import 'encargado/formulario_unidad.dart';
import 'encargado/pantalla_detalle_labor.dart';
import 'encargado/pantalla_inicio_encargado.dart';
import 'encargado/pantalla_nueva_labor.dart';
import 'encargado/pantalla_trabajadores.dart';
import 'encargado/pantalla_unidades.dart';
import 'encargado/pantalla_verificacion.dart';
import 'ingreso/pantalla_ingreso.dart';
import 'proveedores.dart';
import 'trabajador/pantalla_cierre.dart';
import 'trabajador/pantalla_ejecucion.dart';
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
          // "Para enviar" (pantalla H) es de los dos roles.
          if (ruta == '/envios') return null;
          return ruta.startsWith(inicio) ? null : inicio;
      }
    },
    routes: [
      GoRoute(path: '/ingreso', builder: (_, _) => const PantallaIngreso()),
      GoRoute(path: '/envios', builder: (_, _) => const PantallaEnvios()),
      GoRoute(
        path: '/encargado',
        builder: (_, _) => const PantallaInicioEncargado(),
        routes: [
          GoRoute(
            path: 'trabajadores',
            builder: (_, _) => const PantallaTrabajadores(),
            routes: [
              GoRoute(
                path: 'nuevo',
                builder: (_, _) => const FormularioTrabajador(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, estado) =>
                    FormularioTrabajador(id: estado.pathParameters['id']),
              ),
            ],
          ),
          GoRoute(
            path: 'unidades',
            builder: (_, _) => const PantallaUnidades(),
            routes: [
              GoRoute(
                path: 'nueva',
                builder: (_, _) => const FormularioUnidad(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, estado) =>
                    FormularioUnidad(id: estado.pathParameters['id']),
              ),
            ],
          ),
          GoRoute(
            path: 'labores/nueva',
            builder: (_, _) => const PantallaNuevaLabor(),
          ),
          GoRoute(
            path: 'verificacion',
            builder: (_, estado) => PantallaVerificacion(
              pestanaInicial: estado.uri.queryParameters['historial'] == '1'
                  ? 1
                  : 0,
            ),
          ),
          GoRoute(
            path: 'labor/:id',
            builder: (_, estado) =>
                PantallaDetalleLabor(tareaId: estado.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/trabajador',
        builder: (_, _) => const PantallaInicioTrabajador(),
        routes: [
          GoRoute(
            path: 'tarea/:id',
            builder: (_, estado) =>
                PantallaEjecucion(tareaId: estado.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'cierre',
                builder: (_, estado) =>
                    PantallaCierre(tareaId: estado.pathParameters['id']!),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
