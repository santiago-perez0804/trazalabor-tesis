# Historias de usuario (Tablas 9 y 10 de la tesis)

Transcripción fiel del product backlog y de los criterios de aceptación. Formato Dado–Cuando–Entonces (North, 2006).
Prioridad: Alta = Must, Media = Should (MoSCoW). Puntos en escala de Fibonacci.

| ID | Historia | Prioridad | Puntos | Depende de | Sprint |
|---|---|---|---|---|---|
| HU-001 | Iniciar sesión con teléfono y PIN según rol | Alta | 8 | — | 1 |
| HU-002 | Dar de alta y administrar trabajadores | Alta | 5 | HU-001 | 1 |
| HU-003 | Dar de alta unidades productivas con código QR | Alta | 5 | HU-001 | 1 |
| HU-004 | Persistir los datos en el dispositivo (local-first) | Alta | 5 | — | 1 |
| HU-005 | Crear y asignar labor con lista de verificación | Alta | 8 | HU-002, HU-003, HU-004 | 2 |
| HU-006 | Consultar tareas asignadas del día | Alta | 2 | HU-005 | 2 |
| HU-007 | Ejecutar labor sin conexión con lista de verificación | Alta | 5 | HU-006 | 2 |
| HU-008 | Adjuntar evidencia (foto/audio) al cierre | Alta | 5 | HU-007 | 2 |
| HU-009 | Verificar presencia mediante código QR | Media | 3 | HU-003, HU-007 | 2 |
| HU-010 | Recibir notificación de nueva asignación | Media | 3 | HU-005 | 2 |
| HU-011 | Sincronizar bandeja de salida y bitácora de eventos | Alta | 13 | HU-004, HU-007, HU-008 | 3 |
| HU-012 | Verificar cierre, aprobar o reasignar labor | Alta | 5 | HU-011 | 3 |
| HU-013 | Consultar historial de labores por unidad, trabajador y período | Media | 5 | HU-011 | 3 |

Velocidad estimada: 23 puntos (Sprint 1), 26 (Sprint 2), 23 (Sprint 3) = 72.

---

## HU-001 — Iniciar sesión con teléfono y PIN según rol
**Como** usuario, **quiero** ingresar con mi número de teléfono y un PIN numérico, **para** acceder a las funciones de mi rol sin depender de un correo electrónico.

1. Dado que el usuario está registrado y activo, cuando ingresa su teléfono y su PIN correctos, entonces accede a la vista que corresponde a su rol.
2. Dado que ingresa un PIN incorrecto cinco veces seguidas, cuando intenta ingresar nuevamente, entonces el acceso se bloquea en forma temporal.
3. Dado que ya inició sesión antes y no hay conexión, cuando ingresa su PIN, entonces este se valida en el dispositivo y puede operar sin conexión.

## HU-002 — Dar de alta y administrar trabajadores
**Como** encargado, **quiero** dar de alta, modificar y desactivar trabajadores con su nombre y teléfono, **para** que puedan ingresar a la aplicación y recibir labores.

1. Dado que completó el nombre y el teléfono, cuando confirma, entonces el trabajador queda preregistrado.
2. Dado que el teléfono ya está registrado, cuando intenta darlo de alta, entonces el sistema lo impide e informa el motivo.
3. Dado que el trabajador preregistrado ingresa por primera vez, cuando define su PIN, entonces su cuenta queda activada.
4. Dado que el trabajador fue desactivado, cuando intenta ingresar, entonces el acceso se rechaza y deja de figurar para nuevas asignaciones.

## HU-003 — Dar de alta unidades productivas con código QR
**Como** encargado, **quiero** registrar las unidades productivas del establecimiento y generar un código QR para cada una, **para** identificarlas al asignar labores y verificar la presencia del trabajador.

1. Dado que completó el nombre, el tipo y la superficie, cuando confirma, entonces la unidad se guarda con un código QR único.
2. Dado que la unidad está registrada, cuando solicita exportar su código, entonces se genera una imagen apta para imprimir.
3. Dado que la unidad tiene labores asociadas, cuando la desactiva, entonces deja de ofrecerse para nuevas asignaciones y conserva su historial.

## HU-004 — Persistir los datos en el dispositivo
**Como** usuario, **quiero** que la información que registro se guarde en mi teléfono, **para** poder trabajar sin conexión sin perder datos.

1. Dado que no hay conexión, cuando registra una acción, entonces esta se guarda en la base local y sigue disponible al volver a abrir la aplicación.
2. Dado que se registra una acción, cuando se guarda, entonces la entidad, el evento y la operación pendiente se escriben en una misma transacción.
3. Dado que se instala una nueva versión con cambios en el esquema, cuando se abre la aplicación, entonces la migración conserva los datos existentes.

## HU-005 — Crear y asignar labor con lista de verificación
**Como** encargado, **quiero** crear una labor sobre una unidad productiva y asignarla a un trabajador con su lista de verificación y la evidencia requerida, **para** que la instrucción quede completa y registrada sin depender de la comunicación verbal.

1. Dado que completó unidad productiva, trabajador, tipo de labor y al menos un ítem, cuando confirma, entonces la tarea se guarda en el dispositivo y se registran los eventos CREADA y ASIGNADA, aun sin conexión.
2. Dado que el tipo de labor es aplicación fitosanitaria, cuando crea la tarea, entonces la lista incluye como obligatorios producto, dosis, lote y condiciones meteorológicas.
3. Dado que falta un dato obligatorio, cuando intenta confirmar, entonces el sistema lo impide e indica el campo faltante.

