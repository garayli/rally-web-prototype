# Bug Log

A record of bugs encountered and their solutions.

## Template

```markdown
## [Bug Title]
**Date:** YYYY-MM-DD
**Severity:** Low | Medium | High | Critical

### Problem
[Description of the bug]

### Root Cause
[What caused it]

### Solution
[How it was fixed]

### Prevention
[How to avoid this in the future]
```

---

## Entries

## Player Names Not Clickable in Messages
**Date:** 2026-04-26
**Severity:** Low

### Problem
Tapping player name/avatar in Messages inbox and Conversation app bar did nothing.

### Root Cause
Neither location had a gesture handler — avatar was a plain widget, app bar title was a plain Row.

### Solution
Wrapped avatar in `GestureDetector` in inbox tile (tap avatar → profile, tap row → conversation).
Wrapped entire title Row in `GestureDetector` in ConversationScreen app bar.

### Prevention
Any player name/avatar display should default to being tappable to `PlayerProfileScreen`.

---

## Supabase Messages Insert Failing Silently
**Date:** 2026-04-26
**Severity:** Medium

### Problem
Messages sent in the app showed single tick (not delivered) and Supabase `messages` table remained empty.

### Root Cause
Three issues:
1. `profiles` table had no row for the authenticated user → FK on `sender_id` rejected insert
2. Mock player IDs (`"p2"`) are not UUIDs → FK on `receiver_id` rejected insert
3. `auth.currentUser` may be null in mock/dev mode → insert never attempted

### Solution
- Inserted profile row for authenticated user (`leila.rhcp21@gmail.com`, UUID `f9d16b73...`)
- Made `receiver_id` nullable + kept FK as nullable reference (migration `make_receiver_id_nullable`)
- Flutter `_send()` omits `receiver_id` until real player profiles exist

### Prevention
- Always insert a profile row immediately after first Supabase auth sign-up (trigger or signup screen)
- FK constraints on receiver-side relationships should be nullable until all users are real

---

## Request Sheet "Send" Button Allows Duplicate Requests
**Date:** 2026-04-26
**Severity:** Low

### Problem
Tapping "Send Request" closed the sheet immediately — user never saw success state. Reopening the sheet reset `_sent` to false, allowing unlimited duplicate requests.

### Root Cause
`_sent` state was local to `_RequestSheetState`, reset on every sheet open. `Navigator.pop` fired before user could see the label change.

### Solution
- Added `_sentRequests = Set<String>` in `_MatchScreenState` (parent), keyed by player ID
- Passed `alreadySent` and `onSent` callback to `_RequestSheet`
- Delayed pop by 1.2s so user sees "Request Sent ✓" disabled button before dismiss

### Prevention
Per-player sent state must live in the parent screen, not the bottom sheet widget.

---

## Bottom Sheet "Send Request" Button Hidden by Nav Bar
**Date:** 2026-04-26
**Severity:** Medium (device-specific — Samsung A56)

### Problem
"Send Request" button was cut off at the bottom of the screen on Samsung A56.

### Root Cause
Bottom padding used `viewInsets.bottom` (keyboard only) but ignored `padding.bottom` (system nav bar).

### Solution
```dart
MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 28
```

### Prevention
Always combine `viewInsets.bottom + padding.bottom` for bottom sheet padding. Never use `viewInsets.bottom` alone.

---

## Achievements Page Grid Overflow
**Date:** 2026-04-26
**Severity:** Low

### Problem
"Social Butterfly" and "Quick Response" badge titles overflowed their grid cells.

### Root Cause
`childAspectRatio: 0.85` made cells too short. Title `Text` had no `maxLines`, so long titles overflowed horizontally then pushed content out vertically when wrapped.

### Solution
- Reduced `childAspectRatio` to `0.68`
- Reduced internal padding from 12→10, icon circle from 52→46
- Added `maxLines: 2, overflow: TextOverflow.ellipsis` to title text

### Prevention
Grid badge cards with multi-line text need `childAspectRatio ≤ 0.70`. Always set `maxLines` on badge title text.

---

## Notification Preferences Not Persisted on Re-open
**Date:** 2026-04-26
**Severity:** Medium

### Problem
Toggle changes on NotificationPreferencesScreen were lost when navigating away and returning.

### Root Cause
`_prefs` map was initialized with hardcoded defaults inside `State` — reset on every `Navigator.push`. `_save()` only showed a flash UI with no actual storage.

### Solution
Moved prefs into `MockDataService` with `getNotifPrefs()` / `saveNotifPrefs()`. Screen loads from and saves to the singleton.

### Prevention
Any user preference that should survive navigation must live in the data service, not local widget state.

---

## "Mark All Read" Badge Not Updating (Notifications)
**Date:** 2026-04-26
**Severity:** Medium

### Problem
Tapping "Mark all read" on the Notifications screen updated the tile UI locally but the `NotifBadge` counts in the app bar and bottom nav still showed "3".

### Root Cause
Three compounding issues:
1. `MockDataService` was `const` — no shared mutable state, so `markAllRead()` didn't exist and local changes couldn't propagate.
2. `NotifBadge(count: 3)` was hardcoded in both `match_screen.dart` and `main_shell.dart`.
3. `items: const [...]` in `BottomNavigationBar` prevented method calls inside it, causing a compile-time `const_eval_method_invocation` error.

### Solution
- Changed `MockDataService` from `const` to a regular class with a `Set<String> _readIds` field.
- Added `markAllRead()` and `getUnreadCount()` to `DataService` abstract class and `MockDataService`.
- Changed global `dataService` from `const` to `final`.
- `NotificationsScreen` now calls `dataService.markAllRead()` before local `setState`.
- Badges in `match_screen.dart` and `main_shell.dart` read `dataService.getUnreadCount()` dynamically.
- `match_screen.dart` bell icon `.then((_) => setState(() {}))` forces badge refresh on return.
- `main_shell.dart` `items: const [...]` → `items: [...]` with individual `const` on non-dynamic items.

### Prevention
- Never hardcode badge counts — always derive from a shared data layer.
- `const` on a service global blocks mutable state; use `final` for service singletons.
- When adding dynamic values inside `BottomNavigationBar.items`, remove `const` from the list (not the individual items).

---

## Profile Avatar Not Clickable (Match Screen)
**Date:** 2026-04-26
**Severity:** Low

### Problem
Tapping the `PlayerAvatar` in the top-right of the Match screen app bar did nothing.

### Root Cause
The avatar was wrapped only in `Padding` — no gesture handler. A `GestureDetector` was added first but still failed because transparent widgets inside a `SliverAppBar` don't register taps reliably without explicit hit-test behaviour.

### Solution
Replaced with `InkWell` (more reliable in Material context than `GestureDetector` for AppBar actions) and added `import 'profile_screen.dart'`.

### Prevention
- Always use `InkWell` (not `GestureDetector`) for tappable widgets inside AppBar `actions`.
- After fixing, do a **full hot restart (`R`)** — hot reload alone may not rebuild the AppBar widget tree on device.

---

<!-- Add new bugs above this line -->