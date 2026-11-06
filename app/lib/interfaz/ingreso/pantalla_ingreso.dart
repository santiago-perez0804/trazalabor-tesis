import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dominio/perfil.dart';
import '../../dominio/pin.dart';
import '../../repositorio/repositorio_sesion.dart';
import '../comunes/indicador_conexion.dart';
import '../comunes/teclado_pin.dart';
import '../proveedores.dart';
import '../tema.dart';

enum _Paso { telefono, ingresarPin, crearPin, repetirPin }

/// Inicio de sesión con teléfono y PIN (HU-001) y activación de la cuenta del
/// trabajador preregistrado (HU-002 c3), en pocos pasos y sin teclado del sistema
/// para el PIN.
class PantallaIngreso extends ConsumerStatefulWidget {
  const PantallaIngreso({super.key});

  @override
  ConsumerState<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends ConsumerState<PantallaIngreso> {
  final _telefono = TextEditingController();
  var _paso = _Paso.telefono;
  String? _mensaje;
  var _cargando = false;
  String? _pinNuevo;
  Perfil? _recordado;

  @override
  void initState() {
    super.initState();
    final sesion = ref.read(sesionProvider);
    if (sesion is SinSesion && sesion.recordado != null) {
      _recordado = sesion.recordado;
      _telefono.text = _recordado!.telefono;
      _paso = _Paso.ingresarPin;
    }
  }

  @override
  void dispose() {
    _telefono.dispose();
    super.dispose();
  }

  RepositorioSesion get _repo => ref.read(repositorioSesionProvider);

  void _mostrar(String? mensaje, {bool cargando = false}) => setState(() {
        _cargando = cargando;
        _mensaje = mensaje;
      });

  Future<void> _continuar() async {
    final error = validarTelefono(_telefono.text);
    if (error != null) return _mostrar(error);

    _mostrar(null, cargando: true);
    final paso = await _repo.pasoSiguiente(_telefono.text);
    if (!mounted) return;
    setState(() {
      _cargando = false;
      switch (paso) {
        case PasoSiguiente.crearPin:
          _paso = _Paso.crearPin;
        case PasoSiguiente.ingresarPin:
          _paso = _Paso.ingresarPin;
        case PasoSiguiente.desactivado:
          _mensaje = 'Tu cuenta está desactivada. Hablá con el encargado.';
        case PasoSiguiente.noDadoDeAlta:
          _mensaje =
              'Este número no está dado de alta. Pedile al encargado que te agregue.';
        case PasoSiguiente.necesitaConexion:
          _mensaje = 'Sin conexión. El primer ingreso en este teléfono necesita señal.';
      }
    });
  }

  Future<void> _ingresar(String pin) async {
    _mostrar(null, cargando: true);
    _resolver(await _repo.ingresar(_telefono.text, pin));
  }

  void _elegirPin(String pin) {
    final error = validarPinNuevo(pin);
    setState(() {
      _mensaje = error;
      if (error == null) {
        _pinNuevo = pin;
        _paso = _Paso.repetirPin;
      }
    });
  }

  Future<void> _repetirPin(String pin) async {
    if (pin != _pinNuevo) {
      return setState(() {
        _mensaje = 'Los PIN no coinciden. Elegilo de nuevo.';
        _paso = _Paso.crearPin;
      });
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
        _mostrar(mensaje);
      case IngresoBloqueado(:final minutos):
        _mostrar('Ingresaste mal el PIN 5 veces. Esperá $minutos '
            '${minutos == 1 ? 'minuto' : 'minutos'} y probá de nuevo.');
      case IngresoPinRestablecido():
        _paso = _Paso.crearPin;
        _mostrar('El encargado restableció tu PIN. Elegí uno nuevo.');
    }
  }

  void _otroNumero() {
    ref.read(sesionProvider.notifier).olvidarRecordado();
    setState(() {
      _recordado = null;
      _telefono.clear();
      _paso = _Paso.telefono;
      _mensaje = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final (titulo, ayuda) = switch (_paso) {
      _Paso.telefono => ('Ingresá tu número de teléfono', 'Con código de área, sin 0 ni 15.'),
      _Paso.ingresarPin => (
          _recordado != null ? 'Hola, ${_recordado!.nombreCorto}' : 'Ingresá tu PIN',
          'Número ${_telefono.text}'
        ),
      _Paso.crearPin => (
          'Elegí tu PIN de 6 números',
          'Es tu primer ingreso. No uses el mismo número repetido ni números seguidos.'
        ),
      _Paso.repetirPin => ('Repetí tu PIN', 'Para confirmar que lo escribiste bien.'),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('TrazaLabor')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Align(alignment: Alignment.centerRight, child: IndicadorConexion()),
            const SizedBox(height: 16),
            Text(titulo,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(ayuda,
                style: const TextStyle(
                    fontSize: 16, color: ColoresTrazaLabor.textoSecundario)),
            const SizedBox(height: 24),
            if (_paso == _Paso.telefono) ...[
              TextField(
                key: const ValueKey('campo-telefono'),
                controller: _telefono,
                keyboardType: TextInputType.phone,
                autofocus: true,
                style: const TextStyle(fontSize: 24, letterSpacing: 1.5),
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  hintText: '351 555 1234',
                  prefixIcon: Icon(Icons.phone_android),
                ),
                onSubmitted: (_) => _continuar(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _cargando ? null : _continuar,
                child: const Text('Continuar'),
              ),
            ] else
              TecladoPin(
                key: ValueKey(_paso),
                habilitado: !_cargando,
                onCompleto: switch (_paso) {
                  _Paso.ingresarPin => _ingresar,
                  _Paso.crearPin => _elegirPin,
                  _ => _repetirPin,
                },
              ),
            if (_cargando)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_mensaje != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  key: const ValueKey('mensaje-ingreso'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBEAEA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_mensaje!,
                      style: const TextStyle(
                          fontSize: 16, color: ColoresTrazaLabor.sinConexion)),
                ),
              ),
            if (_paso != _Paso.telefono)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  onPressed: _cargando ? null : _otroNumero,
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  child: Text(_recordado != null
                      ? 'No soy ${_recordado!.nombreCorto}'
                      : 'Usar otro número'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
