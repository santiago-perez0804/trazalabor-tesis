# Modelo de datos (Figura 4 y Tabla 14 de la tesis)

Modelo relacional. El **mismo esquema** se implementa en SQLite (Drift, en el dispositivo) y en PostgreSQL (Supabase).
Identificadores: UUID generados en el dispositivo (RFC 9562) → creación sin conexión sin colisiones y reenvío idempotente.
El estado de la tarea **se deriva** de la secuencia de eventos de solo adición; `estado_actual` es solo una proyección para agilizar consultas.

Nombres de tablas y columnas en `snake_case`, exactamente como en la tesis.

## Relaciones (Figura 4)
- Usuario 1:N Tarea (**crea**, vía `creador_id`)
- Usuario 1:N Tarea (**ejecuta**, vía `asignado_id`)
- UnidadProductiva 1:N Tarea (**recibe**)
- Tarea 1:N ItemChecklist (**contiene**)
- Tarea 1:N Evento (**registra**)
- Tarea 1:N Evidencia (**documenta**)
- Usuario 1:N Evento (**es autor**)
- Usuario 1:N Evidencia (**captura**)

## usuario
| Atributo | Tipo | Clave | Descripción |
|---|---|---|---|
| id | UUID | PK | Identificador único generado en el dispositivo. |
| auth_id | UUID | | Identificador del usuario en el servicio de autenticación. |
| nombre | Texto | | Nombre y apellido. |
| telefono | Texto | UK | Número de teléfono con el que el usuario ingresa al sistema. |
| rol | Texto | | `ENCARGADO` o `TRABAJADOR`. |
| especialidad | Texto | | Puesto del trabajador (tambero, tractorista, peón general). |
| activo | Booleano | | Indica si el usuario puede ingresar y recibir asignaciones. |
| created_at_device | Fecha-hora | | Fecha y hora de creación según el reloj del dispositivo. |
| received_at_server | Fecha-hora | | Fecha y hora de recepción en el servidor; vacía hasta sincronizar. |

## unidad_productiva
| Atributo | Tipo | Clave | Descripción |
|---|---|---|---|
| id | UUID | PK | Identificador único de la unidad. |
| nombre | Texto | | Denominación de la unidad (por ejemplo, Lote 7). |
| tipo | Texto | | Lote, potrero o instalación. |
| superficie_ha | Decimal | | Superficie en hectáreas. |
| codigo_qr | Texto | UK | Texto único codificado en el QR del punto físico. |
| latitud / longitud | Decimal | | Coordenadas de referencia de la unidad. |
| activa | Booleano | | Indica si la unidad admite nuevas asignaciones. |

## tarea
| Atributo | Tipo | Clave | Descripción |
|---|---|---|---|
| id | UUID | PK | Identificador único de la labor. |
| unidad_productiva_id | UUID | FK | Unidad productiva sobre la que se ejecuta la labor. |
| creador_id | UUID | FK | Encargado que creó la labor. |
| asignado_id | UUID | FK | Trabajador asignado. |
| tipo_labor | Texto | | General, siembra, aplicación fitosanitaria, sanidad animal o mantenimiento. |
| descripcion | Texto | | Indicaciones de la labor. |
| fecha_programada | Fecha | | Fecha prevista de ejecución. |
| requiere_qr | Booleano | | Indica si el cierre exige verificar presencia por QR. |
| evidencia_requerida | Texto | | `NINGUNA`, `FOTO`, `AUDIO` o `FOTO_Y_AUDIO`. |
| estado_actual | Texto | | Proyección del último evento de la tarea, usada para consultas rápidas. |
| created_at_device | Fecha-hora | | Fecha y hora de creación según el dispositivo. |
| received_at_server | Fecha-hora | | Fecha y hora de recepción en el servidor. |

## item_checklist
| Atributo | Tipo | Clave | Descripción |
|---|---|---|---|
| id | UUID | PK | Identificador único del ítem. |
| tarea_id | UUID | FK | Tarea a la que pertenece. |
| orden | Entero | | Posición del ítem en la lista. |
| descripcion | Texto | | Enunciado del ítem. |
| tipo_respuesta | Texto | | `CHECK`, `NUMERO` o `TEXTO`. |
| obligatorio | Booleano | | Indica si debe completarse para cerrar la labor como completada. |
| valor | Texto | | Respuesta registrada por el trabajador. |
| completado | Booleano | | Indica si el ítem fue completado. |

## evento (solo adición)
| Atributo | Tipo | Clave | Descripción |
|---|---|---|---|
| id | UUID | PK | Identificador único del evento; clave de idempotencia en la sincronización. |
| tarea_id | UUID | FK | Tarea afectada. |
| usuario_id | UUID | FK | Usuario autor del evento. |
| tipo | Texto | | Ver tipos de evento abajo. |
| payload | JSON | | Datos propios del evento (valor de un ítem, motivo, nuevo asignado). |
| created_at_device | Fecha-hora | | Fecha y hora del evento según el dispositivo. |
| received_at_server | Fecha-hora | | Fecha y hora de recepción en el servidor. |
| latitud / longitud | Decimal | | Posición del dispositivo al registrar el evento, si está disponible. |

**Tipos de evento** (strings exactos): `CREADA`, `ASIGNADA`, `INICIADA`, `ITEM_COMPLETADO`, `QR_VERIFICADO`, `EVIDENCIA_ADJUNTA`, `COMPLETADA`, `NO_COMPLETADA`, `VERIFICADA`, `REASIGNADA`.

## evidencia
| Atributo | Tipo | Clave | Descripción |
|---|---|---|---|
| id | UUID | PK | Identificador único del archivo. |
| tarea_id | UUID | FK | Tarea documentada. |
| usuario_id | UUID | FK | Usuario que capturó el archivo. |
| tipo | Texto | | `FOTO` o `AUDIO`. |
| ruta_local | Texto | | Ubicación del archivo en el dispositivo. |
| ruta_remota | Texto | | Ubicación del archivo en el almacenamiento de objetos. |
| tamanio_bytes | Entero | | Tamaño del archivo comprimido. |
| hash_sha256 | Texto | | Huella del archivo para verificar su integridad. |
| created_at_device | Fecha-hora | | Fecha y hora de captura según el dispositivo. |
| received_at_server | Fecha-hora | | Fecha y hora de recepción en el servidor. |

## operacion_pendiente (SOLO en SQLite, no se replica)
Materializa la bandeja de salida transaccional (Richardson): la operación se guarda en la misma transacción que modifica los datos y un proceso separado la envía luego. No es entidad de negocio.

| Atributo | Tipo | Descripción |
|---|---|---|
| id | UUID (PK) | Identificador de la operación (solo en el dispositivo). |
| entidad / entidad_id | Texto / UUID | Tabla y registro a enviar. |
| operacion | Texto | Tipo de operación (inserción o actualización). |
| payload | JSON | Contenido a enviar al servidor. |
| intentos / ultimo_error | Entero / Texto | Cantidad de reintentos y último error recibido. |
| created_at_device | Fecha-hora | Momento en que se encoló. |
| estado | Texto | `PENDIENTE`, `ENVIADO` o `ERROR`. |
