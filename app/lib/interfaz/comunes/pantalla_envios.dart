import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dominio/tipo_evento.dart';
import '../../repositorio/repositorio_bandeja.dart';
import '../control_sincronizacion.dart';
import '../proveedores.dart';
import '../tema.dart';
import 'barra_app.dart';
import 'indicador_conexion.dart';
import 'piezas.dart';

/// "Para enviar" (pantalla H de la Figura 5): lo que quedó guardado en el
/// teléfono a la espera de señal y el avance de las fotos y los audios. El
/// envío es automático; el botón solo permite probar en el momento.
class PantallaEnvios extends ConsumerWidget {
  const PantallaEnvios({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grupos = ref.watch(porEnviarProvider).value ?? const [];
    final enLinea = ref.watch(hayConexionProvider).value ?? false;
    final sinc = ref.watch(controlSincronizacionProvider);
    final hayServidor = ref.watch(sincronizadorProvider) != null;

    return Scaffold(
      appBar: const BarraApp(titulo: 'Para enviar'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          AvisoSuave(
            icono: grupos.isEmpty
                ? Icons.cloud_done_outlined
                : Icons.phone_android,
            titulo: grupos.isEmpty
                ? 'No queda nada por enviar'
                : 'Todo está guardado en tu teléfono. Se envía solo cuando '
                      'vuelva la señal.',
            detalle: grupos.isEmpty ? 'El servidor ya tiene todo.' : null,
          ),
          const SizedBox(height: 12),
          for (final g in grupos) ...[
            if (g.tareaId == null)
              _Tarjeta(
                icono: Icons.manage_accounts_outlined,
                titulo: 'Altas y cambios',
                detalle: 'Trabajadores y lotes',
                estado: _estado(g, enLinea, sinc.sincronizando),
                error: g.conError,
              )
            else ...[
              if (g.cambios > 0)
                _Tarjeta(
                  icono: Icons.check_rounded,
                  titulo: '${g.unidadNombre} · ${g.tipoLabor?.etiqueta ?? ''}',
                  detalle: _queHizo(g.estado),
                  estado: _estado(g, enLinea, sinc.sincronizando),
                  error: g.conError,
                ),
              if (g.archivosPendientes > 0) _TarjetaArchivos(g, enLinea),
            ],
          ],
          const SizedBox(height: 16),
          if (hayServidor)
            OutlinedButton.icon(
              key: const ValueKey('boton-enviar-ahora'),
              onPressed: enLinea && !sinc.sincronizando && grupos.isNotEmpty
                  ? () => ref
                        .read(controlSincronizacionProvider.notifier)
                        .sincronizarAhora()
                  : null,
              icon: sinc.sincronizando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                sinc.sincronizando ? 'Enviando…' : 'Probar enviar ahora',
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Podés seguir trabajando mientras tanto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: ColoresTrazaLabor.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  static String _queHizo(EstadoTarea? e) => switch (e) {
    EstadoTarea.completada => 'Labor terminada',
    EstadoTarea.noCompletada => 'Labor cerrada sin terminar',
    EstadoTarea.iniciada => 'Labor empezada',
    EstadoTarea.verificada => 'Labor aprobada',
    _ => 'Labor asignada',
  };

  static String _estado(GrupoPorEnviar g, bool enLinea, bool enviando) =>
      !enLinea
      ? 'Esperando señal'
      : enviando
      ? 'Enviando…'
      : g.conError
      ? 'No se pudo enviar; se reintenta solo'
      : 'Por enviar';
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.estado,
    this.error = false,
    this.avance,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final String estado;
  final bool error;
  final double? avance;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: ColoresTrazaLabor.franjaSinSenal,
            child: Icon(icono, color: ColoresTrazaLabor.pendiente),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(detalle, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  estado,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: error
                        ? ColoresTrazaLabor.sinConexion
                        : ColoresTrazaLabor.pendiente,
                  ),
                ),
                if (avance != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: avance,
                      minHeight: 7,
                      color: ColoresTrazaLabor.verdeCampo,
                      backgroundColor: ColoresTrazaLabor.borde,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Fotos y audios de una labor: van por su propia cola y muestran el avance
/// por archivo (decisión D33).
class _TarjetaArchivos extends StatelessWidget {
  const _TarjetaArchivos(this.g, this.enLinea);

  final GrupoPorEnviar g;
  final bool enLinea;

  @override
  Widget build(BuildContext context) {
    final partes = [
      if (g.fotos > 0) '${g.fotos} ${g.fotos == 1 ? 'foto' : 'fotos'}',
      if (g.audios > 0) '${g.audios} ${g.audios == 1 ? 'audio' : 'audios'}',
    ];
    final soloFotos = g.audios == 0;
    final cual = soloFotos ? 'foto' : (g.fotos == 0 ? 'audio' : 'archivo');
    final siguiente = g.archivosEnviados + 1;
    return _Tarjeta(
      icono: soloFotos ? Icons.image_outlined : Icons.mic_none,
      titulo: '${g.unidadNombre} · ${partes.join(' y ')}',
      detalle: 'Evidencia de la labor',
      estado: !enLinea
          ? 'Esperando señal'
          : g.conError
          ? 'No se pudo subir; se reintenta solo'
          : 'Enviando $cual $siguiente de ${g.archivos}',
      error: g.conError,
      avance: g.archivos == 0 ? null : g.archivosEnviados / g.archivos,
    );
  }
}
