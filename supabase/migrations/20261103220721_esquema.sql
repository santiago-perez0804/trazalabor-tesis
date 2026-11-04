-- =============================================================================
-- TrazaLabor — esquema central (Tabla 14 de la tesis)
-- Mismo modelo que la base local en Drift (app/lib/repositorio/tablas.dart).
-- Tarea T-04 (parte). Las políticas RLS por rol se agregan en una migración posterior.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tablas
-- -----------------------------------------------------------------------------

create table public.usuario (
  id                 uuid primary key,
  auth_id            uuid unique references auth.users (id) on delete set null,
  nombre             text not null,
  telefono           text not null unique,
  rol                text not null check (rol in ('ENCARGADO', 'TRABAJADOR')),
  especialidad       text,
  activo             boolean not null default true,
  created_at_device  timestamptz not null,
  received_at_server timestamptz not null default now(),
  -- Agregado de implementación (decisión D9): token de FCM para HU-010.
  fcm_token          text
);

create table public.unidad_productiva (
  id           uuid primary key,
  nombre       text not null,
  tipo         text not null check (tipo in ('LOTE', 'POTRERO', 'INSTALACION')),
  superficie_ha numeric(10, 2),
  codigo_qr    text not null unique,
  latitud      double precision,
  longitud     double precision,
  activa       boolean not null default true
);

create table public.tarea (
  id                   uuid primary key,
  unidad_productiva_id uuid not null references public.unidad_productiva (id),
  creador_id           uuid not null references public.usuario (id),
  asignado_id          uuid not null references public.usuario (id),
  tipo_labor           text not null check (tipo_labor in (
                         'GENERAL', 'SIEMBRA', 'APLICACION_FITOSANITARIA',
                         'SANIDAD_ANIMAL', 'MANTENIMIENTO')),
  descripcion          text,
  fecha_programada     date not null,
  requiere_qr          boolean not null default false,
  evidencia_requerida  text not null default 'NINGUNA'
                         check (evidencia_requerida in ('NINGUNA', 'FOTO', 'AUDIO', 'FOTO_Y_AUDIO')),
  -- Proyección: la recalcula el trigger de evento (no la decide el cliente).
  estado_actual        text not null default 'CREADA'
                         check (estado_actual in ('CREADA', 'ASIGNADA', 'INICIADA',
                           'COMPLETADA', 'NO_COMPLETADA', 'VERIFICADA')),
  created_at_device    timestamptz not null,
  received_at_server   timestamptz not null default now()
);
create index idx_tarea_asignado_fecha on public.tarea (asignado_id, fecha_programada);
create index idx_tarea_unidad on public.tarea (unidad_productiva_id);

create table public.item_checklist (
  id             uuid primary key,
  tarea_id       uuid not null references public.tarea (id),
  orden          integer not null,
  descripcion    text not null,
  tipo_respuesta text not null check (tipo_respuesta in ('CHECK', 'NUMERO', 'TEXTO')),
  obligatorio    boolean not null default false,
  valor          text,
  completado     boolean not null default false
);
create index idx_item_tarea on public.item_checklist (tarea_id);

-- Bitácora de solo adición (Fowler, 2005). La clave de idempotencia es el id.
create table public.evento (
  id                 uuid primary key,
  tarea_id           uuid not null references public.tarea (id),
  usuario_id         uuid not null references public.usuario (id),
  tipo               text not null check (tipo in (
                       'CREADA', 'ASIGNADA', 'INICIADA', 'ITEM_COMPLETADO',
                       'QR_VERIFICADO', 'EVIDENCIA_ADJUNTA', 'COMPLETADA',
                       'NO_COMPLETADA', 'VERIFICADA', 'REASIGNADA')),
  payload            jsonb not null default '{}'::jsonb,
  created_at_device  timestamptz not null,
  received_at_server timestamptz not null default now(),
  latitud            double precision,
  longitud           double precision
);
create index idx_evento_tarea on public.evento (tarea_id);
-- Cursor de descarga de la sincronización diferida.
create index idx_evento_recibido on public.evento (received_at_server);

create table public.evidencia (
  id                 uuid primary key,
  tarea_id           uuid not null references public.tarea (id),
  usuario_id         uuid not null references public.usuario (id),
  tipo               text not null check (tipo in ('FOTO', 'AUDIO')),
  -- ruta_local existe por simetría con la Tabla 14; el cliente nunca la envía.
  ruta_local         text,
  ruta_remota        text,
  tamanio_bytes      bigint,
  hash_sha256        text not null check (hash_sha256 ~ '^[0-9a-f]{64}$'),
  created_at_device  timestamptz not null,
  received_at_server timestamptz not null default now()
);
create index idx_evidencia_tarea on public.evidencia (tarea_id);

-- -----------------------------------------------------------------------------
-- La hora del servidor la pone siempre el servidor
-- -----------------------------------------------------------------------------

create function public.fijar_received_at_server()
returns trigger language plpgsql as $$
begin
  if tg_op = 'INSERT' then
    new.received_at_server := now();
  else
    -- En una modificación se conserva la hora de recepción original.
    new.received_at_server := old.received_at_server;
  end if;
  return new;
