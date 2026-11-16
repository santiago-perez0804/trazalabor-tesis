import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../dominio/archivo_evidencia.dart';
import '../../dominio/catalogos.dart';
import '../../dominio/tipo_evento.dart';
import '../../dominio/validar_verificacion.dart';
import '../../repositorio/base_datos.dart';
import '../../repositorio/repositorio_ejecucion.dart';
import '../../repositorio/repositorio_verificacion.dart';
import '../comunes/barra_app.dart';
import '../comunes/caja_mensaje.dart';
import '../comunes/piezas.dart';
import '../control_sincronizacion.dart';
import '../proveedores.dart';
import '../tema.dart';
import 'pantalla_verificacion.dart';

/// Detalle de una labor para el encargado (HU-012 c1, HU-013 c2, T-27, T-30):
/// ítems con sus valores, evidencias, resultado del QR y la cronología con la
/// hora del dispositivo y la del servidor. Desde acá se aprueba o reasigna.
class PantallaDetalleLabor extends ConsumerStatefulWidget {
  const PantallaDetalleLabor({super.key, required this.tareaId});

  final String tareaId;

  @override
  ConsumerState<PantallaDetalleLabor> createState() =>
      _PantallaDetalleLaborState();
}

class _PantallaDetalleLaborState extends ConsumerState<PantallaDetalleLabor> {
  AudioPlayer? _reproductor;
  bool _ocupado = false;

  @override
  void dispose() {
    _reproductor?.dispose();
    super.dispose();
  }

  /// El reproductor se crea recién al escuchar el primer audio.
  void _escuchar(String ruta) =>
      (_reproductor ??= AudioPlayer()).play(DeviceFileSource(ruta));

  String get _encargadoId => (ref.read(sesionProvider) as ConSesion).perfil.id;

