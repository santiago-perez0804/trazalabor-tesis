import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tema.dart';
import 'indicador_conexion.dart';

/// Recuadro de aviso (error o confirmación) con texto grande y buen contraste.
class CajaMensaje extends StatelessWidget {
  const CajaMensaje(this.lineas, {super.key, this.esError = true});

  final List<String> lineas;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    final color = esError
        ? ColoresTrazaLabor.sinConexion
        : ColoresTrazaLabor.enLinea;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esError ? const Color(0xFFFBEAEA) : const Color(0xFFE6F2EA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lineas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(l, style: TextStyle(fontSize: 16, color: color)),
            ),
        ],
      ),
    );
  }
}

/// Aviso estándar después de guardar algo en el teléfono.
void avisarGuardado(BuildContext context, String texto) {
  // Un nombre como "Juan P." ya trae el punto final.
  final frase = texto.replaceFirst(RegExp(r'\.\.$'), '.');
  // Con señal se envía enseguida; sin señal queda en la bandeja de salida.
  final enLinea =
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(hayConexionProvider).value ??
      false;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          enLinea
              ? '$frase Se está enviando.'
              : '$frase Se enviará al haber señal.',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
}

/// Pregunta de confirmación con botones grandes. Devuelve `true` si acepta.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String accion,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(texto, style: const TextStyle(fontSize: 17)),
      actions: [
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(accion),
        ),
      ],
    ),
  );
  return r ?? false;
}
