import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import 'infra/almacen_seguro.dart';
import 'infra/avisos.dart';
import 'infra/supabase_config.dart';
import 'interfaz/control_sincronizacion.dart';
import 'interfaz/proveedores.dart';
import 'interfaz/rutas.dart';
import 'interfaz/tema.dart';
import 'repositorio/base_datos.dart';
import 'repositorio/repositorio_sesion.dart';
import 'sincronizacion/segundo_plano.dart';
import 'sincronizacion/servidor_supabase.dart';
import 'sincronizacion/sincronizador.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  const almacen = AlmacenSeguro();
  final autenticador = await inicializarSupabase(almacen);
  final db = abrirBaseDatos();
  final recordado = await RepositorioSesion(
    remoto: autenticador,
    almacen: almacen,
    db: db,
  ).perfilRecordado();

  final servidor = ConfigSupabase.configurado
      ? ServidorSupabase(Supabase.instance.client)
      : null;
  final contenedor = ProviderContainer(
    overrides: [
      almacenProvider.overrideWithValue(almacen),
      autenticadorProvider.overrideWithValue(autenticador),
      administracionProvider.overrideWithValue(crearAdministracion()),
      baseDatosProvider.overrideWithValue(db),
      perfilRecordadoProvider.overrideWithValue(recordado),
      if (servidor != null) ...[
        servidorProvider.overrideWithValue(servidor),
        sincronizadorProvider.overrideWithValue(
          Sincronizador(db, servidor, avisar: Avisos.nuevaLabor),
        ),
      ],
    ],
  );

  // Aviso de nueva asignación (HU-010): tocarlo abre la labor.
  void abrirTarea(String id) =>
      contenedor.read(tareaDelAvisoProvider.notifier).abrir(id);
  try {
    await Avisos.inicializar(alTocar: abrirTarea);
    final desdeAviso = await Avisos.tareaQueAbrioLaApp();
    if (desdeAviso != null) abrirTarea(desdeAviso);
    await Avisos.pedirPermiso();
  } catch (_) {
    // Sin avisos la app funciona igual: las labores aparecen en la bandeja.
  }
  if (ConfigSupabase.configurado) {
    try {
      await SegundoPlano.registrar();
    } catch (_) {
      // Si workmanager no está disponible, queda la sincronización en primer plano.
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: contenedor,
      child: const TrazaLaborApp(),
    ),
  );
}

class TrazaLaborApp extends ConsumerWidget {
  const TrazaLaborApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantiene activa la sincronización mientras la app está abierta.
    ref.watch(controlSincronizacionProvider);
    final router = ref.watch(routerProvider);

    // HU-010 c2: con sesión de trabajador, el aviso tocado abre la labor.
    void abrirAvisoSiCorresponde() {
      final id = ref.read(tareaDelAvisoProvider);
      final sesion = ref.read(sesionProvider);
      if (id == null || sesion is! ConSesion || sesion.perfil.esEncargado) {
        return;
      }
      ref.read(tareaDelAvisoProvider.notifier).atendida();
      router.go('/trabajador/tarea/$id');
    }

    ref.listen(tareaDelAvisoProvider, (_, _) => abrirAvisoSiCorresponde());
    ref.listen(sesionProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => abrirAvisoSiCorresponde(),
      );
    });

    return MaterialApp.router(
      title: 'TrazaLabor',
      debugShowCheckedModeBanner: false,
      theme: construirTema(),
      // Textos del sistema (calendario, diálogos) en español rioplatense.
      locale: const Locale('es', 'AR'),
      supportedLocales: const [Locale('es', 'AR'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
