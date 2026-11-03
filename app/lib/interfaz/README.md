# Capa de interfaz

Pantallas y componentes visuales, separados por rol:

- `encargado/`: alta de trabajadores y unidades productivas, nueva labor, verificación e historial.
- `trabajador/`: tareas del día, ejecución con lista de verificación, QR y cierre con evidencia.
- `comunes/`: componentes compartidos (indicador de conexión, teclado de PIN, etc.).

Reglas:

- Lee siempre de la base local; nunca llama directamente al servidor.
- Áreas táctiles de al menos 48 × 48 dp y contraste de texto de al menos 4,5:1 (`tema.dart`).
- Indicador de conexión y de operaciones pendientes visible en todo momento.
