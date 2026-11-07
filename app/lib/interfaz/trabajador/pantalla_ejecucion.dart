import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/catalogos.dart';
import '../../dominio/tipo_evento.dart';
import '../../dominio/validar_cierre.dart';
import '../../dominio/validar_qr.dart';
import '../../repositorio/base_datos.dart';
import '../../repositorio/repositorio_ejecucion.dart';
import '../comunes/caja_mensaje.dart';
import '../proveedores.dart';
import '../tema.dart';
import 'escaner_qr.dart';

/// Pantalla C de la Figura 5: ejecución de la labor con su lista de
/// verificación y la verificación por QR (HU-007, HU-009, T-16, T-20).
/// Cada acción queda guardada en el teléfono al instante, con o sin señal.
class PantallaEjecucion extends ConsumerStatefulWidget {
  const PantallaEjecucion({super.key, required this.tareaId});

  final String tareaId;

  @override
  ConsumerState<PantallaEjecucion> createState() => _PantallaEjecucionState();
}

class _PantallaEjecucionState extends ConsumerState<PantallaEjecucion> {
  String? _mensajeQr;
  bool _ocupado = false;

  String get _usuarioId => (ref.read(sesionProvider) as ConSesion).perfil.id;

  RepositorioEjecucion get _repo => ref.read(repositorioEjecucionProvider);

