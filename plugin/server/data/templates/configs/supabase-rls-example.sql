-- =====================================================================
-- BASTION TEMPLATE | Supabase / PostgreSQL Row Level Security pattern
-- Rules: BAAS-01, BAAS-02, BAAS-05, SQL-08, SQL-14
-- Example: per-user "orders" table plus a tenant-scoped "projects" table.
-- =====================================================================

-- 1. Owner-scoped table -------------------------------------------------
create table if not exists public.orders (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  total_cents integer not null check (total_cents >= 0),
  status      text not null default 'pending',
  created_at  timestamptz not null default now()
);

alter table public.orders enable row level security;
alter table public.orders force row level security;

create policy "orders_select_own" on public.orders
  for select to authenticated
  using ( (select auth.uid()) = user_id );

create policy "orders_insert_own" on public.orders
  for insert to authenticated
  with check ( (select auth.uid()) = user_id );

-- Users may not change totals or status from the client (PAY-04).
-- Updates happen only through a server function using the service role.

create index if not exists orders_user_id_idx on public.orders (user_id);

-- 2. Role check helper (SECURITY DEFINER with fixed search_path) --------
create table if not exists public.memberships (
  project_id uuid not null,
  user_id    uuid not null references auth.users (id) on delete cascade,
  role       text not null check (role in ('owner','admin','member','viewer')),
  primary key (project_id, user_id)
);
alter table public.memberships enable row level security;

create policy "memberships_select_own" on public.memberships
  for select to authenticated
  using ( (select auth.uid()) = user_id );

create or replace function public.has_project_role(p_project uuid, p_roles text[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.memberships m
    where m.project_id = p_project
      and m.user_id = (select auth.uid())
      and m.role = any (p_roles)
  );
$$;

revoke execute on function public.has_project_role(uuid, text[]) from public, anon;
grant execute on function public.has_project_role(uuid, text[]) to authenticated;

-- 3. Tenant-scoped table -----------------------------------------------
create table if not exists public.projects (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  created_at timestamptz not null default now()
);
alter table public.projects enable row level security;

create policy "projects_select_members" on public.projects
  for select to authenticated
  using ( public.has_project_role(id, array['owner','admin','member','viewer']) );

create policy "projects_update_admins" on public.projects
  for update to authenticated
  using ( public.has_project_role(id, array['owner','admin']) )
  with check ( public.has_project_role(id, array['owner','admin']) );

-- 4. Verify -------------------------------------------------------------
-- Run the Supabase Security Advisor after applying (BAAS-08)
-- and add tests proving user B cannot read user A's orders (BAAS-11).
