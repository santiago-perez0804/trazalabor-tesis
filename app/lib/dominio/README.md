# Capa de dominio

Reglas del negocio, en Dart puro (sin Flutter, sin base de datos, sin red):

- Tipos de evento de la bitácora: `CREADA`, `ASIGNADA`, `INICIADA`, `ITEM_COMPLETADO`,
  `QR_VERIFICADO`, `EVIDENCIA_ADJUNTA`, `COMPLETADA`, `NO_COMPLETADA`, `VERIFICADA` y `REASIGNADA`.
- Derivación del estado de una labor a partir de su secuencia de eventos.
- Validación del cierre (ítems obligatorios, evidencia requerida, verificación por QR).
- Reglas del PIN y del bloqueo por intentos fallidos.
