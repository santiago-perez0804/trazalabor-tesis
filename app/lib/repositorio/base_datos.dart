import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tablas.dart';

part 'base_datos.g.dart';

/// Base local: fuente primaria de verdad de la app (local-first).
@DriftDatabase(tables: [
  Usuarios,
  UnidadesProductivas,
  Tareas,
  ItemsChecklist,
  Eventos,
  Evidencias,
  OperacionesPendientes,
  Metadatos,
])
class BaseDatos extends _$BaseDatos {
  /// Recibe el ejecutor para poder usar `NativeDatabase.memory()` en pruebas.
  BaseDatos(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Abre la base del dispositivo. `shareAcrossIsolates` permite que el
/// callback de workmanager use la misma conexión que la interfaz.
BaseDatos abrirBaseDatos() => BaseDatos(
      driftDatabase(
        name: 'trazalabor',
        native: const DriftNativeOptions(shareAcrossIsolates: true),
      ),
    );
