# RallyMatch — Full Test Pass & Store-Readiness Plan

Status snapshot that shaped this plan (2026-09-13):
- `DataService` already writes real Supabase data for: notifications, `markAllRead`, `confirmResult`/`disputeResult`, match requests insert (per bugs.md 2026-05-09), and match result logging (per bugs.md 2026-05-15).
- `DataService.getPlayers()`, `getConversations()`, `getUpcomingSessions()` still return static `MockData` — this is *why* a second real login sees the first user's identity/lists (per your n8n testing issue).
- Android release build still uses the **debug signing config** and the **template applicationId** (`io.supabase.rallly.rallly`) — not store-submittable as-is.
- n8n workflow `result-confirmation-workflow.json` depends on real `matches` rows with `result_status='pending_confirmation'`, which only exist once two real accounts play out a full request → log result → confirm flow.

---

## Phase 0 — Device & environment (done)
- [x] Finish adb pairing on S25 Ultra: accept the "Allow USB debugging" popup, confirm `adb devices` shows `device` (not `unauthorized`)
- [x] `flutter run` on the physical device once authorized; confirm app launches and hot reload works

## Phase 1 — Close the mock/real gap (blocks real multi-user testing)

Investigation findings (2026-09-13):
- Confirmed via `mcp__supabase__list_tables`: `profiles` has all `Player.fromJson` columns except `match_score` (no such column — it's a client-only compatibility %). RLS: `profiles` SELECT is `qual: true` (public), so reading other users' profiles works.
- `matches` RLS: "Match participants can view" (`player1_id OR player2_id`) already covers both sides; a narrower duplicate "view own matches" (`player1_id` only) is redundant but harmless (permissive OR). Not touching RLS in this phase — flagged for Phase 5.
- `messages` RLS: SELECT allowed for `sender_id OR receiver_id` match — fine once `receiver_id` is actually populated.
- `match_screen.dart`'s `_RequestSheetState._sendRequest()` only calls `dataService.sendMatchRequest(...)` — no separate direct insert exists. Just need to implement the stub for real; no duplicate-logic risk.
- `dataService.currentUserId` is hardcoded to return the `'me'` sentinel always — this is a real bug for the real-data path: `messages_screen.dart` uses it in `Conversation.unreadCount()` and message-authorship checks, which will misbehave once real UUIDs flow through. Fixing this is required infrastructure for this phase, not optional.
- `log_result_screen.dart` already defines `isUuid()` to distinguish real registered opponents (uuid) from mock/guest ones — reusing this (extracted to a shared util) rather than re-inventing it in `data_service.dart`.
- Decisions confirmed with user: (a) `matchScore` computed client-side from NTRP-rating closeness to current user (`100 - |diff|*40`, clamped 0–100), no schema change; (b) `messages_screen.dart`'s `_send()` will be fixed to set `receiver_id` on insert, since `getConversations()` can't reliably group the user's own outgoing messages without it.

Plan-reviewer agent caught 5 issues before implementation (all applied): re-export trick dropped in favor of a plain new import in the test file; `.or('a.eq.x,b.eq.x')` PostgREST syntax used instead of chained `.eq()` (which is AND, not OR — would've silently returned empty results); `warmCache()` wrapped in try/catch so the MainShell loading gate can never hang; `IndexedStack` gate combines `_prefsLoaded && _cacheLoaded`; added `ValueNotifier<int> cacheVersion` (ADR-008) since `IndexedStack` keeps tabs mounted and a bare cache refresh doesn't trigger their rebuild otherwise.

Implemented:
- [x] New `lib/utils/uuid.dart` — extracted `isUuid()`/`_uuidRe` out of `log_result_screen.dart`; `data_service.dart` and `messages_screen.dart` both import it directly; `test/widget_test.dart` import updated to `package:rallly/utils/uuid.dart`
- [x] `data_service.dart`: fixed `currentUserId` → `supabase.auth.currentUser?.id ?? 'me'`
- [x] `data_service.dart`: added `warmCache()` + `cacheVersion` (`ValueNotifier<int>`) to `DataService`; `_refreshPlayers()` / `_refreshConversations()` / `_refreshUpcomingSessions()` implemented in `MockDataService`, run via `Future.wait` from `warmCache()`
- [x] `getPlayers()`: queries `profiles` excluding self; `match_score` computed via NTRP-closeness formula (ADR-009) and injected into each row before `Player.fromJson`
- [x] `getConversations()`: queries `messages` via `.or('sender_id.eq.$uid,receiver_id.eq.$uid')`, groups by counterpart id, batch-fetches counterpart profiles, builds `Conversation` list
- [x] `getUpcomingSessions()`: queries `matches` via `.or('player1_id.eq.$uid,player2_id.eq.$uid')`, no server-side status filter, batch-fetches opponent profiles, falls back to a guest placeholder `Player` when `player2_id` is null
- [x] `sendMatchRequest()`: real insert into `matches` (`status: 'pending'`), then refreshes the upcoming-sessions cache
- [x] `main_shell.dart`: `IndexedStack` gated behind `dataService.warmCache()` in `initState`, combined with the existing `_prefsLoaded` check
- [x] `messages_screen.dart`: `_send()` now sets `receiver_id: widget.conversation.other.id` (guarded by `isUuid`); stale "Mock mode" comment replaced
- [x] `match_screen.dart`, `messages_screen.dart`, `games_screen.dart`, `profile_screen.dart`, `schedule_screen.dart`: wrapped in `ValueListenableBuilder<int>` on `dataService.cacheVersion` so live cache refreshes actually rebuild these `IndexedStack`-resident screens
- [x] Deleted now-fully-unused `lib/services/mock_data.dart` (its only remaining consumer was `data_service.dart`, just removed); updated `README.md`'s stale "Replacing mock data" section accordingly
- [x] Added ADR-008 (cache-warm-once pattern) and ADR-009 (match-score formula) to `docs/project_notes/decisions.md`
- [x] `flutter analyze` clean (20 pre-existing info/warning-level lints unrelated to this change; zero errors)
- [x] `flutter test`: 9 passed / 5 failed — all 5 failures are the pre-existing English-string-vs-Turkish-UI mismatch (`skillLabel` x3, "You won this match!", "Submit Result"), confirmed unrelated to Phase 1
- [x] Code review pass (code-reviewer agent) — found 1 real bug (fixed: `_playerFromRow` fed a possibly-null `ntrp_rating` straight into `Player.fromJson`'s non-nullable cast — now injects the null-safe value back into the row) and 1 cleanup (fixed: `cacheVersion` was bumped up to 3x per `warmCache()` call — now bumped once, in a `finally`, plus once explicitly in `sendMatchRequest()`)
- [x] Fixed 2 real regressions surfaced by the first test run (not caught by review, caught by actually running tests): `log_result_screen.dart`'s `initState` crashed on `dataService.getPlayers().first` when the cache is legitimately empty (pre-`warmCache()`, or zero registered players) — now null-safe; updated one widget test whose premise (a permanent non-empty mock player list) no longer holds now that there's no static fallback
- [ ] Manual smoke test on the S25 Ultra — **BLOCKED**: login/signup fails for every email except `leyla.garayli@gmail.com`. Root cause (found via `mcp__supabase__query_logs`, not visible in the Flutter app itself): Resend email provider is on the free/testing tier and rejects sending to any other recipient (550 error) until a domain is verified at resend.com/domains. This blocks Phase 2 entirely (needs two distinct real accounts). See `docs/project_notes/bugs.md` "OTP emails only deliver to the project owner's own address". Added a `debugPrint('OTP SEND AUTH ERROR: ...')` in `auth_screen.dart`'s `AuthException` catch branch so this class of failure surfaces in Flutter logs directly next time, instead of requiring a trip to Supabase's server-side auth logs.
- [ ] Once a domain is verified on Resend and Supabase's SMTP "from" address is updated to use it: retry the smoke test (login as `leyla.garayli@gmail.com`, confirm Match tab shows the other real profile with a live compatibility %, send a request, confirm it appears in Schedule/Profile without an app restart)

## Phase 2 — Two-real-account n8n test (the thing that failed last time)
- [x] Create two real Supabase auth accounts (distinct emails) with `profiles` rows — 3 exist: Leyla G. (leyla.garayli@gmail.com), Test User Uma (uma.matsui@gmail.com), Test User Leila (leila.rhcp21@gmail.com)
- [x] Log in as User A on one device/session, User B on another — phone (S25 Ultra) as Leyla G., Chrome web session as Test User Uma. Blocked for a while on Resend's free-tier restriction (only sends to the account owner's own address) — unblocked by disabling Custom SMTP to fall back to Supabase's built-in mailer, which has a strict rate limit but isn't restricted by recipient. Also found the default "Magic Link"/"Confirm signup" email templates only show a clickable link, not the {{ .Token }} code the app's OTP-entry screen expects — added {{ .Token }} to both templates in the dashboard.
- [ ] Confirm Match screen now shows *different* discovery lists per account (validates Phase 1 fix)
- [ ] A sends match request → B receives it as a request, not as their own profile
- [ ] Log a match result → `matches.result_status = 'pending_confirmation'`
- [ ] Confirm n8n webhook fires (check n8n execution log) and honors `RESULT_CONFIRM_WAIT_HOURS`
- [ ] B confirms result via in-app notification action → verify `confirmResult()` updates `result_status='confirmed'` and notification `is_read=true`
- [ ] Repeat with a dispute path (`disputeResult()`)
- [ ] Confirm `RESULT_WEBHOOK_SECRET` mismatch is actually rejected (negative test)

## Phase 3 — Full manual QA pass (all 21 screens)
Use two real accounts from Phase 2 throughout, not mock/'me'.
- [ ] Landing → Auth (email OTP) → OTP entry → Signup (4-step, new user only) → Home
- [ ] MainShell tab persistence: switch tabs, confirm scroll/filter state survives (IndexedStack)
- [ ] Onboarding overlay: fresh install shows it once per tab, `onboarding_seen` persists across restart
- [ ] Match tab: filters, player cards, "İste" request flow, open lobby cards, compatibility %
- [ ] PlayerProfile: viewing another real user's profile (not self)
- [ ] Schedule: upcoming sessions reflect real confirmed/pending matches
- [ ] Messages: inbox + conversation screen with a real second account, unread counts, mark-read
- [ ] Notifications: badge count (`unreadNotifier`) updates live across tabs, mark all read, action buttons (matchRequest/resultConfirmed)
- [ ] Games / CreateGame / DoublesOrganise / OpenLobby: creation + join flow with two accounts
- [ ] Map: OpenStreetMap tiles load, location permission prompt behaves correctly
- [ ] LogResult / ResultCard: registered opponent path AND guest/unregistered opponent path (phone-based, ADR-006)
- [ ] Reputation / Achievements: values reflect real match history, not hardcoded mock numbers
- [ ] NotificationPreferences: toggle persists across navigation and app restart (regression check per bugs.md)
- [ ] Dark mode: spot-check every screen above in both `RallyTheme.light` and `.dark`
- [ ] Rotate/resize: at least one tablet or split-screen check if Play Store listing will claim tablet support

## Phase 4 — Regression sweep against known bug log entries
Re-verify these don't regress (see `docs/project_notes/bugs.md`):
- [ ] Player name/avatar tap → profile, everywhere
- [ ] Bottom sheet buttons not hidden by system nav bar (test specifically on a Samsung device — matches the original A56 bug)
- [ ] No duplicate "Send Request" allowed per player
- [ ] Achievements grid — no text overflow
- [ ] "Mark all read" updates every badge instance app-wide

## Phase 5 — Store readiness (Android first)
- [x] Replaced `applicationId` in `android/app/build.gradle.kts`: `io.supabase.rallly.rallly` → `com.rallymatch.app` (chosen 2026-09-13; permanent once uploaded to Play Store). Left `namespace` unchanged (still `io.supabase.rallly.rallly`) — it only affects internal R-class generation, not the Play Store identity, and changing it would require moving `MainActivity.kt`'s package/directory for zero user-facing benefit.
- [x] Generated a real upload keystore (`android/app/upload-keystore.jks`, RSA 2048, 10000-day validity) and wired `signingConfigs.release` in `build.gradle.kts` to load credentials from `android/key.properties` (both already covered by `.gitignore` — confirmed via `git status`, neither is tracked). Falls back to the debug key only when `key.properties` is absent, so a fresh checkout without it still builds. Verified with `apksigner verify --print-certs`: the built release APK's signer DN matches the new keystore, not the debug cert.
  - **CRITICAL — user must back up `android/app/upload-keystore.jks` and its password (in `android/key.properties`) somewhere outside this machine/repo** (password manager, encrypted cloud storage). If lost, the app can never be updated on the Play Store under this listing again — Google cannot recover or reset it.
- [x] `flutter build apk --release` succeeds end-to-end (53.2MB, cold build after `flutter clean` ~1015s) — first attempt hit a corrupted/stale build cache (`shared_preferences_android` resource merge failure, `XMLStreamException`/`AAPT: failed to read PNG signature`) likely from earlier abrupt `pkill -9`-killed `flutter run` sessions during device troubleshooting; `flutter clean` resolved it, unrelated to the signing/applicationId change itself
- [ ] Bump `pubspec.yaml` version from `1.0.0+1` as needed for your release strategy
- [ ] App icons: confirm `flutter_launcher_icons` or manual `mipmap` assets are the real RallyMatch icon, not the Flutter default
- [ ] Verify permissions declared in `AndroidManifest.xml` match actual usage (location for Map, camera/gallery for `image_picker`) — remove anything unused, add rationale strings where Android requires them
- [ ] Privacy policy URL (required by Play Console) — needed since app handles user profiles, location, messaging
- [ ] Data safety form in Play Console — must accurately reflect: profiles, messages, location, match history collected
- [ ] `flutter build apk --release` and `flutter build appbundle --release` — install the real release build (not debug) on the S25 Ultra and re-smoke-test Phase 3's golden paths
- [ ] Confirm Supabase RLS policies are production-safe (no overly permissive `true` policies left over from dev) — cross-check against `mcp__supabase__get_advisors`
- [ ] Remove/guard any dev-only affordances (e.g. debug prints, test accounts, seeded mock fallbacks) from the release build

## Phase 6 — Final sign-off
- [ ] `flutter analyze` clean
- [ ] `flutter test` clean
- [ ] Full Phase 3 QA pass repeated once more on the actual release build artifact
- [ ] Update `docs/project_notes/bugs.md` / `decisions.md` with anything new discovered during this pass

---

## Review (fill in after execution)
_To be completed once phases are executed — summary of what passed, what broke, and what's still open before store submission._
