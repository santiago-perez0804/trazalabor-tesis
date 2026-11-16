import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/plantillas_labor.dart';
import 'package:trazalabor/dominio/tipo_evento.dart';
import 'package:trazalabor/dominio/validar_cierre.dart';
import 'package:trazalabor/dominio/validar_labor.dart';
import 'package:trazalabor/dominio/validar_verificacion.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/repositorio_ejecucion.dart';
import 'package:trazalabor/repositorio/repositorio_labores.dart';
import 'package:trazalabor/repositorio/repositorio_verificacion.dart';

/// HU-012 (verificar, aprobar o reasignar) y HU-013 (historial).
void main() {
  late BaseDatos db;
  late RepositorioEjecucion ejec;
  late RepositorioVerificacion verif;
  late DateTime ahora;
  const encargado = 'u-enc';
  const juan = 'u-juan';
  const pedro = 'u-pedro';

  setUp(() async {
    db = BaseDatos(NativeDatabase.memory());
    ahora = DateTime(2026, 11, 7, 8);
    DateTime reloj() => ahora = ahora.add(const Duration(minutes: 1));
    ejec = RepositorioEjecucion(db, reloj: reloj);
    verif = RepositorioVerificacion(db, reloj: reloj);
    for (final (id, nombre, rol, tel) in [
      (encargado, 'Encargado', 'ENCARGADO', '3510000001'),
      (juan, 'Juan P.', 'TRABAJADOR', '3510000002'),
      (pedro, 'Pedro G.', 'TRABAJADOR', '3510000003'),
    ]) {
      await db
          .into(db.usuarios)
          .insert(
            UsuariosCompanion.insert(
              id: id,
              nombre: nombre,
              telefono: tel,
              rol: rol,
              createdAtDevice: ahora,
            ),
          );
    }
    for (final (id, nombre) in [('up-7', 'Lote 7'), ('up-2', 'Potrero 2')]) {
      await db
          .into(db.unidadesProductivas)
          .insert(
            UnidadesProductivasCompanion.insert(
              id: id,
              nombre: nombre,
              tipo: 'LOTE',
              codigoQr: 'qr-$id',
            ),
          );
    }
  });

  tearDown(() => db.close());

  /// Labor de mantenimiento sin evidencia ni QR, para cerrar rápido.
  Future<String> asignar({
    String unidad = 'up-7',
    String asignado = juan,
    DateTime? fecha,
  }) => RepositorioLabores(db, reloj: () => ahora).crearLabor(
    BorradorLabor(
      unidadProductivaId: unidad,
      asignadoId: asignado,
      tipoLabor: TipoLabor.mantenimiento,
      fechaProgramada: fecha ?? DateTime(2026, 11, 7),
      items: plantillaPara(TipoLabor.mantenimiento).items,
      evidencia: EvidenciaRequerida.ninguna,
      requiereQr: false,
    ),
    creadorId: encargado,
  );

  Future<void> completarTodo(String tareaId) async {
    final d = (await ejec.leerDetalle(tareaId))!;
    for (final i in d.items) {
      await ejec.completarItem(
        tareaId,
        i.id,
        i.tipoRespuesta == 'CHECK' ? null : 'Cambio de aceite',
        usuarioId: juan,
      );
    }
    await ejec.cerrarCompletada(tareaId, usuarioId: juan);
  }

  Future<String> estado(String tareaId) async => (await (db.select(
    db.tareas,
  )..where((t) => t.id.equals(tareaId))).getSingle()).estadoActual;

  test('las labores cerradas aparecen en "Por verificar"', () async {
    final a = await asignar();
    await asignar(); // sigue abierta
    await completarTodo(a);

    final lista = await verif.observarPorVerificar().first;
    expect(lista.map((l) => l.tarea.id), [a]);
    expect(lista.single.trabajadorNombre, 'Juan P.');
    expect(lista.single.unidadNombre, 'Lote 7');
  });

  test(
    'c1: el detalle trae ítems, cronología completa y si el cierre llegó',
    () async {
      final a = await asignar();
      await completarTodo(a);

      final d = (await verif.leerDetalle(a))!;
      expect(d.detalle.completados, d.detalle.items.length);
      expect(d.cronologia.map((e) => e.tipo), [
        TipoEvento.creada,
        TipoEvento.asignada,
        TipoEvento.iniciada,
        TipoEvento.itemCompletado,
        TipoEvento.itemCompletado,
        TipoEvento.completada,
      ]);
      expect(d.cronologia.last.autor, 'Juan P.');
      expect(d.cierreSincronizado, isFalse, reason: 'todavía no se envió');
    },
  );

  test(
    'c2: aprobar registra VERIFICADA y la labor sale de "Por verificar"',
    () async {
      final a = await asignar();
      await completarTodo(a);

      await verif.aprobar(a, encargadoId: encargado);

      expect(await estado(a), 'VERIFICADA');
      expect(await verif.observarPorVerificar().first, isEmpty);
      final ops = await db.select(db.operacionesPendientes).get();
      expect(
        ops.where((o) => o.payload['tipo'] == 'VERIFICADA'),
        hasLength(1),
        reason: 'el evento queda en la bandeja de salida',
      );
    },
  );

  test('c2: no se aprueba lo que no está completado', () async {
    final a = await asignar();
    await expectLater(
      verif.aprobar(a, encargadoId: encargado),
      throwsA(isA<AccionRechazada>()),
    );
    await ejec.cerrarNoCompletada(a, usuarioId: juan, motivo: 'Llovió');
    await expectLater(
      verif.aprobar(a, encargadoId: encargado),
      throwsA(isA<AccionRechazada>()),
    );
  });

  test(
    'c3: reasignar vuelve la labor a ASIGNADA sin borrar lo anterior',
    () async {
      final a = await asignar();
      await ejec.cerrarNoCompletada(a, usuarioId: juan, motivo: 'Llovió');
      final antes = await db.select(db.eventos).get();

      await verif.reasignar(
        a,
        encargadoId: encargado,
        nuevoTrabajadorId: pedro,
        motivo: 'Hacerla el lunes',
      );

      expect(await estado(a), 'ASIGNADA');
      final tarea = await (db.select(
        db.tareas,
      )..where((t) => t.id.equals(a))).getSingle();
      expect(tarea.asignadoId, pedro);
      final despues = await db.select(db.eventos).get();
      expect(despues.length, antes.length + 1);
      expect(despues.map((e) => e.id), containsAll(antes.map((e) => e.id)));
      final r = despues.singleWhere((e) => e.tipo == 'REASIGNADA');
      expect(r.payload, {
        'nuevo_asignado_id': pedro,
        'motivo': 'Hacerla el lunes',
      });
      // El ciclo nuevo arranca con la lista sin completar.
      final d = (await ejec.leerDetalle(a))!;
      expect(d.completados, 0);
    },
  );

  test('c3: reasignar pide trabajador y motivo', () {
    expect(
      motivoNoReasignable(
        EstadoTarea.completada,
        nuevoTrabajadorId: null,
        motivo: 'x',
      ),
      isNotNull,
    );
    expect(
      motivoNoReasignable(
        EstadoTarea.completada,
        nuevoTrabajadorId: pedro,
        motivo: '  ',
      ),
      isNotNull,
    );
    expect(
      motivoNoReasignable(
        EstadoTarea.iniciada,
        nuevoTrabajadorId: pedro,
        motivo: 'x',
      ),
      isNotNull,
    );
    expect(
      motivoNoReasignable(
        EstadoTarea.noCompletada,
        nuevoTrabajadorId: pedro,
        motivo: 'x',
      ),
      isNull,
    );
  });

  test(
    'HU-013 c1: el historial filtra por unidad, trabajador y período',
    () async {
      final a = await asignar(fecha: DateTime(2026, 11, 2));
      final b = await asignar(unidad: 'up-2', fecha: DateTime(2026, 11, 5));
      final c = await asignar(asignado: pedro, fecha: DateTime(2026, 11, 7));

      Future<List<String>> ids(FiltroHistorial f) async => [
        for (final l in await verif.observarHistorial(f).first) l.tarea.id,
      ];

      expect(await ids(const FiltroHistorial()), [c, b, a]);
      expect(await ids(const FiltroHistorial(unidadId: 'up-2')), [b]);
      expect(await ids(const FiltroHistorial(trabajadorId: pedro)), [c]);
      expect(
        await ids(
          FiltroHistorial(
            desde: DateTime(2026, 11, 1),
            hasta: DateTime(2026, 11, 5),
          ),
        ),
        [b, a],
      );
    },
  );

  test(
    'HU-013 c3: sin labores para los filtros, la lista queda vacía',
    () async {
      await asignar();
      expect(
        await verif
            .observarHistorial(
              FiltroHistorial(
                desde: DateTime(2025, 1, 1),
                hasta: DateTime(2025, 1, 31),
              ),
            )
            .first,
        isEmpty,
      );
    },
  );
}
