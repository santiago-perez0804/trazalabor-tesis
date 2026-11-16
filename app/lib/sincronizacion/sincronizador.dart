import 'package:drift/drift.dart';

import '../dominio/catalogos.dart';
import '../repositorio/base_datos.dart';
import 'cola_multimedia.dart';
import 'descarga.dart';
import 'motor_envio.dart';
import 'servidor.dart';

/// Resultado de una sincronización completa.
class ResultadoSincronizacion {
  const ResultadoSincronizacion({
    this.enviadas = 0,
    this.archivos = 0,
    this.recibidas = 0,
    this.error,
    this.sinSesionRemota = false,
    this.ocupado = false,
  });

  final int enviadas;
  final int archivos;
  final int recibidas;
  final String? error;

  /// No se pudo autenticar en el servidor: queda todo para la próxima.
  final bool sinSesionRemota;

  /// Ya había una sincronización en curso.
  final bool ocupado;

  bool get correcta => error == null && !sinSesionRemota && !ocupado;
}

/// Aviso de nueva asignación (lo implementa `infra/avisos.dart`).
typedef Avisar = Future<void> Function({
  required String tareaId,
  required String titulo,
  required String detalle,
});

/// Orquesta la sincronización diferida (HU-011): primero la bandeja de salida
/// (eventos y entidades, en orden), después la cola de multimedia y por último
/// la descarga de novedades. Corre en primer plano y desde workmanager.
class Sincronizador {
  Sincronizador(this._db, this._servidor, {this._avisar});

  final BaseDatos _db;
  final Servidor _servidor;
  final Avisar? _avisar;
  bool _corriendo = false;

  static const claveUltima = 'ultima_sincronizacion';

  /// [authIdEsperado] es la cuenta del usuario de la sesión: si el servidor
  /// tiene otra (o ninguna), se intenta [reautenticar]; nunca se envía lo de
  /// un usuario con la sesión de otro.
  Future<ResultadoSincronizacion> sincronizar({
    required String usuarioId,
    required String? authIdEsperado,
    Future<bool> Function()? reautenticar,
  }) async {
    if (_corriendo) return const ResultadoSincronizacion(ocupado: true);
    _corriendo = true;
    try {
      if (!_sesionCorrecta(authIdEsperado)) {
        final ok = reautenticar != null && await reautenticar();
        if (!ok || !_sesionCorrecta(authIdEsperado)) {
          return const ResultadoSincronizacion(sinSesionRemota: true);
        }
      }

      final envio = await MotorEnvio(_db, _servidor).enviar();
      final subidas = await ColaMultimedia(_db, _servidor).procesar();
      final ResultadoDescarga descarga;
      try {
        descarga = await Descarga(
          _db,
          _servidor,
        ).descargar(usuarioId: usuarioId);
      } catch (e) {
        return ResultadoSincronizacion(
          enviadas: envio.enviadas,
          archivos: subidas.subidas,
          error: envio.error ?? e.toString(),
        );
      }

      for (final id in descarga.tareasNuevasAsignadas) {
        await _avisarNueva(id);
      }
      if (envio.completo && subidas.fallidas == 0) {
        await _db
            .into(_db.metadatos)
            .insertOnConflictUpdate(
              Metadato(
                clave: claveUltima,
                valor: DateTime.now().toUtc().toIso8601String(),
              ),
            );
      }
      return ResultadoSincronizacion(
        enviadas: envio.enviadas,
        archivos: subidas.subidas,
        recibidas: descarga.filas,
        error:
            envio.error ??
            (subidas.fallidas > 0
                ? 'No se pudieron subir ${subidas.fallidas} archivos'
                : null),
      );
    } catch (e) {
      return ResultadoSincronizacion(error: e.toString());
    } finally {
      _corriendo = false;
    }
  }

  bool _sesionCorrecta(String? esperado) {
    final actual = _servidor.authIdActual;
    return actual != null && (esperado == null || actual == esperado);
  }

  Future<void> _avisarNueva(String tareaId) async {
    final avisar = _avisar;
    if (avisar == null) return;
    final fila = await (_db.select(_db.tareas).join([
      innerJoin(
        _db.unidadesProductivas,
        _db.unidadesProductivas.id.equalsExp(_db.tareas.unidadProductivaId),
      ),
    ])..where(_db.tareas.id.equals(tareaId))).getSingleOrNull();
    if (fila == null) return;
    final tarea = fila.readTable(_db.tareas);
    final unidad = fila.readTable(_db.unidadesProductivas);
    try {
      await avisar(
        tareaId: tareaId,
        titulo: 'Nueva labor asignada',
        detalle:
            '${unidad.nombre} · ${TipoLabor.desdeValor(tarea.tipoLabor).etiqueta}',
      );
    } catch (_) {
      // Sin permiso de notificaciones la labor igual aparece en la bandeja.
    }
  }
}
