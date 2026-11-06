import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../comunes/caja_mensaje.dart';
import '../proveedores.dart';
import '../tema.dart';

/// Lista de trabajadores del establecimiento (HU-002, T-08).
class PantallaTrabajadores extends ConsumerWidget {
  const PantallaTrabajadores({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trabajadores = ref.watch(trabajadoresProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Trabajadores')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/encargado/trabajadores/nuevo'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Agregar trabajador'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          const BarraEstado(),
          if (trabajadores.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text('Todavía no hay trabajadores cargados.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            ),
          for (final t in trabajadores)
            Card(
              child: ListTile(
                minTileHeight: 72,
                leading: CircleAvatar(
                  backgroundColor: t.activo
                      ? ColoresTrazaLabor.verdeCampo
                      : ColoresTrazaLabor.textoSecundario,
                  foregroundColor: Colors.white,
                  child: Text(t.nombre.characters.first.toUpperCase()),
                ),
                title: Text(t.nombre, style: const TextStyle(fontSize: 18)),
                subtitle: Text(
                  [
                    t.telefono,
                    if (t.especialidad != null) t.especialidad!,
                    if (!t.activo) 'Desactivado',
                  ].join(' · '),
                  style: TextStyle(
                      fontSize: 15,
                      color: t.activo
                          ? ColoresTrazaLabor.textoSecundario
                          : ColoresTrazaLabor.sinConexion),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/encargado/trabajadores/${t.id}'),
              ),
            ),
        ],
      ),
    );
  }
}
