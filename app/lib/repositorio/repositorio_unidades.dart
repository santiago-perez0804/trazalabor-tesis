import 'package:drift/drift.dart';

import '../dominio/catalogos.dart';
import '../dominio/validar_altas.dart';
import 'base_datos.dart';
import 'fabrica_eventos.dart';
import 'registrar_accion.dart';
import 'repositorio_trabajadores.dart' show DatosRechazados;

/// Prefijo del texto codificado en el QR de cada unidad (decisión D18).
const prefijoQr = 'TRAZALABOR:UP:';

/// Alta, modificación y desactivación de unidades productivas (HU-003, T-10).
class RepositorioUnidades {
  RepositorioUnidades(this._db);

  final BaseDatos _db;

  Stream<List<UnidadProductiva>> observarUnidades() =>
      (_db.select(_db.unidadesProductivas)
            ..orderBy([
              (u) => OrderingTerm.desc(u.activa),
              (u) => OrderingTerm.asc(u.nombre),
            ]))
          .watch();

  /// HU-003 c3: una unidad desactivada no se ofrece para nuevas asignaciones.
  Stream<List<UnidadProductiva>> observarAsignables() =>
      (_db.select(_db.unidadesProductivas)
            ..where((u) => u.activa.equals(true))
            ..orderBy([(u) => OrderingTerm.asc(u.nombre)]))
          .watch();

  Stream<UnidadProductiva?> observar(String id) =>
      (_db.select(_db.unidadesProductivas)..where((u) => u.id.equals(id)))
          .watchSingleOrNull();

  /// HU-003 c1: la unidad se guarda con un código QR único. Se arma con su
  /// UUID, así se genera sin conexión y sin riesgo de repetirse.
  Future<UnidadProductiva> alta({
    required String nombre,
    required TipoUnidad? tipo,
    required String superficie,
  }) async {
    _validar(nombre: nombre, tipo: tipo, superficie: superficie);
    final id = nuevoId();
    final fila = UnidadProductiva(
      id: id,
      nombre: nombre.trim(),
      tipo: tipo!.valor,
      superficieHa: leerDecimal(superficie),
      codigoQr: '$prefijoQr$id',
      activa: true,
    );
    await _db.registrarAccion(
        Accion(cambios: [CambioEntidad(_db.unidadesProductivas, fila)]));
    return fila;
  }

  /// El código QR no cambia: los carteles ya impresos siguen sirviendo.
  Future<void> modificar(
    String id, {
    required String nombre,
    required TipoUnidad? tipo,
    required String superficie,
  }) async {
    _validar(nombre: nombre, tipo: tipo, superficie: superficie);
    final actual = await _leer(id);
    await _guardarCambio(actual.copyWith(
      nombre: nombre.trim(),
      tipo: tipo!.valor,
      superficieHa: Value(leerDecimal(superficie)),
    ));
  }

  /// HU-003 c3: baja lógica. La fila se conserva con sus labores e historial.
  Future<void> desactivar(String id) async =>
      _guardarCambio((await _leer(id)).copyWith(activa: false));

  Future<void> reactivar(String id) async =>
      _guardarCambio((await _leer(id)).copyWith(activa: true));

  void _validar({
    required String nombre,
    required TipoUnidad? tipo,
    required String superficie,
  }) {
    final errores = validarUnidad(
        nombre: nombre, tipo: tipo?.valor, superficie: superficie);
    if (errores.isNotEmpty) throw DatosRechazados(errores);
  }

  Future<UnidadProductiva> _leer(String id) =>
      (_db.select(_db.unidadesProductivas)..where((u) => u.id.equals(id)))
          .getSingle();

  Future<void> _guardarCambio(UnidadProductiva fila) =>
      _db.registrarAccion(Accion(cambios: [
        CambioEntidad(_db.unidadesProductivas, fila,
            operacion: TipoOperacion.update),
      ]));
}
