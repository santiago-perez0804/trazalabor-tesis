-- =============================================================================
-- TrazaLabor — permisos por rol y activación de cuentas
-- Sección "Seguridad" de la tesis: dos perfiles aplicados en la interfaz y en
-- la base central mediante RLS. T-04 (RLS), T-09 (activación).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Funciones auxiliares. Son security definer para leer `usuario` sin quedar
-- sujetas a las mismas políticas (evita recursión). Solo cuentan usuarios activos.
-- -----------------------------------------------------------------------------

create function public.usuario_actual()
returns uuid language sql stable security definer set search_path = public as $$
  select id from usuario where auth_id = auth.uid() and activo
$$;

create function public.es_encargado()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from usuario
     where auth_id = auth.uid() and activo and rol = 'ENCARGADO')
$$;

-- El usuario es el asignado actual de la tarea, o ya registró eventos en ella.
-- Lo segundo cubre al trabajador que ejecutó sin señal mientras se la
-- reasignaban: la bitácora debe reflejar lo que realmente pasó en el campo.
create function public.participa_en_tarea(p_tarea_id uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from tarea
                  where id = p_tarea_id and asignado_id = public.usuario_actual())
      or exists (select 1 from evento
                  where tarea_id = p_tarea_id and usuario_id = public.usuario_actual())
$$;

-- -----------------------------------------------------------------------------
-- usuario: el encargado administra; el trabajador ve su fila y a los encargados
-- -----------------------------------------------------------------------------

create policy "usuario: ver" on public.usuario for select to authenticated
  using (
    public.es_encargado()
    or id = public.usuario_actual()
    or (rol = 'ENCARGADO' and public.usuario_actual() is not null)
  );

create policy "usuario: alta por el encargado" on public.usuario for insert to authenticated
  with check (public.es_encargado());

create policy "usuario: modificación por el encargado" on public.usuario for update to authenticated
  using (public.es_encargado())
  with check (public.es_encargado());

-- Columnas que el cliente no puede fijar: el vínculo con Auth y el token de FCM
-- los escriben funciones del servidor.
create function public.proteger_columnas_usuario()
returns trigger language plpgsql as $$
begin
  if current_user in ('authenticated', 'anon') then
    if tg_op = 'INSERT' then
      new.auth_id := null;
      new.fcm_token := null;
    else
      new.id := old.id;
      new.auth_id := old.auth_id;
      new.fcm_token := old.fcm_token;
      new.created_at_device := old.created_at_device;
      -- La cuenta de Auth se creó con el teléfono: cambiarlo dejaría al
      -- usuario sin poder ingresar. Primero hay que restablecer el PIN.
      if old.auth_id is not null and new.telefono is distinct from old.telefono then
        raise exception 'No se puede cambiar el teléfono de una cuenta activa'
          using hint = 'Restablecé el PIN del usuario y volvé a intentarlo.';
      end if;
    end if;
  end if;
  return new;
end $$;

create trigger usuario_proteger_columnas before insert or update on public.usuario
  for each row execute function public.proteger_columnas_usuario();

-- -----------------------------------------------------------------------------
-- unidad_productiva: todos los activos la ven; el encargado administra
-- -----------------------------------------------------------------------------

create policy "unidad: ver" on public.unidad_productiva for select to authenticated
  using (public.usuario_actual() is not null);

create policy "unidad: alta por el encargado" on public.unidad_productiva for insert to authenticated
  with check (public.es_encargado());

create policy "unidad: modificación por el encargado" on public.unidad_productiva for update to authenticated
  using (public.es_encargado())
  with check (public.es_encargado());

-- -----------------------------------------------------------------------------
-- tarea e item_checklist: el encargado crea y ve todo; el trabajador ve solo
-- las suyas. Nadie las modifica desde el cliente: las proyecciones las
-- actualiza el trigger de evento.
-- -----------------------------------------------------------------------------

create policy "tarea: ver" on public.tarea for select to authenticated
  using (public.es_encargado() or asignado_id = public.usuario_actual());

create policy "tarea: alta por el encargado" on public.tarea for insert to authenticated
  with check (public.es_encargado() and creador_id = public.usuario_actual());

create policy "item: ver" on public.item_checklist for select to authenticated
  using (
    public.es_encargado()
    or exists (select 1 from public.tarea t
                where t.id = tarea_id and t.asignado_id = public.usuario_actual())
  );

