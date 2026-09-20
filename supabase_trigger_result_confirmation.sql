-- ═══════════════════════════════════════════════════════════════════
-- Result Confirmation Timeout — manual pg_net trigger
-- Use this INSTEAD of Database → Webhooks if the Dashboard UI errors
-- with "schema supabase_functions does not exist". This does the exact
-- same job (POST matches INSERT/UPDATE to n8n) without depending on
-- Supabase's Webhooks feature — only on the pg_net extension.
--
-- Run in: Supabase Dashboard → SQL Editor → New Query → Run
-- Safe to re-run (idempotent guards throughout).
--
-- BEFORE RUNNING: replace the two placeholders below with your real
-- values (same n8n webhook URL / same secret as RESULT_WEBHOOK_SECRET
-- in n8n's Variables UI).
-- ═══════════════════════════════════════════════════════════════════

-- 1. pg_net must be enabled (same extension the Dashboard Webhooks
--    feature itself relies on internally — its functions live in a
--    schema literally named `net`, separate from the `supabase_functions`
--    schema that's missing for you).
create schema if not exists net;
create extension if not exists pg_net with schema net;

-- 1b. VERIFY before continuing: pg_net may already have been installed
--     by Supabase under a different schema (commonly `extensions`), in
--     which case the line above just no-ops and stays wherever it was.
--     Run this and check the result:
--       select extnamespace::regnamespace from pg_extension where extname = 'pg_net';
--     If it prints anything other than `net`, replace every `net.http_post`
--     below with `<that_schema>.http_post` before running the rest.

-- 2. Trigger function — builds the same {type, table, schema, record,
--    old_record} payload shape Supabase Database Webhooks send, so the
--    n8n workflow's existing expressions ($json.body.type,
--    $json.body.record, $json.body.old_record) work unmodified.
create or replace function public.notify_n8n_result_confirmation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_webhook_url    text := 'REPLACE_WITH_N8N_WEBHOOK_URL';   -- e.g. https://<your-instance>.app.n8n.cloud/webhook/result-confirmation
  v_webhook_secret text := 'REPLACE_WITH_WEBHOOK_SECRET';    -- must match RESULT_WEBHOOK_SECRET in n8n Variables — paste the real value only in the Supabase SQL editor, never here
begin
  perform net.http_post(
    url     := v_webhook_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', v_webhook_secret
    ),
    body := jsonb_build_object(
      'type', TG_OP,
      'table', 'matches',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', case when TG_OP = 'UPDATE' then to_jsonb(OLD) else null end
    )
  );
  return NEW;
end;
$$;

-- 3. Attach to matches — fires on every INSERT/UPDATE; the n8n
--    workflow's own "Route Event" switch already filters down to the
--    relevant result_status transitions, exactly as it would with a
--    real Database Webhook.
drop trigger if exists trg_notify_n8n_result_confirmation on public.matches;
create trigger trg_notify_n8n_result_confirmation
  after insert or update on public.matches
  for each row
  execute function public.notify_n8n_result_confirmation();

-- ═══════════════════════════════════════════════════════════════════
-- Note: net.http_post is async — it queues the request and returns
-- immediately; Supabase runs the pg_net worker that drains the queue
-- for you, so no extra setup is needed on hosted projects.
--
-- To verify it's firing: log a result in the app, then check
--   select * from net._http_response order by created desc limit 5;
-- (also check n8n's Executions tab for the corresponding run)
-- ═══════════════════════════════════════════════════════════════════
