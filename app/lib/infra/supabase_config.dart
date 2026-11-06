import 'package:supabase_flutter/supabase_flutter.dart';

import '../dominio/perfil.dart';
import 'administracion_remota.dart';
import 'almacen_seguro.dart';
import 'autenticador_remoto.dart';

/// Credenciales inyectadas con `--dart-define-from-file=config/dev.json`.
/// La clave es la publishable/anon: puede estar en la app. La `service_role`
/// nunca entra al cliente (ver docs/especificacion/arquitectura-y-seguridad.md).
abstract final class ConfigSupabase {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get configurado => url.isNotEmpty && anonKey.isNotEmpty;
}

/// Inicializa el cliente con la sesión guardada en el almacenamiento cifrado y
/// devuelve el autenticador. Sin credenciales la app igual arranca: es
/// local-first y todo queda pendiente de sincronizar.
Future<AutenticadorRemoto> inicializarSupabase(AlmacenClaves almacen) async {
  if (!ConfigSupabase.configurado) return const AutenticadorSinServidor();
  await Supabase.initialize(
    url: ConfigSupabase.url,
    publishableKey: ConfigSupabase.anonKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SesionSupabaseSegura(almacen),
    ),
  );
  return AutenticadorSupabase(Supabase.instance.client);
}

/// Acciones del encargado que resuelve el servidor. Llamar después de
/// [inicializarSupabase].
AdministracionRemota crearAdministracion() => ConfigSupabase.configurado
    ? AdministracionSupabase(Supabase.instance.client)
    : const AdministracionSinServidor();

/// Se usa cuando la app se compila sin credenciales: se comporta como si
/// nunca hubiera conexión.
class AutenticadorSinServidor implements AutenticadorRemoto {
  const AutenticadorSinServidor();

  @override
  Future<EstadoCuenta> estadoCuenta(String telefono) =>
      Future.error(const ErrorSinConexion());

  @override
  Future<Perfil> ingresar(String telefono, String pin) =>
      Future.error(const ErrorSinConexion());

  @override
  Future<Perfil> activar(String telefono, String pin) =>
      Future.error(const ErrorSinConexion());

  @override
  Future<void> salir() async {}
}
