import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dominio/perfil.dart';
import '../infra/administracion_remota.dart';
import '../infra/almacen_seguro.dart';
import '../infra/autenticador_remoto.dart';
import '../repositorio/base_datos.dart';
import '../repositorio/repositorio_bandeja.dart';
import '../repositorio/repositorio_ejecucion.dart';
import '../repositorio/repositorio_labores.dart';
import '../repositorio/repositorio_sesion.dart';
import '../repositorio/repositorio_trabajadores.dart';
import '../repositorio/repositorio_unidades.dart';
import '../repositorio/repositorio_verificacion.dart';

/// Dependencias que se crean en `main()` y se inyectan con overrides
/// (en las pruebas se reemplazan por versiones en memoria).
final baseDatosProvider = Provider<BaseDatos>(
  (ref) => throw UnimplementedError('Se inyecta desde main()'),
);
final almacenProvider = Provider<AlmacenClaves>(
  (ref) => throw UnimplementedError('Se inyecta desde main()'),
);
final autenticadorProvider = Provider<AutenticadorRemoto>(
  (ref) => throw UnimplementedError('Se inyecta desde main()'),
);
final perfilRecordadoProvider = Provider<Perfil?>((ref) => null);

/// Sin override (pruebas, app sin credenciales) se comporta como si nunca
/// hubiera servidor.
final administracionProvider = Provider<AdministracionRemota>(
  (ref) => const AdministracionSinServidor(),
);

final repositorioSesionProvider = Provider<RepositorioSesion>(
  (ref) => RepositorioSesion(
    remoto: ref.watch(autenticadorProvider),
    almacen: ref.watch(almacenProvider),
    db: ref.watch(baseDatosProvider),
  ),
);

final repositorioTrabajadoresProvider = Provider<RepositorioTrabajadores>(
  (ref) => RepositorioTrabajadores(
    ref.watch(baseDatosProvider),
    ref.watch(administracionProvider),
  ),
);
final repositorioUnidadesProvider = Provider<RepositorioUnidades>(
  (ref) => RepositorioUnidades(ref.watch(baseDatosProvider)),
);
final repositorioLaboresProvider = Provider<RepositorioLabores>(
  (ref) => RepositorioLabores(ref.watch(baseDatosProvider)),
);
final repositorioBandejaProvider = Provider<RepositorioBandeja>(
  (ref) => RepositorioBandeja(ref.watch(baseDatosProvider)),
);

// Consultas reactivas sobre la base local (la interfaz siempre lee de SQLite).
final trabajadoresProvider = StreamProvider<List<Usuario>>(
  (ref) => ref.watch(repositorioTrabajadoresProvider).observarTrabajadores(),
);
final trabajadoresAsignablesProvider = StreamProvider<List<Usuario>>(
  (ref) => ref.watch(repositorioTrabajadoresProvider).observarAsignables(),
);
final trabajadorProvider = StreamProvider.family<Usuario?, String>(
  (ref, id) => ref.watch(repositorioTrabajadoresProvider).observar(id),
);
final unidadesProvider = StreamProvider<List<UnidadProductiva>>(
  (ref) => ref.watch(repositorioUnidadesProvider).observarUnidades(),
);
final unidadesAsignablesProvider = StreamProvider<List<UnidadProductiva>>(
  (ref) => ref.watch(repositorioUnidadesProvider).observarAsignables(),
);
final unidadProvider = StreamProvider.family<UnidadProductiva?, String>(
  (ref, id) => ref.watch(repositorioUnidadesProvider).observar(id),
);
final pendientesProvider = StreamProvider<int>(
  (ref) => ref.watch(repositorioBandejaProvider).observarPendientes(),
);

/// Pantalla H: lo guardado en el teléfono, agrupado por labor.
final porEnviarProvider = StreamProvider<List<GrupoPorEnviar>>(
  (ref) => ref.watch(repositorioBandejaProvider).observarPorEnviar(),
);

final repositorioEjecucionProvider = Provider<RepositorioEjecucion>(
  (ref) => RepositorioEjecucion(ref.watch(baseDatosProvider)),
);

/// "Mis tareas de hoy" del usuario con sesión (pantalla B).
final tareasDelDiaProvider = StreamProvider<List<TareaBandeja>>((ref) {
  final sesion = ref.watch(sesionProvider);
  if (sesion is! ConSesion) return Stream.value(const []);
  return ref
      .watch(repositorioEjecucionProvider)
      .observarTareasDelDia(sesion.perfil.id, DateTime.now());
});

final detalleTareaProvider = StreamProvider.family<DetalleTarea?, String>(
  (ref, id) => ref.watch(repositorioEjecucionProvider).observarDetalle(id),
);

final repositorioVerificacionProvider = Provider<RepositorioVerificacion>(
  (ref) => RepositorioVerificacion(ref.watch(baseDatosProvider)),
);

/// Pantalla E: labores cerradas que esperan la revisión del encargado.
final porVerificarProvider = StreamProvider<List<LaborResumen>>(
  (ref) => ref.watch(repositorioVerificacionProvider).observarPorVerificar(),
);

final historialProvider =
    StreamProvider.family<List<LaborResumen>, FiltroHistorial>(
      (ref, filtro) =>
          ref.watch(repositorioVerificacionProvider).observarHistorial(filtro),
    );

final detalleVerificacionProvider =
    StreamProvider.family<DetalleVerificacion?, String>(
      (ref, id) =>
          ref.watch(repositorioVerificacionProvider).observarDetalle(id),
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

final sesionProvider = NotifierProvider<SesionNotifier, EstadoSesion>(
  SesionNotifier.new,
);
