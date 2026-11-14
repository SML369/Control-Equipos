-- =====================================================================
-- Dermato Control — Seguridad de la base de datos (Supabase)
-- Correr en: Supabase → SQL Editor. Se puede ejecutar varias veces.
--
-- Qué hace:
--   1. Crea la lista de cuentas autorizadas (app_usuarios) con los 4 correos.
--   2. Crea la función es_autorizado(), que compara el correo del JWT con esa lista.
--   3. En cada tabla de la app: activa RLS, borra TODAS las políticas existentes,
--      crea la política "cuentas autorizadas" y quita permisos a anon.
--   4. Avisa (sin abortar) si algún correo autorizado no existe en auth.users.
--
-- Nota: la Edge Function `agenda-ical` usa la llave de servicio (service_role),
-- que no pasa por RLS, así que no se ve afectada por este script.
-- Recomendación adicional: en Authentication → Providers → Email, desactivar
-- "Allow new users to sign up" para que nadie pueda crearse una cuenta.
-- =====================================================================

-- 1. Lista de cuentas autorizadas -------------------------------------
create table if not exists public.app_usuarios (email text primary key);
alter table public.app_usuarios enable row level security;
revoke all on table public.app_usuarios from anon, authenticated;
-- Sin políticas: solo la función security definer (dueño postgres) la lee.

insert into public.app_usuarios (email) values
  ('santiagomejia930314@gmail.com'),
  ('carolinamejiadermatologia@gmail.com'),
  ('sneidertorres07@gmail.com'),
  ('dermatologia1228@hotmail.com')
on conflict do nothing;

-- 2. Función que decide si el usuario del token está autorizado --------
create or replace function public.es_autorizado()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.app_usuarios
    where email = lower(coalesce(auth.jwt()->>'email', ''))
  );
$$;
revoke all on function public.es_autorizado() from public, anon;
grant execute on function public.es_autorizado() to authenticated;

-- 3. Proteger las tablas de la app -------------------------------------
do $$
declare
  t text;
  pol record;
begin
  foreach t in array array[
    'sesiones','inventario_ultra','inventario_vol','soluciones',
    'configuracion','protocolos','agenda_aquapure','cotizaciones'
  ] loop
    if to_regclass('public.'||t) is null then
      raise notice 'La tabla % no existe, se omite', t;
      continue;
    end if;

    execute format('alter table public.%I enable row level security', t);

    -- Borrar todas las políticas existentes (no se conocen sus nombres)
    for pol in
      select policyname from pg_policies where schemaname='public' and tablename=t
    loop
      execute format('drop policy if exists %I on public.%I', pol.policyname, t);
    end loop;

    execute format(
      'create policy "cuentas autorizadas" on public.%I for all to authenticated
         using (public.es_autorizado()) with check (public.es_autorizado())', t);

    execute format('revoke all on table public.%I from anon', t);
    execute format('grant select, insert, update, delete on table public.%I to authenticated', t);
  end loop;
end $$;

-- 4. Aviso: correos autorizados que aún no tienen cuenta en Auth -------
do $$
declare
  faltante record;
begin
  for faltante in
    select a.email from public.app_usuarios a
    where not exists (select 1 from auth.users u where lower(u.email) = a.email)
  loop
    raise notice 'AVISO: el correo autorizado % no existe en auth.users (crear el usuario en Authentication)', faltante.email;
  end loop;
end $$;

-- 5. Recargar el esquema de la API y mostrar las cuentas autorizadas ---
notify pgrst, 'reload schema';
select email as cuenta_autorizada from public.app_usuarios order by email;
