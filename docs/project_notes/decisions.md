# Architectural Decision Records

Key architectural decisions and their rationale.

## Template

```markdown
## ADR-[Number]: [Decision Title]
**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded

### Context
[What situation prompted this decision]

### Decision
[What was decided]

### Consequences
- **Positive:** [Benefits]
- **Negative:** [Drawbacks]
```

---

## Decisions

## ADR-001: Figma MCP — View-only token, no write-back
**Date:** 2026-04-26
**Status:** Accepted

### Context
Figma MCP was connected to enable design-to-code workflow. Attempted to set up write-back (create files, upload assets) but Figma's free Starter plan does not allow API tokens with file-write scopes.

### Decision
Use Figma MCP in read-only mode. Primary tools: `get_design_context`, `get_screenshot`, `get_variable_defs`. Write-back tools (`create_new_file`, `upload_assets`, `generate_diagram`) are unavailable until plan is upgraded.

### Consequences
- **Positive:** Design-to-Flutter workflow works fine — read access is all that's needed for implementation.
- **Negative:** Cannot push generated diagrams or updated designs back to Figma from Claude.

---

## ADR-003: ValueNotifier for cross-screen reactive state (no Riverpod)
**Date:** 2026-04-26
**Status:** Accepted

### Context
`IndexedStack` keeps all tab screens alive but doesn't trigger rebuilds on sibling screens. Hardcoded badge counts (`count: 3`) didn't update when notification state changed elsewhere.

### Decision
Use `ValueNotifier<T>` on the `DataService` singleton for any state that must reactively update across multiple screens (e.g. `unreadNotifier`). Screens wrap with `ValueListenableBuilder`. No Riverpod introduced.

### Consequences
- **Positive:** Zero new dependencies, works with plain StatefulWidgets, updates any listener instantly regardless of widget tree position.
- **Negative:** Manual — each cross-screen reactive value needs its own notifier. Riverpod would handle this more elegantly at scale.

---

## ADR-004: Supabase messages.receiver_id is nullable
**Date:** 2026-04-26
**Status:** Accepted

### Context
The `messages` table FK `receiver_id → profiles.id` blocked all inserts because mock players don't have real Supabase profiles (profiles requires auth.users row).

### Decision
Made `receiver_id` nullable and kept FK as a nullable reference (migration: `make_receiver_id_nullable`). Flutter omits `receiver_id` until real player profiles exist. Authenticated sender's profile was inserted manually.

### Consequences
- **Positive:** Messages can be persisted to Supabase immediately even before full player onboarding.
- **Negative:** `receiver_id` will be null for all messages until real players sign up. Queries filtering by receiver won't work yet.
- **How to apply:** When real player onboarding is built, populate `receiver_id` and it will backfill correctly due to nullable FK.

---

## ADR-002: Secret scripts go in .gitignore
**Date:** 2026-04-26
**Status:** Accepted

### Context
`test_figma.ps1` was committed with a hardcoded Figma personal access token. GitHub's push protection blocked the push.

### Decision
- Local test/secret scripts (`test_figma.ps1`, `export_prototype_components.ps1`) are added to `.gitignore`.
- Secrets must use environment variables (`$env:FIGMA_TOKEN`), never hardcoded strings.
- Revoke and regenerate any token that was committed, even if the push was blocked.

### Consequences
- **Positive:** No secrets leak to remote; GitHub push protection satisfied.
- **Negative:** Test scripts must be re-configured locally after a fresh clone.

---

## ADR-005: matches.player2_id is nullable uuid with no FK enforcement during dev
**Date:** 2026-05-09
**Status:** Accepted

### Context
The `matches` table insert uses `player2_id` for the opponent, but mock player IDs are short strings (`'p1'`, `'p2'`), not UUIDs. A strict FK constraint `player2_id → profiles.id` would reject every insert until all players have real Supabase profiles — the same problem that occurred with `messages.receiver_id` (see ADR-004).

### Decision
`player2_id` is `uuid` but nullable, with a FK to `profiles.id`. For guest/mock opponents, `player2_id` is sent as `null`; opponent identity is stored in `opponent_name` (text) and `opponent_phone` (text) instead. Once real player onboarding is complete, `player2_id` can be populated retroactively by matching on phone number.

### Consequences
- **Positive:** Inserts succeed immediately in dev/testing; guest match results are stored with enough data to link later.
- **Negative:** No referential integrity on opponent until real profiles exist. Queries joining matches → profiles on `player2_id` return null for guest rows.
- **How to apply:** When real onboarding is built, populate `player2_id` by querying `profiles` by phone number at insert time.

---

## ADR-006: Phone number as unregistered opponent identifier
**Date:** 2026-05-15
**Status:** Accepted

