import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../dominio/tipo_evento.dart';
import '../../dominio/validar_verificacion.dart';
import '../../repositorio/repositorio_verificacion.dart';
import '../comunes/barra_app.dart';
import '../proveedores.dart';
import '../tema.dart';

/// Pantalla E de la Figura 5 (HU-012, HU-013, T-27 a T-30): pestañas
/// "Por verificar" e "Historial".
class PantallaVerificacion extends StatelessWidget {
  const PantallaVerificacion({super.key, this.pestanaInicial = 0});

  final int pestanaInicial;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: pestanaInicial,
      child: Scaffold(
        appBar: const BarraApp(
          titulo: 'Revisar labores',
          subtitulo: 'Cierres para aprobar e historial',
          inferior: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFD5E3DC),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontFamily: 'Atkinson',
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            tabs: [
              Tab(text: 'Por revisar', height: 48),
              Tab(text: 'Historial', height: 48),
            ],
          ),
        ),
        body: const TabBarView(children: [_PorVerificar(), _Historial()]),
      ),
    );
  }
}

class _PorVerificar extends ConsumerWidget {
  const _PorVerificar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labores = ref.watch(porVerificarProvider).value;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (labores == null)
          const Center(child: CircularProgressIndicator())
        else if (labores.isEmpty)
          const _Vacio(
            icono: Icons.task_alt,
            texto:
                'No hay labores para verificar.\n'
                'Cuando un trabajador cierre una labor y se sincronice, '
                'aparece acá.',
          )
        else
          for (final l in labores) TarjetaLabor(l),
      ],
    );
  }
}

class _Historial extends ConsumerStatefulWidget {
  const _Historial();

  @override
  ConsumerState<_Historial> createState() => _HistorialState();
}

class _HistorialState extends ConsumerState<_Historial> {
  String? _unidadId;
  String? _trabajadorId;
  DateTimeRange? _periodo;

  @override
  Widget build(BuildContext context) {
    final unidades = ref.watch(unidadesProvider).value ?? const [];
    final trabajadores = ref.watch(trabajadoresProvider).value ?? const [];
    final filtro = FiltroHistorial(
      unidadId: _unidadId,
      trabajadorId: _trabajadorId,
      desde: _periodo?.start,
      hasta: _periodo?.end,
    );
    final labores = ref.watch(historialProvider(filtro)).value;
    final formato = DateFormat('d/M', 'es');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String?>(
          key: const ValueKey('filtro-unidad'),
          initialValue: _unidadId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Unidad'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todas')),
            for (final u in unidades)
              DropdownMenuItem(value: u.id, child: Text(u.nombre)),
          ],
          onChanged: (v) => setState(() => _unidadId = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          key: const ValueKey('filtro-trabajador'),
          initialValue: _trabajadorId,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Trabajador'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos')),
            for (final t in trabajadores)
              DropdownMenuItem(value: t.id, child: Text(t.nombre)),
          ],
          onChanged: (v) => setState(() => _trabajadorId = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  _periodo == null
                      ? 'Período: todos'
                      : '${formato.format(_periodo!.start)} al ${formato.format(_periodo!.end)}',
                ),
                onPressed: () async {
                  final ahora = DateTime.now();
                  final elegido = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(ahora.year - 2),
                    lastDate: DateTime(ahora.year + 1),
                    initialDateRange: _periodo,
                    helpText: 'Elegí el período',
                  );
                  if (elegido != null) setState(() => _periodo = elegido);
                },
              ),
            ),
            if (_periodo != null)
              IconButton(
                tooltip: 'Quitar período',
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _periodo = null),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (labores == null)
          const Center(child: CircularProgressIndicator())
        else if (labores.isEmpty)
          const _Vacio(
            icono: Icons.search_off,
            texto: 'No hay labores para esos filtros.',
          )
        else ...[
          Text(
            labores.length == 1 ? '1 labor' : '${labores.length} labores',
            style: const TextStyle(
              fontSize: 15,
              color: ColoresTrazaLabor.textoSecundario,
            ),
          ),
          const SizedBox(height: 4),
          for (final l in labores) TarjetaLabor(l, mostrarFecha: true),
        ],
      ],
    );
  }
}

/// Tarjeta de una labor para el encargado: unidad, tipo, responsable,
/// estado y fecha. Abre el detalle con la cronología.
class TarjetaLabor extends StatelessWidget {
  const TarjetaLabor(this.l, {super.key, this.mostrarFecha = false});

  final LaborResumen l;
  final bool mostrarFecha;

  @override
  Widget build(BuildContext context) {
    final (color, icono) = colorEstado(l.estado);
    final fecha = DateTime.tryParse(l.tarea.fechaProgramada);
    final cuando = mostrarFecha && fecha != null
        ? DateFormat('d/M', 'es').format(fecha)
        : l.ultimoMovimiento == null
        ? null
        : DateFormat('d/M · HH:mm', 'es').format(l.ultimoMovimiento!);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/encargado/labor/${l.tarea.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icono, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.unidadNombre} · ${l.tipoLabor.etiqueta}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      [l.trabajadorNombre, ?cuando].join(' · '),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      etiquetaEstado(l.estado),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Color e ícono de cada estado (contraste ≥ 4,5:1 sobre blanco).
(Color, IconData) colorEstado(EstadoTarea e) => switch (e) {
  EstadoTarea.completada => (ColoresTrazaLabor.enLinea, Icons.check_circle),
  EstadoTarea.verificada => (ColoresTrazaLabor.verdeCampo, Icons.verified),
  EstadoTarea.noCompletada => (ColoresTrazaLabor.sinConexion, Icons.cancel),
  EstadoTarea.iniciada => (ColoresTrazaLabor.pendiente, Icons.timelapse),
  _ => (ColoresTrazaLabor.textoSecundario, Icons.schedule),
};

class ChipEstado extends StatelessWidget {
  const ChipEstado(this.estado, {super.key});
  final EstadoTarea estado;

  @override
  Widget build(BuildContext context) {
    final (color, _) = colorEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        etiquetaEstado(estado),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.icono, required this.texto});
  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        Icon(icono, size: 56, color: ColoresTrazaLabor.textoSecundario),
        const SizedBox(height: 12),
        Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17),
        ),
      ],
    ),
  );
}
