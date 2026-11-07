import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/archivo_evidencia.dart';
import '../../infra/captura_evidencia.dart';
import '../../repositorio/base_datos.dart';
import '../../repositorio/repositorio_ejecucion.dart';
import '../comunes/caja_mensaje.dart';
import '../proveedores.dart';
import '../tema.dart';

/// Pantalla D de la Figura 5: cierre de la labor con foto y audio
/// (HU-007 c2, HU-008, T-17, T-18). Todo se guarda en el teléfono; los
/// archivos quedan en la cola de multimedia para enviarse con señal.
class PantallaCierre extends ConsumerStatefulWidget {
  const PantallaCierre({super.key, required this.tareaId});

  final String tareaId;

  @override
  ConsumerState<PantallaCierre> createState() => _PantallaCierreState();
}

class _PantallaCierreState extends ConsumerState<PantallaCierre> {
  final _grabador = GrabadorAudio();
  final _reproductor = AudioPlayer();
  final _motivo = TextEditingController();
  bool _grabando = false;
  bool _grabandoMotivo = false;
  bool _noCompletada = false;
  bool _ocupado = false;

  String get _usuarioId => (ref.read(sesionProvider) as ConSesion).perfil.id;
  RepositorioEjecucion get _repo => ref.read(repositorioEjecucionProvider);

  @override
  void dispose() {
    _grabador.dispose();
    _reproductor.dispose();
    _motivo.dispose();
    super.dispose();
  }

