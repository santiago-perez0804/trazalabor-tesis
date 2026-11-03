import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'infra/supabase_config.dart';
import 'interfaz/pantalla_inicio.dart';
import 'interfaz/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarSupabase();
  runApp(const ProviderScope(child: TrazaLaborApp()));
}

class TrazaLaborApp extends StatelessWidget {
  const TrazaLaborApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrazaLabor',
      debugShowCheckedModeBanner: false,
      theme: construirTema(),
      home: const PantallaInicio(),
    );
  }
}
