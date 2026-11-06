import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trazalabor/dominio/perfil.dart';
import 'package:trazalabor/infra/almacen_seguro.dart';
import 'package:trazalabor/repositorio/base_datos.dart';
import 'package:trazalabor/repositorio/repositorio_sesion.dart';

import '../apoyo/autenticador_falso.dart';

void main() {
  late BaseDatos db;
  late AutenticadorFalso remoto;
  late AlmacenEnMemoria almacen;
  late DateTime ahora;
  late RepositorioSesion repo;

  setUp(() {
    db = BaseDatos(NativeDatabase.memory());
    remoto = AutenticadorFalso();
    almacen = AlmacenEnMemoria();
    ahora = DateTime(2026, 10, 30, 8);
    repo = RepositorioSesion(
      remoto: remoto,
      almacen: almacen,
      db: db,
      reloj: () => ahora,
      iteracionesHash: 1000,
    );
  });

  tearDown(() => db.close());

  test('ingreso con conexión: guarda perfil, hash y usuario local (HU-001 c1)',
      () async {
    remoto.agregar(juan, pin: '482913');

    final r = await repo.ingresar('351 000 0002', '482913');

    expect(r, isA<IngresoCorrecto>());
    expect((r as IngresoCorrecto).perfil.rol, 'TRABAJADOR');
    expect(r.sinConexion, isFalse);
    expect((await repo.perfilRecordado())?.id, 'u-juan');
    expect(almacen.datos.keys, contains('pin_hash:3510000002'));
    expect((await db.select(db.usuarios).getSingle()).nombre, 'Juan P.');
  });

  test('sin conexión valida el PIN en el dispositivo (HU-001 c3)', () async {
    remoto.agregar(juan, pin: '482913');
    await repo.ingresar('3510000002', '482913');
    await repo.salir();

    remoto.hayConexion = false;
    expect(await repo.pasoSiguiente('3510000002'), PasoSiguiente.ingresarPin);

    final r = await repo.ingresar('3510000002', '482913');
    expect(r, isA<IngresoCorrecto>());
    expect((r as IngresoCorrecto).sinConexion, isTrue);

    final mal = await repo.ingresar('3510000002', '111222');
    expect(mal, isA<IngresoRechazado>());
  });

  test('sin conexión y sin ingreso previo no deja entrar', () async {
    remoto.hayConexion = false;
    expect(await repo.pasoSiguiente('3510000002'), PasoSiguiente.necesitaConexion);
    final r = await repo.ingresar('3510000002', '482913');
    expect((r as IngresoRechazado).mensaje, contains('primer ingreso'));
  });

  test('cinco PIN incorrectos bloquean quince minutos (HU-001 c2)', () async {
    remoto.agregar(juan, pin: '482913');

    for (var i = 1; i <= 4; i++) {
      final r = await repo.ingresar('3510000002', '000111');
      expect(r, isA<IngresoRechazado>());
      expect((r as IngresoRechazado).mensaje, contains('${5 - i}'));
    }
    final quinto = await repo.ingresar('3510000002', '000111');
    expect(quinto, isA<IngresoBloqueado>());
    expect((quinto as IngresoBloqueado).minutos, 15);

    // Bloqueado: ni siquiera se consulta al servidor, aunque el PIN sea correcto.
    final llamadas = remoto.llamadasIngresar;
    expect(await repo.ingresar('3510000002', '482913'), isA<IngresoBloqueado>());
    expect(remoto.llamadasIngresar, llamadas);

    // El bloqueo es por teléfono: otro usuario del mismo equipo puede entrar.
    remoto.agregar(encargado, pin: '739215');
    expect(await repo.ingresar('3510000001', '739215'), isA<IngresoCorrecto>());

    ahora = ahora.add(const Duration(minutes: 15));
    expect(await repo.ingresar('3510000002', '482913'), isA<IngresoCorrecto>());
  });

  test('un usuario desactivado no ingresa (HU-002 c4)', () async {
    remoto.agregar(
      const Perfil(
          id: 'u-x', nombre: 'Desactivado', telefono: '3510000004',
          rol: 'TRABAJADOR', activo: false),
      pin: '482913',
    );
    final r = await repo.ingresar('3510000004', '482913');
    expect((r as IngresoRechazado).mensaje, contains('desactivada'));
    expect(almacen.datos.keys, isNot(contains('pin_hash:3510000004')));
  });

  test('desactivado después de haber ingresado: tampoco entra sin conexión (HU-002 c4)',
      () async {
    remoto.agregar(juan, pin: '482913');
    await repo.ingresar('3510000002', '482913');
    await repo.salir();

    // El encargado lo desactiva.
    remoto.agregar(juan, estado: EstadoCuenta.inactivo, pin: '482913');
    final r = await repo.ingresar('3510000002', '482913');
    expect((r as IngresoRechazado).mensaje, contains('no está habilitada'));
    expect(almacen.datos.keys, isNot(contains('pin_hash:3510000002')));

    remoto.hayConexion = false;
    expect(await repo.pasoSiguiente('3510000002'), PasoSiguiente.necesitaConexion);
    expect(await repo.ingresar('3510000002', '482913'), isA<IngresoRechazado>());
  });

  test('activación del trabajador preregistrado (HU-002 c3)', () async {
    remoto.agregar(juan, estado: EstadoCuenta.preregistrado);
    expect(await repo.pasoSiguiente('3510000002'), PasoSiguiente.crearPin);

    final debil = await repo.activar('3510000002', '123456');
    expect(debil, isA<IngresoRechazado>());

    final r = await repo.activar('3510000002', '482913');
    expect(r, isA<IngresoCorrecto>());
    expect(await repo.pasoSiguiente('3510000002'), PasoSiguiente.ingresarPin);
  });

  test('PIN restablecido por el encargado: pide elegir uno nuevo', () async {
    remoto.agregar(juan, pin: '482913');
    await repo.ingresar('3510000002', '482913');

    // El encargado lo restablece: la cuenta vuelve a quedar preregistrada.
    remoto.agregar(juan, estado: EstadoCuenta.preregistrado);
    final r = await repo.ingresar('3510000002', '482913');
    expect(r, isA<IngresoPinRestablecido>());
    expect(almacen.datos.keys, isNot(contains('pin_hash:3510000002')));
    // No se contó como intento fallido.
    expect(almacen.datos['intentos_pin:3510000002'], contains('"fallos":0'));
  });

  test('teléfono no dado de alta', () async {
    expect(await repo.pasoSiguiente('3519999999'), PasoSiguiente.noDadoDeAlta);
  });

  test('sin conexión no usa el perfil recordado de otro teléfono', () async {
    remoto
      ..agregar(juan, pin: '482913')
      ..agregar(encargado, pin: '739215');
    await repo.ingresar('3510000001', '739215'); // queda recordado el encargado
    await repo.ingresar('3510000002', '482913'); // y ahora Juan
    remoto.hayConexion = false;

    final r = await repo.ingresar('3510000001', '739215');
    expect((r as IngresoCorrecto).perfil.rol, 'ENCARGADO');
  });
}
