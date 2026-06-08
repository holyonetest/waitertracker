-- ============================================================
--  Трекер официанта — настройка базы Supabase
--  Запустите весь этот файл в Supabase → SQL Editor → New query → Run
-- ============================================================

-- Одна строка на пользователя: ник + весь блоб трекера (jsonb)
create table if not exists public.profiles (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  nickname   text not null default '',
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Включаем Row Level Security: без неё анон-ключ открыл бы все строки.
alter table public.profiles enable row level security;

-- Каждый видит только свою строку
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = user_id);

-- Каждый создаёт строку только для себя
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = user_id);

-- Каждый меняет только свою строку
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- DELETE-политики нет: приложение не удаляет профили.
-- При удалении аккаунта строка уходит каскадом (on delete cascade).
