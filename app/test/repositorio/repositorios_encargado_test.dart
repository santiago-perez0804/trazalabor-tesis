import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/plantillas_labor.dart';
import 'package:trazalabor/dominio/validar_labor.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/repositorio_bandeja.dart';
import 'package:trazalabor/repositorio/repositorio_labores.dart';
import 'package:trazalabor/repositorio/repositorio_trabajadores.dart';
import 'package:trazalabor/repositorio/repositorio_unidades.dart';

import '../apoyo/administracion_falsa.dart';

void main() {
  late BaseDatos db;
  late AdministracionFalsa remoto;
  late RepositorioTrabajadores trabajadores;
  late RepositorioUnidades unidades;
  late RepositorioLabores labores;
  final hora = DateTime(2026, 11, 6, 8);
  const encargado = 'u-encargado';

  setUp(() async {
    db = BaseDatos(NativeDatabase.memory());
    remoto = AdministracionFalsa();
    trabajadores = RepositorioTrabajadores(db, remoto, reloj: () => hora);
    unidades = RepositorioUnidades(db);
    labores = RepositorioLabores(db, reloj: () => hora);
    // El encargado queda en la base local al iniciar sesión.
    await db.into(db.usuarios).insert(UsuariosCompanion.insert(
          id: encargado,
          nombre: 'Encargado de prueba',
          telefono: '3510000001',
          rol: 'ENCARGADO',
          createdAtDevice: hora,
        ));
  });

  tearDown(() => db.close());

  Future<List<OperacionPendiente>> operaciones() =>
      db.select(db.operacionesPendientes).get();

  group('trabajadores (HU-002)', () {
    test('alta: queda guardado y encolado como INSERT (c1)', () async {
      final juan = await trabajadores.alta(
          nombre: ' Juan P. ', telefono: '351 000-0002', especialidad: 'Tambero');

      expect(juan.telefono, '3510000002');
      expect(juan.nombre, 'Juan P.');
      expect(juan.authId, isNull, reason: 'preregistrado: sin cuenta de Auth');

      final ops = await operaciones();
      expect(ops.single.entidad, 'usuario');
      expect(ops.single.operacion, 'INSERT');
      expect(ops.single.payload['telefono'], '3510000002');
      expect(ops.single.payload.containsKey('auth_id'), isFalse);
    });

    test('teléfono ya registrado: no se guarda y se informa el motivo (c2)',
        () async {
      await trabajadores.alta(nombre: 'Juan P.', telefono: '3510000002');

      await expectLater(
        trabajadores.alta(nombre: 'Otro', telefono: '351-000-0002'),
        throwsA(isA<DatosRechazados>().having((e) => e.errores['telefono'],
            'motivo', contains('ya está registrado a nombre de Juan P.'))),
      );
      // También choca con el teléfono del encargado.
      await expectLater(
          trabajadores.alta(nombre: 'Otro', telefono: '3510000001'),
          throwsA(isA<DatosRechazados>()));
      expect(await operaciones(), hasLength(1));
    });

    test('modificar conserva el teléfono propio y encola un UPDATE', () async {
      final juan = await trabajadores.alta(nombre: 'Juan P.', telefono: '3510000002');
      await trabajadores.modificar(juan.id,
          nombre: 'Juan Pérez', telefono: '3510000002', especialidad: '');

      final fila = await trabajadores.observar(juan.id).first;
      expect(fila!.nombre, 'Juan Pérez');
      expect(fila.especialidad, isNull);
      expect((await operaciones()).last.operacion, 'UPDATE');
    });

    test('desactivado: deja de figurar para nuevas asignaciones (c4)', () async {
      final juan = await trabajadores.alta(nombre: 'Juan P.', telefono: '3510000002');
      final pedro = await trabajadores.alta(nombre: 'Pedro G.', telefono: '3510000003');

      await trabajadores.desactivar(juan.id);

      final asignables = await trabajadores.observarAsignables().first;
      expect(asignables.map((u) => u.id), [pedro.id]);
      final todos = await trabajadores.observarTrabajadores().first;
      expect(todos, hasLength(2), reason: 'el encargado lo sigue viendo');
      expect(todos.last.activo, isFalse);
      final op = (await operaciones()).last;
      expect(op.operacion, 'UPDATE');
      expect(op.payload['activo'], isFalse);
    });

    test('restablecer PIN: pide conexión y avisa los errores del servidor',
        () async {
      expect(await trabajadores.restablecerPin('u-1'), isNull);
      expect(remoto.restablecidos, ['u-1']);

      expect(await trabajadores.restablecerPin('desconocido'),
          'No existe ese usuario');

      remoto.hayConexion = false;
      expect(await trabajadores.restablecerPin('u-1'), contains('conexión'));
      expect(await operaciones(), isEmpty, reason: 'no pasa por la bandeja');
    });
  });

  group('unidades productivas (HU-003)', () {
    test('alta con código QR único (c1)', () async {
      final a = await unidades.alta(
          nombre: 'Lote 7', tipo: TipoUnidad.lote, superficie: '12,5');
      final b = await unidades.alta(
          nombre: 'Potrero 2', tipo: TipoUnidad.potrero, superficie: '30');

      expect(a.codigoQr, '$prefijoQr${a.id}');
      expect(a.codigoQr, isNot(b.codigoQr));
      expect(a.superficieHa, 12.5);
      expect((await operaciones()).map((o) => o.entidad).toSet(),
          {'unidad_productiva'});
    });

    test('datos inválidos no se guardan', () async {
      await expectLater(
          unidades.alta(nombre: '', tipo: null, superficie: ''),
          throwsA(isA<DatosRechazados>()));
      expect(await operaciones(), isEmpty);
    });

    test('desactivada: conserva la fila y no se ofrece para asignar (c3)',
        () async {
      final lote = await unidades.alta(
          nombre: 'Lote 7', tipo: TipoUnidad.lote, superficie: '12');
      await unidades.desactivar(lote.id);

      expect(await unidades.observarAsignables().first, isEmpty);
      final fila = (await unidades.observarUnidades().first).single;
      expect(fila.activa, isFalse);
      expect(fila.codigoQr, lote.codigoQr, reason: 'el QR impreso sigue valiendo');
    });
  });

  group('labores (HU-005)', () {
    test('crear y asignar: tarea, ítems, CREADA y ASIGNADA en una transacción (c1)',
        () async {
      final juan = await trabajadores.alta(nombre: 'Juan P.', telefono: '3510000002');
      final lote = await unidades.alta(
          nombre: 'Lote 7', tipo: TipoUnidad.lote, superficie: '12');
      final antes = (await operaciones()).length;

      final plantilla = plantillaPara(TipoLabor.aplicacionFitosanitaria);
      final id = await labores.crearLabor(
        BorradorLabor(
          unidadProductivaId: lote.id,
          asignadoId: juan.id,
          tipoLabor: TipoLabor.aplicacionFitosanitaria,
          fechaProgramada: DateTime(2026, 11, 6),
          descripcion: 'Aplicar al costado del camino',
          items: plantilla.items,
          evidencia: plantilla.evidencia,
          requiereQr: plantilla.requiereQr,
        ),
        creadorId: encargado,
      );

      final tarea = await db.select(db.tareas).getSingle();
      expect(tarea.id, id);
      expect(tarea.estadoActual, 'ASIGNADA');
      expect(tarea.fechaProgramada, '2026-11-06');
      expect(tarea.evidenciaRequerida, 'FOTO');
      expect(tarea.requiereQr, isTrue);

      final items = await (db.select(db.itemsChecklist)
            ..orderBy([(i) => OrderingTerm.asc(i.orden)]))
          .get();
      expect(items, hasLength(4));
      expect(items.every((i) => i.obligatorio), isTrue);
      expect(items.map((i) => i.orden), [1, 2, 3, 4]);

      final eventos = await db.select(db.eventos).get();
      expect(eventos.map((e) => e.tipo), ['CREADA', 'ASIGNADA']);
      expect(eventos.last.payload['asignado_id'], juan.id);
      expect(eventos.every((e) => e.usuarioId == encargado), isTrue);

      // tarea + 4 ítems + 2 eventos
      expect((await operaciones()).length - antes, 7);
    });

    test('con un dato faltante no se guarda nada (c3)', () async {
      await expectLater(
        labores.crearLabor(
            BorradorLabor(
                tipoLabor: TipoLabor.general,
                fechaProgramada: DateTime(2026, 11, 6),
                items: plantillaPara(TipoLabor.general).items),
            creadorId: encargado),
        throwsA(isA<LaborIncompleta>().having((e) => e.faltantes, 'faltantes',
            ['Elegí la unidad productiva.', 'Elegí el trabajador.'])),
      );
      expect(await db.select(db.tareas).get(), isEmpty);
      expect(await operaciones(), isEmpty);
    });
  });

  test('el contador de la bandeja cuenta lo que falta enviar', () async {
    final bandeja = RepositorioBandeja(db);
    expect(await bandeja.observarPendientes().first, 0);

    await trabajadores.alta(nombre: 'Juan P.', telefono: '3510000002');
    await unidades.alta(nombre: 'Lote 7', tipo: TipoUnidad.lote, superficie: '1');
    expect(await bandeja.observarPendientes().first, 2);

    await (db.update(db.operacionesPendientes)
          ..where((o) => o.entidad.equals('usuario')))
        .write(const OperacionesPendientesCompanion(estado: Value('ENVIADO')));
    expect(await bandeja.observarPendientes().first, 1);
  });
}
