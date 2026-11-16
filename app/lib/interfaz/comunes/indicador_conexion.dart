import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de la red del dispositivo. Solo indica si hay una interfaz de red
/// activa; el motor de sincronización confirma el acceso real al servidor.
/// Lo muestra la franja permanente de `barra_app.dart` en todas las pantallas.
final hayConexionProvider = StreamProvider<bool>((ref) async* {
  final conectividad = Connectivity();
  bool conectado(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);

  yield conectado(await conectividad.checkConnectivity());
  yield* conectividad.onConnectivityChanged.map(conectado);
});
