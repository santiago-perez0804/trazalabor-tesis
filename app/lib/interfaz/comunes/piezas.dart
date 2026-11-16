import 'package:flutter/material.dart';

import '../tema.dart';

/// "Paso 2 de 3" con la barra de segmentos de la Figura 5 (pantallas C y D).
class IndicadorPasos extends StatelessWidget {
  const IndicadorPasos({super.key, required this.paso, this.total = 3});

  final int paso;
  final int total;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Paso $paso de $total',
        key: const ValueKey('indicador-paso'),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: ColoresTrazaLabor.textoSecundario,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  color: i <= paso
                      ? ColoresTrazaLabor.verdeCampo
                      : ColoresTrazaLabor.borde,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ],
      ),
    ],
  );
}

/// Título de una sección ("Marcá lo que hiciste", "Qué pasó").
class Rotulo extends StatelessWidget {
  const Rotulo(this.texto, {super.key});
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 8),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
    ),
  );
}

/// Recuadro de color suave con ícono, un título y un detalle opcional
/// ("Estás en el Lote 7", "Agregaste 1 foto y 1 audio").
class AvisoSuave extends StatelessWidget {
  const AvisoSuave({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.alerta = false,
  });

  final IconData icono;
  final String titulo;
  final String? detalle;

  /// Crema con texto marrón (pendiente) en lugar de verde claro.
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    final fondo = alerta
        ? ColoresTrazaLabor.franjaSinSenal
        : ColoresTrazaLabor.franjaConSenal;
    final frente = alerta
        ? ColoresTrazaLabor.pendiente
        : ColoresTrazaLabor.verdeCampo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icono, color: frente, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: frente,
                  ),
                ),
                if (detalle != null)
                  Text(
                    detalle!,
                    style: TextStyle(fontSize: 14.5, color: frente),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón cuadrado grande con ícono arriba ("Sacar foto", "Grabar audio").
class BotonGrande extends StatelessWidget {
  const BotonGrande({
    super.key,
    required this.icono,
    required this.texto,
    required this.onPressed,
    this.activo = false,
  });

  final IconData icono;
  final String texto;
  final VoidCallback? onPressed;

  /// Grabando: se pinta de rojo para que se note.
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final color = activo
        ? ColoresTrazaLabor.sinConexion
        : ColoresTrazaLabor.verdeCampo;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 112),
        padding: const EdgeInsets.all(10),
        foregroundColor: color,
        backgroundColor: activo ? const Color(0xFFFBEAEA) : Colors.white,
        side: BorderSide(color: color, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 36),
          const SizedBox(height: 8),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Botón de borde ámbar con dos renglones ("No pude terminar / Contá el
/// motivo con un audio").
class BotonAlternativo extends StatelessWidget {
  const BotonAlternativo({
    super.key,
    required this.texto,
    required this.detalle,
    required this.onPressed,
  });

  final String texto;
  final String detalle;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 64),
      foregroundColor: ColoresTrazaLabor.pendiente,
      side: const BorderSide(color: ColoresTrazaLabor.ambar, width: 1.6),
    ),
    onPressed: onPressed,
    child: Column(
      children: [
        Text(texto),
        Text(
          detalle,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w400),
        ),
      ],
    ),
  );
}
