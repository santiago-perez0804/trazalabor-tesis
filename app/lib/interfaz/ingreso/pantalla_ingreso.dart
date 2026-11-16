import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dominio/perfil.dart';
import '../../dominio/pin.dart';
import '../../repositorio/repositorio_sesion.dart';
import '../comunes/barra_app.dart';
import '../comunes/teclado_pin.dart';
import '../proveedores.dart';
import '../tema.dart';

/// Ingreso (pantalla F de la Figura 5): teléfono y PIN en una sola pantalla
/// (HU-001). Si es el primer ingreso de un trabajador preregistrado, el PIN
/// escrito es el que elige y se pide repetirlo para activar la cuenta
/// (HU-002 c3).
class PantallaIngreso extends ConsumerStatefulWidget {
  const PantallaIngreso({super.key});

  @override
  ConsumerState<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends ConsumerState<PantallaIngreso> {
  final _telefono = TextEditingController();
  String _pin = '';
  String? _mensaje;
  var _cargando = false;

  /// PIN elegido en el primer ingreso, a la espera de que se repita.
  String? _pinNuevo;

  /// Cambia para vaciar el teclado después de un error.
  var _reinicio = 0;
  Perfil? _recordado;

  @override
  void initState() {
    super.initState();
    final sesion = ref.read(sesionProvider);
    if (sesion is SinSesion && sesion.recordado != null) {
      _recordado = sesion.recordado;
      _telefono.text = _recordado!.telefono;
    }
  }

  @override
  void dispose() {
    _telefono.dispose();
    super.dispose();
  }

  RepositorioSesion get _repo => ref.read(repositorioSesionProvider);

  void _mostrar(
    String? mensaje, {
    bool cargando = false,
    bool limpiar = false,
  }) => setState(() {
    _cargando = cargando;
    _mensaje = mensaje;
    if (limpiar) {
      _pin = '';
      _reinicio++;
    }
  });

  Future<void> _ingresar() async {
    final error = validarTelefono(_telefono.text);
    if (error != null) return _mostrar(error);
    if (_pin.length != longitudPin) {
      return _mostrar('Escribí los 6 números de tu PIN.');
    }
    FocusScope.of(context).unfocus();
    final pin = _pin;

    _mostrar(null, cargando: true);
    final paso = await _repo.pasoSiguiente(_telefono.text);
    if (!mounted) return;
    switch (paso) {
      case PasoSiguiente.ingresarPin:
        _resolver(await _repo.ingresar(_telefono.text, pin));
      case PasoSiguiente.crearPin:
        // Primer ingreso: el PIN escrito es el que elige.
        final motivo = validarPinNuevo(pin);
        if (motivo != null) {
          return _mostrar(
            'Es tu primer ingreso: elegí tu PIN. $motivo',
            limpiar: true,
          );
        }
        setState(() {
          _cargando = false;
          _mensaje = null;
          _pinNuevo = pin;
        });
      case PasoSiguiente.desactivado:
        _mostrar(
          'Tu cuenta está desactivada. Hablá con el encargado.',
          limpiar: true,
        );
      case PasoSiguiente.noDadoDeAlta:
        _mostrar(
          'Este número no está dado de alta. Pedile al encargado que te '
          'agregue.',
          limpiar: true,
        );
      case PasoSiguiente.necesitaConexion:
        _mostrar(
          'Sin señal. El primer ingreso en este teléfono necesita señal.',
          limpiar: true,
        );
    }
  }

  Future<void> _repetirPin(String pin) async {
    if (pin != _pinNuevo) {
      setState(() => _pinNuevo = null);
      return _mostrar('Los PIN no coinciden. Elegilo de nuevo.', limpiar: true);
    }
    _mostrar(null, cargando: true);
    _resolver(await _repo.activar(_telefono.text, pin));
  }

  void _resolver(ResultadoIngreso r) {
    if (!mounted) return;
    switch (r) {
      case IngresoCorrecto():
        ref.read(sesionProvider.notifier).ingresado(r);
      case IngresoRechazado(:final mensaje):
        _pinNuevo = null;
        _mostrar(mensaje, limpiar: true);
      case IngresoBloqueado(:final minutos):
        _mostrar(
          'Ingresaste mal el PIN 5 veces. Esperá $minutos '
          '${minutos == 1 ? 'minuto' : 'minutos'} y probá de nuevo.',
          limpiar: true,
        );
      case IngresoPinRestablecido():
        _mostrar(
          'El encargado restableció tu PIN. Elegí uno nuevo y tocá '
          '"Ingresar".',
          limpiar: true,
        );
    }
  }

  void _otroNumero() {
    ref.read(sesionProvider.notifier).olvidarRecordado();
    setState(() {
      _recordado = null;
      _telefono.clear();
      _pinNuevo = null;
      _mensaje = null;
      _pin = '';
      _reinicio++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repitiendo = _pinNuevo != null;
    return Scaffold(
      appBar: const BarraApp(
        titulo: 'Labores del campo',
        subtitulo: 'Ingresá con tu teléfono y tu PIN',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            if (repitiendo) ...[
              const Text(
                'Repetí tu PIN',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Es tu primer ingreso: escribilo otra vez para confirmarlo.',
                style: TextStyle(
                  fontSize: 16,
                  color: ColoresTrazaLabor.textoSecundario,
                ),
              ),
              const SizedBox(height: 20),
              TecladoPin(
                key: const ValueKey('teclado-repetir'),
                habilitado: !_cargando,
                onCompleto: _repetirPin,
              ),
            ] else ...[
              if (_recordado != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hola, ${_recordado!.nombreCorto}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _cargando ? null : _otroNumero,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text('No soy ${_recordado!.nombreCorto}'),
                    ),
                  ],
                )
              else ...[
                const _Rotulo('Tu número de teléfono'),
                TextField(
                  key: const ValueKey('campo-telefono'),
                  controller: _telefono,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 22, letterSpacing: 1.2),
                  decoration: const InputDecoration(
                    hintText: '351 555 1234',
                    helperText: 'Con código de área, sin 0 ni 15.',
                  ),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
              ],
              const SizedBox(height: 18),
              const _Rotulo('Tu PIN de 6 números'),
              const SizedBox(height: 6),
              TecladoPin(
                key: ValueKey('teclado-$_reinicio'),
                habilitado: !_cargando,
                enviarAlCompletar: false,
                onCambio: (pin) => setState(() => _pin = pin),
              ),
            ],
            if (_cargando)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_mensaje != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  key: const ValueKey('mensaje-ingreso'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBEAEA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _mensaje!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: ColoresTrazaLabor.sinConexion,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            if (repitiendo)
              OutlinedButton(
                onPressed: _cargando
                    ? null
                    : () => setState(() {
                        _pinNuevo = null;
                        _pin = '';
                        _reinicio++;
                      }),
                child: const Text('Volver'),
              )
            else
              FilledButton(
                key: const ValueKey('boton-ingresar'),
                onPressed: _cargando || _pin.length != longitudPin
                    ? null
                    : _ingresar,
                child: const Text('Ingresar'),
              ),
            const SizedBox(height: 12),
            const Text(
              '¿Olvidaste el PIN? Pedíselo al encargado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: ColoresTrazaLabor.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  );
}