create policy "item: alta por el encargado" on public.item_checklist for insert to authenticated
  with check (public.es_encargado());

-- -----------------------------------------------------------------------------
-- evento: solo inserción y siempre a nombre propio.
--   Encargado: eventos de gestión (CREADA, ASIGNADA, VERIFICADA, REASIGNADA).
--   Quien participa en la tarea: eventos de ejecución.
-- No hay políticas de UPDATE ni DELETE (además el trigger lo impide).
-- -----------------------------------------------------------------------------

create policy "evento: ver" on public.evento for select to authenticated
  using (
    public.es_encargado()
    or exists (select 1 from public.tarea t
                where t.id = tarea_id and t.asignado_id = public.usuario_actual())
  );

create policy "evento: registrar" on public.evento for insert to authenticated
  with check (
    usuario_id = public.usuario_actual()
    and (
      (tipo in ('CREADA', 'ASIGNADA', 'VERIFICADA', 'REASIGNADA') and public.es_encargado())
      or
      (tipo in ('INICIADA', 'ITEM_COMPLETADO', 'QR_VERIFICADO', 'EVIDENCIA_ADJUNTA',
                'COMPLETADA', 'NO_COMPLETADA') and public.participa_en_tarea(tarea_id))
    )
  );

create policy "evidencia: ver" on public.evidencia for select to authenticated
  using (
    public.es_encargado()
    or exists (select 1 from public.tarea t
                where t.id = tarea_id and t.asignado_id = public.usuario_actual())
  );

create policy "evidencia: registrar" on public.evidencia for insert to authenticated
  with check (usuario_id = public.usuario_actual() and public.participa_en_tarea(tarea_id));

-- -----------------------------------------------------------------------------
-- Activación de cuentas (HU-002 c3) sin credenciales administrativas en la app
-- -----------------------------------------------------------------------------

-- Estado de la cuenta de un teléfono. Se consulta antes de iniciar sesión para
-- decidir si el usuario debe crear su PIN o ingresarlo.
create function public.estado_cuenta(p_telefono text)
returns text language sql stable security definer set search_path = public as $$
  select coalesce(
    (select case
              when not activo then 'INACTIVO'
              when auth_id is null then 'PREREGISTRADO'
              else 'ACTIVO'
            end
       from usuario
      where telefono = regexp_replace(p_telefono, '\D', '', 'g')),
    'INEXISTENTE')
$$;

revoke execute on function public.estado_cuenta(text) from public;
grant execute on function public.estado_cuenta(text) to anon, authenticated;

-- Al crearse una cuenta en Auth (signUp con <teléfono>@trazalabor.local),
-- se vincula con el usuario preregistrado por el encargado. Si el teléfono
-- no fue dado de alta, o está desactivado, la cuenta se rechaza.
create function public.vincular_cuenta_auth()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_telefono text := split_part(new.email, '@', 1);
  v_usuario  uuid;
begin
  if new.email is null or split_part(new.email, '@', 2) <> 'trazalabor.local' then
    raise exception 'Solo se admiten cuentas de TrazaLabor';
  end if;

  update usuario
     set auth_id = new.id
   where telefono = v_telefono and auth_id is null and activo
  returning id into v_usuario;

  if v_usuario is null then
    raise exception 'El teléfono % no fue dado de alta por un encargado', v_telefono;
  end if;
  return new;
end $$;

create trigger trazalabor_vincular_cuenta after insert on auth.users
  for each row execute function public.vincular_cuenta_auth();

-- Las funciones internas no se exponen como RPC.
revoke execute on function public.vincular_cuenta_auth() from public, anon, authenticated;
revoke execute on function public.proteger_columnas_usuario() from public, anon, authenticated;

-- -----------------------------------------------------------------------------
-- Almacenamiento de evidencias: bucket privado, una carpeta por tarea
-- -----------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit)
values ('evidencias', 'evidencias', false, 10485760)
on conflict (id) do nothing;

create policy "evidencias: subir a tareas propias" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'evidencias'
    and public.participa_en_tarea(((storage.foldername(name))[1])::uuid)
  );

create policy "evidencias: ver de tareas visibles" on storage.objects for select to authenticated
  using (
    bucket_id = 'evidencias'
    and (public.es_encargado()
         or public.participa_en_tarea(((storage.foldername(name))[1])::uuid))
  );
