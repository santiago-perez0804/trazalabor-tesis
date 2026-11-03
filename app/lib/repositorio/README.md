# Capa de repositorio

Acceso a la base local SQLite mediante Drift, que es la fuente primaria de los datos.

- Tablas del diccionario de datos: `usuario`, `unidad_productiva`, `tarea`, `item_checklist`,
  `evento`, `evidencia` y la bandeja de salida `operacion_pendiente` (solo en el dispositivo).
- Cada acción se guarda en una única transacción que escribe la entidad, el evento y la
  operación pendiente.
- Los eventos solo se insertan: nunca se modifican ni se borran.
