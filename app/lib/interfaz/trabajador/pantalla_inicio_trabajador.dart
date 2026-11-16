import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/estado_bandeja.dart';
import '../../dominio/validar_labor.dart' show fechaComoTexto;
import '../../repositorio/repositorio_ejecucion.dart';
import '../comunes/barra_app.dart';
import '../comunes/barra_sesion.dart';
import '../proveedores.dart';
import '../tema.dart';

/// "Tareas de hoy" (pantalla B de la Figura 5, HU-006, T-15). Lee de la base
/// local con consultas reactivas: sin conexión muestra lo último que recibió
/// el teléfono. La franja de la barra indica lo que falta enviar.
class PantallaInicioTrabajador extends ConsumerWidget {
  const PantallaInicioTrabajador({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tareas = ref.watch(tareasDelDiaProvider).value ?? const [];
    final sesion = ref.watch(sesionProvider);
    final nombre = sesion is ConSesion ? sesion.perfil.nombreCorto : '';
    // La primera por hacer se destaca: es la que sigue.
    final siguiente = tareas
        .where(
          (t) =>
              t.estado == EstadoBandeja.enCurso ||
              t.estado == EstadoBandeja.pendiente,
        )
        .firstOrNull;

    return Scaffold(
      appBar: BarraApp(
        titulo: 'Tareas de hoy',
        subtitulo: '${fechaLarga(DateTime.now())} · $nombre',
        acciones: const [BotonSalir()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (tareas.isEmpty) ...[
            const SizedBox(height: 48),
            const Icon(
              Icons.wb_sunny_outlined,
              size: 56,
              color: ColoresTrazaLabor.textoSecundario,
            ),
            const SizedBox(height: 12),
            const Text(
              'No tenés labores para hoy.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cuando el encargado te asigne una, te llega un aviso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ColoresTrazaLabor.textoSecundario,
              ),
            ),
          ] else
            for (final t in tareas)
              TarjetaTarea(t, destacada: identical(t, siguiente)),
        ],
      ),
    );
  }
}

/// Tarjeta de una labor en "Tareas de hoy": círculo con el estado, unidad,
/// tipo y el estado en palabras.
class TarjetaTarea extends StatelessWidget {
  const TarjetaTarea(this.t, {super.key, this.destacada = false});

  final TareaBandeja t;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    final (fondo, frente, icono) = switch (t.estado) {
      EstadoBandeja.pendiente => (
        ColoresTrazaLabor.verdeCampo,
        Colors.white,
        Icons.play_arrow_rounded,
      ),
      EstadoBandeja.enCurso => (
        ColoresTrazaLabor.franjaSinSenal,
        ColoresTrazaLabor.pendiente,
        Icons.schedule,
      ),
      EstadoBandeja.completadaPorEnviar ||
      EstadoBandeja.noCompletadaPorEnviar => (
        const Color(0xFFEDEBE4),
        ColoresTrazaLabor.verdeCampo,
        Icons.upload_rounded,
      ),
      EstadoBandeja.verificada => (
        ColoresTrazaLabor.franjaConSenal,
        ColoresTrazaLabor.verdeCampo,
        Icons.verified,
      ),
      _ => (
        ColoresTrazaLabor.franjaConSenal,
        ColoresTrazaLabor.verdeCampo,
        Icons.check_rounded,
      ),
    };
    final colorEstado = t.estado == EstadoBandeja.enCurso
        ? ColoresTrazaLabor.pendiente
        : ColoresTrazaLabor.verdeCampo;
    final atrasada =
        t.tarea.fechaProgramada.compareTo(fechaComoTexto(DateTime.now())) < 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: destacada
            ? const BorderSide(color: ColoresTrazaLabor.verdeCampo, width: 2.5)
            : const BorderSide(color: ColoresTrazaLabor.borde),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/trabajador/tarea/${t.tarea.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: fondo,
                child: Icon(icono, color: frente, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.unidadNombre,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      t.tipoLabor.etiqueta,
                      style: const TextStyle(fontSize: 15.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        t.estado.etiqueta,
                        if (atrasada) 'de un día anterior',
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colorEstado,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
