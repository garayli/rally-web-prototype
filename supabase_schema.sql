-- ═══════════════════════════════════════════════════════════════════
-- Rallly — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Run
-- ═══════════════════════════════════════════════════════════════════

-- 1. PROFILES (extends Supabase auth.users)
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  name          text not null,
  initials      text not null,
  avatar_url    text,
  ntrp_rating   real not null default 3.0,
  location      text not null default '',
  about         text not null default '',
  wins          int not null default 0,
  losses        int not null default 0,
  matches_played int not null default 0,
  win_rate      real not null default 0,
  availability  text[] not null default '{}',       -- e.g. {'Mon AM','Wed PM','Sat Full'}
  preferred_courts text[] not null default '{}',
  avatar_gradient_start text not null default '#5a8a00',
  avatar_gradient_end   text not null default '#8db600',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- 2. MATCHES
create type match_status as enum ('confirmed', 'pending', 'completed', 'cancelled');
create type match_format as enum ('singles', 'doubles');

create table if not exists public.matches (
  id            uuid primary key default gen_random_uuid(),
  player1_id    uuid not null references public.profiles(id) on delete cascade,
  player2_id    uuid not null references public.profiles(id) on delete cascade,
  date_time     timestamptz not null,
  court         text not null,
  status        match_status not null default 'pending',
  format        match_format not null default 'singles',
  -- result fields (null until match completed)
  winner_id     uuid references public.profiles(id),
  sets          jsonb,           -- e.g. [{"player1":6,"player2":4},{"player1":7,"player2":5}]
  rating_delta  real,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- 3. MESSAGES
create table if not exists public.messages (
  id            uuid primary key default gen_random_uuid(),
  sender_id     uuid not null references public.profiles(id) on delete cascade,
  receiver_id   uuid not null references public.profiles(id) on delete cascade,
  text          text not null,
  is_read       boolean not null default false,
  created_at    timestamptz not null default now()
);

-- 4. REVIEWS
create table if not exists public.reviews (
  id            uuid primary key default gen_random_uuid(),
  reviewer_id   uuid not null references public.profiles(id) on delete cascade,
  reviewed_id   uuid not null references public.profiles(id) on delete cascade,
  match_id      uuid references public.matches(id) on delete set null,
  rating        int not null check (rating between 1 and 5),
  comment       text not null default '',
  created_at    timestamptz not null default now()
);

-- 5. NOTIFICATIONS
create type notif_type as enum (
  'matchRequest', 'matchConfirmed', 'matchDeclined',
  'resultConfirmed', 'review', 'reminder',
  'nearbyPlayer', 'cancellation'
);

create table if not exists public.notifications (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references public.profiles(id) on delete cascade,
  type            notif_type not null,
  title           text not null,
  body            text not null,
  is_read         boolean not null default false,
  avatar_initials text,
  avatar_color    text,
  action_id       text,           -- match id, player id, etc.
  created_at      timestamptz not null default now()
);

-- ═══════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS) — users can only access their own data
-- ═══════════════════════════════════════════════════════════════════

-- Profiles: anyone can read, only owner can update
alter table public.profiles enable row level security;
create policy "Public profiles are viewable by everyone"
  on public.profiles for select using (true);
create policy "Users can update own profile"
  on public.profiles for update using (auth.uid() = id);
create policy "Users can insert own profile"
  on public.profiles for insert with check (auth.uid() = id);

-- Matches: participants can read/create, only participants can update
alter table public.matches enable row level security;
create policy "Match participants can view"
  on public.matches for select using (
    auth.uid() = player1_id or auth.uid() = player2_id
  );
create policy "Authenticated users can create matches"
  on public.matches for insert with check (auth.uid() = player1_id);
create policy "Match participants can update"
  on public.matches for update using (
    auth.uid() = player1_id or auth.uid() = player2_id
  );

-- Messages: sender and receiver can read, sender can create
alter table public.messages enable row level security;
create policy "Users can view their messages"
  on public.messages for select using (
    auth.uid() = sender_id or auth.uid() = receiver_id
  );
create policy "Users can send messages"
  on public.messages for insert with check (auth.uid() = sender_id);
create policy "Receiver can mark as read"
  on public.messages for update using (auth.uid() = receiver_id);

-- Reviews: public read, only reviewer can create
alter table public.reviews enable row level security;
create policy "Reviews are viewable by everyone"
  on public.reviews for select using (true);
create policy "Users can create reviews"
  on public.reviews for insert with check (auth.uid() = reviewer_id);

-- Notifications: only the owner
alter table public.notifications enable row level security;
create policy "Users can view own notifications"
  on public.notifications for select using (auth.uid() = user_id);
create policy "Users can update own notifications"
  on public.notifications for update using (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════════════════
-- AUTO-CREATE PROFILE on signup (trigger)
-- ═══════════════════════════════════════════════════════════════════
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, initials)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', 'New Player'),
    coalesce(
      upper(left(new.raw_user_meta_data->>'name', 1)) ||
      upper(left(split_part(new.raw_user_meta_data->>'name', ' ', 2), 1)),
      'NP'
    )
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger: run after each new auth signup
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ═══════════════════════════════════════════════════════════════════
-- INDEXES for performance
-- ═══════════════════════════════════════════════════════════════════
create index if not exists idx_matches_player1 on public.matches(player1_id);
create index if not exists idx_matches_player2 on public.matches(player2_id);
create index if not exists idx_messages_sender on public.messages(sender_id);
create index if not exists idx_messages_receiver on public.messages(receiver_id);
create index if not exists idx_notifications_user on public.notifications(user_id);
create index if not exists idx_reviews_reviewed on public.reviews(reviewed_id);
