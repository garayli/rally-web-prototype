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

### 2026-09-27 — Two-account test found critical bugs (see `bugs.md`)
Setup: phone = leyla.garayli@gmail.com, Chrome = leila.rhcp@gmail.com.
- Match requests reached neither side (no notification).
- Messages "disappeared" for the sender and never arrived live on the other side.

Fixed:
- [x] The "Maç İste" buttons in PlayerProfile, Conversation and Map were fake (snackbar only). All four entry points now use the real sheet: `lib/widgets/match_request_sheet.dart` → `showMatchRequestSheet()`.
- [x] Notifications were never loaded after login. `warmCache()` now loads them too.
- [x] No live refresh anywhere. Added `DataService.refreshLive()`: MainShell polls it every 10s in the foreground and an open chat every 4s. `cacheVersion` is bumped only when the data actually changed.
- [x] `NotificationsScreen` reloads silently on every `cacheVersion` change.
- [x] Kabul/Reddet was local-only. It now goes through `respondToMatchRequest()`, which updates `matches.status` and rewrites the notification.
- [x] Added `DataService.sendMessage()`. Insert errors are no longer swallowed: the bubble shows `error_outline`, and tapping it retries.
- [x] `ConversationScreen` reads its thread from the cache, so a sent message no longer "disappears" on leave/reopen.
- [x] Conversation fetches carry a sequence number, so an old poll can't overwrite newer data. The inbox is sorted by latest message.
- [x] `flutter analyze` on the changed files: 0 issues. `flutter test`: 12 pass / 5 fail. The 5 failures are the known English-string tests, unrelated to this change.

Verified in the Supabase Dashboard SQL Editor on 2026-09-27 (no migration needed):
- [x] The notifications INSERT policy is live: "Requester can notify opponent of match request", `with_check` `type = 'matchRequest'::notif_type AND action_id …`.
- [x] `matches` UPDATE policy "Match participants can update": `auth.uid() = player1_id OR auth.uid() = player2_id`. Kabul/Reddet can update the match.
- [x] `notifications.type` is the `notif_type` enum. It includes `matchConfirmed` and `matchDeclined`, and "Users can update own notifications" (`auth.uid() = user_id`) exists, so the notification rewrite after Kabul/Reddet works.
- [ ] Two-device retest: A sends from the Match tab, profile and chat → a notification reaches B within ≤10s. Messages flow both ways within ~4s while the chat is open, and each side's inbox shows the thread.

Known follow-ups (not fixed in this pass):
- [ ] The requester isn't notified when a request is accepted or declined; they only see the status change in Schedule. The notifications insert policy only allows `matchRequest`.
- [ ] `resultPending` notifications come back with their buttons after confirm/dispute. Only `is_read` is set; the type isn't changed because n8n owns the result-notification types. Now more visible because of live reload.
- [ ] `markConversationRead` only tracks read state locally, in memory. New messages in a thread that was already opened don't show as unread, and `messages.is_read` is never written.
- [ ] Replace polling with Supabase Realtime. Checked 2026-09-27: `profiles`, `matches`, `messages` and `reviews` are already in the `supabase_realtime` publication; `notifications` is **not**. Adding it: `alter publication supabase_realtime add table notifications;`. Don't run it before the decision to switch to Realtime.
- [ ] `messages` already has a "Receiver can mark as read" UPDATE policy (`auth.uid() = receiver_id`), so writing `is_read` needs no migration, only app code.

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
- [ ] **FIRST PLAY UPLOAD — add Google's app-signing SHA-1 to the Android API key.** Play re-signs every build it distributes (internal testing included) with its own certificate, and the Android key (restricted 2026-09-21) only allows the debug + upload SHA-1s. Until Play's SHA-1 is added, Firebase calls from Play-installed builds are rejected with 403. Steps + exact `gcloud` command: `docs/project_notes/key_facts.md` → "Firebase / Google Cloud".
- [x] iOS and browser API keys deleted 2026-09-21 (unrestricted, exposed in git history). When iOS or web is set up later, create new keys restricted from day one — see `key_facts.md` → "Firebase / Google Cloud"

