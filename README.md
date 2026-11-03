# TrazaLabor

Prototipo del Trabajo Final de Grado **"Sistema móvil para la trazabilidad de labores rurales con operación sin conexión"**
— Santiago Pérez, Ingeniería en Software, Universidad Siglo 21 (2026).

Aplicación Android (Flutter) **local-first**: el encargado asigna labores con listas de verificación sobre unidades
productivas y el trabajador rural las ejecuta y documenta desde su teléfono —aun sin señal— con fotos, audios y
lectura de códigos QR que acreditan su presencia. Cada acción se registra como un evento de solo adición con la hora
del dispositivo y la del servidor, y se sincroniza en diferido con Supabase.

| Capa | Tecnología |
|---|---|
| Aplicación móvil | Flutter (Dart) |
| Persistencia local | SQLite mediante Drift |
| Sincronización | Bandeja de salida transaccional + registro de eventos de solo adición (diseño propio) |
| Ejecución diferida | workmanager |
| Infraestructura central | Supabase (PostgreSQL, API REST, Auth, Storage) |
| Notificaciones | Firebase Cloud Messaging |
| Verificación de presencia | Códigos QR |

## Estructura

```
app/        Aplicación Flutter (Android)
  lib/interfaz/       Pantallas por rol (encargado, trabajador) y componentes comunes
  lib/dominio/        Reglas del negocio: eventos, estado de la labor, cierre, PIN
  lib/repositorio/    Base local SQLite (Drift) y bandeja de salida transaccional
  lib/sincronizacion/ Envío diferido de la bandeja y de la multimedia
  lib/infra/          Supabase, almacenamiento seguro, notificaciones, cámara y QR
supabase/   Configuración del proyecto, migraciones SQL y funciones del servidor
docs/       Especificación tomada de la tesis y trazabilidad historias → código
```

## Puesta en marcha (desarrollo)

1. Copiar `app/config/ejemplo.json` a `app/config/dev.json` y completar la URL y la clave publicable de Supabase.
2. Desde `app/`: `flutter pub get` y `flutter run --dart-define-from-file=config/dev.json`.

## Documentación

- Especificación: [`docs/especificacion/`](docs/especificacion/)
- Trazabilidad historias de usuario → código: [`docs/trazabilidad.md`](docs/trazabilidad.md)