### Context
Users need to log match results against opponents who don't use the app. A free-text name alone is not a reliable identifier. Phone number is unique and stable, and when the opponent eventually registers with the same number their historic match results can be retroactively linked.

### Decision
Unregistered opponents are identified by phone number (minimum 10 digits, digits-only). Name is optional. Both are stored in `matches.opponent_phone` and `matches.opponent_name`. `player2_id` is null for these rows. Phone is not yet stored in `profiles`; linking is future work.

### Consequences
- **Positive:** Consistent unique key for future retroactive linking. Simple UX — just enter a number.
- **Negative:** Relies on phone being unique per person (not enforced at DB level). No real-time validation that the number belongs to any real person.
- **How to apply:** Future signup flow should collect phone → store in `profiles.phone` → on match insert, query profiles by phone to auto-populate `player2_id`.

---

## ADR-007: Onboarding overlay — custom implementation over third-party package
**Date:** 2026-05-15
**Status:** Accepted

### Context
New users needed per-tab guidance on what each page does. Options considered: third-party packages (`showcaseview`, `tutorial_coach_mark`), a full-screen intro carousel, and a custom `Stack`-based overlay card.

### Decision
Custom `Stack`-based overlay rendered inside `Scaffold.body`, managed in `MainShell`. No third-party onboarding package introduced. Seen-state stored in `shared_preferences` (already a transitive dep, promoted to direct). Overlay is a semi-transparent backdrop + centered card (icon + title + bullets + dismiss button). `BottomNavigationBar` lives in `Scaffold.bottomNavigationBar` so it is never obscured.

### Consequences
- **Positive:** Zero new UI dependencies; fits existing `flutter_animate` + `StatefulWidget + setState` patterns; fully controllable styling.
- **Negative:** Overlay points at the page as a whole, not at specific UI elements. If per-element coach marks are needed later, a package like `showcaseview` would require adding `GlobalKey`s to target widgets.
- **How to apply:** To reset onboarding in development, clear the `onboarding_seen` SharedPreferences key. To add a new tab, append an entry to `kTabOnboardingContent` in `onboarding_overlay.dart` and increase `List.filled(5, ...)` to the new count.

---

## ADR-008: Cache-warm-once in MainShell instead of async DataService interface
**Date:** 2026-09-13
**Status:** Accepted

### Context
`getPlayers()`, `getConversations()`, and `getUpcomingSessions()` needed to move from static `MockData` to real Supabase queries, which are inherently async. But the abstract `DataService` interface declares them synchronous (`List<T>`, not `Future<List<T>>`), and they're called directly inside `build()` — sometimes multiple times per build — across 10 screen files. Converting all of them to `Future<List<T>>` would mean adding FutureBuilder/initState-load boilerplate to all 10 files.

### Decision
Kept the three getters synchronous. Added `Future<void> warmCache()` to `DataService`, which fetches all three lists once and populates internal cache fields on `MockDataService` (which, despite its name, is the one real Supabase-backed implementation — see the Data Layer section of CLAUDE.md). `MainShell` — the sole entry point into the tabbed app post-login, since all secondary screens are reached via `Navigator.push` from within its tabs — calls `warmCache()` in `initState` and gates building the tab `IndexedStack` behind it (same `_prefsLoaded`-style boolean pattern already used for the onboarding overlay), so every tab's very first build already has real data with zero per-screen signature changes.
Because `IndexedStack` keeps all 4 tabs mounted for the life of the session, a later cache refresh (e.g. after `sendMatchRequest`) doesn't trigger a rebuild on its own. Added `ValueNotifier<int> cacheVersion` to `DataService`, bumped at the end of every internal refresh; `match_screen.dart`, `messages_screen.dart`, `games_screen.dart`, `profile_screen.dart`, and `schedule_screen.dart` wrap their body in `ValueListenableBuilder<int>` on it (mirroring the existing `unreadNotifier` pattern in `MainShell`'s bottom nav, per ADR-003).

### Consequences
- **Positive:** Zero interface-breaking changes to the 10 screen call sites; reuses an established codebase pattern (ADR-003) instead of introducing a new one; `warmCache()` swallows its own errors so the loading gate can never hang indefinitely on a network failure.
- **Negative:** Data is only as fresh as the last `warmCache()`/refresh call — there's no pull-to-refresh or realtime subscription yet. A screen that isn't wrapped in the `cacheVersion` listener (e.g. `doubles_organise_screen.dart`, which only reads `getPlayers()`) won't reflect a mid-session player-list change, but nothing currently mutates that list mid-session so this is a non-issue for now.
- **How to apply:** Any new screen that reads `getPlayers()`/`getConversations()`/`getUpcomingSessions()` and needs to reflect a cache refresh made elsewhere (not just its own initial render) should wrap its body in `ValueListenableBuilder<int>(valueListenable: dataService.cacheVersion, ...)`.

