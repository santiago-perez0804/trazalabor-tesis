-- Usuarios de prueba para desarrollo. Teléfonos ficticios.
-- Local: se carga solo con `npx supabase db reset`.
-- Nube:  npx supabase db query --linked -f supabase/seed.sql
-- Quedan PREREGISTRADOS: cada uno activa su cuenta eligiendo su PIN en la app.
insert into public.usuario (id, nombre, telefono, rol, especialidad, created_at_device) values
  ('7a1e0b52-0000-4000-8000-000000000001', 'Encargado de prueba', '3510000001', 'ENCARGADO',  null,           now()),
  ('7a1e0b52-0000-4000-8000-000000000002', 'Juan P.',             '3510000002', 'TRABAJADOR', 'peón general', now()),
  ('7a1e0b52-0000-4000-8000-000000000003', 'Pedro G.',            '3510000003', 'TRABAJADOR', 'tractorista',  now())
on conflict (id) do nothing;
