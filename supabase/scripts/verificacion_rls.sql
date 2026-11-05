-- Verifica las políticas RLS simulando a cada rol, sin dejar datos.
--   npx supabase db query --linked -f supabase/scripts/verificacion_rls.sql
-- Requiere que el encargado (3510000001) y Juan (3510000002) hayan activado su
-- cuenta. Todo se revierte con la excepción final ("RESULTADO: ...").
do $$
declare
  r        text := '';
  n        integer;
  v_txt    text;
  enc_auth uuid := (select auth_id from public.usuario where telefono = '3510000001');
  juan_aut uuid := (select auth_id from public.usuario where telefono = '3510000002');
  enc      uuid := (select id from public.usuario where telefono = '3510000001');
  juan     uuid := (select id from public.usuario where telefono = '3510000002');
  pedro    uuid := (select id from public.usuario where telefono = '3510000003');
  up       uuid := 'eeeeeeee-0000-4000-8000-000000000010';
  t_juan   uuid := 'eeeeeeee-0000-4000-8000-000000000020';
  t_pedro  uuid := 'eeeeeeee-0000-4000-8000-000000000021';
begin
  if enc_auth is null or juan_aut is null then
    raise exception 'Primero activá las cuentas del encargado y de Juan';
  end if;

  -- ===== Como ENCARGADO =====
  perform set_config('request.jwt.claims', json_build_object('sub', enc_auth, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';

  insert into public.unidad_productiva (id, nombre, tipo, codigo_qr) values (up, 'Lote RLS', 'LOTE', 'rls-qr');
  insert into public.tarea (id, unidad_productiva_id, creador_id, asignado_id, tipo_labor, fecha_programada, created_at_device)
    values (t_juan,  up, enc, juan,  'GENERAL', current_date, now()),
           (t_pedro, up, enc, pedro, 'GENERAL', current_date, now());
  insert into public.item_checklist (id, tarea_id, orden, descripcion, tipo_respuesta, obligatorio)
    values ('eeeeeeee-0000-4000-8000-000000000030', t_juan, 1, 'Dosis', 'NUMERO', true);
  insert into public.evento (id, tarea_id, usuario_id, tipo, created_at_device) values
    (gen_random_uuid(), t_juan,  enc, 'CREADA',   now()), (gen_random_uuid(), t_juan,  enc, 'ASIGNADA', now()),
    (gen_random_uuid(), t_pedro, enc, 'CREADA',   now()), (gen_random_uuid(), t_pedro, enc, 'ASIGNADA', now());
  r := r || '[OK] el encargado crea unidad, tareas, ítems y eventos de gestión | ';

  begin
    insert into public.evento (id, tarea_id, usuario_id, tipo, created_at_device)
      values (gen_random_uuid(), t_juan, juan, 'INICIADA', now());
    r := r || '[FALLA] el encargado registró un evento a nombre de Juan | ';
  exception when insufficient_privilege then
    r := r || '[OK] nadie registra eventos a nombre de otro | ';
  end;

  -- ===== Como JUAN (trabajador) =====
  execute 'reset role';
  perform set_config('request.jwt.claims', json_build_object('sub', juan_aut, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';

  select count(*) into n from public.tarea where id in (t_juan, t_pedro);
  r := r || format('[%s] Juan ve %s de 2 tareas (solo la suya) | ', case when n = 1 then 'OK' else 'FALLA' end, n);

  select count(*) into n from public.evento where tarea_id = t_pedro;
  r := r || format('[%s] Juan ve %s eventos de la tarea de Pedro | ', case when n = 0 then 'OK' else 'FALLA' end, n);

  insert into public.evento (id, tarea_id, usuario_id, tipo, payload, created_at_device) values
    (gen_random_uuid(), t_juan, juan, 'INICIADA', '{}', now() + interval '1 minute'),
    (gen_random_uuid(), t_juan, juan, 'ITEM_COMPLETADO',
     '{"item_id": "eeeeeeee-0000-4000-8000-000000000030", "valor": "1.5"}', now() + interval '2 minute');
  select estado_actual into v_txt from public.tarea where id = t_juan;
  r := r || format('[%s] Juan registra eventos de ejecución; estado = %s | ', case when v_txt = 'INICIADA' then 'OK' else 'FALLA' end, v_txt);

  begin
    insert into public.evento (id, tarea_id, usuario_id, tipo, created_at_device)
      values (gen_random_uuid(), t_juan, juan, 'VERIFICADA', now() + interval '3 minute');
    r := r || '[FALLA] Juan aprobó su propia labor | ';
  exception when insufficient_privilege then
    r := r || '[OK] Juan no puede registrar VERIFICADA | ';
  end;

  begin
    insert into public.evento (id, tarea_id, usuario_id, tipo, created_at_device)
      values (gen_random_uuid(), t_pedro, juan, 'INICIADA', now());
    r := r || '[FALLA] Juan registró en la tarea de Pedro | ';
  exception when insufficient_privilege then
    r := r || '[OK] Juan no registra eventos en tareas ajenas | ';
  end;

  update public.evento set tipo = 'VERIFICADA' where tarea_id = t_juan;
  get diagnostics n = row_count;
  r := r || format('[%s] Juan modificó %s eventos | ', case when n = 0 then 'OK' else 'FALLA' end, n);

  update public.tarea set estado_actual = 'VERIFICADA' where id = t_juan;
  get diagnostics n = row_count;
  r := r || format('[%s] Juan modificó %s tareas | ', case when n = 0 then 'OK' else 'FALLA' end, n);

  -- ===== Como ENCARGADO: no puede cambiar el teléfono de una cuenta activa =====
  execute 'reset role';
  perform set_config('request.jwt.claims', json_build_object('sub', enc_auth, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  begin
    update public.usuario set telefono = '3519999999' where id = juan;
    r := r || '[FALLA] se cambió el teléfono de una cuenta activa';
  exception when raise_exception then
    r := r || '[OK] el teléfono de una cuenta activa no se puede cambiar';
  end;

  execute 'reset role';
  raise exception 'RESULTADO: %', r;
end $$;
