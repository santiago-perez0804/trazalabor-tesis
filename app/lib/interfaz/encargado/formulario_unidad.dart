import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../dominio/catalogos.dart';
import '../../infra/exportar_qr.dart';
import '../../repositorio/base_datos.dart';
import '../../repositorio/repositorio_trabajadores.dart' show DatosRechazados;
import '../comunes/barra_app.dart';
import '../comunes/caja_mensaje.dart';
import '../proveedores.dart';
import '../tema.dart';
import 'pantalla_unidades.dart' show formatearHectareas;

/// Alta (sin [id]) o edición de una unidad productiva con su código QR
/// (HU-003 c1, c2 y c3).
class FormularioUnidad extends ConsumerStatefulWidget {
  const FormularioUnidad({super.key, this.id});

  final String? id;

  @override
  ConsumerState<FormularioUnidad> createState() => _FormularioUnidadState();
}

class _FormularioUnidadState extends ConsumerState<FormularioUnidad> {
  final _nombre = TextEditingController();
  final _superficie = TextEditingController();
  TipoUnidad? _tipo;
  Map<String, String> _errores = const {};
  bool _cargado = false;
  bool _ocupado = false;

  bool get _esAlta => widget.id == null;

  @override
  void dispose() {
    _nombre.dispose();
    _superficie.dispose();
    super.dispose();
  }

  void _cargar(UnidadProductiva u) {
    if (_cargado) return;
    _cargado = true;
    _nombre.text = u.nombre;
    _tipo = TipoUnidad.desdeValor(u.tipo);
    _superficie.text = u.superficieHa == null
        ? ''
        : formatearHectareas(u.superficieHa!);
  }

  Future<void> _guardar() async {
    final repo = ref.read(repositorioUnidadesProvider);
    setState(() => _ocupado = true);
    try {
      if (_esAlta) {
        final nueva = await repo.alta(
          nombre: _nombre.text,
          tipo: _tipo,
          superficie: _superficie.text,
        );
        if (!mounted) return;
        avisarGuardado(context, 'Unidad agregada. Ya podés exportar su QR.');
        // Se abre su ficha para exportar el código enseguida.
        context.pushReplacement('/encargado/unidades/${nueva.id}');
      } else {
        await repo.modificar(
          widget.id!,
          nombre: _nombre.text,
          tipo: _tipo,
          superficie: _superficie.text,
        );
        if (!mounted) return;
        avisarGuardado(context, 'Cambios guardados.');
        context.pop();
      }
    } on DatosRechazados catch (e) {
      setState(() => _errores = e.errores);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _exportar(UnidadProductiva u) async {
    setState(() => _ocupado = true);
    try {
      await compartirQr(
        codigo: u.codigoQr,
        nombre: u.nombre,
        detalle: [
          TipoUnidad.desdeValor(u.tipo).etiqueta,
          if (u.superficieHa != null)
            '${formatearHectareas(u.superficieHa!)} ha',
        ].join(' · '),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _cambiarActiva(UnidadProductiva u) async {
    final repo = ref.read(repositorioUnidadesProvider);
    if (u.activa) {
      final ok = await confirmar(
        context,
        titulo: 'Desactivar ${u.nombre}',
        texto:
            'No se va a ofrecer para labores nuevas. '
            'Sus labores e historial se conservan.',
        accion: 'Desactivar',
      );
      if (!ok) return;
      await repo.desactivar(u.id);
    } else {
      await repo.reactivar(u.id);
    }
    if (mounted) {
      avisarGuardado(
        context,
        u.activa ? 'Unidad desactivada.' : 'Unidad activada.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final existente = _esAlta
        ? null
        : ref.watch(unidadProvider(widget.id!)).value;
    if (existente != null) _cargar(existente);

    return Scaffold(
      appBar: BarraApp(titulo: _esAlta ? 'Nuevo lote o lugar' : 'Lote o lugar'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (existente != null) ...[
            Center(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: existente.codigoQr,
                  size: 220,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  semanticsLabel: 'Código QR de ${existente.nombre}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _ocupado ? null : () => _exportar(existente),
              icon: const Icon(Icons.print_outlined),
              label: const Text('Exportar QR para imprimir'),
            ),
            const SizedBox(height: 24),
          ],
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Nombre (por ejemplo, Lote 7)',
              errorText: _errores['nombre'],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tipo', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final t in TipoUnidad.values)
                ChoiceChip(
                  label: Text(t.etiqueta, style: const TextStyle(fontSize: 17)),
                  selected: _tipo == t,
                  onSelected: (_) => setState(() => _tipo = t),
                ),
            ],
          ),
          if (_errores['tipo'] != null)
            Text(
              _errores['tipo']!,
              style: const TextStyle(
                fontSize: 14,
                color: ColoresTrazaLabor.sinConexion,
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _superficie,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Superficie',
              suffixText: 'ha',
              errorText: _errores['superficie'],
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _ocupado ? null : _guardar,
            icon: const Icon(Icons.save),
            label: Text(_esAlta ? 'Agregar unidad' : 'Guardar cambios'),
          ),
          if (existente != null) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              existente.activa
                  ? 'Activa: se ofrece para labores nuevas.'
                  : 'Desactivada: no se ofrece para labores nuevas.',
              style: TextStyle(
                fontSize: 16,
                color: existente.activa
                    ? ColoresTrazaLabor.enLinea
                    : ColoresTrazaLabor.sinConexion,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _ocupado ? null : () => _cambiarActiva(existente),
              icon: Icon(
                existente.activa
                    ? Icons.block_outlined
                    : Icons.check_circle_outline,
              ),
              label: Text(
                existente.activa ? 'Desactivar unidad' : 'Volver a activar',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
