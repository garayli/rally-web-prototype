# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RallyMatch is a tennis/racquet sport matchmaking app built in Flutter. The Flutter project lives in `rallly_flutter/`. There is also an HTML prototype at `rallly-v3_3.html` that serves as the visual design reference.

All UI strings are in Turkish (TR). Skill levels appear as "Başlangıç" / "Orta" / "İleri" throughout.

## Commands

All commands run from inside `rallly_flutter/`:

```bash
flutter pub get                          # install dependencies
flutter run                             # run on connected device/emulator
flutter run -d chrome                   # run on Chrome (web)
flutter build apk --release             # build Android APK
flutter analyze                         # lint / static analysis
flutter test                            # run all tests
flutter test test/widget_test.dart      # run a single test file
```

## Architecture

### Auth Flow (`lib/main.dart` + `lib/router/app_router.dart`)

The app uses **GoRouter** (`lib/router/app_router.dart`) for top-level routing. `_AppRouter` in `main.dart` handles the Supabase init check via a `_AppPage` enum + `switch` expression, then hands off to GoRouter.

```
landing → /auth/email → /auth/otp → /signup (new users only) → /home (MainShell)
```

GoRouter's `redirect()` enforces the auth guard — logged-in users are bounced from `/landing`/`/auth/*`/`/signup`; unauthenticated users from `/home` and below. `_GoRouterRefreshStream` listens to `supabase.auth.onAuthStateChange` and triggers redirects on logout.

Route data is passed via `extra`: e.g., `context.go('/auth/otp', extra: {'email': '...', 'isSignUp': true})`.

Secondary screens (PlayerProfile, Games, CreateGame, etc.) are still pushed via plain `Navigator.push` from within tab screens.

Supabase credentials live in `lib/config/supabase_config.dart` (`supabaseUrl` and `supabaseAnon`). Auth uses Email OTP with PKCE flow; the redirect URL is `io.supabase.rallly://login-callback/`.

### Navigation inside the app (`lib/screens/main_shell.dart`)

`MainShell` is a bottom-nav shell with 5 tabs using `IndexedStack` (state is preserved across tabs):
- Match, Schedule, Messages, Notifications, Profile

`IndexedStack` keeps all 5 screens alive — higher memory use, but no scroll-position loss on tab switch.

A custom `OnboardingOverlay` (not a third-party package) is shown once per tab. Seen-state is persisted in `SharedPreferences` using key `'onboarding_seen'` (list of seen tab indices).

### Data Layer

All data is currently **mock only** (`lib/services/mock_data.dart`).

**Never import `MockData` directly in screens.** All screens must use the `DataService` abstract interface (`lib/services/data_service.dart`) via the global `dataService` singleton. This is the single swap point when wiring real Supabase queries.

`DataService` exposes:
- `currentUserId` — `'me'` in mock; real user ID from Supabase auth
- `getPlayers()`, `getConversations()`, `getUpcomingSessions()`, `getNotifications()`
- `unreadNotifier` (`ValueNotifier<int>`) — reactive badge count used by MainShell
- `markAllRead()`, `markConversationRead(id)`, `getNotifPrefs()`, `saveNotifPrefs()`

The sentinel value `'me'` appears as `senderId` in mock conversations. Replace with `supabase.auth.currentUser!.id` when wiring Supabase.

The models are in `lib/models/models.dart`:
- `Player` — NTRP rating, availability slots, preferred courts, gradient avatar colours, match compatibility %
- `MatchSession` — references a `Player` opponent, has `MatchStatus` and optional `MatchResult`
- `SetScore` / `MatchResult` — per-set scores, winner, and rating delta
- `Conversation` / `ChatMessage` — messaging thread; `unreadCount(currentUserId)` filters by sender
- `AppNotification` — typed notification with `NotifType` enum; `hasActions` is true only for matchRequest/resultConfirmed

When connecting to Supabase, replace `DataService` calls with real queries. Required DB tables: `profiles`, `matches`, `messages`, `reviews`, `notifications`, `lobbies`.

Nullable FK pattern: `matches.player2_id` and `messages.receiver_id` are nullable to support unregistered (guest) opponents. Guests are identified by `opponent_phone` for future retroactive account linking (ADR-005/006 in `docs/project_notes/decisions.md`).

### State Management

Plain `StatefulWidget` + `setState`. For cross-screen reactive state, use `ValueNotifier<T>` (ADR-003) — see `dataService.unreadNotifier` + `ValueListenableBuilder` in `MainShell`. Do **not** introduce `flutter_riverpod` unless explicitly asked.

### Theme (`lib/theme/app_theme.dart`)

All colours are in `RallyColors` (static consts). `RallyTheme.light` / `RallyTheme.dark` produce `ThemeData`.

