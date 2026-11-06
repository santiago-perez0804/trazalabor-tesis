import '../dominio/tipo_evento.dart';
import '../dominio/validar_labor.dart';
import 'base_datos.dart';
import 'fabrica_eventos.dart';
import 'registrar_accion.dart';

/// La labor no se guardó porque falta algún dato (HU-005 c3).
class LaborIncompleta implements Exception {
  const LaborIncompleta(this.faltantes);
  final List<String> faltantes;

  @override
  String toString() => faltantes.join(' ');
}

/// Creación y asignación de labores (HU-005, T-13).
class RepositorioLabores {
  RepositorioLabores(this._db, {DateTime Function()? reloj})
      : _reloj = reloj ?? DateTime.now;

  final BaseDatos _db;
  final DateTime Function() _reloj;

  /// HU-005 c1: la tarea, sus ítems y los eventos CREADA y ASIGNADA se guardan
  /// en el dispositivo en una sola transacción, aun sin conexión.
  /// Devuelve el id de la tarea.
  Future<String> crearLabor(BorradorLabor borrador,
      {required String creadorId}) async {
    final faltantes = validarLabor(borrador);
    if (faltantes.isNotEmpty) throw LaborIncompleta(faltantes);

    final ahora = _reloj();
    final tareaId = nuevoId();
    final descripcion = borrador.descripcion.trim();

    final tarea = Tarea(
      id: tareaId,
      unidadProductivaId: borrador.unidadProductivaId!,
      creadorId: creadorId,
      asignadoId: borrador.asignadoId!,
      tipoLabor: borrador.tipoLabor!.valor,
      descripcion: descripcion.isEmpty ? null : descripcion,
      fechaProgramada: fechaComoTexto(borrador.fechaProgramada!),
      requiereQr: borrador.requiereQr,
      evidenciaRequerida: borrador.evidencia.valor,
      estadoActual: EstadoTarea.creada.valor,
      createdAtDevice: ahora,
    );

    final items = [
      for (final (i, item) in borrador.items.indexed)
        ItemChecklist(
          id: nuevoId(),
          tareaId: tareaId,
          orden: i + 1,
          descripcion: item.descripcion.trim(),
          tipoRespuesta: item.tipoRespuesta.valor,
          obligatorio: item.obligatorio,
          completado: false,
        ),
    ];

    await _db.registrarAccion(Accion(
      cambios: [
        CambioEntidad(_db.tareas, tarea),
        for (final item in items) CambioEntidad(_db.itemsChecklist, item),
      ],
      eventos: [
        nuevoEvento(
            tareaId: tareaId,
            usuarioId: creadorId,
            tipo: TipoEvento.creada,
            ahora: ahora),
        nuevoEvento(
            tareaId: tareaId,
            usuarioId: creadorId,
            tipo: TipoEvento.asignada,
            payload: {'asignado_id': borrador.asignadoId},
            ahora: ahora),
      ],
    ));
    return tareaId;
  }
}
