# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rallly is a tennis/racquet sport matchmaking app built in Flutter. The Flutter project lives in `rallly_flutter/`. There is also an HTML prototype at `rallly-v3_3.html` that serves as the visual design reference.

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

### Auth Flow (`lib/main.dart`)

Auth is managed by a single `_AppRouter` stateful widget using a `_AppPage` enum and a `switch` expression. The flow is:

```
landing → authEmail → authOtp → signup (new users only) → home (MainShell)
```

The app initialises Supabase on startup. If `supabase.auth.currentSession` is non-null, it skips straight to `home`. The global `supabase` accessor is defined in `main.dart`.

Supabase credentials must be filled in `lib/config/supabase_config.dart` (`supabaseUrl` and `supabaseAnon`). Auth uses Email OTP with PKCE flow; the redirect URL is `io.supabase.rallly://login-callback/`.

### Navigation inside the app (`lib/screens/main_shell.dart`)

`MainShell` is a bottom-nav shell with 5 tabs using `IndexedStack` (state is preserved across tabs):
- Match, Schedule, Messages, Notifications, Profile

Secondary screens (PlayerProfile, Games, CreateGame, etc.) are pushed via `Navigator.push` from within tab screens. There is **no GoRouter** in use despite it being listed in `pubspec.yaml` — navigation is plain `Navigator`.

### Data Layer

All data is currently **mock only** (`lib/services/mock_data.dart`). The models are in `lib/models/models.dart`:
- `Player` — NTRP rating, availability slots, preferred courts, gradient avatar colours, match compatibility %
- `MatchSession` — references a `Player` opponent, has `MatchStatus` and optional `MatchResult`
- `Conversation` / `ChatMessage` — messaging thread
- `AppNotification` — typed notification with `NotifType` enum

When connecting to Supabase, replace `MockData` calls with real queries. Required DB tables: `profiles`, `matches`, `messages`, `reviews`, `notifications`.

### Theme (`lib/theme/app_theme.dart`)

All colours are in `RallyColors` (static consts, no theming extension needed — just reference `RallyColors.accent` etc. directly). `RallyTheme.light` / `RallyTheme.dark` produce `ThemeData`.

Colour palette key:
- `accent` (#5A8A00) — tennis ball green, primary CTA
- `accent2` (#C8431A) — clay red, destructive/secondary
- Background: cream (`#F5F0E8` light) / near-black (`#0F110D` dark)

Typography: **InstrumentSerif** (local font, `assets/fonts/`) for display/headline styles; **Plus Jakarta Sans** (Google Fonts) for body text. The font files must be downloaded from Google Fonts and placed in `assets/fonts/`.

### Shared Widgets (`lib/widgets/shared_widgets.dart`)

Reusable components to use across screens:
- `PlayerAvatar` — gradient circle with initials
- `SkillBadge` — coloured pill for Beginner / Intermediate / Advanced
- `MatchScoreBadge` — large % compatibility display
- `PlayerCard` — list item with avatar, skill badge, match %, and Request button
- `RallyButton` — wraps `FilledButton` / `OutlinedButton` with loading state
- `NotifBadge` — notification dot count badge
- `SectionHeader` — uppercase label + optional action link

### State Management

Plain `StatefulWidget` + `setState`. `flutter_riverpod` is in `pubspec.yaml` but not yet wired up — do not introduce Riverpod unless explicitly asked.

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
- Check `docs/project_notes/decisions.md` for existing decisions
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

Key dependencies that are declared but not yet actively used in screen code:
- `go_router` — declared but navigation uses plain `Navigator`
- `flutter_riverpod` / `riverpod_annotation` / `riverpod_generator` — declared but not used
- `flutter_animate` — available for animations
- `shimmer` — available for loading skeletons