  void _avisar(String texto) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(texto, style: const TextStyle(fontSize: 16))),
  );

  Future<void> _hacer(Future<void> Function() accion) async {
    setState(() => _ocupado = true);
    try {
      await accion();
    } on AccionRechazada catch (e) {
      if (mounted) _avisar(e.mensaje);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _adjuntar(ArchivoEvidencia? archivo) async {
    if (archivo == null) return;
    await _repo.adjuntarEvidencia(
      widget.tareaId,
      archivo,
      usuarioId: _usuarioId,
    );
  }

  Future<void> _tomarFoto() =>
      _hacer(() async => _adjuntar(await tomarFoto(widget.tareaId)));

  /// Empieza o termina la grabación. [motivo]: el audio explica por qué la
  /// labor no se completó, y al terminar se cierra como NO_COMPLETADA.
  Future<void> _alternarGrabacion({bool motivo = false}) async {
    if (!_grabando) {
      final ok = await _grabador.empezar(widget.tareaId);
      if (!ok) {
        _avisar('Hace falta permiso para usar el micrófono.');
        return;
      }
      setState(() {
        _grabando = true;
        _grabandoMotivo = motivo;
      });
      return;
    }
    final esMotivo = _grabandoMotivo;
    setState(() {
      _grabando = false;
      _grabandoMotivo = false;
    });
    await _hacer(() async {
      final archivo = await _grabador.terminar();
      await _adjuntar(archivo);
      if (esMotivo && archivo != null) {
        await _repo.cerrarNoCompletada(
          widget.tareaId,
          usuarioId: _usuarioId,
          motivoAudioId: archivo.id,
        );
        _terminar('Labor cerrada como no completada.');
      }
    });
  }

  Future<void> _cerrarCompletada() => _hacer(() async {
    await _repo.cerrarCompletada(widget.tareaId, usuarioId: _usuarioId);
    _terminar('Labor completada.');
  });

  Future<void> _cerrarNoCompletadaConTexto() => _hacer(() async {
    await _repo.cerrarNoCompletada(
      widget.tareaId,
      usuarioId: _usuarioId,
      motivo: _motivo.text,
    );
    _terminar('Labor cerrada como no completada.');
  });

  void _terminar(String texto) {
    if (!mounted) return;
    avisarGuardado(context, '$texto Guardado en el teléfono.');
    context.go('/trabajador');
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(detalleTareaProvider(widget.tareaId)).value;
    if (d == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final cierre = d.validarCierreActual();
    // HU-007 c2: lo que falta para cerrar como completada, siempre a la vista.
    final faltantes = cierre.faltantes;
    final resumen = [
      '${d.fotos} ${d.fotos == 1 ? 'foto' : 'fotos'}',
      '${d.audios} ${d.audios == 1 ? 'audio' : 'audios'}',
    ].join(' · ');

    return Scaffold(
      appBar: AppBar(title: const Text('Cierre de labor')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const BarraEstado(),
          Text(
            '${d.unidad.nombre} · ${d.completados} de ${d.items.length} ítems',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('boton-foto'),
                  onPressed: _ocupado || _grabando ? null : _tomarFoto,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Tomar foto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('boton-audio'),
                  style: _grabando && !_grabandoMotivo
                      ? FilledButton.styleFrom(
                          backgroundColor: ColoresTrazaLabor.sinConexion,
                        )
                      : null,
                  onPressed: _ocupado || _grabandoMotivo
                      ? null
                      : () => _alternarGrabacion(),
                  icon: Icon(
                    _grabando && !_grabandoMotivo ? Icons.stop : Icons.mic,
                  ),
                  label: Text(
                    _grabando && !_grabandoMotivo ? 'Detener' : 'Grabar audio',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$resumen adjuntos (comprimidos)',
            style: const TextStyle(
              fontSize: 16,
              color: ColoresTrazaLabor.textoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          for (final e in d.evidencias) _FilaEvidencia(e, _reproductor),
          const SizedBox(height: 16),
          if (faltantes.isNotEmpty) ...[
            CajaMensaje(faltantes),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            key: const ValueKey('boton-completada'),
            onPressed: _ocupado || _grabando || !cierre.puedeCompletar
                ? null
                : _cerrarCompletada,
            icon: const Icon(Icons.check_circle),
            label: const Text('Completada'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('boton-no-completada'),
            onPressed: _ocupado || _grabando
                ? null
                : () => setState(() => _noCompletada = !_noCompletada),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('No completada'),
          ),
          if (_noCompletada) ...[
            const SizedBox(height: 16),
            const Text(
              '¿Por qué no se pudo completar?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: _grabandoMotivo
                  ? FilledButton.styleFrom(
                      backgroundColor: ColoresTrazaLabor.sinConexion,
                    )
                  : null,
              onPressed: _ocupado || (_grabando && !_grabandoMotivo)
                  ? null
                  : () => _alternarGrabacion(motivo: true),
              icon: Icon(_grabandoMotivo ? Icons.stop : Icons.mic),
              label: Text(
                _grabandoMotivo ? 'Terminar y cerrar' : 'Contarlo con un audio',
              ),
            ),
            const SizedBox(height: 12),
            const Text('o escribilo:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            TextField(
              key: const ValueKey('campo-motivo'),
              controller: _motivo,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 17),
              decoration: const InputDecoration(hintText: 'Motivo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const ValueKey('boton-confirmar-no-completada'),
              onPressed: _ocupado || _grabando
                  ? null
                  : _cerrarNoCompletadaConTexto,
              child: const Text('Cerrar como no completada'),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Se guarda en el teléfono. Se enviará al haber señal.',
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
}

/// Foto en miniatura o audio con botón para escucharlo antes del cierre
/// (HU-008 c2).
class _FilaEvidencia extends StatelessWidget {
  const _FilaEvidencia(this.e, this.reproductor);

  final Evidencia e;
  final AudioPlayer reproductor;

  @override
  Widget build(BuildContext context) {
    final ruta = e.rutaLocal;
    final kb = ((e.tamanioBytes ?? 0) / 1024).round();
    final esFoto = e.tipo == TipoEvidencia.foto.valor;
    return Card(
      child: ListTile(
        minTileHeight: 72,
        leading: esFoto && ruta != null && File(ruta).existsSync()
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(ruta),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  cacheWidth: 112,
                ),
              )
            : Icon(esFoto ? Icons.photo : Icons.graphic_eq, size: 36),
        title: Text(
          esFoto ? 'Foto' : 'Audio',
          style: const TextStyle(fontSize: 17),
        ),
        subtitle: Text('$kb KB · huella ${e.hashSha256.substring(0, 8)}…'),
        trailing: !esFoto && ruta != null
            ? IconButton(
                tooltip: 'Escuchar',
                iconSize: 32,
                icon: const Icon(Icons.play_circle_fill),
                onPressed: () => reproductor.play(DeviceFileSource(ruta)),
              )
            : null,
      ),
    );
  }
}
