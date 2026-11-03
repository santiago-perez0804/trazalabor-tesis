# Arquitectura, seguridad e interfaz (secciones "Diagrama de arquitectura", "Seguridad" y "Prototipos de interfaces")

## Arquitectura (Figura 6)
- Se distribuye como **APK por ABI** y corre en Android de gama de entrada. Encargado y trabajador usan **la misma app**, con vistas según el rol.
- Tres capas: **interfaz → dominio → repositorio**. El repositorio lee y escribe en **SQLite mediante Drift, que es la fuente primaria de verdad**.
- Cada acción se guarda en **una única transacción** que inserta el evento y la operación pendiente en la bandeja de salida.
- Fotos y audios se comprimen y pasan a una **cola de multimedia independiente**. El QR se lee **localmente** con la cámara.
- Al recuperar la conexión, **workmanager** (sobre WorkManager de Android) envía por HTTPS:
  - **Auth** emite los testigos de acceso y de refresco.
  - **API REST (PostgREST)** recibe los registros como **inserciones idempotentes** (`upsert` con `on_conflict` sobre el `id`, ignorando duplicados).
  - **PostgreSQL** aplica **RLS por rol**.
  - La multimedia se sube a **Storage con URL prefirmadas**.
- **Firebase Cloud Messaging** avisa al trabajador de las nuevas asignaciones.
- Se usa la API REST de Supabase **en forma directa, sin funciones intermedias** para la sincronización: la idempotencia se resuelve en la base de datos.

## Seguridad — acceso
- Ingreso con **número de teléfono + PIN numérico**. Como el login por SMS requiere un proveedor pago, la cuenta se registra con un **identificador derivado del teléfono** y el **PIN cumple la función de contraseña**.
- El teléfono identifica al usuario y es **único**.
- PIN de **seis dígitos**; **no** puede ser un único dígito repetido ni una secuencia consecutiva (111111, 123456).
- Los trabajadores **no se registran solos**: el encargado los da de alta con nombre y teléfono, y cada trabajador **valida su cuenta en el primer ingreso al definir su PIN**.
- **5 intentos fallidos consecutivos → bloqueo de 15 minutos**. El encargado puede **restablecer el PIN** de un trabajador desde la app.
- El PIN **no se almacena en texto plano**: Auth lo guarda con **bcrypt**; en el dispositivo se conserva un **valor derivado con salt** para validar sin conexión (OWASP).
- Sesión: **testigo de acceso de corta duración + testigo de refresco**, guardados en el **almacenamiento cifrado del sistema operativo**. Si el testigo vence sin conexión, el usuario sigue operando localmente tras validar su PIN, y lo pendiente se envía al renovarse la sesión.

## Seguridad — perfiles (en la interfaz **y** en la base central con RLS)
- **Encargado**: da de alta trabajadores y unidades productivas, crea y asigna labores, verifica su cierre, las aprueba o reasigna y consulta el historial de su establecimiento.
- **Trabajador**: consulta solo las labores que tiene asignadas, las ejecuta, adjunta evidencia y registra eventos sobre ellas; **no puede modificar ni eliminar eventos ya registrados**.

## Seguridad — otros
- Comunicación por **HTTPS**. Fotos y audios con **URL prefirmadas de validez temporal**. Cada archivo lleva una **huella SHA-256 que se verifica al recibirlo**.
- La tabla de eventos **solo admite inserciones**. Cada evento conserva la hora del **dispositivo** y la del **servidor** (permite detectar manipulación del reloj del teléfono).
- Datos personales limitados a **nombre y teléfono**, con consentimiento (Ley 25.326).

## Política de respaldo
- **Copia automática en la nube**: en el plan Pro, Supabase hace una copia diaria y conserva 7 días (no incluye Storage).
- **Copia programada**: **domingos 03:00**, una tarea en la computadora de administración exporta la base completa y descarga fotos y audios; el resultado se guarda **cifrado** en un disco externo y en otro servicio de nube distinto de Supabase. Se conservan **4 copias semanales**.
- **Copia en el dispositivo**: las operaciones de la bandeja **solo se marcan como enviadas cuando el servidor confirma**.
- **Código fuente**: Git + repositorio remoto; con cada versión publicada, copia comprimida en el disco externo.
- El responsable controla la copia cada semana y **una vez por mes restaura la última copia en Docker local** para comprobar que es utilizable.

## Criterios de interfaz para el contexto rural
- Áreas táctiles de **al menos 48 × 48 dp** (Material Design).
- Contraste de texto de **al menos 4,5:1** (WCAG 2.2) para el uso a pleno sol.
- Tareas resueltas **en pocos pasos**.
- **Audio como alternativa al texto**.
- **Indicador permanente** del estado de conexión y de sincronización.

## Pantallas (Figura 5)
- **A. Nueva labor** (encargado, HU-005): unidad, trabajador, tipo de labor, lista de verificación (+ agregar ítem), evidencia requerida, "Requiere verificación QR", botón **Asignar labor**.
- **B. Mis tareas de hoy** (trabajador, HU-006/HU-010): fecha y "N operaciones pendientes"; tarjetas con unidad · tipo y estado (Pendiente / En curso / Completada · sincronizada / Completada · por enviar); leyenda "✓ sincronizada ↻ pendiente de envío".
- **C. Ejecución** (trabajador, HU-007/HU-009): visor QR, "✓ QR verificado: Lote 7", barra de avance "2 de 4 ítems", ítems con check o valor numérico, **Continuar al cierre**.
- **D. Cierre de labor** (trabajador, HU-008): **Tomar foto** / **Grabar audio**, "1 foto · 1 audio adjuntos (comprimidos)", **Completada** / **No completada (motivo por audio)**, "Guardado en el teléfono. Se enviará al haber señal."
- **E. Verificación** (encargado, HU-012/HU-013): pestañas Por verificar / Historial; cronología con hora del dispositivo y del servidor (p. ej. "10:05 INICIADA (disp.) · 10:31 (serv.)"); **Aprobar** / **Reasignar**; filtros Unidad · Trabajador · Período.

## Fuera de alcance del prototipo
Integración con la Receta Fitosanitaria Digital provincial y registro de movimientos de hacienda (trabajo futuro, junto con panel web, NFC y análisis geográfico).
