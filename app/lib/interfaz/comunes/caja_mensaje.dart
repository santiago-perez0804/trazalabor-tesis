import 'package:flutter/material.dart';

import '../tema.dart';
import 'contador_pendientes.dart';
import 'indicador_conexion.dart';

/// Recuadro de aviso (error o confirmación) con texto grande y buen contraste.
class CajaMensaje extends StatelessWidget {
  const CajaMensaje(this.lineas, {super.key, this.esError = true});

  final List<String> lineas;
  final bool esError;

  @override
  Widget build(BuildContext context) {
    final color =
        esError ? ColoresTrazaLabor.sinConexion : ColoresTrazaLabor.enLinea;
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

/// Fila con el contador de pendientes y el indicador de conexión, para las
/// pantallas que no llevan el saludo (ambos tienen que verse siempre).
class BarraEstado extends StatelessWidget {
  const BarraEstado({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(child: ContadorPendientes()),
            SizedBox(width: 8),
            IndicadorConexion(),
          ],
        ),
      );
}

/// Aviso estándar después de guardar algo en el teléfono.
void avisarGuardado(BuildContext context, String texto) {
  // Un nombre como "Juan P." ya trae el punto final.
  final frase = texto.replaceFirst(RegExp(r'\.\.$'), '.');
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('$frase Se enviará al haber señal.',
          style: const TextStyle(fontSize: 16)),
    ));
}

/// Pregunta de confirmación con botones grandes. Devuelve `true` si acepta.
Future<bool> confirmar(BuildContext context,
    {required String titulo,
    required String texto,
    required String accion}) async {
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
