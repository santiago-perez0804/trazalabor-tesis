import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../dominio/catalogos.dart';
import '../../dominio/plantillas_labor.dart';
import '../../dominio/validar_cierre.dart';
import '../../dominio/validar_labor.dart';
import '../../repositorio/repositorio_labores.dart';
import '../comunes/barra_app.dart';
import '../comunes/caja_mensaje.dart';
import '../proveedores.dart';
import '../tema.dart';
import 'editor_checklist.dart';

/// Pantalla A de la Figura 5: crear y asignar una labor con su lista de
/// verificación y la evidencia requerida (HU-005, T-13).
class PantallaNuevaLabor extends ConsumerStatefulWidget {
  const PantallaNuevaLabor({super.key});

  @override
  ConsumerState<PantallaNuevaLabor> createState() => _PantallaNuevaLaborState();
}

class _PantallaNuevaLaborState extends ConsumerState<PantallaNuevaLabor> {
  String? _unidadId;
  String? _asignadoId;
  TipoLabor? _tipo;
  DateTime _fecha = _hoy();
  final _descripcion = TextEditingController();
  List<ItemEditable> _items = [];
  EvidenciaRequerida _evidencia = EvidenciaRequerida.ninguna;
  bool _requiereQr = false;
  List<String> _faltantes = const [];
  bool _intentado = false;
  bool _ocupado = false;

  static DateTime _hoy() {
    final ahora = DateTime.now();
    return DateTime(ahora.year, ahora.month, ahora.day);
  }

