# Trazabilidad tesis → código

Vincula cada historia de usuario y cada tarea técnica de la tesis con el código que la implementa y con las
pruebas que la verifican.

## Historias de usuario
| HU | Estado | Archivos principales | Pruebas |
|---|---|---|---|
| HU-001 | Pendiente | | |
| HU-002 | Pendiente | | |
| HU-003 | Pendiente | | |
| HU-004 | Hecho (c1 y c2); c3 se verifica con la primera versión 2 del esquema | `app/lib/repositorio/tablas.dart`, `base_datos.dart`, `registrar_accion.dart`; `supabase/migrations/20261103220721_esquema.sql` | `app/test/repositorio/registrar_accion_test.dart`; `supabase/scripts/verificacion_nube.sql`; `supabase/tests/esquema.test.sql`; esquema v1 en `app/drift_schemas/` |
| HU-005 | Pendiente | | |
| HU-006 | Pendiente | | |
| HU-007 | Pendiente | | |
| HU-008 | Pendiente | | |
| HU-009 | Pendiente | | |
| HU-010 | Pendiente | | |
| HU-011 | Pendiente | | |
| HU-012 | Pendiente | | |
| HU-013 | Pendiente | | |

## Tareas técnicas
| T | Estado | Notas |
|---|---|---|
| T-01 | Hecho | Proyecto Flutter con la estructura por capas `interfaz/`, `dominio/`, `repositorio/`, `sincronizacion/` e `infra/`; tema según la Figura 5 e indicador permanente de conexión. |
| T-02 | Hecho | Esquema Drift de las seis entidades de la Tabla 14 con restricciones CHECK y claves foráneas; versión 1 del esquema guardada para pruebas de migración. |
| T-03 | Hecho | `registrarAccion()`: entidad, evento y operación pendiente en una sola transacción; el contenido se prepara en el formato que espera la API REST. |
| T-04 | Parcial | Tablas equivalentes en PostgreSQL, hora del servidor, bitácora de solo adición y proyecciones; RLS habilitada. Faltan las políticas por rol. |
| T-12 | Parcial | Pruebas de dominio, repositorio y transacción de la bandeja. Falta el hash del PIN. |

## Decisiones de implementación no especificadas en la tesis
| # | Tema | Qué dice la tesis | Qué se implementa | Motivo |
|---|---|---|---|---|
| D1 | Gestión de estado y navegación | — | Riverpod (estado) y go_router (navegación) | La tesis no define estos componentes de la capa de interfaz. |
| D2 | Cursor de sincronización | No figura | Tabla local `metadato(clave, valor)`, solo en SQLite como `OperacionPendiente` | Saber desde dónde descargar los eventos nuevos. |
| D3 | Proyecciones en el servidor | `estado_actual` es una proyección | Un trigger `AFTER INSERT ON evento` recalcula `tarea.estado_actual`, `tarea.asignado_id` e `item_checklist` | El trabajador solo inserta eventos y nunca actualiza filas, coherente con la bitácora de solo adición. |
| D4 | Cola de multimedia | "Cola de multimedia independiente" | Filas de `operacion_pendiente` con `operacion = 'SUBIDA'`, procesadas en un ciclo separado del de eventos | Reutiliza intentos, último error y estado de la bandeja sin otra tabla. La Tabla 14 solo lista inserción y actualización. |
| D5 | Inmutabilidad de la evidencia | Solo la tabla de eventos "solo admite inserciones" | `evidencia` también rechaza UPDATE, DELETE y TRUNCATE | La huella SHA-256 no debe poder cambiar después de registrada. |
| D6 | Eventos con la misma hora | El estado se deriva de la secuencia | Desempate por etapa del ciclo (`rangoEvento()` en Dart y `rango_evento()` en SQL) | CREADA y ASIGNADA se registran en el mismo instante; sin desempate el estado sería indeterminado. |
| D7 | Fecha programada | Tipo "Fecha" | Texto `AAAA-MM-DD` en SQLite y `date` en PostgreSQL | SQLite no tiene tipo fecha; así no se corre el día por zona horaria. |
| D8 | Valores de `unidad_productiva.tipo` y `tarea.tipo_labor` | Texto descriptivo | Valores fijos en mayúsculas (`LOTE`, `APLICACION_FITOSANITARIA`, …) con CHECK | Permite filtrar y aplicar plantillas sin ambigüedad. |
| D9 | Token de notificaciones | No figura en la Tabla 14 | Columna `usuario.fcm_token`, solo en el servidor | El servidor necesita saber a qué dispositivo enviar el aviso de nueva asignación (HU-010). |
