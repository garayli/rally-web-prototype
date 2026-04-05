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

## pubspec.yaml Notes

Key dependencies that are declared but not yet actively used in screen code:
- `go_router` — declared but navigation uses plain `Navigator`
- `flutter_riverpod` / `riverpod_annotation` / `riverpod_generator` — declared but not used
- `flutter_animate` — available for animations
- `shimmer` — available for loading skeletons
