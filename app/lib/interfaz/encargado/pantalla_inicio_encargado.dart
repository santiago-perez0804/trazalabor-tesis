import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../repositorio/repositorio_verificacion.dart';
import '../comunes/barra_app.dart';
import '../comunes/barra_sesion.dart';
import '../proveedores.dart';
import '../tema.dart';

/// Inicio del encargado: un resumen del día y las secciones de trabajo
/// (HU-002, HU-003, HU-005, HU-012, HU-013).
class PantallaInicioEncargado extends ConsumerWidget {
  const PantallaInicioEncargado({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final porVerificar = ref.watch(porVerificarProvider).value?.length;
    final deHoy = ref
        .watch(historialProvider(FiltroHistorial(desde: hoy, hasta: hoy)))
        .value
        ?.length;
    final activos = ref.watch(trabajadoresAsignablesProvider).value?.length;
    final sesion = ref.watch(sesionProvider);
    final nombre = sesion is ConSesion ? sesion.perfil.nombreCorto : '';

    final secciones = [
      (
        Icons.fact_check_outlined,
        'Revisar labores',
        porVerificar == null || porVerificar == 0
            ? 'Aprobar cierres y ver el historial'
            : porVerificar == 1
            ? '1 labor espera tu revisión'
            : '$porVerificar labores esperan tu revisión',
        '/encargado/verificacion',
      ),
      (
        Icons.add_task,
        'Nueva labor',
        'Asignar una labor con su lista',
        '/encargado/labores/nueva',
      ),
      (
        Icons.people_alt_outlined,
        'Trabajadores',
        'Altas, cambios y PIN',
        '/encargado/trabajadores',
      ),
      (
        Icons.grid_view,
        'Lotes y lugares',
        'Unidades productivas y sus códigos QR',
        '/encargado/unidades',
      ),
    ];
    return Scaffold(
      appBar: BarraApp(
        titulo: 'Hola, $nombre',
        subtitulo: fechaLarga(ahora),
        acciones: const [BotonSalir()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Resumen(
                  valor: porVerificar,
                  texto: 'por revisar',
                  destacado: (porVerificar ?? 0) > 0,
                  onTap: () => context.push('/encargado/verificacion'),
                ),
                const SizedBox(width: 10),
                _Resumen(valor: deHoy, texto: 'labores hoy'),
                const SizedBox(width: 10),
                _Resumen(
                  valor: activos,
                  texto: 'trabajadores',
                  onTap: () => context.push('/encargado/trabajadores'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final (icono, titulo, detalle, ruta) in secciones)
            Card(
              child: ListTile(
                minTileHeight: 76,
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: ColoresTrazaLabor.franjaConSenal,
                  child: Icon(
                    icono,
                    size: 28,
                    color: ColoresTrazaLabor.verdeCampo,
                  ),
                ),
                title: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(detalle, style: const TextStyle(fontSize: 15)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(ruta),
              ),
            ),
        ],
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({
    required this.valor,
    required this.texto,
    this.destacado = false,
    this.onTap,
  });

  final int? valor;
  final String texto;
  final bool destacado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fondo = destacado ? ColoresTrazaLabor.verdeCampo : Colors.white;
    final color = destacado ? Colors.white : ColoresTrazaLabor.verdeCampo;
    return Expanded(
      child: Material(
        color: fondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: destacado
                ? ColoresTrazaLabor.verdeCampo
                : ColoresTrazaLabor.borde,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  valor?.toString() ?? '–',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                // En una sola línea: se achica si no entra.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    texto,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: destacado
                          ? Colors.white
                          : ColoresTrazaLabor.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