## Phase 5b — Internationalization (i18n) before store upload

Investigation findings (2026-10-03):
- No localization infrastructure exists: no `l10n.yaml`, no `flutter_localizations`, no `supportedLocales` / `localizationsDelegates`, no `lib/l10n/`. Only `intl: ^0.19.0` is declared.
- ~75 literal `Text('...')` call sites in `lib/`, plus more strings in `label:` / `hintText:` / `SnackBar` / data layer (not yet counted).
- `DateFormat(...)` is used in ~15 places (schedule, match, profile, messages, notifications, my_results, reputation screens) without an explicit locale; several chain `.toUpperCase()` (Turkish `i/İ` risk).
- Skill labels (`Başlangıç` / `Orta` / `İleri`) appear as raw strings in 8 places — should become an enum-to-label mapping in the UI layer.
- iOS `Info.plist` has `CFBundleDevelopmentRegion` but no `CFBundleLocalizations`.

Decisions / approach:
- Use Flutter's official `gen-l10n` + ARB (no new packages, no Riverpod; consistent with ADR-003).
- Template language = Turkish (`app_tr.arb`, current UI language); second language = English (`app_en.arb`) — **confirm target languages with user**.
- Follow device locale first; in-app language picker (`ValueNotifier<Locale>` + `SharedPreferences`) deferred to a later iteration.
- Never put translated strings in `DataService` / models — return enums/codes, translate in the UI layer. Presentation-only change; no backend/API logic touched (Version 2 constraint).

Implemented (2026-10-03):
- [x] `flutter_localizations` + `generate: true` in `pubspec.yaml`; `intl` bumped `^0.19.0` → `^0.20.2` (required by `flutter_localizations`); `l10n.yaml` (`arb-dir: lib/l10n`, template `app_tr.arb`, `untranslated-messages-file: build/l10n_untranslated.json`)
- [x] `lib/l10n/app_tr.arb` + `app_en.arb` (403 keys each, ICU plurals/placeholders), `lib/l10n/l10n.dart` (`context.l10n`, `context.localeName`), generated code committed
- [x] `main.dart`: delegates, `supportedLocales`, `onGenerateTitle`, `initializeDateFormatting()`, locale resolution (device language → fallback `tr`)
- [x] Skill/sport/day/time/court-theme labels → `lib/l10n/option_labels.dart`. **Stored values stay Turkish** (`'Başlangıç'`, `'Pzt'`, `'Sabah'`, `'Her seviye'`, `'Belirtilmedi'`); only labels are localized. `SkillBadge` localizes its own label.
- [x] Data layer: `StateError('<Turkish>')` → `DataException(DataError.x)`; UI maps via `lib/l10n/data_error_message.dart`
- [x] All screens/widgets migrated (main_shell, landing, auth, signup, match, messages, notifications, notification prefs, profile, edit profile, player profile, map, games, schedule, create game, doubles organise, open lobby, log result, result card, reputation, achievements, my results, match request sheet, onboarding overlay, shared widgets, profile completeness)
- [x] Every `DateFormat` now takes `context.localeName`; hand-built date label in `match_request_sheet.dart` replaced; 12/24h handled per locale in `schedule_screen.dart`
- [x] Android: `androidResources.localeFilters` (tr, en), `res/xml/locales_config.xml`, `android:localeConfig` in the manifest. iOS: `CFBundleLocalizations` + `tr.lproj`/`en.lproj` `InfoPlist.strings` (permission texts)
- [x] Tests: `flutter test` → 32 passed, 0 failed. Fixed the 5 pre-existing English-vs-Turkish failures; added ARB key-parity test, option-label test, and a 360x740 layout test per supported locale (also caught a real overflow in `_CourtHero`, fixed with `maxLines`/ellipsis)
- [x] `flutter analyze`: 0 errors; 13 issues (was 19 before this work — all pre-existing lints)
- [x] ADR-011 in `docs/project_notes/decisions.md`; Localization section in `CLAUDE.md`