## HU-006 — Consultar tareas asignadas del día
**Como** trabajador, **quiero** ver las labores que tengo asignadas para el día, **para** saber qué tengo que hacer, dónde y con qué requisitos.

1. Dado que tiene labores asignadas, cuando abre la aplicación, entonces ve la lista con la unidad productiva, el tipo de labor y el estado de cada una.
2. Dado que no hay conexión, cuando abre la lista, entonces ve las labores recibidas en la última sincronización y el indicador de operaciones pendientes.
3. Dado que selecciona una labor, cuando la abre, entonces ve su lista de verificación y la evidencia requerida.

## HU-007 — Ejecutar labor sin conexión con lista de verificación
**Como** trabajador, **quiero** completar la lista de verificación y cerrar la labor desde mi teléfono, aunque no haya señal, **para** dejar constancia de lo realizado en el momento y el lugar en que ocurre.

1. Dado que no hay conexión, cuando inicia la labor y marca un ítem, entonces se registran los eventos INICIADA e ITEM_COMPLETADO y se encolan en la bandeja de salida en la misma transacción.
2. Dado que faltan ítems obligatorios o la evidencia requerida, cuando intenta cerrar como completada, entonces el sistema lo impide y permite cerrar como NO_COMPLETADA con motivo por audio o texto.
3. Dado que la labor se cerró sin conexión, cuando vuelve a la bandeja, entonces figura como pendiente de sincronizar.

## HU-008 — Adjuntar evidencia (foto/audio) al cierre
**Como** trabajador, **quiero** adjuntar fotos o audios a la labor, **para** dejar constancia de lo realizado sin necesidad de escribir.

1. Dado que la labor requiere foto, cuando la captura, entonces se comprime, se guarda en el dispositivo con su huella SHA-256 y se registra el evento EVIDENCIA_ADJUNTA.
2. Dado que graba un audio, cuando lo confirma, entonces queda asociado a la labor y puede reproducirlo antes del cierre.
3. Dado que no hay conexión, cuando adjunta la evidencia, entonces esta queda en la cola de multimedia para su envío posterior.

## HU-009 — Verificar presencia mediante código QR
**Como** trabajador, **quiero** escanear el código QR del lugar donde realizo la labor, **para** dejar constancia de que estuve en la unidad productiva asignada.

1. Dado que la labor requiere QR, cuando escanea el código de la unidad asignada, entonces se registra el evento QR_VERIFICADO con fecha y hora.
2. Dado que escanea el código de otra unidad, cuando se lee, entonces el sistema informa la diferencia y no registra la verificación.
3. Dado que no hay conexión, cuando escanea el código, entonces la lectura se valida contra los datos guardados en el dispositivo.

## HU-010 — Recibir notificación de nueva asignación
**Como** trabajador, **quiero** recibir un aviso en mi teléfono cuando se me asigna una labor, **para** enterarme sin que el encargado deba avisarme por otro medio.

1. Dado que se le asignó una labor y esta se sincronizó, cuando su dispositivo tiene conexión, entonces recibe una notificación.
2. Dado que recibió la notificación, cuando la toca, entonces se abre el detalle de la labor.

## HU-011 — Sincronizar bandeja de salida y bitácora de eventos
**Como** encargado, **quiero** que lo registrado sin conexión se envíe solo al servidor cuando haya señal y sin duplicarse, **para** contar con la bitácora completa y verificable de las labores.

1. Dado que hay operaciones pendientes y se recupera la conexión, cuando corre la tarea en segundo plano, entonces se envían en orden y se marcan como sincronizadas al recibir confirmación.
2. Dado que un envío se interrumpe y se reintenta, cuando el servidor recibe un evento con un UUID ya existente, entonces no crea un registro duplicado.
3. Dado que la subida de una evidencia se interrumpe, cuando se reintenta, entonces se reanuda sin bloquear el envío de los eventos.

## HU-012 — Verificar cierre, aprobar o reasignar labor
**Como** encargado, **quiero** revisar la lista completada, la evidencia y la verificación QR de una labor cerrada y aprobarla o reasignarla, **para** validar lo realmente hecho antes de consolidarlo.

1. Dado que la tarea está COMPLETADA y sincronizada, cuando la abre, entonces ve los ítems, valores, evidencias, el resultado del QR y las marcas temporales.
2. Dado que es conforme, cuando la aprueba, entonces se registra VERIFICADA y pasa al historial.
3. Dado que no es conforme o quedó NO_COMPLETADA, cuando la reasigna, entonces se registra REASIGNADA con el nuevo trabajador y el motivo, sin modificar los eventos anteriores.

## HU-013 — Consultar historial de labores por unidad, trabajador y período
**Como** encargado, **quiero** consultar las labores realizadas por unidad productiva, trabajador y período, **para** saber qué se hizo, quién lo hizo y cuándo.

1. Dado que seleccionó los filtros, cuando consulta, entonces ve las labores con su estado, fecha y responsable.
2. Dado que abre una labor del historial, cuando se muestra, entonces ve la secuencia completa de eventos con sus marcas temporales y evidencias.
3. Dado que no hay labores para los filtros elegidos, cuando consulta, entonces el sistema informa que no hay resultados.
