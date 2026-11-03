# Objetivos, alcance y riesgos (entrega final de la tesis)

## Objetivo general
Desarrollar una aplicación móvil con funcionamiento sin conexión que permita asignar y registrar de manera
trazable las labores ejecutadas en establecimientos agropecuarios de la provincia de Córdoba.

## Objetivos específicos
1. Relevar las prácticas actuales de asignación, ejecución y registro de labores rurales mediante entrevistas
   semiestructuradas a productores, encargados y trabajadores, identificando los puntos de pérdida de información.
2. Determinar los requisitos de trazabilidad exigibles al registro de una labor, considerando el marco normativo
   provincial, los esquemas de certificación aplicables y las necesidades de gestión interna.
3. Identificar las condiciones de conectividad y el equipamiento móvil disponibles en los establecimientos, a fin
   de establecer las restricciones bajo las cuales debe operar la aplicación.
4. Definir las funciones que la aplicación debe brindar al encargado y al trabajador, a partir de los problemas
   detectados en el relevamiento.
5. Seleccionar las tecnologías que permitan registrar las labores sin conexión y sincronizarlas sin pérdida ni
   duplicación de datos.

## Objetivo del prototipo
Prototipo de aplicación móvil local-first que permita al encargado asignar labores con listas de verificación
sobre unidades productivas y al trabajador ejecutarlas, verificarlas por código QR y documentarlas con evidencia
sin conexión, registrando cada acción en una bitácora de eventos inmutable que se sincroniza de forma diferida
para su verificación y consulta.

## Límites
Desde que el encargado da de alta a los trabajadores y las unidades productivas y define y asigna una labor con su
lista de verificación, hasta que verifica su cierre con la evidencia registrada y la información queda consolidada
en el historial de labores por unidad productiva, trabajador y período.

## Alcances (procesos)

**Gestión de trabajadores y unidades productivas** (encargado)
1. Da de alta a cada trabajador con su nombre y teléfono, y lo modifica o lo da de baja cuando corresponde.
2. Registra las unidades productivas del establecimiento (lotes, potreros e instalaciones).
3. El sistema genera el código QR de cada unidad productiva, que se imprime y se coloca en el lugar.

**Asignación de labores** (encargado, trabajador)
1. El encargado crea la labor sobre una unidad productiva, con su lista de verificación y la evidencia requerida.
2. La asigna a un trabajador.
3. El trabajador recibe una notificación con la nueva asignación.

**Ejecución y registro de la labor** (trabajador)
1. Consulta las labores del día, aun sin conexión.
2. Al llegar a la unidad productiva, escanea su código QR para verificar su presencia.
3. Completa la lista de verificación y adjunta las fotos o los audios requeridos.
4. Cierra la labor, que queda registrada en el teléfono.
5. Al recuperar la señal, la aplicación sincroniza lo registrado.

**Aplicación de productos fitosanitarios** (encargado, trabajador aplicador)
1. El encargado asigna la aplicación como una labor con una lista de verificación específica.
2. El aplicador registra en la lista los valores efectivamente aplicados.
3. Cierra la labor con la evidencia requerida.

**Control y consolidación** (encargado)
1. Revisa la labor cerrada junto con su evidencia.
2. La aprueba o la reasigna a otro trabajador.
3. Consulta el historial de labores por unidad productiva, trabajador y período.

**Fuera del alcance:** la integración con la Receta Fitosanitaria Digital provincial y el registro de movimientos
de hacienda.

## Riesgos de mayor exposición (Tablas 22 y 23)

| Riesgo | Exposición | Acción preventiva | Acción de contingencia |
|---|---|---|---|
| R1. Retraso en el desarrollo | 2,80 | Priorizar las historias de prioridad alta y fijar el alcance de cada sprint al iniciarlo. | Postergar las historias de prioridad media (HU-009, HU-010 y HU-013) sin afectar el núcleo del negocio. |
| R2. Duplicación o pérdida de eventos en la sincronización | 2,50 | Identificadores UUID generados en el dispositivo, inserción idempotente y pruebas con cortes de conexión simulados. | Reprocesar la bandeja de salida desde el registro local y conciliar los eventos por UUID y marca temporal del servidor. |
| R3. Baja adopción por parte de los trabajadores | 2,50 | Diseño con pocos pasos, audio como alternativa al texto y presentación del registro como respaldo para el propio trabajador. | Capacitación breve en el establecimiento y simplificación de las listas de verificación según la retroalimentación recibida. |
| R4. Rendimiento insuficiente en teléfonos de gama baja | 2,00 | Compresión de la multimedia, paquetes de instalación por arquitectura y pruebas en un equipo de gama de entrada. | Eliminar del dispositivo las evidencias ya sincronizadas y reducir la resolución de captura. |
| R5. Vencimiento de la sesión sin conexión | 1,50 | Validación local del PIN y testigo de refresco de mayor duración. | Conservar las operaciones en la bandeja de salida y enviarlas una vez renovada la sesión. |

R1 a R5 concentran el 75,3 % de la exposición total; el resto (R6 a R9) no tiene plan de contingencia.
