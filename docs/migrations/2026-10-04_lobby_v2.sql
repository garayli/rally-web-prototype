-- Lobby v2: format (singles/doubles), request cap, roster capacity, close.
-- Run once in the Supabase SQL editor. Idempotent: safe to re-run.
-- Rules: 10 *pending* requests max; roster = 1 (singles) / 3 (doubles) accepted.

-- ── 1. Columns ───────────────────────────────────────────────────────────────
ALTER TABLE public.lobbies
  ADD COLUMN IF NOT EXISTS format text NOT NULL DEFAULT 'singles',
  ADD COLUMN IF NOT EXISTS pending_count integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS accepted_count integer NOT NULL DEFAULT 0;

ALTER TABLE public.matches
  ADD COLUMN IF NOT EXISTS lobby_id uuid REFERENCES public.lobbies(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS matches_lobby_id_idx ON public.matches (lobby_id);

-- format check
ALTER TABLE public.lobbies DROP CONSTRAINT IF EXISTS lobbies_format_check;
ALTER TABLE public.lobbies
  ADD CONSTRAINT lobbies_format_check CHECK (format IN ('singles', 'doubles'));

-- status check: replace whatever check exists on status with one that has 'closed'
DO $$
DECLARE c text;
BEGIN
  FOR c IN
    SELECT conname FROM pg_constraint
    WHERE conrelid = 'public.lobbies'::regclass AND contype = 'c'
      AND pg_get_constraintdef(oid) ILIKE '%status%'
  LOOP
    EXECUTE format('ALTER TABLE public.lobbies DROP CONSTRAINT %I', c);
  END LOOP;
END $$;
ALTER TABLE public.lobbies
  ADD CONSTRAINT lobbies_status_check
  CHECK (status IN ('open', 'full', 'closed', 'cancelled'));

-- ── 2. RLS: everyone sees public open/full lobbies; creator sees all of theirs ─
DO $$
DECLARE p text;
BEGIN
  FOR p IN
    SELECT policyname FROM pg_policies
    WHERE schemaname = 'public' AND tablename = 'lobbies' AND cmd = 'SELECT'
  LOOP
    EXECUTE format('DROP POLICY %I ON public.lobbies', p);
  END LOOP;
END $$;
CREATE POLICY "Lobbies visible: public open/full or own" ON public.lobbies
  FOR SELECT USING (
    creator_id = auth.uid()
    OR (is_public = true AND status IN ('open', 'full'))
  );

-- ── 3. Guard new / accepted requests (race-free: locks the lobby row) ─────────
CREATE OR REPLACE FUNCTION public.lobby_guard_match() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  l public.lobbies%ROWTYPE;
  cap integer;
BEGIN
  IF NEW.lobby_id IS NULL THEN RETURN NEW; END IF;

  SELECT * INTO l FROM public.lobbies WHERE id = NEW.lobby_id FOR UPDATE;
  IF NOT FOUND THEN RETURN NEW; END IF;
  cap := CASE WHEN l.format = 'doubles' THEN 3 ELSE 1 END;

  IF TG_OP = 'INSERT' THEN
    IF NEW.player2_id IS DISTINCT FROM l.creator_id THEN
      RAISE EXCEPTION 'lobby_mismatch';
    END IF;
    IF NEW.player1_id = l.creator_id THEN RAISE EXCEPTION 'lobby_own'; END IF;
    IF l.status NOT IN ('open', 'full') THEN RAISE EXCEPTION 'lobby_closed'; END IF;
    IF EXISTS (SELECT 1 FROM public.matches m
               WHERE m.lobby_id = l.id AND m.player1_id = NEW.player1_id
                 AND m.status <> 'cancelled') THEN
      RAISE EXCEPTION 'lobby_already_requested';
    END IF;
    IF l.accepted_count >= cap THEN RAISE EXCEPTION 'lobby_full'; END IF;
    IF l.pending_count >= 10 THEN RAISE EXCEPTION 'lobby_queue_full'; END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    -- accepting: only while there is room (a cancelled request can't be revived)
    IF NEW.status = 'confirmed' AND OLD.status IS DISTINCT FROM 'confirmed' THEN
      IF OLD.status = 'cancelled' THEN RAISE EXCEPTION 'lobby_request_ended'; END IF;
      IF l.accepted_count >= cap THEN RAISE EXCEPTION 'lobby_full'; END IF;
    END IF;
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS lobby_guard_match_trg ON public.matches;
CREATE TRIGGER lobby_guard_match_trg
  BEFORE INSERT OR UPDATE OF status ON public.matches
  FOR EACH ROW EXECUTE FUNCTION public.lobby_guard_match();

-- ── 4. Keep the counters + open/full status in sync ───────────────────────────
CREATE OR REPLACE FUNCTION public.lobby_recount(lid uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  p integer; a integer; cap integer; f text;
BEGIN
  IF lid IS NULL THEN RETURN; END IF;
  SELECT count(*) FILTER (WHERE status = 'pending'),
         count(*) FILTER (WHERE status IN ('confirmed', 'completed'))
    INTO p, a FROM public.matches WHERE lobby_id = lid;
  SELECT format INTO f FROM public.lobbies WHERE id = lid;
  IF NOT FOUND THEN RETURN; END IF;
  cap := CASE WHEN f = 'doubles' THEN 3 ELSE 1 END;
  UPDATE public.lobbies
     SET pending_count = p,
         accepted_count = a,
         status = CASE
           WHEN status IN ('open', 'full') THEN (CASE WHEN a >= cap THEN 'full' ELSE 'open' END)
           ELSE status END
   WHERE id = lid;
END $$;

CREATE OR REPLACE FUNCTION public.lobby_recount_trg() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF TG_OP IN ('UPDATE', 'DELETE') THEN PERFORM public.lobby_recount(OLD.lobby_id); END IF;
  IF TG_OP IN ('INSERT', 'UPDATE') THEN PERFORM public.lobby_recount(NEW.lobby_id); END IF;
  RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS lobby_recount_match_trg ON public.matches;
CREATE TRIGGER lobby_recount_match_trg
  AFTER INSERT OR UPDATE OF status, lobby_id OR DELETE ON public.matches
  FOR EACH ROW EXECUTE FUNCTION public.lobby_recount_trg();

-- ── 5. Closing a lobby: decline what is still pending, notify, retire buttons ─
CREATE OR REPLACE FUNCTION public.lobby_on_close() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE m record;
BEGIN
  IF NEW.status = 'closed' AND OLD.status IS DISTINCT FROM 'closed' THEN
    FOR m IN SELECT id, player1_id FROM public.matches
             WHERE lobby_id = NEW.id AND status = 'pending' LOOP
      UPDATE public.matches SET status = 'cancelled' WHERE id = m.id;
      INSERT INTO public.notifications (user_id, type, title, body, action_id)
        VALUES (m.player1_id, 'matchDeclined', 'Lobi Kapandı',
                'Organizatör lobiyi kapattı, katılma isteğin sona erdi.', m.id);
      -- the organiser's Kabul/Reddet card for this request must not stay live
      UPDATE public.notifications
         SET type = 'matchDeclined', title = 'İstek Sona Erdi', is_read = true
       WHERE user_id = NEW.creator_id AND type = 'matchRequest'
         AND action_id::text = m.id::text;
    END LOOP;
  END IF;
  RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS lobby_on_close_trg ON public.lobbies;
CREATE TRIGGER lobby_on_close_trg
  AFTER UPDATE OF status ON public.lobbies
  FOR EACH ROW EXECUTE FUNCTION public.lobby_on_close();

NOTIFY pgrst, 'reload schema';