end $$;

create trigger usuario_received_at_server before insert or update on public.usuario
  for each row execute function public.fijar_received_at_server();
create trigger tarea_received_at_server before insert or update on public.tarea
  for each row execute function public.fijar_received_at_server();
create trigger evento_received_at_server before insert on public.evento
  for each row execute function public.fijar_received_at_server();
create trigger evidencia_received_at_server before insert on public.evidencia
  for each row execute function public.fijar_received_at_server();

-- -----------------------------------------------------------------------------
-- Solo adición: evento (y la evidencia, cuya huella no debe cambiar)
-- -----------------------------------------------------------------------------

create function public.rechazar_modificacion()
returns trigger language plpgsql as $$
begin
  raise exception '% es de solo adición', tg_table_name
    using hint = format('Operación %s rechazada: registrar un evento nuevo.', tg_op);
end $$;

create trigger evento_solo_adicion before update or delete on public.evento
  for each row execute function public.rechazar_modificacion();
create trigger evento_sin_truncate before truncate on public.evento
  for each statement execute function public.rechazar_modificacion();
create trigger evidencia_solo_adicion before update or delete on public.evidencia
  for each row execute function public.rechazar_modificacion();
create trigger evidencia_sin_truncate before truncate on public.evidencia
  for each statement execute function public.rechazar_modificacion();

-- -----------------------------------------------------------------------------
-- Proyecciones derivadas de la bitácora (misma regla que dominio/derivar_estado.dart)
-- -----------------------------------------------------------------------------

-- Etapa del ciclo: desempata eventos con la misma hora del dispositivo.
-- Debe coincidir con rangoEvento() en Dart.
create function public.rango_evento(p_tipo text)
returns integer language sql immutable as $$
  select case p_tipo
    when 'CREADA' then 0
    when 'ASIGNADA' then 1
    when 'INICIADA' then 2
    when 'ITEM_COMPLETADO' then 3
    when 'QR_VERIFICADO' then 3
    when 'EVIDENCIA_ADJUNTA' then 3
    when 'COMPLETADA' then 4
    when 'NO_COMPLETADA' then 4
    when 'VERIFICADA' then 5
    when 'REASIGNADA' then 5
  end
$$;

create function public.proyectar_eventos_tarea(p_tarea_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_estado        text;
  v_reasignada_at timestamptz;
  v_nuevo_asig    uuid;
begin
  -- Estado: último evento de estado; REASIGNADA vuelve a ASIGNADA.
  select case e.tipo when 'REASIGNADA' then 'ASIGNADA' else e.tipo end
    into v_estado
    from evento e
   where e.tarea_id = p_tarea_id
     and e.tipo in ('CREADA', 'ASIGNADA', 'INICIADA', 'COMPLETADA',
                    'NO_COMPLETADA', 'VERIFICADA', 'REASIGNADA')
   order by e.created_at_device desc, rango_evento(e.tipo) desc
   limit 1;

  -- Última reasignación: define el asignado vigente y el inicio del ciclo.
  select e.created_at_device, (e.payload ->> 'nuevo_asignado_id')::uuid
    into v_reasignada_at, v_nuevo_asig
    from evento e
   where e.tarea_id = p_tarea_id and e.tipo = 'REASIGNADA'
   order by e.created_at_device desc
   limit 1;

  update tarea
     set estado_actual = coalesce(v_estado, 'CREADA'),
         asignado_id   = coalesce(v_nuevo_asig, asignado_id)
   where id = p_tarea_id;

  -- Ítems: se reinician y se aplica el último ITEM_COMPLETADO del ciclo vigente.
  update item_checklist
     set valor = null, completado = false
   where tarea_id = p_tarea_id;

  update item_checklist i
     set valor = u.valor, completado = true
    from (
      select distinct on (e.payload ->> 'item_id')
             (e.payload ->> 'item_id')::uuid as item_id,
             e.payload ->> 'valor'           as valor
        from evento e
       where e.tarea_id = p_tarea_id
         and e.tipo = 'ITEM_COMPLETADO'
         and (v_reasignada_at is null or e.created_at_device > v_reasignada_at)
       order by e.payload ->> 'item_id', e.created_at_device desc, e.received_at_server desc
    ) u
   where i.id = u.item_id
     and i.tarea_id = p_tarea_id;
end $$;

create function public.evento_proyectar()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.proyectar_eventos_tarea(new.tarea_id);
  return null;
end $$;

create trigger evento_proyectar after insert on public.evento
  for each row execute function public.evento_proyectar();

-- Las funciones security definer no se exponen como RPC.
revoke execute on function public.proyectar_eventos_tarea(uuid) from public, anon, authenticated;

-- -----------------------------------------------------------------------------
-- RLS: habilitada y sin políticas = nadie accede por la API hasta que se agreguen
-- las políticas por rol (Encargado / Trabajador).
-- -----------------------------------------------------------------------------

alter table public.usuario           enable row level security;
alter table public.unidad_productiva enable row level security;
alter table public.tarea             enable row level security;
alter table public.item_checklist    enable row level security;
alter table public.evento            enable row level security;
alter table public.evidencia         enable row level security;