---

## ADR-009: Player.matchScore computed client-side from NTRP-rating closeness
**Date:** 2026-09-13
**Status:** Accepted

### Context
`Player.matchScore` (the compatibility % shown on `PlayerCard`/`MatchScoreBadge`) was a hardcoded per-mock-player value. The `profiles` table has no `match_score` column, and no real compatibility-matching algorithm has been designed yet.

### Decision
Compute it client-side in `MockDataService._playerFromRow()`: `100 - |other.ntrp_rating - me.ntrp_rating| * 40`, clamped to 0–100, injected into the row map before `Player.fromJson()` — no schema change, no `copyWith` added to the `Player` model.

### Consequences
- **Positive:** Real, varying compatibility numbers immediately instead of a placeholder 0; no migration needed.
- **Negative:** This is a stand-in, not a real matching algorithm — it ignores location, availability overlap, playstyle, etc. Whoever designs the real compatibility algorithm later should replace this formula in one place (`_playerFromRow`).
- **How to apply:** Do not read anything into the specific constant (40) or shape of this formula — it was chosen to produce a plausible-looking spread of scores, not from any matchmaking research.

---

## ADR-010: Android applicationId + real upload signing config
**Date:** 2026-09-13
**Status:** Accepted

### Context
The Android release build shipped with the Flutter template placeholder `applicationId` (`io.supabase.rallly.rallly`) and signed release builds with the debug key — both must be fixed before any Play Store upload, and `applicationId` cannot be changed after the first upload.

### Decision
Set `applicationId = "com.rallymatch.app"` in `android/app/build.gradle.kts`. Left `namespace` unchanged (`io.supabase.rallly.rallly`) since it only drives internal R-class generation, not the Play Store listing identity — changing it would require moving `MainActivity.kt`'s package/directory for no user-facing benefit. Generated a real upload keystore (`android/app/upload-keystore.jks`) and wired `signingConfigs.release` to load `keyAlias`/`keyPassword`/`storeFile`/`storePassword` from `android/key.properties` (both gitignored). `signingConfig` falls back to the debug key only when `key.properties` doesn't exist, so a fresh checkout without the keystore still builds (just not release-signed).

### Consequences
- **Positive:** Release builds are now properly signed (verified via `apksigner verify --print-certs` — signer DN matches the new keystore, not the debug cert); `applicationId` is locked in before any store upload.
- **Negative:** The keystore and its password exist only on the machine that generated them (not yet backed up elsewhere as of this writing) — if lost, this Play Store listing can never be updated again. `namespace` and `applicationId` now permanently differ, which is harmless but can look odd to someone unfamiliar with the distinction.
- **How to apply:** Before any release build/store upload, confirm `android/app/upload-keystore.jks` still exists and its password (in `android/key.properties`) is backed up outside this machine. Never regenerate the keystore to "fix" a missing one — a new keystore is a different signing identity and Google Play will reject it as an update to the existing app.

## ADR-011: Internationalization with gen-l10n (ARB), canonical Turkish values in the data layer
**Date:** 2026-10-03
**Status:** Accepted

### Context
All UI strings were hardcoded Turkish literals spread across ~30 files, and `DateFormat` calls had no locale. The app is going to the stores with Turkish and English. Several Turkish strings are not display text at all — they are values written to Supabase and used as logic keys (`profiles.skill_level` = `'Başlangıç'`, `available_days` = `'Pzt'`, `time_prefs` = `'Sabah'`, `lobbies.skill_level` = `'Her seviye'`, `matches.court` = `'Belirtilmedi'`).

### Decision
- Use Flutter's official `gen-l10n`: `lib/l10n/app_tr.arb` is the template, `app_en.arb` the translation, config in `l10n.yaml`, generated code committed under `lib/l10n/`. Screens use `context.l10n.<key>` (extension in `lib/l10n/l10n.dart`) and `context.localeName` for every `DateFormat`. No new package; `intl` bumped to `^0.20.2` as `flutter_localizations` requires.
- **Stored values stay Turkish and never change with the UI language.** `lib/l10n/option_labels.dart` maps each canonical value to a localized label (`skillLevelLabel`, `dayLabel`, `timeLabel`, `sportLabel`, `availabilitySlotLabel`, `courtDisplay`); unknown values fall back to the raw string.
- The data layer holds no user-facing text. `DataService` throws `DataException(DataError.x)`; the UI converts it with `dataErrorMessage(l10n, e)`.
- Locale follows the device; unsupported languages fall back to `tr`. No in-app language picker yet.
- Android: `androidResources.localeFilters` + `res/xml/locales_config.xml` (per-app language on Android 13+). iOS: `CFBundleLocalizations` + `InfoPlist.strings`.
- `test/widget_test.dart` checks that both ARB files have identical keys and renders key screens at 360x740 in every supported locale.

