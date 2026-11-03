import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/tipo_evento.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/fabrica_eventos.dart';
import 'package:trazalabor/repositorio/registrar_accion.dart';

void main() {
  late BaseDatos db;
  final hora = DateTime(2026, 10, 20, 10, 5);

  const encargado = 'u-encargado';
  const trabajador = 'u-trabajador';
  const otroTrabajador = 'u-otro';
  const lote7 = 'up-lote7';

  setUp(() async {
    db = BaseDatos(NativeDatabase.memory());
    // Catálogo mínimo: usuarios y unidad productiva.
    for (final (id, rol, tel) in [
      (encargado, 'ENCARGADO', '3510000001'),
      (trabajador, 'TRABAJADOR', '3510000002'),
      (otroTrabajador, 'TRABAJADOR', '3510000003'),
    ]) {
      await db.into(db.usuarios).insert(UsuariosCompanion.insert(
            id: id,
            nombre: 'Usuario $id',
            telefono: tel,
            rol: rol,
            createdAtDevice: hora,
          ));
    }
    await db.into(db.unidadesProductivas).insert(
          UnidadesProductivasCompanion.insert(
            id: lote7,
            nombre: 'Lote 7',
            tipo: 'LOTE',
            codigoQr: 'TRZ-LOTE7',
          ),
        );
  });

  tearDown(() => db.close());

  Tarea tareaNueva(String id) => Tarea(
        id: id,
        unidadProductivaId: lote7,
        creadorId: encargado,
        asignadoId: trabajador,
        tipoLabor: 'APLICACION_FITOSANITARIA',
        fechaProgramada: '2026-10-20',
        requiereQr: true,
        evidenciaRequerida: 'FOTO_Y_AUDIO',
        estadoActual: 'CREADA',
        createdAtDevice: hora,
      );

  ItemChecklist item(String id, String tareaId, int orden) => ItemChecklist(
        id: id,
        tareaId: tareaId,
        orden: orden,
        descripcion: 'Ítem $orden',
        tipoRespuesta: 'NUMERO',
        obligatorio: true,
        completado: false,
      );

  Future<void> crearTarea(String id) => db.registrarAccion(Accion(
        cambios: [
          CambioEntidad(db.tareas, tareaNueva(id)),
          CambioEntidad(db.itemsChecklist, item('$id-i1', id, 1)),
        ],
        eventos: [
          nuevoEvento(
              tareaId: id,
              usuarioId: encargado,
              tipo: TipoEvento.creada,
              ahora: hora),
          nuevoEvento(
              tareaId: id,
              usuarioId: encargado,
              tipo: TipoEvento.asignada,
              ahora: hora),
        ],
      ));

  test('crear y asignar escribe entidad, eventos y operaciones juntas',
      () async {
    await crearTarea('t1');

    final tarea = await db.select(db.tareas).getSingle();
    expect(tarea.estadoActual, 'ASIGNADA');
    expect(await db.select(db.eventos).get(), hasLength(2));

    final ops = await db.select(db.operacionesPendientes).get();
    // tarea + ítem + 2 eventos
    expect(ops, hasLength(4));
    expect(ops.every((o) => o.estado == 'PENDIENTE'), isTrue);
    expect(ops.map((o) => o.entidad).toSet(),
        {'tarea', 'item_checklist', 'evento'});
  });

  test('si algo falla a mitad de la transacción no queda nada (HU-004 c2)',
      () async {
    final repetido = nuevoEvento(
        tareaId: 't2',
        usuarioId: encargado,
        tipo: TipoEvento.creada,
        ahora: hora);

    final accion = Accion(
      cambios: [CambioEntidad(db.tareas, tareaNueva('t2'))],
      // El mismo evento dos veces: el segundo insert viola la PK.
      eventos: [repetido, repetido],
    );

    await expectLater(db.registrarAccion(accion), throwsA(anything));

    expect(await db.select(db.tareas).get(), isEmpty);
    expect(await db.select(db.eventos).get(), isEmpty);
    expect(await db.select(db.operacionesPendientes).get(), isEmpty);
  });

  test('el payload encolado está listo para PostgREST', () async {
    await crearTarea('t3');
    final opEvento = await (db.select(db.operacionesPendientes)
          ..where((o) => o.entidad.equals('evento'))
          ..limit(1))
        .getSingle();

    final p = opEvento.payload;
    expect(p.containsKey('received_at_server'), isFalse,
        reason: 'la hora del servidor la pone el servidor');
    expect(p['tarea_id'], 't3', reason: 'claves en snake_case');
    expect(p['payload'], isA<Map>(), reason: 'jsonb como objeto, no string');
    expect(p['created_at_device'], endsWith('Z'), reason: 'fecha en UTC');
    expect(opEvento.entidadId, p['id']);
  });

  test('ITEM_COMPLETADO proyecta el ítem localmente sin encolarlo', () async {
    await crearTarea('t4');
    final antes = (await db.select(db.operacionesPendientes).get()).length;

    await db.registrarAccion(Accion(eventos: [
      nuevoEvento(
          tareaId: 't4',
          usuarioId: trabajador,
          tipo: TipoEvento.iniciada,
          ahora: hora.add(const Duration(minutes: 1))),
      nuevoEvento(
        tareaId: 't4',
        usuarioId: trabajador,
        tipo: TipoEvento.itemCompletado,
        payload: {'item_id': 't4-i1', 'valor': '1.5'},
        ahora: hora.add(const Duration(minutes: 2)),
      ),
    ]));

    final it = await db.select(db.itemsChecklist).getSingle();
    expect(it.completado, isTrue);
    expect(it.valor, '1.5');
    expect((await db.select(db.tareas).getSingle()).estadoActual, 'INICIADA');

    final ops = await db.select(db.operacionesPendientes).get();
    // Solo se agregan los 2 eventos; la proyección no viaja.
    expect(ops.length - antes, 2);
    expect(ops.where((o) => o.entidad == 'item_checklist'), hasLength(1));
  });

  test('REASIGNADA cambia el asignado y reinicia los ítems', () async {
    await crearTarea('t5');
    await db.registrarAccion(Accion(eventos: [
      nuevoEvento(
        tareaId: 't5',
        usuarioId: trabajador,
        tipo: TipoEvento.itemCompletado,
        payload: {'item_id': 't5-i1', 'valor': '2'},
        ahora: hora.add(const Duration(minutes: 1)),
      ),
      nuevoEvento(
        tareaId: 't5',
        usuarioId: trabajador,
        tipo: TipoEvento.noCompletada,
        payload: {'motivo': 'se rompió la pulverizadora'},
        ahora: hora.add(const Duration(minutes: 2)),
      ),
      nuevoEvento(
        tareaId: 't5',
        usuarioId: encargado,
        tipo: TipoEvento.reasignada,
        payload: {
          'nuevo_asignado_id': otroTrabajador,
          'motivo': 'reprogramar'
        },
        ahora: hora.add(const Duration(minutes: 3)),
      ),
    ]));

    final tarea = await db.select(db.tareas).getSingle();
    expect(tarea.estadoActual, 'ASIGNADA');
    expect(tarea.asignadoId, otroTrabajador);

    final it = await db.select(db.itemsChecklist).getSingle();
    expect(it.completado, isFalse);
    expect(it.valor, isNull);

    // Los eventos anteriores siguen intactos (HU-012 c3).
    expect(await db.select(db.eventos).get(), hasLength(5));
  });

  test('las claves foráneas están activas', () async {
    final huerfana = tareaNueva('t6').copyWith(unidadProductivaId: 'no-existe');
    await expectLater(
      db.registrarAccion(Accion(cambios: [CambioEntidad(db.tareas, huerfana)])),
      throwsA(anything),
    );
    expect(await db.select(db.operacionesPendientes).get(), isEmpty);
  });

  test('un evento nunca se reemplaza: reinsertarlo falla', () async {
    final e = nuevoEvento(
        tareaId: 't7', usuarioId: encargado, tipo: TipoEvento.creada);
    await crearTarea('t7');
    await db.registrarAccion(Accion(eventos: [e]));
    await expectLater(
      db.registrarAccion(Accion(eventos: [e.copyWith(tipo: 'VERIFICADA')])),
      throwsA(anything),
    );
    final guardado = await (db.select(db.eventos)
          ..where((x) => x.id.equals(e.id)))
        .getSingle();
    expect(guardado.tipo, 'CREADA');
  });
}