Colour palette key:
- `accent` (#5A8A00) — tennis ball green, primary CTA
- `accent2` (#C8431A) — clay red, destructive/secondary
- Background: cream (`#F5F0E8` light) / near-black (`#0F110D` dark)

Typography: **InstrumentSerif** (local font, `assets/fonts/`) for display/headline styles; **Plus Jakarta Sans** (Google Fonts) for body text. The font files must be downloaded from Google Fonts and placed in `assets/fonts/`.

### Shared Widgets (`lib/widgets/shared_widgets.dart`)

- `PlayerAvatar` — gradient circle with initials (hex → Color; fallback to gray on invalid hex)
- `SkillBadge` — coloured pill for skill level
- `MatchScoreBadge` — large % compatibility display (InstrumentSerif)
- `PlayerCard` — list item with avatar, skill badge, match %, and "İste" button
- `RallyButton` — wraps `FilledButton` / `OutlinedButton` with loading state
- `NotifBadge` — red dot notification count badge
- `SectionHeader` — uppercase label + optional action link

## Engineering Standards

### Verification Before Done
- Never mark a task complete without proving it works.
- Diff behavior between main and your changes when relevant.
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness.

### Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution."
- Skip this for simple, obvious fixes — don't over-engineer.
- Challenge your own work before presenting it.

### Supabase Column Checklist
- Before writing Flutter code that references new columns, run `apply_migration` first
- Verify columns exist with `mcp__claude_ai_Supabase__list_tables` (verbose=true) before testing inserts
- After any DDL change, always run `NOTIFY pgrst, 'reload schema'` so PostgREST picks up the new schema
- If code must be written before the migration: wrap new column keys in `if (condition) ...{ 'col': val }` conditional spread so they are never sent to a table that doesn't have them yet
- `matches.player1_id` FK targets `profiles.id`, not `auth.users` — the logged-in user must have a profile row

### Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding.
- Point at logs, errors, failing tests — then resolve them.
- Zero context switching required from the user.
- Go fix failing CI tests without being told how.

## Task Management

1. **Plan First**: Write plan to `tasks/todo.md` with checkable items.
2. **Verify Plan**: Check in before starting implementation.
3. **Track Progress**: Mark items complete as you go.
4. **Explain Changes**: High-level summary at each step.
5. **Document Results**: Add review section to `tasks/todo.md`.
6. **Capture Lessons**: Update CLAUDE.md with anything non-obvious learned.

## Project Memory System

### Memory-Aware Protocols

**Before proposing architectural changes:**
- Check `docs/project_notes/decisions.md` for existing ADRs
- Verify the proposed approach doesn't conflict with past choices

**When encountering errors or bugs:**
- Search `docs/project_notes/bugs.md` for similar issues
- Apply known solutions if found
- Document new bugs and solutions when resolved

**When looking up project configuration:**
- Check `docs/project_notes/key_facts.md` for credentials, ports, URLs
- Prefer documented facts over assumptions

---

## Agent Execution Protocol

When a task is given, all agents run conceptually in parallel — each produces output independently without waiting for others. Every agent focuses only on its own responsibility.

### Agents

| Agent | Responsibility |
|---|---|
| **Research** | Best practices, similar patterns, library trade-offs, feasibility |
| **Plan Reviewer** | Challenges complexity, enforces simplicity, flags over-engineering |
| **Developer** | Implements the validated plan following project conventions |
| **Code Reviewer** | Reviews output for correctness, null safety, convention compliance |
| **Tester** | Writes and runs `flutter analyze` + widget/unit tests |

### Output structure

Every response using the agent workflow must be structured as:

```
[Agent: Research]
...findings...

[Agent: Plan Reviewer]
...verdict and required changes...

[Agent: Developer]
...implementation summary...

[Agent: Code Reviewer]
...APPROVED or CHANGES REQUIRED...

[Agent: Tester]
...ALL TESTS PASS or FAILURES FOUND...
```

### Synthesis step

After all agents respond, a final **Synthesis** block combines results:
- What was built
- Any unresolved issues from review or testing
- Next recommended action

### When to skip agents

- **Research** — skip for tasks where the approach is already established in the codebase
- **Plan Reviewer** — skip for single-line fixes with no architectural impact
- **Tester** — skip for purely cosmetic changes (color swaps, label text)

Always include at minimum: Developer + Code Reviewer.

### Agent definitions

Live in `.claude/agents/` — one file per agent with its system prompt and allowed tools.

---

## pubspec.yaml Notes

Dependencies declared but **not yet actively used**:
- `flutter_riverpod` / `riverpod_annotation` / `riverpod_generator` — not used; ValueNotifier is the pattern
- `shimmer` — declared but no loading skeletons implemented yet

Dependencies that **are** used but easy to overlook:
- `go_router` — used in `lib/router/app_router.dart`
- `flutter_animate` — card fade/slide animations in match_screen
- `shared_preferences` — onboarding seen-state per tab
- `intl` — date/time formatting throughout
- `share_plus` — share results from result_card_screen
- `flutter_map` + `latlong2` — OpenStreetMap tiles in map_screen

## Version 2: UI/UX Overhaul Guidelines
   - **Current Issue:** The current UI feels cluttered, non-intuitive, and lacks smooth transitions.
   - **Goal:** Rebuild the presentation layer to be clean, user-friendly, and modern.
   - **Constraint:** Do NOT touch or break the underlying backend logic, API integration, or local state management unless explicitly requested. Keep presentation components decoupled from business logic.
