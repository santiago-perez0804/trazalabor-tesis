-- Pruebas pgTAP del esquema central. Correr con: npx supabase test db
-- (requiere `npx supabase start`, es decir, Docker con su disco en D:).
begin;
select plan(9);

insert into usuario (id, nombre, telefono, rol, created_at_device) values
  ('00000000-0000-4000-8000-000000000001', 'Encargado', '3510000001', 'ENCARGADO',  '2026-10-20T13:00:00Z'),
  ('00000000-0000-4000-8000-000000000002', 'Trabajador', '3510000002', 'TRABAJADOR', '2026-10-20T13:00:00Z'),
  ('00000000-0000-4000-8000-000000000003', 'Otro',       '3510000003', 'TRABAJADOR', '2026-10-20T13:00:00Z');
insert into unidad_productiva (id, nombre, tipo, codigo_qr) values
  ('00000000-0000-4000-8000-000000000010', 'Lote 7', 'LOTE', 'TRZ-TEST-LOTE7');

-- El cliente intenta fijar su propia hora de recepción: debe ignorarse.
insert into tarea (id, unidad_productiva_id, creador_id, asignado_id, tipo_labor,
                   fecha_programada, created_at_device, received_at_server)
values ('00000000-0000-4000-8000-000000000020', '00000000-0000-4000-8000-000000000010',
        '00000000-0000-4000-8000-000000000001', '00000000-0000-4000-8000-000000000002',
        'APLICACION_FITOSANITARIA', '2026-10-20', '2026-10-20T13:00:00Z', '2000-01-01T00:00:00Z');
insert into item_checklist (id, tarea_id, orden, descripcion, tipo_respuesta, obligatorio) values
  ('00000000-0000-4000-8000-000000000030', '00000000-0000-4000-8000-000000000020', 1, 'Dosis (l/ha)', 'NUMERO', true);

select isnt(
  (select received_at_server from tarea where id = '00000000-0000-4000-8000-000000000020'),
  '2000-01-01T00:00:00Z'::timestamptz,
  'received_at_server lo pone el servidor, no el cliente');

-- CREADA y ASIGNADA con la misma hora, insertadas al revés.
insert into evento (id, tarea_id, usuario_id, tipo, created_at_device) values
  ('00000000-0000-4000-8000-000000000101', '00000000-0000-4000-8000-000000000020', '00000000-0000-4000-8000-000000000001', 'ASIGNADA', '2026-10-20T13:00:00Z'),
  ('00000000-0000-4000-8000-000000000100', '00000000-0000-4000-8000-000000000020', '00000000-0000-4000-8000-000000000001', 'CREADA',   '2026-10-20T13:00:00Z');

select is(
  (select estado_actual from tarea where id = '00000000-0000-4000-8000-000000000020'),
  'ASIGNADA', 'a igual hora, ASIGNADA gana a CREADA (rango_evento)');

insert into evento (id, tarea_id, usuario_id, tipo, payload, created_at_device) values
  ('00000000-0000-4000-8000-000000000102', '00000000-0000-4000-8000-000000000020', '00000000-0000-4000-8000-000000000002', 'INICIADA', '{}', '2026-10-20T13:05:00Z'),
  ('00000000-0000-4000-8000-000000000103', '00000000-0000-4000-8000-000000000020', '00000000-0000-4000-8000-000000000002', 'ITEM_COMPLETADO',
   '{"item_id": "00000000-0000-4000-8000-000000000030", "valor": "1.5"}', '2026-10-20T13:10:00Z');

select is(
  (select estado_actual from tarea where id = '00000000-0000-4000-8000-000000000020'),
  'INICIADA', 'ITEM_COMPLETADO no cambia el estado');
select is(
  (select valor from item_checklist where id = '00000000-0000-4000-8000-000000000030'),
  '1.5', 'el trigger proyecta el valor del ítem');

select throws_ok(
  $$update evento set tipo = 'VERIFICADA' where id = '00000000-0000-4000-8000-000000000100'$$,
  'P0001', 'evento es de solo adición', 'UPDATE sobre evento rechazado');
select throws_ok(
  $$delete from evento where id = '00000000-0000-4000-8000-000000000100'$$,
  'P0001', 'evento es de solo adición', 'DELETE sobre evento rechazado');

insert into evento (id, tarea_id, usuario_id, tipo, payload, created_at_device) values
  ('00000000-0000-4000-8000-000000000104', '00000000-0000-4000-8000-000000000020', '00000000-0000-4000-8000-000000000002', 'NO_COMPLETADA',
   '{"motivo": "se rompió la pulverizadora"}', '2026-10-20T13:20:00Z'),
  ('00000000-0000-4000-8000-000000000105', '00000000-0000-4000-8000-000000000020', '00000000-0000-4000-8000-000000000001', 'REASIGNADA',
   '{"nuevo_asignado_id": "00000000-0000-4000-8000-000000000003", "motivo": "reprogramar"}', '2026-10-20T14:00:00Z');

select is(
  (select estado_actual from tarea where id = '00000000-0000-4000-8000-000000000020'),
  'ASIGNADA', 'REASIGNADA vuelve la tarea a ASIGNADA');
select is(
  (select asignado_id from tarea where id = '00000000-0000-4000-8000-000000000020'),
  '00000000-0000-4000-8000-000000000003'::uuid, 'REASIGNADA cambia el asignado');
select is(
  (select completado from item_checklist where id = '00000000-0000-4000-8000-000000000030'),
  false, 'REASIGNADA reinicia los ítems del ciclo anterior');

select * from finish();
rollback;
