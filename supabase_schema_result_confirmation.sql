-- ═══════════════════════════════════════════════════════════════════
-- Result Confirmation Timeout — additive migration
-- Run in: Supabase Dashboard → SQL Editor → New Query → Run
-- Safe to re-run (idempotent guards throughout).
-- After running, also run: NOTIFY pgrst, 'reload schema';
-- ═══════════════════════════════════════════════════════════════════

-- 1. Ensure notifications table + notif_type enum exist (defensive —
--    supabase_schema.sql may or may not have been applied live).
do $$
begin
  if not exists (select 1 from pg_type where typname = 'notif_type') then
    create type public.notif_type as enum (
      'matchRequest','matchConfirmed','matchDeclined','resultConfirmed',
      'review','reminder','nearbyPlayer','cancellation'
    );
  end if;
end$$;

create table if not exists public.notifications (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references public.profiles(id) on delete cascade,
  type            notif_type not null,
  title           text not null,
  body            text not null,
  is_read         boolean not null default false,
  avatar_initials text,
  avatar_color    text,
  action_id       text,
  created_at      timestamptz not null default now()
);

alter table public.notifications enable row level security;

-- Read/mark-read your own only. No INSERT policy for regular users on
-- purpose: every notification in this feature is written by n8n via the
-- service_role key, which bypasses RLS entirely. A self-scoped insert
-- policy couldn't work anyway (player2 inserting a row targeted at
-- player1's user_id would fail `auth.uid() = user_id`).
drop policy if exists "Users can view own notifications" on public.notifications;
create policy "Users can view own notifications"
  on public.notifications for select using (auth.uid() = user_id);

drop policy if exists "Users can update own notifications" on public.notifications;
create policy "Users can update own notifications"
  on public.notifications for update using (auth.uid() = user_id);

create index if not exists idx_notifications_user on public.notifications(user_id);

-- 2. New notif_type values for the result-confirmation flow.
alter type public.notif_type add value if not exists 'resultPending';
alter type public.notif_type add value if not exists 'resultDisputed';

-- 3. Result-confirmation state on matches (additive, non-breaking).
alter table public.matches
  add column if not exists result_status       text not null default 'confirmed',
  add column if not exists result_logged_by    uuid references public.profiles(id),
  add column if not exists result_logged_at    timestamptz not null default now(),
  add column if not exists result_confirmed_at timestamptz,
  add column if not exists auto_confirmed      boolean not null default false;

alter table public.matches drop constraint if exists matches_result_status_check;
alter table public.matches add constraint matches_result_status_check
  check (result_status in ('pending_confirmation', 'confirmed', 'disputed'));

-- No RLS changes needed on matches: the existing policy
--   "Match participants can update" using (auth.uid() = player1_id or auth.uid() = player2_id)
-- already permits the opponent (player2) to flip result_status via
-- confirmResult/disputeResult, and n8n's service_role key bypasses
-- RLS entirely for the 48h auto-confirm UPDATE.

-- ═══════════════════════════════════════════════════════════════════
-- After running this script: Supabase Dashboard → SQL Editor → run:
--   NOTIFY pgrst, 'reload schema';
-- (per CLAUDE.md's Supabase Column Checklist)
-- ═══════════════════════════════════════════════════════════════════
