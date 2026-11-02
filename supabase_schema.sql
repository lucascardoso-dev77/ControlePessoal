-- Cole no SQL Editor do Supabase e execute.
create table if not exists despesas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  descricao text not null,
  valor numeric(12,2) not null,
  data date not null,
  categoria text not null default 'Outros',
  created_at timestamptz default now()
);
create table if not exists pendencias (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  titulo text not null,
  vence date not null,
  icone text default '📌',
  feito boolean default false,
  created_at timestamptz default now()
);
create table if not exists metas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  titulo text not null,
  prazo date not null,
  progresso int not null default 0 check (progresso between 0 and 100),
  created_at timestamptz default now()
);

-- Cada usuário só enxerga e altera os próprios dados
do $$ declare t text; begin
  foreach t in array array['despesas','pendencias','metas'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "dono" on %I', t);
    execute format('create policy "dono" on %I for all using (auth.uid() = user_id) with check (auth.uid() = user_id)', t);
  end loop;
end $$;
