import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/archivo_evidencia.dart';
import 'package:trazalabor/dominio/catalogos.dart';
import 'package:trazalabor/dominio/plantillas_labor.dart';
import 'package:trazalabor/dominio/validar_labor.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/repositorio_ejecucion.dart';
import 'package:trazalabor/repositorio/repositorio_labores.dart';
import 'package:trazalabor/sincronizacion/cola_multimedia.dart';
import 'package:trazalabor/sincronizacion/descarga.dart';
import 'package:trazalabor/sincronizacion/motor_envio.dart';
import 'package:trazalabor/sincronizacion/sincronizador.dart';

import '../apoyo/autenticador_falso.dart';
import '../apoyo/servidor_falso.dart';

/// HU-011 y T-31: sincronización entre dos teléfonos (encargado y Juan) a
/// través de un servidor simulado, con cortes de conexión.
void main() {
  // Dos bases en memoria = dos teléfonos: es a propósito.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late ServidorFalso servidor;
  late BaseDatos telEncargado;
  late BaseDatos telJuan;

  setUp(() async {
    servidor = ServidorFalso();
    // Lo que ya está en el servidor (seed): usuarios y una unidad.
    servidor.tablas['usuario'] = {
      for (final p in [encargado, juan])
        p.id: {
          'id': p.id,
          'auth_id': null,
          'nombre': p.nombre,
          'telefono': p.telefono,
          'rol': p.rol,
          'especialidad': null,
          'activo': true,
          'created_at_device': '2026-11-01T12:00:00.000Z',
          'received_at_server': '2026-11-01T12:00:01.000Z',
        },
    };
    servidor.tablas['unidad_productiva'] = {
      'up-7': {
        'id': 'up-7',
        'nombre': 'Lote 7',
        'tipo': 'LOTE',
        'superficie_ha': 12,
        'codigo_qr': 'TRAZALABOR:UP:up-7',
        'latitud': null,
        'longitud': null,
        'activa': true,
      },
    };
    telEncargado = BaseDatos(NativeDatabase.memory());
    telJuan = BaseDatos(NativeDatabase.memory());
    await Descarga(telEncargado, servidor).descargar(usuarioId: encargado.id);
    await Descarga(telJuan, servidor).descargar(usuarioId: juan.id);
  });

  tearDown(() async {
    await telEncargado.close();
    await telJuan.close();
  });

  Future<String> asignarLabor() => RepositorioLabores(telEncargado).crearLabor(
    BorradorLabor(
      unidadProductivaId: 'up-7',
      asignadoId: juan.id,
      tipoLabor: TipoLabor.mantenimiento,
      fechaProgramada: DateTime.now(),
      items: plantillaPara(TipoLabor.mantenimiento).items,
    ),
    creadorId: encargado.id,
  );

  Future<List<OperacionPendiente>> ops(BaseDatos db) =>
      db.select(db.operacionesPendientes).get();

  test('la descarga trae usuarios y unidades del servidor', () async {
    expect(await telJuan.select(telJuan.usuarios).get(), hasLength(2));
    expect(
      await telJuan.select(telJuan.unidadesProductivas).get(),
      hasLength(1),
    );
  });

  test(
    'c1: se envía en orden y cada operación queda ENVIADO al confirmarse',
    () async {
      await asignarLabor();
      final r = await MotorEnvio(telEncargado, servidor).enviar();

      expect(r.completo, isTrue);
      expect((await ops(telEncargado)).map((o) => o.estado).toSet(), {
        'ENVIADO',
      });
      expect(servidor.tablas['tarea'], hasLength(1));
      expect(servidor.tablas['item_checklist'], hasLength(2));
      expect(servidor.tablas['evento']!.values.map((e) => e['tipo']), [
        'CREADA',
        'ASIGNADA',
      ]);
    },
  );

  test('c1: ante un corte se detiene; lo que sigue queda pendiente', () async {
    await asignarLabor();
    servidor.cortarDespuesDe = 2;
    final r = await MotorEnvio(telEncargado, servidor).enviar();

    expect(r.completo, isFalse);
    expect(r.enviadas, 2);
    final estados = (await ops(telEncargado)).map((o) => o.estado).toList();
    expect(estados.where((e) => e == 'ENVIADO'), hasLength(2));
    expect(estados.where((e) => e == 'ERROR'), hasLength(1));
    final conError = (await ops(telEncargado))
        .singleWhere((o) => o.estado == 'ERROR');
    expect(conError.intentos, 1);
    expect(conError.ultimoError, contains('Sin conexión'));

    servidor.reconectar();
    final otra = await MotorEnvio(telEncargado, servidor).enviar();
    expect(otra.completo, isTrue);
    expect(
      (await ops(telEncargado)).every((o) => o.estado == 'ENVIADO'),
      isTrue,
    );
  });

  test('c2: reenviar lo ya recibido no duplica nada', () async {
    await asignarLabor();
    await MotorEnvio(telEncargado, servidor).enviar();
    final antes = servidor.tablas['evento']!.length;

    // Como si se hubiera perdido la confirmación: todo vuelve a PENDIENTE.
    await telEncargado
        .update(telEncargado.operacionesPendientes)
        .write(
          const OperacionesPendientesCompanion(estado: Value('PENDIENTE')),
        );
    await MotorEnvio(telEncargado, servidor).enviar();

    expect(servidor.tablas['evento'], hasLength(antes));
    expect(servidor.tablas['tarea'], hasLength(1));
  });

  test(
    'la labor asignada llega al teléfono de Juan con su lista y su estado',
    () async {
      final tareaId = await asignarLabor();
      await MotorEnvio(telEncargado, servidor).enviar();

      final r = await Descarga(telJuan, servidor).descargar(usuarioId: juan.id);

      expect(r.tareasNuevasAsignadas, [tareaId]);
      final tarea = await (telJuan.select(
        telJuan.tareas,
      )..where((t) => t.id.equals(tareaId))).getSingle();
      expect(tarea.estadoActual, 'ASIGNADA');
      expect(await telJuan.select(telJuan.itemsChecklist).get(), hasLength(2));
      // Lo descargado no se reenvía.
      expect(await ops(telJuan), isEmpty);

      // Una segunda descarga no la vuelve a avisar.
      final otra = await Descarga(
        telJuan,
        servidor,
      ).descargar(usuarioId: juan.id);
      expect(otra.tareasNuevasAsignadas, isEmpty);
    },
  );

  test(
    'lo que Juan hizo sin señal llega al encargado al volver la conexión',
    () async {
      final tareaId = await asignarLabor();
      await MotorEnvio(telEncargado, servidor).enviar();
      await Descarga(telJuan, servidor).descargar(usuarioId: juan.id);

      // Sin señal: Juan marca un ítem (se inicia sola, D22).
      final ejec = RepositorioEjecucion(telJuan);
      final item = (await telJuan.select(telJuan.itemsChecklist).get())
          .firstWhere((i) => i.tipoRespuesta == 'CHECK');
      await ejec.completarItem(tareaId, item.id, null, usuarioId: juan.id);
      servidor.cortarDespuesDe = 0;
      expect((await MotorEnvio(telJuan, servidor).enviar()).completo, isFalse);

      // Vuelve la señal.
      servidor.reconectar();
      expect((await MotorEnvio(telJuan, servidor).enviar()).completo, isTrue);
      await Descarga(telJuan, servidor).descargar(usuarioId: juan.id);
      final propios = await telJuan.select(telJuan.eventos).get();
      expect(
        propios.every((e) => e.receivedAtServer != null),
        isTrue,
        reason: 'el servidor informa su marca temporal',
      );

      await Descarga(telEncargado, servidor).descargar(usuarioId: encargado.id);
      final enEncargado = await (telEncargado.select(
        telEncargado.tareas,
      )..where((t) => t.id.equals(tareaId))).getSingle();
      expect(enEncargado.estadoActual, 'INICIADA');
      final itemEnc = await (telEncargado.select(
        telEncargado.itemsChecklist,
      )..where((i) => i.id.equals(item.id))).getSingle();
      expect(itemEnc.completado, isTrue);
    },
  );

  test(
    'c3: una foto que no sube no frena los eventos y se reintenta',
    () async {
      final tareaId = await asignarLabor();
      await MotorEnvio(telEncargado, servidor).enviar();
      await Descarga(telJuan, servidor).descargar(usuarioId: juan.id);

      final dir = await Directory.systemTemp.createTemp('evidencia');
      addTearDown(() => dir.delete(recursive: true));
      final archivo = File('${dir.path}/foto.jpg')
        ..writeAsBytesSync([1, 2, 3, 4]);
      await RepositorioEjecucion(telJuan).adjuntarEvidencia(
        tareaId,
        ArchivoEvidencia(
          id: 'ev-1',
          tipo: TipoEvidencia.foto,
          rutaLocal: archivo.path,
          tamanioBytes: 4,
          hashSha256: sha256.convert([1, 2, 3, 4]).toString(),
        ),
        usuarioId: juan.id,
      );

      servidor.fallarArchivos = true;
      final envio = await MotorEnvio(telJuan, servidor).enviar();
      final subidas = await ColaMultimedia(telJuan, servidor).procesar();
      expect(envio.completo, isTrue, reason: 'los eventos salieron igual');
      expect(subidas.fallidas, 1);
      expect(servidor.tablas['evidencia'], contains('ev-1'));
      expect(servidor.archivos, isEmpty);

      servidor.fallarArchivos = false;
      final otra = await ColaMultimedia(telJuan, servidor).procesar();
      expect(otra.subidas, 1);
      expect(servidor.archivos.keys, ['$tareaId/ev-1.jpg']);
      expect((await ops(telJuan)).every((o) => o.estado == 'ENVIADO'), isTrue);
    },
  );

  test('sin la cuenta correcta en el servidor no se envía nada', () async {
    await asignarLabor();
    servidor.authIdActual = null;
    final r = await Sincronizador(
      telEncargado,
      servidor,
    ).sincronizar(usuarioId: encargado.id, authIdEsperado: 'auth-1');

    expect(r.sinSesionRemota, isTrue);
    expect(servidor.upserts, 0);
  });

  test(
    'el sincronizador envía, sube, descarga y avisa la labor nueva',
    () async {
      final tareaId = await asignarLabor();
      final enc = await Sincronizador(
        telEncargado,
        servidor,
      ).sincronizar(usuarioId: encargado.id, authIdEsperado: null);
      expect(enc.correcta, isTrue);

      final avisos = <String>[];
      final r = await Sincronizador(
        telJuan,
        servidor,
        avisar: ({required tareaId, required titulo, required detalle}) async =>
            avisos.add('$titulo: $detalle'),
      ).sincronizar(usuarioId: juan.id, authIdEsperado: null);

      expect(r.correcta, isTrue);
      expect(avisos, ['Nueva labor asignada: Lote 7 · Mantenimiento']);
      expect(
        await (telJuan.select(
          telJuan.tareas,
        )..where((t) => t.id.equals(tareaId))).getSingleOrNull(),
        isNotNull,
      );
    },
  );
}
