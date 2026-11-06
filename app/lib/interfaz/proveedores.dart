import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dominio/perfil.dart';
import '../infra/almacen_seguro.dart';
import '../infra/autenticador_remoto.dart';
import '../repositorio/base_datos.dart';
import '../repositorio/repositorio_sesion.dart';

/// Dependencias que se crean en `main()` y se inyectan con overrides
/// (en las pruebas se reemplazan por versiones en memoria).
final baseDatosProvider = Provider<BaseDatos>(
    (ref) => throw UnimplementedError('Se inyecta desde main()'));
final almacenProvider = Provider<AlmacenClaves>(
    (ref) => throw UnimplementedError('Se inyecta desde main()'));
final autenticadorProvider = Provider<AutenticadorRemoto>(
    (ref) => throw UnimplementedError('Se inyecta desde main()'));
final perfilRecordadoProvider = Provider<Perfil?>((ref) => null);

final repositorioSesionProvider = Provider<RepositorioSesion>(
  (ref) => RepositorioSesion(
    remoto: ref.watch(autenticadorProvider),
    almacen: ref.watch(almacenProvider),
    db: ref.watch(baseDatosProvider),
  ),
);

sealed class EstadoSesion {
  const EstadoSesion();
}

class SinSesion extends EstadoSesion {
  const SinSesion({this.recordado});

  /// Último usuario de este teléfono, para saludarlo y pedirle solo el PIN.
  final Perfil? recordado;
}

class ConSesion extends EstadoSesion {
  const ConSesion(this.perfil, {this.sinConexion = false});
  final Perfil perfil;
  final bool sinConexion;
}

class SesionNotifier extends Notifier<EstadoSesion> {
  @override
  EstadoSesion build() =>
      SinSesion(recordado: ref.read(perfilRecordadoProvider));

  void ingresado(IngresoCorrecto r) =>
      state = ConSesion(r.perfil, sinConexion: r.sinConexion);

  Future<void> salir() async {
    final anterior = switch (state) {
      ConSesion(:final perfil) => perfil,
      SinSesion(:final recordado) => recordado,
    };
    await ref.read(repositorioSesionProvider).salir();
    state = SinSesion(recordado: anterior);
  }

  /// "No soy yo": vuelve a pedir el teléfono.
  void olvidarRecordado() => state = const SinSesion();
}

final sesionProvider =
    NotifierProvider<SesionNotifier, EstadoSesion>(SesionNotifier.new);
