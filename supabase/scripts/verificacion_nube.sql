-- VerificaciÃ³n del esquema contra el proyecto en la nube, sin Docker.
--   npx supabase db query --linked -f supabase/scripts/verificacion_nube.sql
-- Todo ocurre dentro de un bloque que al final se revierte con una excepciÃ³n
-- controlada: no quedan datos de prueba (la bitÃ¡cora no admite DELETE).
-- El resultado aparece en el mensaje de error "RESULTADO: ...".
do $$
declare
  r      text := '';
  v_txt  text;
  v_bool boolean;
  t      constant uuid := 'ffffffff-0000-4000-8000-000000000020';
begin
  insert into usuario (id, nombre, telefono, rol, created_at_device) values
    ('ffffffff-0000-4000-8000-000000000001', 'Verif enc', 'verif-1', 'ENCARGADO',  now()),
    ('ffffffff-0000-4000-8000-000000000002', 'Verif trab', 'verif-2', 'TRABAJADOR', now()),
    ('ffffffff-0000-4000-8000-000000000003', 'Verif otro', 'verif-3', 'TRABAJADOR', now());
  insert into unidad_productiva (id, nombre, tipo, codigo_qr)
    values ('ffffffff-0000-4000-8000-000000000010', 'Verif lote', 'LOTE', 'verif-qr');
  insert into tarea (id, unidad_productiva_id, creador_id, asignado_id, tipo_labor,
                     fecha_programada, created_at_device, received_at_server)
    values (t, 'ffffffff-0000-4000-8000-000000000010', 'ffffffff-0000-4000-8000-000000000001',
            'ffffffff-0000-4000-8000-000000000002', 'GENERAL', current_date, now(), '2000-01-01');
  insert into item_checklist (id, tarea_id, orden, descripcion, tipo_respuesta, obligatorio)
    values ('ffffffff-0000-4000-8000-000000000030', t, 1, 'Dosis', 'NUMERO', true);

  select received_at_server > '2001-01-01' into v_bool from tarea where id = t;
  r := r || format('[%s] received_at_server lo pone el servidor | ', case when v_bool then 'OK' else 'FALLA' end);

  insert into evento (id, tarea_id, usuario_id, tipo, created_at_device) values
    ('ffffffff-0000-4000-8000-000000000101', t, 'ffffffff-0000-4000-8000-000000000001', 'ASIGNADA', '2026-10-20T13:00:00Z'),
    ('ffffffff-0000-4000-8000-000000000100', t, 'ffffffff-0000-4000-8000-000000000001', 'CREADA',   '2026-10-20T13:00:00Z');
  select estado_actual into v_txt from tarea where id = t;
  r := r || format('[%s] estado con empate de hora = %s | ', case when v_txt = 'ASIGNADA' then 'OK' else 'FALLA' end, v_txt);

  insert into evento (id, tarea_id, usuario_id, tipo, payload, created_at_device) values
    ('ffffffff-0000-4000-8000-000000000103', t, 'ffffffff-0000-4000-8000-000000000002', 'ITEM_COMPLETADO',
     '{"item_id": "ffffffff-0000-4000-8000-000000000030", "valor": "1.5"}', '2026-10-20T13:10:00Z');
  select valor into v_txt from item_checklist where id = 'ffffffff-0000-4000-8000-000000000030';
  r := r || format('[%s] proyecciÃ³n del Ã­tem = %s | ', case when v_txt = '1.5' then 'OK' else 'FALLA' end, v_txt);

  begin
    update evento set tipo = 'VERIFICADA' where id = 'ffffffff-0000-4000-8000-000000000100';
    r := r || '[FALLA] UPDATE sobre evento permitido | ';
  exception when raise_exception then
    r := r || format('[OK] UPDATE rechazado: %s | ', sqlerrm);
  end;

  begin
    delete from evento where id = 'ffffffff-0000-4000-8000-000000000100';
    r := r || '[FALLA] DELETE sobre evento permitido | ';
  exception when raise_exception then
    r := r || format('[OK] DELETE rechazado: %s | ', sqlerrm);
  end;

  insert into evento (id, tarea_id, usuario_id, tipo, payload, created_at_device) values
    ('ffffffff-0000-4000-8000-000000000105', t, 'ffffffff-0000-4000-8000-000000000001', 'REASIGNADA',
     '{"nuevo_asignado_id": "ffffffff-0000-4000-8000-000000000003"}', '2026-10-20T14:00:00Z');
  select estado_actual || ' / ' || asignado_id::text into v_txt from tarea where id = t;
  r := r || format('[%s] reasignaciÃ³n = %s', case when v_txt = 'ASIGNADA / ffffffff-0000-4000-8000-000000000003' then 'OK' else 'FALLA' end, v_txt);

  -- Revierte todo lo anterior y muestra el resultado.
  raise exception 'RESULTADO: %', r;
end $$;