### Consequences
- **Positive:** Adding a language = one ARB file + one entry in the Android locale lists. A missing translation fails a test.
- **Negative:** Text written to the DB by the app or by n8n is stored in one language and shown as-is to the recipient: notification title/body (`data_service.dart` `_notifyMatchRequest`, `_notifyRequesterOfResponse`, `respondToMatchRequest`; the n8n result-confirmation workflow) and the guest placeholder name `'Misafir Oyuncu'`. These are still Turkish for English users. Real fix: store `type` + params (name, court) and render in the client — needs a `notifications` schema change, so deliberately not done here.
- **How to apply:** Never put a literal user-facing string in a widget or in `DataService`; add a key to both ARB files, run `flutter gen-l10n`. Never localize a value you write to Supabase — localize only its label.

---

## ADR-012: Profile gate on /home; lobby join as a match request
**Date:** 2026-10-03
**Status:** Accepted

### Context
Device testing showed (1) profiles "not saving": signup swallowed a failed save and entered the app anyway, and "Başla" on an existing account re-ran the wizard; (2) the lobby "Katıl" button only showed a snackbar. A join table plus a new notification type would have needed a migration.

### Decision
- `/home` is wrapped in `_ProfileGate` (`router/app_router.dart`). It calls `dataService.hasCompletedProfile()` → `isProfileComplete()` (`utils/profile_check.dart`): a row with a real name and a location. The auth trigger's `'New Player'` placeholder doesn't count. Incomplete → `/signup`. OTP verification always goes to `/home`; the gate decides. `SignupScreen` stays on the wizard when the save fails.
- Joining a lobby = `dataService.joinLobby()`, which inserts a `matches` row (player1 = joiner, player2 = lobby creator, lobby's date/court, `pending`) and sends the standard `matchRequest` notification. It reuses existing RLS policies and the Kabul/Reddet flow. Own lobby → `DataError.ownLobby`; duplicate (same pair, slot, court, not cancelled) → `DataError.alreadyRequested`.
- `MatchSession.isRequester` records which side the user is. Set scores, `rating_delta` and the pending state are from player1's view; `wonBy()`, `setsForMe()`, `ratingDeltaForMe()` translate them. `log_result_screen` writes `winner_id` only when player1 wins, so an empty winner means player2 won.

### Consequences
- **Positive:** No migration; every entry path is covered by one gate; request cards can say "Sana gelen istek" vs "Yanıt bekleniyor".
- **Negative:** A lobby stays open after its creator accepts (no `lobby_id` on `matches`, and only the creator can update `lobbies`). The sport isn't stored on the match. A doubles partner can't be stored (no column).
- **How to apply:** Never call a screen's completion callback from `finally` after a write that can fail. If lobbies need capacity/closing, add `matches.lobby_id` + a lobby-update policy first.

---

<!-- Add new ADRs above this line -->
---

## ADR-013: Lobby v2 — format, 10-pending cap, roster, close (DB-enforced)
**Date:** 2026-10-04
**Status:** Accepted (supersedes the "lobby stays open" consequence of ADR-012)

### Context
Lobbies had no format, no limit on requests, no way to see/remove accepted players or to close. Other users can't read someone else's `matches` (RLS), so "is this lobby full?" can't be derived on the client.

### Decision
- `lobbies.format` (singles/doubles), `pending_count`, `accepted_count`, status `open|full|closed|cancelled`; `matches.lobby_id`. Migration: `docs/migrations/2026-10-04_lobby_v2.sql`.
- Rules live in DB triggers (row-locked, so no race): max **10 pending** requests, roster 1 (singles) / 3 (doubles); counters and open↔full are recomputed on every `matches` change; closing declines pending requests and notifies.
- Client: `Lobby` model, `lobbyCardState()` (`utils/lobby_state.dart`, unit-tested), lobbies cached in `DataService` (`getLobbies`, polled by `refreshLive`), organiser `showLobbyManageSheet()`; server errors `lobby_queue_full|lobby_full|lobby_closed` map to `DataError`.
- The cap counts *pending* only: accepting one frees a slot for exactly one more request.

### Consequences
- **Positive:** every card is correct for every viewer; two people can't take the last slot.
- **Negative:** code needs the migration applied first (`lobbies.format` insert fails otherwise). Requests made before the migration have no `lobby_id` and don't count toward a lobby.
- **How to apply:** any new way of changing `matches.status` for lobby rows must go through the trigger-protected columns; never write the counters from the app.
