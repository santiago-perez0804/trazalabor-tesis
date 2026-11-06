# Trazabilidad tesis → código

Vincula cada historia de usuario y cada tarea técnica de la tesis con el código que la implementa y con las
pruebas que la verifican.

## Historias de usuario
| HU | Estado | Archivos principales | Pruebas |
|---|---|---|---|
| HU-001 | Hecho | `app/lib/dominio/pin.dart`, `control_intentos.dart`, `perfil.dart`; `app/lib/repositorio/repositorio_sesion.dart`; `app/lib/infra/hash_pin.dart`, `autenticador_remoto.dart`, `almacen_seguro.dart`; `app/lib/interfaz/ingreso/`, `rutas.dart`; `supabase/migrations/20261105165317_permisos_por_rol.sql` | `app/test/dominio/pin_test.dart` (c2), `app/test/repositorio/repositorio_sesion_test.dart` (c1, c2, c3), `app/test/widget_test.dart`; en el emulador: ingreso por rol, sin conexión y bloqueo |
| HU-002 | Hecho | `app/lib/repositorio/repositorio_trabajadores.dart`; `app/lib/interfaz/encargado/pantalla_trabajadores.dart`, `formulario_trabajador.dart`; activación: RPC `estado_cuenta` + trigger `vincular_cuenta_auth`; desactivación: `usuario.activo` + `usuario_actual()` en las políticas RLS; restablecer PIN: `supabase/functions/restablecer-pin/` y `app/lib/infra/administracion_remota.dart` | `app/test/repositorio/repositorios_encargado_test.dart` (c1, c2, c4), `app/test/encargado_test.dart` (c2), `app/test/repositorio/repositorio_sesion_test.dart` (c3, c4); `supabase/scripts/verificacion_rls.sql` (10/10 OK en la nube) |
| HU-003 | Hecho | `app/lib/repositorio/repositorio_unidades.dart`; `app/lib/infra/exportar_qr.dart`; `app/lib/interfaz/encargado/pantalla_unidades.dart`, `formulario_unidad.dart` | `app/test/repositorio/repositorios_encargado_test.dart` (c1, c3); en el emulador: exportación de la imagen para imprimir (c2) |
| HU-004 | Hecho (c1 y c2); c3 se verifica con la primera versión 2 del esquema | `app/lib/repositorio/tablas.dart`, `base_datos.dart`, `registrar_accion.dart`; `supabase/migrations/20261103220721_esquema.sql` | `app/test/repositorio/registrar_accion_test.dart`; `supabase/scripts/verificacion_nube.sql`; `supabase/tests/esquema.test.sql`; esquema v1 en `app/drift_schemas/` |
| HU-005 | Hecho | `app/lib/dominio/plantillas_labor.dart`, `validar_labor.dart`, `catalogos.dart`; `app/lib/repositorio/repositorio_labores.dart`; `app/lib/interfaz/encargado/pantalla_nueva_labor.dart`, `editor_checklist.dart` | `app/test/dominio/validar_labor_test.dart` (c2, c3), `app/test/repositorio/repositorios_encargado_test.dart` (c1, c3), `app/test/encargado_test.dart` (c2, c3); en el emulador: labor asignada en modo avión |
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
| T-04 | Hecho | Tablas equivalentes en PostgreSQL, hora del servidor, bitácora de solo adición y proyecciones; políticas RLS por rol, bucket privado `evidencias` y Edge Function `restablecer-pin`. |
| T-05 | Hecho | Pantalla de ingreso con teléfono y teclado de PIN propio (teclas de 64 dp); recuerda al último usuario del teléfono. |
| T-06 | Hecho | PBKDF2-HMAC-SHA256 con salt, 50 000 iteraciones, fuera del hilo de la interfaz (~0,3 s en PC; a confirmar en el celular). |
| T-07 | Hecho | Sesión de Supabase en `flutter_secure_storage`; sin conexión se valida el PIN contra el hash local y se opera igual. |
| T-08 | Hecho | Alta, modificación y desactivación de trabajadores desde la vista del encargado; restablecer PIN con conexión. |
| T-09 | Hecho | El trabajador preregistrado elige su PIN en el primer ingreso y su cuenta queda activada. |
| T-10 | Hecho | Alta, modificación y desactivación (baja lógica) de unidades productivas. |
| T-11 | Hecho | Código QR único por unidad; imagen PNG de 1200 px con el nombre de la unidad, lista para imprimir o compartir. |
| T-12 | Hecho | Pruebas de dominio, repositorio, transacción de la bandeja, hash del PIN y sesión. |
| T-13 | Hecho | Pantalla "Nueva labor" (pantalla A): unidad y trabajador activos, tipo de labor, fecha, indicaciones, evidencia requerida y verificación QR. |
| T-14 | Hecho | Editor de la lista de verificación (agregar, quitar, tipo de respuesta, obligatorio) y plantillas por tipo de labor. |

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
| D10 | Restablecer PIN | "El encargado puede restablecer el PIN … desde la aplicación" | Edge Function `restablecer-pin`: borra la cuenta de Auth del trabajador, que vuelve a quedar PREREGISTRADO y elige un PIN nuevo en su próximo ingreso | Requiere la clave de servicio, que no puede estar en la app. Además, así el encargado nunca conoce el PIN de nadie. |
| D11 | Bloqueo por intentos | 5 intentos → 15 minutos | Bloqueo en el dispositivo, por número de teléfono (también sin conexión); en el servidor rigen los límites de frecuencia de Supabase Auth | Los hooks de verificación de contraseña de Supabase no están en el plan gratuito. Por teléfono para que, en un equipo compartido, los errores de uno no bloqueen a otro. |
| D12 | Activación del trabajador | Valida su cuenta al definir el PIN, sin exponer credenciales administrativas | RPC `estado_cuenta(telefono)` + registro en Auth + trigger sobre `auth.users` que vincula `auth_id` con el usuario preregistrado | Permite la activación sin la clave de servicio en la app. Si el teléfono no fue dado de alta o está desactivado, la cuenta se rechaza. |
| D13 | Fortaleza del PIN | "El dispositivo conserva un valor derivado con salt" | PBKDF2 con 50 000 iteraciones | Un PIN de 6 dígitos tiene 10^6 combinaciones: ninguna función de derivación lo protege sola si se extrae el hash. La protección real es la combinación del almacenamiento cifrado del sistema, el bloqueo por intentos y bcrypt con límites de frecuencia en el servidor. |
| D14 | Columnas protegidas de `usuario` | — | Trigger `proteger_columnas_usuario`: el cliente no fija `auth_id`, `fcm_token` ni `created_at_device`, y no puede cambiar el teléfono de una cuenta activa | La cuenta de Auth se crea con el teléfono: cambiarlo dejaría al usuario sin poder ingresar. |
| D15 | Eventos tras una reasignación | El trabajador "registra eventos sobre" sus labores | Puede registrar eventos de ejecución si es el asignado actual o si ya había registrado eventos en esa tarea (`participa_en_tarea`) | Si ejecutó sin señal mientras se la reasignaban, la bitácora debe reflejar lo que pasó en el campo y la bandeja no debe trabarse. |
| D16 | Consulta previa al ingreso | — | RPC `estado_cuenta(telefono)` accesible sin sesión | Decide si el usuario crea o ingresa su PIN. Revela si un número está dado de alta; se acepta en un prototipo de un solo establecimiento. |
| D17 | Desactivación y acceso sin conexión | "El acceso se rechaza" (HU-002 c4) | Al detectar con conexión que la cuenta fue desactivada, se borra el hash local del PIN | Sin esto, un trabajador desactivado podría seguir ingresando sin señal en ese teléfono. Mientras no haya conexión, el teléfono no puede enterarse de la desactivación. |
| D18 | Contenido del código QR | "Texto único codificado en el QR del punto físico" | `TRAZALABOR:UP:<id de la unidad>` | Se genera sin conexión y sin riesgo de repetirse; el prefijo permite reconocer al escanear que el código es de una unidad de TrazaLabor. El código no cambia al editar la unidad, así los carteles impresos siguen sirviendo. |
| D19 | Plantillas de labor | Solo fija los ítems obligatorios de la aplicación fitosanitaria (producto, dosis, lote y condiciones meteorológicas) | Esos cuatro ítems son fijos (no se pueden quitar ni volver opcionales). Los demás tipos traen ítems sugeridos y editables, además de la evidencia y el QR sugeridos | Agiliza la carga sin imponer requisitos que la tesis no define. |
| D20 | Administración sin conexión | — | Altas, cambios y desactivaciones se guardan en el teléfono y se envían con la sincronización; restablecer el PIN requiere conexión | Restablecer el PIN es una acción del servidor (Edge Function con clave de servicio) y no puede quedar pendiente. |
| D21 | Indicador de pendientes | "Indicador permanente del estado de conexión y de sincronización" | Contador de operaciones de la bandeja todavía no confirmadas, junto al indicador de conexión en todas las pantallas con sesión | Hace visible que lo registrado quedó guardado y aún no llegó al servidor. |