Copy fixes made while migrating (the old Turkish copy was wrong/English): notifications filter chips `Sıralama`/`Mesaj` → `Maçlar`/`Diğer` (they filter match vs. other notifications); `MATCH` badge → `EŞLEŞME`; `🎾 N% match` tag → `🎾 %N eşleşme`; `'$n of $m'` in Achievements → `{n} / {m}`; share text was English-only.

Still open:
- [ ] **Notification text is Turkish-only for English users**: title/body are written to the DB by the app (`data_service.dart`) and by n8n, then shown verbatim. Proper fix = store `type` + params and render in the client (needs a `notifications` schema change + n8n update). Also the guest placeholder name `'Misafir Oyuncu'`.
- [ ] **Android build not verified here** (no Android SDK in this environment) — run `flutter build apk --release` on the dev machine to confirm the `localeFilters` / `localeConfig` changes
- [ ] iOS: when the Xcode project is created, add `tr.lproj/en.lproj/InfoPlist.strings` to the Runner target and set Localizations (Turkish, English) in project info
- [ ] Manual pass on a device with the language set to English and to Turkish (real fonts — the layout test uses fallback glyph widths); also check Android 13+ per-app language
- [ ] Store listings per language (title, description, screenshots, release notes) + privacy policy/terms in both languages
- [ ] Optional later: in-app language picker (`ValueNotifier<Locale>` + `SharedPreferences`)

Found while migrating (not i18n, not fixed):
- `MyResultsScreen` crashes with `RangeError` when fewer than 5 players are cached (`my_results_screen.dart:18`, hardcoded mock results index `players[...]`); it is reachable from Profile → Sonuçlarım / Skor Talepleri
- `DoublesOrganiseScreen._submit` only shows a "request sent" SnackBar after a fake delay — nothing is written (reachable via Maç Oluştur → Maç Başlat)
- `ResultCardScreen` always shows the initials/colors `LG` / purple for "you"; Profile stats (18 wins, 4.8★…), Reputation reviews, Achievements and Landing stats (2.400+ players) are hardcoded demo data — review before store submission (Play/App Store reject misleading content)

## Phase 6 — Final sign-off
- [ ] `flutter analyze` clean
- [ ] `flutter test` clean
- [ ] i18n (Phase 5b) complete and verified in every supported language
- [ ] Full Phase 3 QA pass repeated once more on the actual release build artifact
- [ ] Update `docs/project_notes/bugs.md` / `decisions.md` with anything new discovered during this pass

---

## 2026-10-03 — Device-test bug batch (see bugs.md "Device-Test Batch")
- [x] Tümünü gör → GamesScreen; Geçmiş sekmesi + Sonuçlarım real data (RangeError)
- [x] Match cards tappable (shared `showMatchDetailSheet`); incoming vs sent pending labels
- [x] Lobby join writes a request + notifies creator; own lobby blocked
- [x] Avatar initials, back button in Bildirimler, nearby-players tile moved
- [x] Profile persistence: signup no longer swallows save errors, `_ProfileGate` on /home
- [x] Doubles/singles organise screen really sends the request
- [x] Hardcoded stats removed (profile, landing)
- [x] `flutter analyze`: 0 errors; `flutter test`: 44 pass
- [ ] Device retest (two accounts): lobby join → creator gets notification ≤10s; fresh signup → kill app → login lands on Home with the same profile
- [ ] Reputation / Achievements still demo data — decide hide vs wire before store review

## Review (fill in after execution)
_To be completed once phases are executed — summary of what passed, what broke, and what's still open before store submission._

---

## 2026-10-04 — Lobby v2: format, request cap, roster, close, remove, messaging (PLAN — awaiting approval)

