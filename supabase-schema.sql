-- LOAN SMART · RL
-- Supabase database + RLS
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  display_name text,
  verified_mobile text,
  created_at timestamptz not null default now()
);

create table if not exists public.loans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  lender text,
  principal numeric(14,2) not null check (principal >= 0),
  interest_rate numeric(7,3) not null check (interest_rate >= 0),
  tenure_months integer not null check (tenure_months > 0),
  frequency text not null check (frequency in ('monthly','weekly')),
  payment_amount numeric(14,2) not null check (payment_amount >= 0),
  start_date date,
  next_payment_date date,
  remaining_balance numeric(14,2) not null default 0 check (remaining_balance >= 0),
  status text not null default 'active' check (status in ('active','completed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.saved_calculations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'EMI calculation',
  calculation jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists public.payment_history (
  id uuid primary key default gen_random_uuid(),
  loan_id uuid not null references public.loans(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  payment_date date not null,
  amount numeric(14,2) not null check (amount >= 0),
  principal numeric(14,2) default 0,
  interest numeric(14,2) default 0,
  notes text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.loans enable row level security;
alter table public.saved_calculations enable row level security;
alter table public.payment_history enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles for select using (id = auth.uid());
drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles for insert with check (id = auth.uid());
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists loans_own on public.loans;
create policy loans_own on public.loans for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists saved_calculations_own on public.saved_calculations;
create policy saved_calculations_own on public.saved_calculations for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists payments_own on public.payment_history;
create policy payments_own on public.payment_history for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Private loan document bucket. Create the bucket in Storage as private,
-- then add equivalent owner-only policies in the Supabase dashboard.
