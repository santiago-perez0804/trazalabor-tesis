import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../infra/almacen_seguro.dart';
import '../infra/avisos.dart';
import '../infra/supabase_config.dart';
import '../repositorio/base_datos.dart';
import '../repositorio/repositorio_sesion.dart';
import 'servidor_supabase.dart';
import 'sincronizador.dart';

/// Sincronización en segundo plano con workmanager (HU-011 c1, T-23).
///
/// - Una tarea periódica (cada 15 minutos, lo mínimo de Android) que solo
///   corre con red.
/// - Una tarea única que se programa al perder la señal y corre apenas
///   vuelve, aunque la app esté cerrada.
abstract final class SegundoPlano {
  static const _tarea = 'sincronizar';

  static Future<void> registrar() async {
    await Workmanager().initialize(despachadorSegundoPlano);
    await Workmanager().registerPeriodicTask(
      'sincronizacion-periodica',
      _tarea,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  /// Se llama al quedarse sin conexión con cosas por enviar.
  static Future<void> alVolverLaSenal() => Workmanager().registerOneOffTask(
    'sincronizacion-al-volver',
    _tarea,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

/// Punto de entrada del isolate de workmanager: ahí no existe nada de la app,
/// así que se abren de nuevo Drift (compartida entre isolates) y Supabase.
@pragma('vm:entry-point')
void despachadorSegundoPlano() {
  Workmanager().executeTask((_, _) async {
    if (!ConfigSupabase.configurado) return true;
    const almacen = AlmacenSeguro();
    final autenticador = await inicializarSupabase(almacen);
    final db = abrirBaseDatos();
    try {
      // Solo se sincroniza lo del usuario con sesión abierta en el teléfono.
      final perfil = await RepositorioSesion(
        remoto: autenticador,
        almacen: almacen,
        db: db,
      ).perfilRecordado();
      if (perfil == null) return true;
      final r = await Sincronizador(
        db,
        ServidorSupabase(Supabase.instance.client),
        avisar: Avisos.nuevaLabor,
      ).sincronizar(usuarioId: perfil.id, authIdEsperado: perfil.authId);
      // Si falló por la red, workmanager lo reintenta más tarde.
      return r.correcta || r.sinSesionRemota;
    } catch (_) {
      return false;
    } finally {
      await db.close();
    }
  });
}