### Rules (agreed with user)
- Lobby has a **format**: `singles` (organiser + 1) or `doubles` (organiser + 3). Chosen when creating the lobby.
- **Request cap = 10 *pending* requests per lobby** (accepted/declined ones don't count). 10 pending → accept 1 → 9 pending → exactly 1 more person can ask; the next one is blocked until the organiser answers another.
- **Roster capacity** = accepted players: 1 (singles) / 3 (doubles). When reached the lobby is `full` (cards say so, no new requests) and reopens if the organiser removes someone.
- Organiser can **close** a lobby at any time (stops new requests; pending ones are auto-declined + notified; already accepted players keep their match).
- Organiser sees **who is accepted** (and pending) per lobby, can **message** both pending and accepted people, and can **remove** an accepted person later (match cancelled, spot freed, person notified).

### Card text (joiner side) — proposal
| State | Button | Small line |
|---|---|---|
| can join | Katıl | – |
| I asked, pending | İstek gönderildi | – |
| I'm accepted | Katıldın | – |
| 10 pending (I'm not one of them) | Şimdilik dolu | "Organizatör yanıtlayınca yer açılır" |
| roster full (I'm not in) | Kadro dolu | – |
| organiser closed (I was declined/removed or never asked) | card disappears from the list |
| I was declined / removed | Katıl again only if lobby still open & has room |
Organiser card: format chip + `1/3 kabul · 4 bekleyen` ; tap → management sheet.

### DB (needs migration — Supabase MCP not authorised in this session; SQL file will be written to `docs/migrations/`)
- [x] (SQL written, **user runs it**) `lobbies`: `format` (singles|doubles, default singles), `pending_count`, `accepted_count` (counters so *every* user can read "full" despite `matches` RLS), status check gains `closed` (already has open/full/cancelled)
- [ ] `matches.lobby_id` FK → `lobbies(id)`
- [ ] SECURITY DEFINER trigger on `matches` (insert/update/delete): keeps counters, sets `lobbies.status` open↔full, raises named errors on insert when lobby closed / full / pending ≥ 10 (server-side → no race when two people tap the last slot)
- [ ] On lobby close: pending matches → cancelled
- [ ] RLS: lobbies SELECT for status open+full; notifications INSERT policy extended to `cancellation` (organiser → removed player) and a lobby-closed notice
- [ ] `NOTIFY pgrst, 'reload schema'` + verify with `list_tables`

### App
- [x] `OpenLobbyScreen`: Tekli/Çiftli selector
- [x] `DataService`: `lobbies` moved into the shared cache (`refreshLive`, `cacheVersion`) instead of one-shot load in `match_screen`; `joinLobby` sends `lobby_id` and maps server errors → `DataError.lobbyQueueFull / lobbyFull / lobbyClosed`; new `getLobbyParticipants`, `respondToLobbyRequest(matchId)`, `removeFromLobby`, `closeLobby`
- [x] Pure function `lobbyCardState(lobby, mySessions, uid)` (unit-tested) replaces the inline logic in `_LobbyCardState`
- [x] `LobbyManageSheet` (organiser): pending list (Kabul / Reddet / Mesaj), accepted list (Mesaj / Çıkar), Lobiyi kapat
- [ ] Messaging: "Mesaj" opens the existing 1:1 conversation with that player (works before any message exists); joiner also gets a "Mesaj" entry on their lobby card sheet
- [x] l10n (TR + EN) for all new strings; `flutter gen-l10n`
- [ ] Tests: card-state function, cap/full rules; SQL rules exercised with two real accounts after migration
- [x] ADR-013 + key_facts `lobbies`/`matches` update; supersede the ADR-012 "lobby stays open" consequence

### Open questions
1. Doubles = organiser + 3 accepted (4 players total) — OK?
2. "Close" keeps already-accepted matches and auto-declines pending ones — OK?
3. Migration: authorise Supabase MCP (I apply + verify), or I write the SQL and you run it in the SQL editor?

### Status 2026-10-04
- Done: SQL file, app code, l10n, 7 new unit tests (`test/lobby_state_test.dart`); `flutter analyze` 0 errors, `flutter test` 51 pass.
- Not done: migration not run by me; two-account device test of the whole flow; joiner-side "message organiser" entry point (organiser → player only, replies work both ways).
