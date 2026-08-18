-- ============================================================
--  EQUIPES  (líder, cabo eleitoral, motorista etc. por região)
--  Rode DEPOIS do schema. Idempotente na estrutura.
-- ============================================================
create table if not exists public.equipes (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  regiao text not null,
  criado_por uuid references auth.users(id),
  criado_em timestamptz not null default now()
);
create index if not exists idx_equipes_regiao on public.equipes(regiao);

create table if not exists public.equipe_membros (
  id uuid primary key default gen_random_uuid(),
  equipe_id uuid not null references public.equipes(id) on delete cascade,
  nome text not null,
  funcao text,
  telefone text,
  criado_por uuid references auth.users(id),
  criado_em timestamptz not null default now()
);
create index if not exists idx_equipe_membros_equipe on public.equipe_membros(equipe_id);

alter table public.equipes enable row level security;
alter table public.equipe_membros enable row level security;

-- Equipes: só super admin cria/edita/exclui; editores enxergam a(s) sua(s) região(ões).
drop policy if exists "eq: leitura" on public.equipes;
create policy "eq: leitura" on public.equipes for select to authenticated
  using (public.eh_super_admin() or exists (
    select 1 from public.profiles p where p.id = auth.uid() and equipes.regiao = any(p.regioes)
  ));
drop policy if exists "eq: escrita super" on public.equipes;
create policy "eq: escrita super" on public.equipes for all to authenticated
  using (public.eh_super_admin()) with check (public.eh_super_admin());

-- Membros: leitura segue a equipe; escrita só super admin.
drop policy if exists "eqm: leitura" on public.equipe_membros;
create policy "eqm: leitura" on public.equipe_membros for select to authenticated
  using (public.eh_super_admin() or exists (
    select 1 from public.equipes e join public.profiles p on p.id = auth.uid()
    where e.id = equipe_membros.equipe_id and e.regiao = any(p.regioes)
  ));
drop policy if exists "eqm: escrita super" on public.equipe_membros;
create policy "eqm: escrita super" on public.equipe_membros for all to authenticated
  using (public.eh_super_admin()) with check (public.eh_super_admin());

grant all on public.equipes to anon, authenticated;
grant all on public.equipe_membros to anon, authenticated;
