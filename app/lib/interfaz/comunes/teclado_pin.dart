import 'package:flutter/material.dart';

import '../../dominio/pin.dart';
import '../tema.dart';

/// Teclado numérico propio para el PIN: teclas de 64 dp (cómodas con guantes
/// o a pleno sol), sin depender del teclado del sistema. Al completar los seis
/// dígitos llama a [onCompleto] y se limpia.
class TecladoPin extends StatefulWidget {
  const TecladoPin({required this.onCompleto, this.habilitado = true, super.key});

  final ValueChanged<String> onCompleto;
  final bool habilitado;

  @override
  State<TecladoPin> createState() => _TecladoPinState();
}

class _TecladoPinState extends State<TecladoPin> {
  String _digitos = '';

  void _tocar(String d) {
    if (!widget.habilitado || _digitos.length >= longitudPin) return;
    setState(() => _digitos += d);
    if (_digitos.length == longitudPin) {
      final pin = _digitos;
      setState(() => _digitos = '');
      widget.onCompleto(pin);
    }
  }

  void _borrar() {
    if (!widget.habilitado || _digitos.isEmpty) return;
    setState(() => _digitos = _digitos.substring(0, _digitos.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${_digitos.length} de $longitudPin números ingresados',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < longitudPin; i++)
                Container(
                  key: ValueKey('punto-$i'),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _digitos.length
                        ? ColoresTrazaLabor.verdeCampo
                        : Colors.transparent,
                    border: Border.all(
                        color: ColoresTrazaLabor.verdeCampo, width: 2),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        for (final fila in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '<'],
        ])
          Row(
            children: [
              for (final tecla in fila)
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _tecla(tecla),
                )),
            ],
          ),
      ],
    );
  }

  Widget _tecla(String tecla) {
    if (tecla.isEmpty) return const SizedBox(height: 64);
    final esBorrar = tecla == '<';
    return SizedBox(
      height: 64,
      child: OutlinedButton(
        key: ValueKey('tecla-$tecla'),
        onPressed: widget.habilitado ? (esBorrar ? _borrar : () => _tocar(tecla)) : null,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero,
        ),
        child: esBorrar
            ? const Icon(Icons.backspace_outlined, semanticLabel: 'Borrar')
            : Text(tecla,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