  Future<void> _hacer(Future<void> Function() accion, String aviso) async {
    setState(() => _ocupado = true);
    try {
      await accion();
      if (mounted) avisarGuardado(context, aviso);
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

  Future<void> _aprobar() async {
    final ok = await confirmar(
      context,
      titulo: 'Aprobar labor',
      texto: 'Se registra como verificada y pasa al historial.',
      accion: 'Aprobar',
    );
    if (!ok) return;
    await _hacer(
      () => ref
          .read(repositorioVerificacionProvider)
          .aprobar(widget.tareaId, encargadoId: _encargadoId),
      'Labor aprobada.',
    );
  }

  Future<void> _reasignar(DetalleVerificacion v) async {
    final elegido = await showDialog<(String, String)>(
      context: context,
      builder: (_) => _DialogoReasignar(asignadoActual: v.tarea.asignadoId),
    );
    if (elegido == null) return;
    await _hacer(
      () => ref
          .read(repositorioVerificacionProvider)
          .reasignar(
            widget.tareaId,
            encargadoId: _encargadoId,
            nuevoTrabajadorId: elegido.$1,
            motivo: elegido.$2,
          ),
      'Labor reasignada.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = ref.watch(detalleVerificacionProvider(widget.tareaId)).value;
    if (v == null) {
      return const Scaffold(
        appBar: BarraApp(titulo: 'Revisar la labor'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final d = v.detalle;
    final tipo = TipoLabor.desdeValor(d.tarea.tipoLabor);
    final cerrada =
        v.estado == EstadoTarea.completada ||
        v.estado == EstadoTarea.noCompletada;
    final (colorEstadoLabor, _) = colorEstado(v.estado);
    final cierre = v.cronologia.lastWhereOrNull(
      (e) =>
          e.tipo == TipoEvento.completada || e.tipo == TipoEvento.noCompletada,
    );
    final fecha = DateTime.tryParse(d.tarea.fechaProgramada);
    final cuando = cierre != null
        ? DateFormat('d/M · HH:mm')
              .format(cierre.evento.createdAtDevice.toLocal())
        : fecha == null
        ? null
        : DateFormat('d/M').format(fecha);

    return Scaffold(
      appBar: BarraApp(
        titulo: 'Revisar la labor',
        subtitulo: '${d.unidad.nombre} · ${tipo.etiqueta}',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Resumen de la labor (Figura 5, pantalla E).
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${d.unidad.nombre} · ${tipo.etiqueta}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [v.trabajadorNombre, ?cuando].join(' · '),
                    style: const TextStyle(fontSize: 15.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    etiquetaEstado(v.estado),
                    key: const ValueKey('estado-labor'),
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: colorEstadoLabor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (cerrada && !v.cierreSincronizado) ...[
            const SizedBox(height: 8),
            const AvisoSuave(
              icono: Icons.sync,
              titulo: 'El cierre todavía no llegó al servidor',
              detalle:
                  'Se actualiza solo cuando el teléfono del trabajador '
                  'tenga señal.',
              alerta: true,
            ),
          ],
          if (d.tarea.requiereQr) ...[
            const SizedBox(height: 8),
            AvisoSuave(
              icono: Icons.qr_code_2,
              titulo: d.qrVerificado
                  ? 'Estuvo en ${d.unidad.nombre}'
                  : 'No leyó el código QR',
              detalle: d.qrVerificado && d.qrLeidoEn != null
                  ? 'Código QR leído a las '
                        '${DateFormat('HH:mm').format(d.qrLeidoEn!.toLocal())}'
                  : null,
              alerta: !d.qrVerificado,
            ),
          ],
          // Toda la evidencia de la labor, también la de intentos anteriores
          // a una reasignación (HU-013 c2).
          if (v.todasLasEvidencias.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final e in v.todasLasEvidencias)
                  _MosaicoEvidencia(e, escuchar: _escuchar),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Rotulo('Qué pasó'),
          for (final e in v.cronologia)
            _FilaCronologia(e, d: d, nombres: v.nombres),
          const SizedBox(height: 12),
          Rotulo(
            'Lista de verificación · ${d.completados} de ${d.items.length}',
          ),
          for (final i in d.items) _ItemVerificado(i),
          const SizedBox(height: 20),
          if (v.estado == EstadoTarea.completada) ...[
            FilledButton(
              key: const ValueKey('boton-aprobar'),
              onPressed: _ocupado ? null : _aprobar,
              child: const Text('Aprobar'),
            ),
            const SizedBox(height: 12),
          ],
          if (cerrada)
            OutlinedButton(
              key: const ValueKey('boton-reasignar'),
              onPressed: _ocupado ? null : () => _reasignar(v),
              child: const Text('Reasignar a otro trabajador'),
            ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () =>
                  context.push('/encargado/verificacion?historial=1'),
              child: const Text(
                'Ver historial de labores',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemVerificado extends StatelessWidget {
  const _ItemVerificado(this.i);
  final ItemChecklist i;

  @override
  Widget build(BuildContext context) {
    final tipo = TipoRespuesta.desdeValor(i.tipoRespuesta);
    final valor = i.valor == null
        ? null
        : tipo == TipoRespuesta.numero
        ? i.valor!.replaceAll('.', ',')
        : i.valor;
    return Card(
      child: ListTile(
        minTileHeight: 56,
        leading: Icon(
          i.completado ? Icons.check_circle : Icons.radio_button_unchecked,
          color: i.completado
              ? ColoresTrazaLabor.enLinea
              : ColoresTrazaLabor.textoSecundario,
        ),
        title: Text(i.descripcion, style: const TextStyle(fontSize: 16)),
        // El valor va debajo: una respuesta larga no aplasta la descripción.
        subtitle: valor == null || tipo == TipoRespuesta.check
            ? (i.completado ? null : const Text('Sin completar'))
            : Text(
                valor,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ColoresTrazaLabor.texto,
                ),
              ),
      ),
    );
  }
}

/// "Ver foto" / "Escuchar audio" (Figura 5, pantalla E). En el teléfono del
/// encargado el archivo se baja del servidor al abrir la labor y se comprueba
/// su huella SHA-256.
class _MosaicoEvidencia extends ConsumerWidget {
  const _MosaicoEvidencia(this.e, {required this.escuchar});

  final Evidencia e;
  final void Function(String ruta) escuchar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruta = ref.watch(rutaEvidenciaProvider(e));
    final esFoto = e.tipo == TipoEvidencia.foto.valor;
    final local = ruta.value;
    final estado = ruta.isLoading
        ? 'Descargando…'
        : ruta.hasError
        ? 'Archivo alterado'
        : local == null
        ? 'Todavía no llegó'
        : 'Huella verificada';
    final ancho = (MediaQuery.sizeOf(context).width - 42) / 2;
    final sobreFoto = esFoto && local != null;
    final colorTexto = sobreFoto ? Colors.white : ColoresTrazaLabor.verdeCampo;

    void abrir() {
      if (local == null) return;
      if (!esFoto) return escuchar(local);
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.all(12),
          child: InteractiveViewer(child: Image.file(File(local))),
        ),
      );
    }

    return SizedBox(
      width: ancho,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: esFoto ? const Color(0xFFE4E1D8) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: esFoto
                    ? ColoresTrazaLabor.borde
                    : ColoresTrazaLabor.verdeCampo,
                width: esFoto ? 1 : 1.6,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: local == null ? null : abrir,
              child: SizedBox(
                height: 104,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (sobreFoto)
                      Image.file(
                        File(local),
                        fit: BoxFit.cover,
                        cacheWidth: 360,
                        color: Colors.black38,
                        colorBlendMode: BlendMode.darken,
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          esFoto
                              ? Icons.image_outlined
                              : Icons.play_arrow_rounded,
                          size: 32,
                          color: colorTexto,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          esFoto ? 'Ver foto' : 'Escuchar audio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorTexto,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                ruta.hasError ? Icons.error_outline : Icons.verified_user,
                size: 15,
                color: ruta.hasError
                    ? ColoresTrazaLabor.sinConexion
                    : ColoresTrazaLabor.textoSecundario,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  estado,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: ColoresTrazaLabor.textoSecundario,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Una línea de "Qué pasó": hora del teléfono en negrita, la frase llana y,
/// debajo, quién lo hizo y cuándo llegó al servidor (HU-012 c1, HU-013 c2).
class _FilaCronologia extends StatelessWidget {
  const _FilaCronologia(this.e, {required this.d, required this.nombres});

  final EventoCronologia e;
  final DetalleTarea d;
  final Map<String, String> nombres;

  static final _hora = DateFormat('HH:mm', 'es');
  static final _diaHora = DateFormat('d/M HH:mm', 'es');

  String _formato(DateTime t) {
    final local = t.toLocal();
    final hoy = DateTime.now();
    final mismoDia =
        local.year == hoy.year &&
        local.month == hoy.month &&
        local.day == hoy.day;
    return (mismoDia ? _hora : _diaHora).format(local);
  }

  @override
  Widget build(BuildContext context) {
    final servidor = e.evento.receivedAtServer;
    final frase = fraseEvento(
      tipo: e.tipo,
      payload: e.evento.payload,
      unidad: d.unidad.nombre,
      item: (id) => d.items.where((i) => i.id == id).firstOrNull?.descripcion,
      persona: (id) => nombres[id],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62,
            child: Text(
              _formato(e.evento.createdAtDevice),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(frase, style: const TextStyle(fontSize: 16)),
                Text(
                  [
                    e.autor,
                    servidor == null
                        ? 'todavía no llegó al servidor'
                        : 'llegó al servidor ${_formato(servidor)}',
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: servidor == null
                        ? ColoresTrazaLabor.pendiente
                        : ColoresTrazaLabor.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Elegir el nuevo trabajador y escribir el motivo (HU-012 c3).
class _DialogoReasignar extends ConsumerStatefulWidget {
  const _DialogoReasignar({required this.asignadoActual});
  final String asignadoActual;

  @override
  ConsumerState<_DialogoReasignar> createState() => _DialogoReasignarState();
}

class _DialogoReasignarState extends ConsumerState<_DialogoReasignar> {
  late String? _trabajador = widget.asignadoActual;
  final _motivo = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trabajadores =
        ref.watch(trabajadoresAsignablesProvider).value ?? const [];
    if (_trabajador != null && !trabajadores.any((t) => t.id == _trabajador)) {
      _trabajador = null;
    }
    return AlertDialog(
      title: const Text('Reasignar labor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _trabajador,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Trabajador'),
              items: [
                for (final t in trabajadores)
                  DropdownMenuItem(value: t.id, child: Text(t.nombre)),
              ],
              onChanged: (v) => setState(() => _trabajador = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _motivo,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                hintText: 'Qué hay que rehacer',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: ColoresTrazaLabor.sinConexion),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final motivo = _motivo.text.trim();
            if (_trabajador == null || motivo.isEmpty) {
              setState(
                () => _error = _trabajador == null
                    ? 'Elegí a quién se la reasignás.'
                    : 'Escribí el motivo.',
              );
              return;
            }
            Navigator.pop(context, (_trabajador!, motivo));
          },
          child: const Text('Reasignar'),
        ),
      ],
    );
  }
}

extension<E> on List<E> {
  E? lastWhereOrNull(bool Function(E) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}
