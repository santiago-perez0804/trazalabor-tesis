# Infraestructura

Adaptadores a servicios externos y del sistema operativo:

- Cliente de Supabase (autenticación, API REST y almacenamiento de objetos).
- Almacenamiento cifrado para la sesión y el hash local del PIN.
- Firebase Cloud Messaging para el aviso de nuevas asignaciones.
- Cámara, lector de QR y grabación de audio.

Las credenciales se inyectan al compilar con `--dart-define-from-file=config/dev.json`
(archivo fuera del control de versiones; ver `config/ejemplo.json`).
