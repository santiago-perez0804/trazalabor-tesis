import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/catalogos.dart';
import '../comunes/caja_mensaje.dart';
import '../proveedores.dart';
import '../tema.dart';

/// Lista de unidades productivas (HU-003, T-10).
class PantallaUnidades extends ConsumerWidget {
  const PantallaUnidades({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unidades = ref.watch(unidadesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Unidades productivas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/encargado/unidades/nueva'),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Agregar unidad'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          const BarraEstado(),
          if (unidades.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text('Todavía no hay unidades productivas cargadas.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            ),
          for (final u in unidades)
            Card(
              child: ListTile(
                minTileHeight: 72,
                leading: Icon(Icons.qr_code_2,
                    size: 36,
                    color: u.activa
                        ? ColoresTrazaLabor.verdeCampo
                        : ColoresTrazaLabor.textoSecundario),
                title: Text(u.nombre, style: const TextStyle(fontSize: 18)),
                subtitle: Text(
                  [
                    TipoUnidad.desdeValor(u.tipo).etiqueta,
                    if (u.superficieHa != null)
                      '${formatearHectareas(u.superficieHa!)} ha',
                    if (!u.activa) 'Desactivada',
                  ].join(' · '),
                  style: TextStyle(
                      fontSize: 15,
                      color: u.activa
                          ? ColoresTrazaLabor.textoSecundario
                          : ColoresTrazaLabor.sinConexion),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/encargado/unidades/${u.id}'),
              ),
            ),
        ],
      ),
    );
  }
}

/// 12.5 → "12,5"; 40.0 → "40".
String formatearHectareas(double ha) {
  final texto = ha == ha.roundToDouble() ? ha.toStringAsFixed(0) : ha.toString();
  return texto.replaceAll('.', ',');
}
