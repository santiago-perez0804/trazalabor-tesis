import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/archivo_evidencia.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/estado_bandeja.dart';
import 'package:trazalabor/dominio/plantillas_labor.dart';
import 'package:trazalabor/dominio/validar_cierre.dart';
import 'package:trazalabor/dominio/validar_labor.dart';
import 'package:trazalabor/dominio/validar_qr.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/repositorio_ejecucion.dart';
import 'package:trazalabor/repositorio/repositorio_labores.dart';

void main() {
  late BaseDatos db;
  late RepositorioEjecucion repo;
  late DateTime ahora;
  final hoy = DateTime(2026, 11, 7);
  const encargado = 'u-enc';
  const juan = 'u-juan';
  const pedro = 'u-pedro';

  setUp(() async {
    db = BaseDatos(NativeDatabase.memory());
    ahora = DateTime(2026, 11, 7, 8);
    // Cada acción, un minuto después de la anterior.
    DateTime reloj() => ahora = ahora.add(const Duration(minutes: 1));
    repo = RepositorioEjecucion(db, reloj: reloj);
    for (final (id, rol, tel) in [
      (encargado, 'ENCARGADO', '3510000001'),
      (juan, 'TRABAJADOR', '3510000002'),
      (pedro, 'TRABAJADOR', '3510000003'),
    ]) {
      await db
          .into(db.usuarios)
          .insert(
            UsuariosCompanion.insert(
              id: id,
              nombre: id,
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
              codigoQr: '$prefijoQr$id',
            ),
          );
    }
  });

  tearDown(() => db.close());

  /// Labor asignada por el encargado, como en HU-005.
  Future<String> asignar({
    String asignado = juan,
    DateTime? fecha,
    TipoLabor tipo = TipoLabor.aplicacionFitosanitaria,
    EvidenciaRequerida? evidencia,
    bool? requiereQr,
  }) {
    final p = plantillaPara(tipo);
    return RepositorioLabores(db, reloj: () => ahora).crearLabor(
      BorradorLabor(
        unidadProductivaId: 'up-7',
        asignadoId: asignado,
        tipoLabor: tipo,
        fechaProgramada: fecha ?? hoy,
        items: p.items,
        evidencia: evidencia ?? p.evidencia,
        requiereQr: requiereQr ?? p.requiereQr,
      ),
      creadorId: encargado,
    );
  }

  Future<DetalleTarea> detalle(String id) async =>
      (await repo.leerDetalle(id))!;

  Future<List<String>> tiposDeEventos(String id) async =>
      (await (db.select(db.eventos)
                ..where((e) => e.tareaId.equals(id))
                ..orderBy([(e) => OrderingTerm.asc(e.createdAtDevice)]))
              .get())
          .map((e) => e.tipo)
          .toList();

  Future<List<OperacionPendiente>> operaciones() =>
      db.select(db.operacionesPendientes).get();

  ArchivoEvidencia foto(String id) => ArchivoEvidencia(
    id: id,
    tipo: TipoEvidencia.foto,
    rutaLocal: '/evidencias/$id.jpg',
    tamanioBytes: 120000,
    hashSha256: 'a' * 64,
  );

  group('bandeja del día (HU-006)', () {
    test('muestra solo las labores del trabajador para hoy y las abiertas de antes', () async {
      final deHoy = await asignar();
      final deAyer = await asignar(
        fecha: hoy.subtract(const Duration(days: 1)),
      );
      await asignar(asignado: pedro);
      await asignar(fecha: hoy.add(const Duration(days: 1)));

      final bandeja = await repo.observarTareasDelDia(juan, hoy).first;
      expect(bandeja.map((t) => t.tarea.id).toSet(), {deHoy, deAyer});
      expect(bandeja.first.unidadNombre, 'Lote 7');
      expect(bandeja.first.estado, EstadoBandeja.pendiente);
    });

    test(
      'una labor cerrada sin enviar figura "por enviar" (HU-007 c3)',
      () async {
        final id = await asignar(tipo: TipoLabor.general, requiereQr: false);
        final item = (await detalle(id)).items.single;
        await repo.completarItem(id, item.id, null, usuarioId: juan);
        await repo.cerrarCompletada(id, usuarioId: juan);

        var bandeja = await repo.observarTareasDelDia(juan, hoy).first;
        expect(bandeja.single.estado, EstadoBandeja.completadaPorEnviar);

        // Cuando el servidor confirma todo, pasa a "sincronizada".
        await db
            .update(db.operacionesPendientes)
            .write(
              const OperacionesPendientesCompanion(estado: Value('ENVIADO')),
            );
        bandeja = await repo.observarTareasDelDia(juan, hoy).first;
        expect(bandeja.single.estado, EstadoBandeja.completadaSincronizada);
      },
    );

    test('una labor de un día anterior cerrada sin señal sigue a la vista hasta enviarse', () async {
      final id = await asignar(fecha: hoy.subtract(const Duration(days: 1)));
      await repo.cerrarNoCompletada(id, usuarioId: juan, motivo: 'Llovió');

      var bandeja = await repo.observarTareasDelDia(juan, hoy).first;
      expect(bandeja.single.estado, EstadoBandeja.noCompletadaPorEnviar);

      // Ya enviada y de otro día: deja de figurar en "Mis tareas de hoy".
      await db
          .update(db.operacionesPendientes)
          .write(
            const OperacionesPendientesCompanion(estado: Value('ENVIADO')),
          );
      bandeja = await repo.observarTareasDelDia(juan, hoy).first;
      expect(bandeja, isEmpty);
    });
  });

  group('ejecución (HU-007)', () {
    test(
      'iniciar y marcar un ítem: eventos y operaciones juntos (c1)',
      () async {
        final id = await asignar();
        final antes = (await operaciones()).length;

        await repo.iniciar(id, usuarioId: juan);
        final dosis = (await detalle(id)).items[1];
        await repo.completarItem(id, dosis.id, '2,5', usuarioId: juan);

        final d = await detalle(id);
        expect(d.estado.valor, 'INICIADA');
        expect(d.items[1].completado, isTrue);
        expect(d.items[1].valor, '2.5');
        expect(await tiposDeEventos(id), [
          'CREADA',
          'ASIGNADA',
          'INICIADA',
          'ITEM_COMPLETADO',
        ]);
        final nuevas = (await operaciones()).skip(antes).toList();
        expect(nuevas.map((o) => o.entidad), ['evento', 'evento']);
        expect(nuevas.last.payload['payload'], {
          'item_id': dosis.id,
          'valor': '2.5',
        });
      },
    );

    test(
      'marcar un ítem sin iniciar inicia la labor en la misma acción',
      () async {
        final id = await asignar();
        final producto = (await detalle(id)).items.first;
        await repo.completarItem(id, producto.id, 'Glifosato', usuarioId: juan);

        expect((await detalle(id)).estado.valor, 'INICIADA');
        expect(await tiposDeEventos(id), [
          'CREADA',
          'ASIGNADA',
          'INICIADA',
          'ITEM_COMPLETADO',
        ]);
      },
    );

    test('un valor inválido no se registra', () async {
      final id = await asignar();
      final dosis = (await detalle(id)).items[1];
      await expectLater(
        repo.completarItem(id, dosis.id, 'mucha', usuarioId: juan),
        throwsA(isA<AccionRechazada>()),
      );
      expect(await tiposDeEventos(id), ['CREADA', 'ASIGNADA']);
    });

    test('con faltantes no cierra como completada; sí como no completada con motivo (c2)', () async {
      final id = await asignar();
      await expectLater(
        repo.cerrarCompletada(id, usuarioId: juan),
        throwsA(
          isA<AccionRechazada>().having(
            (e) => e.faltantes,
            'faltantes',
            containsAll([
              'Falta sacar una foto',
              'Falta escanear el código QR del lugar',
            ]),
          ),
        ),
      );
      await expectLater(
        repo.cerrarNoCompletada(id, usuarioId: juan),
        throwsA(isA<AccionRechazada>()),
        reason: 'sin motivo no se cierra',
      );

      await repo.cerrarNoCompletada(
        id,
        usuarioId: juan,
        motivo: 'Viento fuerte, no se pudo aplicar',
      );
      final d = await detalle(id);
      expect(d.estado.valor, 'NO_COMPLETADA');
      final ultimo = (await db.select(db.eventos).get()).last;
      expect(ultimo.payload, {'motivo': 'Viento fuerte, no se pudo aplicar'});

      // Cerrada: ya no admite eventos de ejecución.
      await expectLater(
        repo.iniciar(id, usuarioId: juan),
        throwsA(isA<AccionRechazada>()),
      );
    });

    test('labor completa: ítems, foto y QR → COMPLETADA', () async {
      final id = await asignar();
      for (final (i, valor) in [
        'Glifosato',
        '2',
        'L-123',
        'Sin viento',
      ].indexed) {
        final item = (await detalle(id)).items[i];
        await repo.completarItem(id, item.id, valor, usuarioId: juan);
      }
      await repo.adjuntarEvidencia(id, foto('f1'), usuarioId: juan);
      expect(
        await repo.verificarQr(id, '${prefijoQr}up-7', usuarioId: juan),
        isA<QrCoincide>(),
      );

      expect((await detalle(id)).validarCierreActual().puedeCompletar, isTrue);
      await repo.cerrarCompletada(id, usuarioId: juan);
      expect((await detalle(id)).estado.valor, 'COMPLETADA');
    });
  });

  group('evidencia (HU-008)', () {
    test(
      'fila, evento y subida del archivo en una misma transacción (c1 y c3)',
      () async {
        final id = await asignar();
        final antes = (await operaciones()).length;

        await repo.adjuntarEvidencia(id, foto('f1'), usuarioId: juan);

        final ev = await db.select(db.evidencias).getSingle();
        expect(ev.rutaRemota, '$id/f1.jpg');
        expect(ev.hashSha256, 'a' * 64);
        final nuevas = (await operaciones()).skip(antes).toList();
        expect(nuevas.map((o) => (o.entidad, o.operacion)), [
          ('evidencia', 'INSERT'),
          ('evento', 'INSERT'), // INICIADA automática
          ('evento', 'INSERT'), // EVIDENCIA_ADJUNTA
          ('evidencia', 'SUBIDA'),
        ]);
        final subida = nuevas.last;
        expect(subida.entidadId, 'f1');
        expect(subida.payload['ruta_local'], '/evidencias/f1.jpg');
        expect(subida.payload['ruta_remota'], '$id/f1.jpg');
        expect(
          nuevas.first.payload.containsKey('ruta_local'),
          isFalse,
          reason: 'la ruta local no viaja al servidor',
        );
        expect((await detalle(id)).fotos, 1);
      },
    );
  });

  group('QR (HU-009)', () {
    test(
      'el de otra unidad informa la diferencia y no registra nada (c2)',
      () async {
        final id = await asignar();
        final r = await repo.verificarQr(
          id,
          '${prefijoQr}up-2',
          usuarioId: juan,
        );
        expect(r, isA<QrDeOtraUnidad>());
        expect((r as QrDeOtraUnidad).nombre, 'Potrero 2');
        expect(await tiposDeEventos(id), ['CREADA', 'ASIGNADA']);
        expect((await detalle(id)).qrVerificado, isFalse);
      },
    );

    test(
      'el correcto registra QR_VERIFICADO con el código, sin conexión (c1, c3)',
      () async {
        final id = await asignar();
        await repo.verificarQr(id, '${prefijoQr}up-7', usuarioId: juan);
        final ultimo = (await db.select(db.eventos).get()).last;
        expect(ultimo.tipo, 'QR_VERIFICADO');
        expect(ultimo.payload, {'codigo_qr': '${prefijoQr}up-7'});
        expect((await detalle(id)).qrVerificado, isTrue);
      },
    );
  });
}