  Future<void> _hacer(Future<void> Function() accion) async {
    setState(() => _ocupado = true);
    try {
      await accion();
    } on AccionRechazada catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.mensaje, style: const TextStyle(fontSize: 16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _escanear(DetalleTarea d) async {
    final leido = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => EscanerQr(unidad: d.unidad.nombre)),
    );
    if (leido == null || !mounted) return;
    await _hacer(() async {
      final r = await _repo.verificarQr(
        widget.tareaId,
        leido,
        usuarioId: _usuarioId,
      );
      setState(
        () => _mensajeQr = r is QrCoincide
            ? null
            : explicarQr(r, unidadEsperada: d.unidad.nombre),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final detalle = ref.watch(detalleTareaProvider(widget.tareaId)).value;
    if (detalle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final d = detalle;
    final tipo = TipoLabor.desdeValor(d.tarea.tipoLabor);
    final abierta = d.admiteEjecucion;
    final total = d.items.length;

    return Scaffold(
      appBar: AppBar(title: Text('${d.unidad.nombre} · ${tipo.etiqueta}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const BarraEstado(),
          if (!abierta)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CajaMensaje([
                switch (d.estado) {
                  EstadoTarea.completada => 'Labor cerrada como completada.',
                  EstadoTarea.noCompletada =>
                    'Labor cerrada como no completada.',
                  EstadoTarea.verificada =>
                    'Labor verificada por el encargado.',
                  _ => 'Labor cerrada.',
                },
              ], esError: false),
            ),
          if (d.tarea.descripcion != null) ...[
            const Text(
              'Indicaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(d.tarea.descripcion!, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 16),
          ],
          _Requisitos(d),
          const SizedBox(height: 16),
          if (abierta && d.estado == EstadoTarea.asignada) ...[
            FilledButton.icon(
              key: const ValueKey('boton-iniciar'),
              onPressed: _ocupado
                  ? null
                  : () => _hacer(
                      () =>
                          _repo.iniciar(widget.tareaId, usuarioId: _usuarioId),
                    ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar labor'),
            ),
            const SizedBox(height: 16),
          ],
          if (d.tarea.requiereQr) ...[
            if (d.qrVerificado)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F2EA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      color: ColoresTrazaLabor.enLinea,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'QR verificado: ${d.unidad.nombre}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: ColoresTrazaLabor.enLinea,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                key: const ValueKey('boton-escanear'),
                onPressed: _ocupado || !abierta ? null : () => _escanear(d),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear código del lugar'),
              ),
            if (_mensajeQr != null) ...[
              const SizedBox(height: 8),
              CajaMensaje([_mensajeQr!]),
            ],
            const SizedBox(height: 20),
          ],
          Text(
            'Lista de verificación · ${d.completados} de $total ítems',
            key: const ValueKey('avance'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : d.completados / total,
              minHeight: 10,
              color: ColoresTrazaLabor.verdeCampo,
              backgroundColor: const Color(0xFFDDE3DF),
            ),
          ),
          const SizedBox(height: 12),
          for (final item in d.items)
            _ItemEjecucion(
              key: ValueKey(item.id),
              item: item,
              habilitado: abierta && !_ocupado,
              onGuardar: (valor) => _hacer(
                () => _repo.completarItem(
                  widget.tareaId,
                  item.id,
                  valor,
                  usuarioId: _usuarioId,
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (abierta)
            FilledButton.icon(
              key: const ValueKey('boton-cierre'),
              onPressed: () =>
                  context.push('/trabajador/tarea/${widget.tareaId}/cierre'),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Continuar al cierre'),
            ),
        ],
      ),
    );
  }
}

/// Lo que pide la labor para cerrarse: evidencia y QR.
class _Requisitos extends StatelessWidget {
  const _Requisitos(this.d);

  final DetalleTarea d;

  @override
  Widget build(BuildContext context) {
    final evidencia = switch (d.evidenciaRequerida) {
      EvidenciaRequerida.ninguna => 'Sin evidencia obligatoria',
      EvidenciaRequerida.foto => 'Pide una foto',
      EvidenciaRequerida.audio => 'Pide un audio',
      EvidenciaRequerida.fotoYAudio => 'Pide foto y audio',
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          avatar: const Icon(Icons.photo_camera_outlined, size: 20),
          label: Text(evidencia, style: const TextStyle(fontSize: 15)),
        ),
        if (d.tarea.requiereQr)
          const Chip(
            avatar: Icon(Icons.qr_code_2, size: 20),
            label: Text('Pide escanear el QR', style: TextStyle(fontSize: 15)),
          ),
      ],
    );
  }
}

/// Un ítem de la lista: casilla para los de tildar; campo y "Guardar" para
/// número o texto. Corregir un valor registra un evento nuevo: lo anterior
/// queda en la bitácora.
class _ItemEjecucion extends StatefulWidget {
  const _ItemEjecucion({
    super.key,
    required this.item,
    required this.habilitado,
    required this.onGuardar,
  });

  final ItemChecklist item;
  final bool habilitado;
  final Future<void> Function(String? valor) onGuardar;

  @override
  State<_ItemEjecucion> createState() => _ItemEjecucionState();
}

class _ItemEjecucionState extends State<_ItemEjecucion> {
  late final _texto = TextEditingController(text: widget.item.valor);
  bool _editando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final tipo = TipoRespuesta.desdeValor(item.tipoRespuesta);
    final titulo = Text(
      item.descripcion + (item.obligatorio ? '' : ' (opcional)'),
      style: const TextStyle(fontSize: 17),
    );

    if (tipo == TipoRespuesta.check) {
      return Card(
        child: CheckboxListTile(
          minTileHeight: 64,
          value: item.completado,
          title: titulo,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: item.completado || !widget.habilitado
              ? null
              : (_) => widget.onGuardar(null),
        ),
      );
    }

    final mostrarCampo = !item.completado || _editando;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  item.completado
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: item.completado
                      ? ColoresTrazaLabor.enLinea
                      : ColoresTrazaLabor.textoSecundario,
                ),
                const SizedBox(width: 10),
                Expanded(child: titulo),
              ],
            ),
            const SizedBox(height: 8),
            if (!mostrarCampo)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tipo == TipoRespuesta.numero
                          ? (item.valor ?? '').replaceAll('.', ',')
                          : item.valor ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.habilitado)
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(64, 48),
                      ),
                      onPressed: () => setState(() => _editando = true),
                      child: const Text('Corregir'),
                    ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _texto,
                      enabled: widget.habilitado,
                      keyboardType: tipo == TipoRespuesta.numero
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: tipo == TipoRespuesta.numero
                            ? 'Número'
                            : 'Respuesta',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: widget.habilitado
                        ? () async {
                            await widget.onGuardar(_texto.text);
                            if (mounted) setState(() => _editando = false);
                          }
                        : null,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
