import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'infra/almacen_seguro.dart';
import 'infra/supabase_config.dart';
import 'interfaz/proveedores.dart';
import 'interfaz/rutas.dart';
import 'interfaz/tema.dart';
import 'repositorio/base_datos.dart';
import 'repositorio/repositorio_sesion.dart';

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

  runApp(ProviderScope(
    overrides: [
      almacenProvider.overrideWithValue(almacen),
      autenticadorProvider.overrideWithValue(autenticador),
      baseDatosProvider.overrideWithValue(db),
      perfilRecordadoProvider.overrideWithValue(recordado),
    ],
    child: const TrazaLaborApp(),
  ));
}

class TrazaLaborApp extends ConsumerWidget {
  const TrazaLaborApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TrazaLabor',
      debugShowCheckedModeBanner: false,
      theme: construirTema(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
