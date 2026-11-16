import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path_provider/path_provider.dart';

import '../repositorio/base_datos.dart';
import '../sincronizacion/archivos_evidencia.dart';
import '../sincronizacion/segundo_plano.dart';
import '../sincronizacion/servidor.dart';
import '../sincronizacion/sincronizador.dart';
import 'comunes/indicador_conexion.dart';
import 'proveedores.dart';

/// Se inyecta desde `main()`. Sin override (pruebas, app sin credenciales) no
/// hay servidor y todo queda pendiente de envío.
final sincronizadorProvider = Provider<Sincronizador?>((ref) => null);
final servidorProvider = Provider<Servidor?>((ref) => null);

final archivosEvidenciaProvider = Provider<ArchivosEvidencia>(
  (ref) => ArchivosEvidencia(
    ref.watch(baseDatosProvider),
    ref.watch(servidorProvider),
    () async => (await getApplicationDocumentsDirectory()).path,
  ),
);

/// Ruta local de una foto o audio; en el teléfono del encargado se baja del
/// servidor la primera vez que se abre.
final rutaEvidenciaProvider = FutureProvider.autoDispose
    .family<String?, Evidencia>(
      (ref, v) => ref.watch(archivosEvidenciaProvider).rutaLocal(v),
    );

class EstadoSincronizacion {
  const EstadoSincronizacion({
    this.sincronizando = false,
    this.ultimaVez,
    this.error,
  });

  final bool sincronizando;

  /// Última sincronización completa (todo enviado y recibido).
  final DateTime? ultimaVez;
  final String? error;

  EstadoSincronizacion copiar({bool? sincronizando}) => EstadoSincronizacion(
    sincronizando: sincronizando ?? this.sincronizando,
    ultimaVez: ultimaVez,
    error: error,
  );
}

/// Decide cuándo sincronizar mientras la app está abierta (HU-011 c1):
/// al recuperar la señal, al iniciar sesión, al registrar algo nuevo, al
/// volver la app al frente y cada 30 segundos con conexión (así el encargado
/// ve llegar los cierres sin tocar nada). Con la app cerrada sigue
/// workmanager (`sincronizacion/segundo_plano.dart`).
class ControlSincronizacion extends Notifier<EstadoSincronizacion> {
  Timer? _periodico;
  Timer? _demora;

  static const _cada = Duration(seconds: 30);

  @override
  EstadoSincronizacion build() {
    if (ref.watch(sincronizadorProvider) == null) {
      return const EstadoSincronizacion();
    }

    ref.listen(hayConexionProvider, (antes, ahora) {
      final conectado = ahora.value ?? false;
      if (conectado && antes?.value != true) {
        sincronizarAhora();
      } else if (!conectado) {
        // Si se cierra la app sin señal, workmanager envía al volver.
        SegundoPlano.alVolverLaSenal().ignore();
      }
    });
    ref.listen(sesionProvider, (_, s) {
      if (s is ConSesion) sincronizarAhora();
    });
    ref.listen(pendientesProvider, (antes, ahora) {
      if ((ahora.value ?? 0) > (antes?.value ?? 0)) {
        // Se registró algo: se envía enseguida, agrupando acciones seguidas.
        _demora?.cancel();
        _demora = Timer(const Duration(seconds: 2), sincronizarAhora);
      }
    });

    _periodico = Timer.periodic(_cada, (_) => sincronizarAhora());
    final ciclo = AppLifecycleListener(onResume: sincronizarAhora);
    ref.onDispose(() {
      _periodico?.cancel();
      _demora?.cancel();
      ciclo.dispose();
    });
    return const EstadoSincronizacion();
  }

  Future<void> sincronizarAhora() async {
    final sincronizador = ref.read(sincronizadorProvider);
    final sesion = ref.read(sesionProvider);
    if (sincronizador == null || sesion is! ConSesion) return;
    if (ref.read(hayConexionProvider).value != true) return;
    if (state.sincronizando) return;

    state = state.copiar(sincronizando: true);
    final r = await sincronizador.sincronizar(
      usuarioId: sesion.perfil.id,
      authIdEsperado: sesion.perfil.authId,
      reautenticar: ref.read(repositorioSesionProvider).reautenticar,
    );
    if (!ref.mounted) return;
    state = EstadoSincronizacion(
      ultimaVez: r.correcta ? DateTime.now() : state.ultimaVez,
      error: r.ocupado
          ? state.error
          : r.sinSesionRemota
          ? 'No se pudo conectar con tu cuenta'
          : r.error == null
          ? null
          : 'No se pudo enviar todo; se reintenta solo',
    );
  }
}

/// Labor del aviso que tocó el trabajador (HU-010 c2). Se abre apenas hay
/// sesión de trabajador: si la app estaba cerrada, después de ingresar el PIN.
class TareaDelAviso extends Notifier<String?> {
  @override
  String? build() => null;

  void abrir(String tareaId) => state = tareaId;
  void atendida() => state = null;
}

final tareaDelAvisoProvider = NotifierProvider<TareaDelAviso, String?>(
  TareaDelAviso.new,
);

final controlSincronizacionProvider =
    NotifierProvider<ControlSincronizacion, EstadoSincronizacion>(
      ControlSincronizacion.new,
    );