  @override
  void dispose() {
    _descripcion.dispose();
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  /// Al elegir el tipo se carga su plantilla (T-14).
  void _elegirTipo(TipoLabor? tipo) {
    if (tipo == null) return;
    final plantilla = plantillaPara(tipo);
    setState(() {
      for (final i in _items) {
        i.dispose();
      }
      _tipo = tipo;
      _items = plantilla.items.map(ItemEditable.desde).toList();
      _evidencia = plantilla.evidencia;
      _requiereQr = plantilla.requiereQr;
      _refrescarFaltantes();
    });
  }

  BorradorLabor _borrador() => BorradorLabor(
    unidadProductivaId: _unidadId,
    asignadoId: _asignadoId,
    tipoLabor: _tipo,
    fechaProgramada: _fecha,
    descripcion: _descripcion.text,
    items: _items.map((i) => i.aBorrador()).toList(),
    evidencia: _evidencia,
    requiereQr: _requiereQr,
  );

  void _refrescarFaltantes() {
    if (_intentado) _faltantes = validarLabor(_borrador());
  }

  Future<void> _elegirFecha() async {
    final hoy = _hoy();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Fecha de la labor',
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _asignar(String creadorId, String nombreTrabajador) async {
    setState(() {
      _intentado = true;
      _faltantes = validarLabor(_borrador());
    });
    if (_faltantes.isNotEmpty) return;

    setState(() => _ocupado = true);
    try {
      await ref
          .read(repositorioLaboresProvider)
          .crearLabor(_borrador(), creadorId: creadorId);
      if (!mounted) return;
      avisarGuardado(
        context,
        'Labor guardada en el teléfono y asignada a $nombreTrabajador.',
      );
      context.pop();
    } on LaborIncompleta catch (e) {
      setState(() => _faltantes = e.faltantes);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  bool get _pideFoto =>
      _evidencia == EvidenciaRequerida.foto ||
      _evidencia == EvidenciaRequerida.fotoYAudio;
  bool get _pideAudio =>
      _evidencia == EvidenciaRequerida.audio ||
      _evidencia == EvidenciaRequerida.fotoYAudio;

  static EvidenciaRequerida _armarEvidencia(bool foto, bool audio) =>
      switch ((foto, audio)) {
        (true, true) => EvidenciaRequerida.fotoYAudio,
        (true, false) => EvidenciaRequerida.foto,
        (false, true) => EvidenciaRequerida.audio,
        (false, false) => EvidenciaRequerida.ninguna,
      };

  @override
  Widget build(BuildContext context) {
    final sesion = ref.watch(sesionProvider);
    final unidades = ref.watch(unidadesAsignablesProvider).value ?? const [];
    final trabajadores =
        ref.watch(trabajadoresAsignablesProvider).value ?? const [];

    // Si la unidad o el trabajador elegido se desactivó, se descarta.
    if (_unidadId != null && !unidades.any((u) => u.id == _unidadId)) {
      _unidadId = null;
    }
    if (_asignadoId != null && !trabajadores.any((t) => t.id == _asignadoId)) {
      _asignadoId = null;
    }

    String? marca(bool falta) => _intentado && falta ? 'Falta completar' : null;
    final fecha = DateFormat("EEEE d 'de' MMMM", 'es').format(_fecha);

    return Scaffold(
      appBar: const BarraApp(
        titulo: 'Nueva labor',
        subtitulo: 'Qué hay que hacer, dónde y quién',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (unidades.isEmpty || trabajadores.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CajaMensaje([
                if (unidades.isEmpty)
                  'Primero cargá una unidad productiva activa.',
                if (trabajadores.isEmpty) 'Primero cargá un trabajador activo.',
              ]),
            ),
          const _Pregunta('¿Dónde?'),
          DropdownButtonFormField<String>(
            key: const ValueKey('campo-unidad'),
            initialValue: _unidadId,
            isExpanded: true,
            style: const TextStyle(
              fontFamily: 'Atkinson',
              fontSize: 18,
              color: ColoresTrazaLabor.texto,
            ),
            decoration: InputDecoration(
              hintText: 'Elegí el lote o lugar',
              errorText: marca(_unidadId == null),
            ),
            items: [
              for (final u in unidades)
                DropdownMenuItem(
                  value: u.id,
                  child: Text(
                    '${u.nombre} · ${TipoUnidad.desdeValor(u.tipo).etiqueta}',
                  ),
                ),
            ],
            onChanged: (v) => setState(() {
              _unidadId = v;
              _refrescarFaltantes();
            }),
          ),
          const _Pregunta('¿Quién la hace?'),
          DropdownButtonFormField<String>(
            key: const ValueKey('campo-trabajador'),
            initialValue: _asignadoId,
            isExpanded: true,
            style: const TextStyle(
              fontFamily: 'Atkinson',
              fontSize: 18,
              color: ColoresTrazaLabor.texto,
            ),
            decoration: InputDecoration(
              hintText: 'Elegí el trabajador',
              errorText: marca(_asignadoId == null),
            ),
            items: [
              for (final t in trabajadores)
                DropdownMenuItem(
                  value: t.id,
                  child: Text(
                    [
                      t.nombre,
                      if (t.especialidad != null) t.especialidad,
                    ].join(' · '),
                  ),
                ),
            ],
            onChanged: (v) => setState(() {
              _asignadoId = v;
              _refrescarFaltantes();
            }),
          ),
          const _Pregunta('¿Qué labor?'),
          DropdownButtonFormField<TipoLabor>(
            key: const ValueKey('campo-tipo'),
            initialValue: _tipo,
            isExpanded: true,
            style: const TextStyle(
              fontFamily: 'Atkinson',
              fontSize: 18,
              color: ColoresTrazaLabor.texto,
            ),
            decoration: InputDecoration(
              hintText: 'Elegí el tipo de labor',
              errorText: marca(_tipo == null),
            ),
            items: [
              for (final t in TipoLabor.values)
                DropdownMenuItem(value: t, child: Text(t.etiqueta)),
            ],
            onChanged: _elegirTipo,
          ),
          const _Pregunta('¿Cuándo?'),
          OutlinedButton.icon(
            onPressed: _elegirFecha,
            icon: const Icon(Icons.event),
            label: Text(fecha[0].toUpperCase() + fecha.substring(1)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descripcion,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 17),
            decoration: const InputDecoration(
              labelText: 'Indicaciones (opcional)',
            ),
          ),
          const _Pregunta('Lista de verificación'),
          if (_tipo == null)
            const Text(
              'Elegí el tipo de labor para cargar su lista.',
              style: TextStyle(
                fontSize: 16,
                color: ColoresTrazaLabor.textoSecundario,
              ),
            )
          else
            EditorChecklist(
              items: _items,
              onCambio: () => setState(_refrescarFaltantes),
              onAgregar: () => setState(() {
                _items.add(
                  ItemEditable.desde(const ItemBorrador(descripcion: '')),
                );
                _refrescarFaltantes();
              }),
              onQuitar: (i) => setState(() {
                _items.removeAt(i).dispose();
                _refrescarFaltantes();
              }),
            ),
          const _Pregunta('Pedir al terminar'),
          Row(
            children: [
              Expanded(
                child: _Alternador(
                  key: const ValueKey('pedir-foto'),
                  texto: 'Foto',
                  activo: _pideFoto,
                  onTap: () => setState(
                    () => _evidencia = _armarEvidencia(!_pideFoto, _pideAudio),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Alternador(
                  key: const ValueKey('pedir-audio'),
                  texto: 'Audio',
                  activo: _pideAudio,
                  onTap: () => setState(
                    () => _evidencia = _armarEvidencia(_pideFoto, !_pideAudio),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Alternador(
                  key: const ValueKey('pedir-qr'),
                  texto: 'Código QR',
                  activo: _requiereQr,
                  onTap: () => setState(() => _requiereQr = !_requiereQr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_faltantes.isNotEmpty) ...[
            CajaMensaje(_faltantes),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            key: const ValueKey('boton-asignar'),
            onPressed: _ocupado || sesion is! ConSesion
                ? null
                : () => _asignar(
                    sesion.perfil.id,
                    trabajadores
                            .where((t) => t.id == _asignadoId)
                            .firstOrNull
                            ?.nombre ??
                        'el trabajador',
                  ),
            icon: const Icon(Icons.send),
            label: const Text('Asignar labor'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Título de cada bloque del formulario ("¿Dónde?", "¿Quién la hace?").
class _Pregunta extends StatelessWidget {
  const _Pregunta(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  );
}

/// Botón que se prende o se apaga (Foto / Audio / Código QR).
class _Alternador extends StatelessWidget {
  const _Alternador({
    super.key,
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: activo,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        backgroundColor: activo
            ? ColoresTrazaLabor.franjaConSenal
            : Colors.white,
        side: BorderSide(
          color: ColoresTrazaLabor.verdeCampo,
          width: activo ? 2.2 : 1.2,
        ),
      ),
      onPressed: onTap,
      // Activo = fondo verde claro y borde grueso; sin tilde, para que el
      // texto entre entero en tres columnas.
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(texto, maxLines: 1)),
    ),
  );
}
