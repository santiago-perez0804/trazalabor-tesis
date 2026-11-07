import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../dominio/estado_bandeja.dart';
import '../../dominio/validar_labor.dart' show fechaComoTexto;
import '../../repositorio/repositorio_ejecucion.dart';
import '../comunes/barra_sesion.dart';
import '../proveedores.dart';
import '../tema.dart';

/// "Mis tareas de hoy" (pantalla B de la Figura 5, HU-006, T-15). Lee de la
/// base local con consultas reactivas: sin conexión muestra lo último que
/// recibió el teléfono.
class PantallaInicioTrabajador extends ConsumerWidget {
  const PantallaInicioTrabajador({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoy = DateFormat("EEEE d 'de' MMMM", 'es').format(DateTime.now());
    final tareas = ref.watch(tareasDelDiaProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas de hoy'),
        actions: const [BotonSalir()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const EncabezadoSesion(),
          const SizedBox(height: 8),
          Text(
            hoy[0].toUpperCase() + hoy.substring(1),
            style: const TextStyle(
              fontSize: 16,
              color: ColoresTrazaLabor.textoSecundario,
            ),
          ),
          const SizedBox(height: 12),
          if (tareas.isEmpty) ...[
            const SizedBox(height: 28),
            const Icon(
              Icons.inbox_outlined,
              size: 56,
              color: ColoresTrazaLabor.textoSecundario,
            ),
            const SizedBox(height: 12),
            const Text(
              'No tenés labores asignadas para hoy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ] else ...[
            for (final t in tareas) _TarjetaTarea(t),
            const SizedBox(height: 12),
            const Text(
              '✓ sincronizada   ↻ pendiente de envío',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: ColoresTrazaLabor.textoSecundario,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaTarea extends StatelessWidget {
  const _TarjetaTarea(this.t);

  final TareaBandeja t;

  @override
  Widget build(BuildContext context) {
    final (color, icono) = switch (t.estado) {
      EstadoBandeja.pendiente => (
        ColoresTrazaLabor.verdeCampo,
        Icons.play_circle_outline,
      ),
      EstadoBandeja.enCurso => (ColoresTrazaLabor.pendiente, Icons.timelapse),
      EstadoBandeja.completadaPorEnviar ||
      EstadoBandeja.noCompletadaPorEnviar => (
        ColoresTrazaLabor.pendiente,
        Icons.sync,
      ),
      _ => (ColoresTrazaLabor.enLinea, Icons.check_circle_outline),
    };
    final atrasada =
        t.tarea.fechaProgramada.compareTo(fechaComoTexto(DateTime.now())) < 0;
    return Card(
      child: ListTile(
        minTileHeight: 80,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icono, size: 34, color: color),
        title: Text(
          '${t.unidadNombre} · ${t.tipoLabor.etiqueta}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [t.estado.etiqueta, if (atrasada) 'de un día anterior'].join(' · '),
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/trabajador/tarea/${t.tarea.id}'),
      ),
    );
  }
}
