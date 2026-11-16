import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dominio/catalogos.dart';
import '../../repositorio/base_datos.dart';
import '../../repositorio/repositorio_trabajadores.dart';
import '../comunes/barra_app.dart';
import '../comunes/caja_mensaje.dart';
import '../comunes/indicador_conexion.dart';
import '../proveedores.dart';
import '../tema.dart';

/// Alta (sin [id]) o edición de un trabajador (HU-002 c1, c2 y c4).
class FormularioTrabajador extends ConsumerStatefulWidget {
  const FormularioTrabajador({super.key, this.id});

  final String? id;

  @override
  ConsumerState<FormularioTrabajador> createState() =>
      _FormularioTrabajadorState();
}

class _FormularioTrabajadorState extends ConsumerState<FormularioTrabajador> {
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _especialidad = TextEditingController();
  Map<String, String> _errores = const {};
  bool _cargado = false;
  bool _ocupado = false;

  bool get _esAlta => widget.id == null;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _especialidad.dispose();
    super.dispose();
  }

  void _cargar(Usuario u) {
    if (_cargado) return;
    _cargado = true;
    _nombre.text = u.nombre;
    _telefono.text = u.telefono;
    _especialidad.text = u.especialidad ?? '';
  }

  Future<void> _guardar() async {
    final repo = ref.read(repositorioTrabajadoresProvider);
    setState(() => _ocupado = true);
    try {
      if (_esAlta) {
        await repo.alta(
          nombre: _nombre.text,
          telefono: _telefono.text,
          especialidad: _especialidad.text,
        );
      } else {
        await repo.modificar(
          widget.id!,
          nombre: _nombre.text,
          telefono: _telefono.text,
          especialidad: _especialidad.text,
        );
      }
      if (!mounted) return;
      avisarGuardado(
        context,
        _esAlta ? 'Trabajador agregado.' : 'Cambios guardados.',
      );
      context.pop();
    } on DatosRechazados catch (e) {
      setState(() => _errores = e.errores);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _cambiarActivo(Usuario u) async {
    final repo = ref.read(repositorioTrabajadoresProvider);
    if (u.activo) {
      final ok = await confirmar(
        context,
        titulo: 'Desactivar a ${u.nombre}',
        texto:
            'No va a poder ingresar ni recibir labores nuevas. '
            'Sus labores anteriores se conservan.',
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
        u.activo ? 'Trabajador desactivado.' : 'Trabajador activado.',
      );
    }
  }

  Future<void> _restablecerPin(Usuario u) async {
    final ok = await confirmar(
      context,
      titulo: 'Restablecer PIN',
      texto:
          '${u.nombre} va a tener que elegir un PIN nuevo la próxima vez '
          'que entre. Vos no vas a conocer su PIN.',
      accion: 'Restablecer',
    );
    if (!ok || !mounted) return;
    setState(() => _ocupado = true);
    final motivo = await ref
        .read(repositorioTrabajadoresProvider)
        .restablecerPin(u.id);
    if (!mounted) return;
    setState(() => _ocupado = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          motivo ??
              'Listo. ${u.nombre} elige un PIN nuevo en su próximo ingreso.',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existente = _esAlta
        ? null
        : ref.watch(trabajadorProvider(widget.id!)).value;
    if (existente != null) _cargar(existente);
    final hayConexion = ref.watch(hayConexionProvider).value ?? false;

    return Scaffold(
      appBar: BarraApp(
        titulo: _esAlta ? 'Nuevo trabajador' : 'Datos del trabajador',
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            key: const ValueKey('campo-nombre'),
            controller: _nombre,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Nombre y apellido',
              errorText: _errores['nombre'],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('campo-telefono'),
            controller: _telefono,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 18, letterSpacing: 1),
            decoration: InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: const Icon(Icons.phone_android),
              errorText: _errores['telefono'],
              errorMaxLines: 3,
              helperText: _esAlta
                  ? 'Con código de área, sin 0 ni 15. Con este número va a '
                        'ingresar a la aplicación.'
                  : 'Si ya activó su cuenta, para cambiar el número primero '
                        'restablecé su PIN.',
              helperMaxLines: 3,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _especialidad,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(labelText: 'Puesto (opcional)'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final e in especialidadesSugeridas)
                ActionChip(
                  label: Text(e, style: const TextStyle(fontSize: 16)),
                  onPressed: () => setState(() => _especialidad.text = e),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const ValueKey('boton-guardar'),
            onPressed: _ocupado ? null : _guardar,
            icon: const Icon(Icons.save),
            label: Text(_esAlta ? 'Agregar trabajador' : 'Guardar cambios'),
          ),
          if (existente != null) ...[
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              existente.activo
                  ? 'Activo: puede ingresar y recibir labores.'
                  : 'Desactivado: no puede ingresar ni recibir labores.',
              style: TextStyle(
                fontSize: 16,
                color: existente.activo
                    ? ColoresTrazaLabor.enLinea
                    : ColoresTrazaLabor.sinConexion,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _ocupado ? null : () => _cambiarActivo(existente),
              icon: Icon(
                existente.activo
                    ? Icons.person_off_outlined
                    : Icons.person_outline,
              ),
              label: Text(
                existente.activo ? 'Desactivar trabajador' : 'Volver a activar',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _ocupado || !hayConexion || !existente.activo
                  ? null
                  : () => _restablecerPin(existente),
              icon: const Icon(Icons.lock_reset),
              label: const Text('Restablecer PIN'),
            ),
            if (!hayConexion)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Para restablecer el PIN hace falta conexión.',
                  style: TextStyle(
                    fontSize: 15,
                    color: ColoresTrazaLabor.textoSecundario,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
