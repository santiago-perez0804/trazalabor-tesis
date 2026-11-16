import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../dominio/catalogos.dart';
import '../../dominio/tipo_evento.dart';
import '../../dominio/validar_cierre.dart';
import '../../dominio/validar_qr.dart';
import '../../repositorio/base_datos.dart';
import '../../repositorio/repositorio_ejecucion.dart';
import '../comunes/barra_app.dart';
import '../comunes/caja_mensaje.dart';
import '../comunes/piezas.dart';
import '../proveedores.dart';
import '../tema.dart';
import 'escaner_qr.dart';

/// Pantalla C de la Figura 5, "Hacer la labor": lista de verificación y
/// verificación por QR (HU-007, HU-009, T-16, T-20). Cada acción queda
/// guardada en el teléfono al instante, con o sin señal.
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.mensaje)));
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
    final d = ref.watch(detalleTareaProvider(widget.tareaId)).value;
    if (d == null) {
      return const Scaffold(
        appBar: BarraApp(titulo: 'Labor'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final tipo = TipoLabor.desdeValor(d.tarea.tipoLabor);
    final abierta = d.admiteEjecucion;
    final empezada = d.estado != EstadoTarea.asignada;

    return Scaffold(
      appBar: BarraApp(titulo: d.unidad.nombre, subtitulo: tipo.etiqueta),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (!abierta) ...[
            AvisoSuave(
              icono: Icons.lock_outline,
              titulo: switch (d.estado) {
                EstadoTarea.completada => 'Labor terminada',
                EstadoTarea.noCompletada => 'Labor cerrada sin terminar',
                EstadoTarea.verificada => 'Labor revisada por el encargado',
                _ => 'Labor cerrada',
              },
              detalle: 'Se puede mirar, pero ya no cambiar.',
            ),
            const SizedBox(height: 16),
          ] else ...[
            IndicadorPasos(paso: empezada ? 2 : 1),
            const SizedBox(height: 16),
          ],
          if (d.tarea.descripcion != null) ...[
            AvisoSuave(
              icono: Icons.info_outline,
              titulo: 'Indicaciones',
              detalle: d.tarea.descripcion,
              alerta: true,
            ),
            const SizedBox(height: 12),
          ],
          _Requisitos(d),
          const SizedBox(height: 12),
          if (d.tarea.requiereQr) ...[
            if (d.qrVerificado)
              AvisoSuave(
                icono: Icons.qr_code_2,
                titulo: 'Estás en ${d.unidad.nombre}',
                detalle: d.qrLeidoEn == null
                    ? 'Código QR leído'
                    : 'Código QR leído a las '
                          '${DateFormat('HH:mm').format(d.qrLeidoEn!.toLocal())}',
              )
            else
              OutlinedButton.icon(
                key: const ValueKey('boton-escanear'),
                onPressed: _ocupado || !abierta ? null : () => _escanear(d),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear el código del lugar'),
              ),
            if (_mensajeQr != null) ...[
              const SizedBox(height: 8),
              CajaMensaje([_mensajeQr!]),
            ],
            const SizedBox(height: 16),
          ],
          if (abierta && !empezada) ...[
            FilledButton.icon(
              key: const ValueKey('boton-iniciar'),
              onPressed: _ocupado
                  ? null
                  : () => _hacer(
                      () =>
                          _repo.iniciar(widget.tareaId, usuarioId: _usuarioId),
                    ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Empezar la labor'),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              const Expanded(child: Rotulo('Marcá lo que hiciste')),
              Text(
                '${d.completados} de ${d.items.length}',
                key: const ValueKey('avance'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColoresTrazaLabor.textoSecundario,
                ),
              ),
            ],
          ),
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
            FilledButton(
              key: const ValueKey('boton-cierre'),
              onPressed: () =>
                  context.push('/trabajador/tarea/${widget.tareaId}/cierre'),
              child: const Text('Seguir'),
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
      EvidenciaRequerida.ninguna => null,
      EvidenciaRequerida.foto => 'Al terminar, una foto',
      EvidenciaRequerida.audio => 'Al terminar, un audio',
      EvidenciaRequerida.fotoYAudio => 'Al terminar, foto y audio',
    };
    if (evidencia == null && !d.tarea.requiereQr) return const SizedBox();
    Widget chip(IconData icono, String texto) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresTrazaLabor.borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 18, color: ColoresTrazaLabor.verdeCampo),
          const SizedBox(width: 6),
          Text(texto, style: const TextStyle(fontSize: 14.5)),
        ],
      ),
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (evidencia != null) chip(Icons.photo_camera_outlined, evidencia),
        if (d.tarea.requiereQr) chip(Icons.qr_code_2, 'Escanear el QR'),
      ],
    );
  }
}

/// Un ítem de la lista: casilla grande para los de tildar; campo y ✓ para
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
  late final _texto = TextEditingController(
    text: widget.item.valor?.replaceAll('.', ','),
  );
  bool _editando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    await widget.onGuardar(_texto.text);
    if (mounted) setState(() => _editando = false);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final tipo = TipoRespuesta.desdeValor(item.tipoRespuesta);
    final titulo = item.descripcion + (item.obligatorio ? '' : ' (opcional)');
    final borde = item.completado
        ? const BorderSide(color: ColoresTrazaLabor.verdeCampo, width: 2)
        : const BorderSide(color: ColoresTrazaLabor.borde, width: 1.2);
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: borde,
    );

    if (tipo == TipoRespuesta.check) {
      return Card(
        shape: forma,
        child: CheckboxListTile(
          minTileHeight: 62,
          value: item.completado,
          shape: forma,
          title: Text(titulo, style: const TextStyle(fontSize: 17)),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: item.completado || !widget.habilitado
              ? null
              : (_) => widget.onGuardar(null),
        ),
      );
    }

    final mostrarCampo = !item.completado || _editando;
    final esNumero = tipo == TipoRespuesta.numero;
    final valorVisible = esNumero
        ? (item.valor ?? '').replaceAll('.', ',')
        : item.valor ?? '';

    final campo = TextField(
      controller: _texto,
      enabled: widget.habilitado,
      keyboardType: esNumero
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      textAlign: esNumero ? TextAlign.end : TextAlign.start,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 18),
      onSubmitted: (_) => _guardar(),
      decoration: InputDecoration(
        isDense: true,
        hintText: esNumero ? '0' : 'Escribí la respuesta',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
    final botonGuardar = IconButton.filled(
      tooltip: 'Guardar',
      onPressed: widget.habilitado ? _guardar : null,
      icon: const Icon(Icons.check),
      style: IconButton.styleFrom(
        backgroundColor: ColoresTrazaLabor.verdeCampo,
        minimumSize: const Size(48, 48),
      ),
    );

    return Card(
      shape: forma,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        child: !mostrarCampo
            ? Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: ColoresTrazaLabor.verdeCampo,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titulo, style: const TextStyle(fontSize: 16)),
                        Text(
                          valorVisible,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
            : esNumero
            // Número: rótulo a la izquierda y campo chico a la derecha.
            ? Row(
                children: [
                  Expanded(
                    child: Text(titulo, style: const TextStyle(fontSize: 17)),
                  ),
                  SizedBox(width: 96, child: campo),
                  const SizedBox(width: 8),
                  botonGuardar,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 17)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: campo),
                      const SizedBox(width: 8),
                      botonGuardar,
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
