# Sprint backlog (Tablas 11, 12 y 13 de la tesis)

El desarrollo se organiza en 3 sprints (Tablas 11 a 13). Los IDs `T-xx` se usan en `docs/trazabilidad.md`
para vincular cada tarea con el código que la implementa.

## Sprint 1 — Núcleo, roles y persistencia local
Objetivo: disponer del núcleo de la aplicación con autenticación por rol, alta de trabajadores y de unidades productivas con código QR, y persistencia local sobre la que se apoyarán la ejecución y la sincronización.

| Historia | ID | Tarea técnica |
|---|---|---|
| HU-004 | T-01 | Configurar el proyecto Flutter y la estructura por capas (interfaz, dominio, repositorio) |
| HU-004 | T-02 | Definir el esquema Drift de las seis entidades y la estrategia de migraciones |
| HU-004 | T-03 | Crear la tabla local OperacionPendiente y el repositorio que escribe entidad, evento y operación en una misma transacción |
| HU-001 | T-04 | Configurar el proyecto Supabase: tablas PostgreSQL equivalentes y políticas RLS por rol |
| HU-001 | T-05 | Implementar la pantalla de inicio de sesión (teléfono y PIN numérico) |
| HU-001 | T-06 | Implementar el hash local del PIN con función de derivación y salt para validación sin conexión |
| HU-001 | T-07 | Implementar la gestión de tokens (almacenamiento seguro, refresco y expiración sin conexión) |
| HU-002 | T-08 | Implementar el alta, baja y modificación de trabajadores (vista de encargado) |
| HU-002 | T-09 | Implementar la activación del trabajador preregistrado en su primer ingreso |
| HU-003 | T-10 | Implementar el alta, baja y modificación de unidades productivas |
| HU-003 | T-11 | Generar y exportar el código QR de cada unidad productiva para su impresión |
| HU-001 a HU-004 | T-12 | Escribir pruebas unitarias (repositorios, transacción de la bandeja, hash del PIN, migraciones) |

## Sprint 2 — Tareas, listas de verificación y evidencia
Objetivo: permitir la creación y asignación de labores con lista de verificación, y su ejecución sin conexión con evidencia, verificación por código QR y notificación al trabajador.

| Historia | ID | Tarea técnica |
|---|---|---|
| HU-005 | T-13 | Implementar la pantalla de creación de la labor con selección de unidad, trabajador y tipo de labor |
| HU-005 | T-14 | Implementar el editor de la lista de verificación y las plantillas por tipo de labor |
| HU-006 | T-15 | Implementar la bandeja de tareas del trabajador con consultas reactivas |
| HU-007 | T-16 | Implementar la ejecución de la lista de verificación y los eventos INICIADA e ITEM_COMPLETADO |
| HU-007 | T-17 | Implementar el cierre como COMPLETADA o NO_COMPLETADA con validación de ítems obligatorios |
| HU-008 | T-18 | Implementar la captura y compresión de fotos y la grabación de audio |
| HU-008 | T-19 | Calcular la huella SHA-256 de cada archivo y crear la cola de multimedia |
| HU-009 | T-20 | Implementar el escaneo y la validación local del código QR |
| HU-010 | T-21 | Integrar Firebase Cloud Messaging y el aviso de nueva asignación |
| HU-005 a HU-010 | T-22 | Escribir pruebas unitarias y de interfaz |

## Sprint 3 — Sincronización, verificación e historial
Objetivo: sincronizar la bandeja de salida y la bitácora de eventos con el servidor, y habilitar la verificación del cierre y la consulta del historial de labores.

| Historia | ID | Tarea técnica |
|---|---|---|
| HU-011 | T-23 | Implementar el proceso de envío en segundo plano con workmanager |
| HU-011 | T-24 | Implementar el envío ordenado e idempotente mediante upsert, con reintentos y registro de errores |
| HU-011 | T-25 | Implementar la subida reanudable de evidencias mediante direcciones prefirmadas |
| HU-011 | T-26 | Registrar la marca temporal del servidor y descargar las nuevas asignaciones |
| HU-012 | T-27 | Implementar la vista de verificación del cierre con evidencias y marcas temporales |
| HU-012 | T-28 | Implementar la aprobación (VERIFICADA) y la reasignación (REASIGNADA) |
| HU-013 | T-29 | Implementar el historial con filtros por unidad, trabajador y período |
| HU-013 | T-30 | Implementar la vista de la secuencia de eventos de una labor |
| HU-011 a HU-013 | T-31 | Escribir pruebas de integración de la sincronización con cortes de conexión simulados |

## Actividades de cierre (Tabla 3)
| ID | Actividad | Inicio | Fin |
|---|---|---|---|
| 13 | Pruebas de integración y de operación sin conexión | 09/11/2026 | 13/11/2026 |
| 14 | Entrega del prototipo (paquete de instalación e instructivo de puesta en marcha) | 14/11/2026 | 15/11/2026 |
