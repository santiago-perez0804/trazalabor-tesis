import 'package:supabase_flutter/supabase_flutter.dart';

/// Credenciales inyectadas con `--dart-define-from-file=config/dev.json`.
/// La clave es la publishable/anon: puede estar en la app. La `service_role`
/// nunca entra al cliente (ver docs/especificacion/arquitectura-y-seguridad.md).
abstract final class ConfigSupabase {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get configurado => url.isNotEmpty && anonKey.isNotEmpty;
}

/// Inicializa el cliente si hay credenciales. Sin ellas la app igual arranca:
/// es local-first y la sincronización simplemente queda pendiente.
Future<void> inicializarSupabase() async {
  if (!ConfigSupabase.configurado) return;
  await Supabase.initialize(
    url: ConfigSupabase.url,
    publishableKey: ConfigSupabase.anonKey,
  );
}
