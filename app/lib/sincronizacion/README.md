# Sincronización diferida

Envío de la bandeja de salida y de la cola de multimedia cuando hay conexión, y descarga de
las novedades del servidor.

- Se ejecuta en segundo plano con workmanager.
- Envía las operaciones en orden y de forma idempotente (upsert por UUID): reenviar no duplica.
- Una operación se marca como enviada solo cuando el servidor confirma la recepción.
- Las fotos y los audios van por una cola separada que no bloquea el envío de los eventos.
