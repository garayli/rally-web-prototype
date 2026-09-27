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

## Match Request Not Persisted to Supabase
**Date:** 2026-05-09
**Severity:** High

### Problem
Tapping "İstek Gönder" (Send Request) in the match request bottom sheet showed the success state UI but the Supabase `matches` table remained empty after every request.

### Root Cause
The button handler in `_RequestSheetState` only called `setState(() => _sent = true)` and `widget.onSent()` — no Supabase insert was ever made. The sent-state tracking existed purely in memory.

### Solution
- Extracted an async `_sendRequest()` method on `_RequestSheetState`
- Calls `supabase.from('matches').insert({requester_id, opponent_id, status: 'pending', format, court, proposed_time})`
- On success: updates state, calls `widget.onSent()`, pops sheet, shows snackbar
- On failure: reverts `_loading` to false, shows error snackbar with reason
- Button shows `loading: true` while the request is in flight
- Added `import '../main.dart' show supabase;` to `match_screen.dart`

### Prevention
Any "send" / "submit" action that is supposed to persist data must call Supabase (or the data service) — UI-only state changes are not a substitute.

---

## Lobby Card Bottom Overflow (Match Screen)
**Date:** 2026-05-09
**Severity:** Low

### Problem
"Bottom Overflowed by 3.0 pixels" rendered on the Match screen after the Açık Lobiler horizontal card section was added.

### Root Cause
`_LobbyCard` used `Spacer()` inside its Column to push the "Katıl" button to the bottom. The Column's height is constrained by the `SizedBox(height: 180)` ListView minus its vertical padding — the card content was already within ~3px of that limit, so the Spacer caused an overflow rather than expanding to fill space.

### Solution
Replaced `const Spacer()` with `const SizedBox(height: 8)` in `_LobbyCard`. The button now sits a fixed 8px below the last content line; the Column is purely content-sized.

### Prevention
Never use `Spacer()` inside a Column that lives inside a height-constrained horizontal `ListView`. The cross-axis height is fixed — `Spacer` doesn't help here and will overflow if content is close to the boundary. Use a fixed `SizedBox` gap instead.

---

## Log Result — Guest Opponent Columns Not Found
**Date:** 2026-05-15
**Severity:** High

### Problem
Saving a match result with an unregistered (guest) opponent always failed. The error was "column not found in schema cache" for `opponent_name` / `opponent_phone`.

### Root Cause
The migration to add `opponent_name` and `opponent_phone` to the `matches` table was designed but never executed. The Flutter code (including the `if (_guestMode) ...{}` conditional guard) was correct, but PostgREST rejects any insert that references a column that does not yet exist in the DB, regardless of guards on the Flutter side.

### Solution
- Ran `apply_migration` to add `ALTER TABLE public.matches ADD COLUMN IF NOT EXISTS opponent_name text, ADD COLUMN IF NOT EXISTS opponent_phone text`
- Followed with `NOTIFY pgrst, 'reload schema'` to flush the PostgREST schema cache
- Verified columns exist via `list_tables` (verbose=true) before retesting

### Prevention
Always run DDL migrations before writing (or testing) Flutter code that references new columns. Verify with `list_tables` (verbose=true). A conditional guard on the Flutter side does not protect against referencing a column that doesn't exist — PostgREST validates the schema at insert time regardless.

---

## OTP emails only deliver to the project owner's own address
**Date:** 2026-09-13
**Severity:** High (blocks all multi-account testing)

### Problem
Login/signup on a real device failed for every email except `leyla.garayli@gmail.com`. The app only showed a generic "Bir şeyler yanlış gitti. Lütfen tekrar deneyin." with no useful detail.

### Root Cause
Supabase's email sending is configured through Resend, which is on the free/testing tier: it only allows sending to the account owner's own verified email address until a domain is verified at resend.com/domains. Every other recipient gets a 550 SMTP rejection. This was only visible in Supabase's own auth logs (`mcp__supabase__query_logs`, `source = 'auth_logs'`) — the Flutter client only ever saw a generic `AuthException`, and `auth_screen.dart`'s `_translateError()` had a catch-all fallback that discarded the real message before it ever reached a log line.

### Solution
Not yet fixed — needs a verified domain on Resend (resend.com/domains: add the DNS records they provide, wait for verification) and then updating the "from" address in Supabase Dashboard → Project Settings → Auth → SMTP Settings to use that domain. Added a `debugPrint('OTP SEND AUTH ERROR: ...')` in the `AuthException` catch branch of `auth_screen.dart` so the real message surfaces in the Flutter logs next time, instead of requiring a trip to the Supabase auth logs.

### Prevention
When any auth/email-triggered flow silently fails in the UI with a generic error, check `mcp__supabase__query_logs` (`source = 'auth_logs'`) before assuming it's a Flutter-side bug — Supabase's own auth service logs the real SMTP/provider error even when the client only receives a generic `AuthException`. Don't let translation/fallback error-message functions swallow the original message without at least logging it.

---

## Match Requests Never Reach the Opponent (No Notification)
**Date:** 2026-09-27
**Severity:** Critical

### Problem
Two-account test: phone signed in as leyla.garayli@gmail.com, Chrome as leila.rhcp@gmail.com. A match request was sent from each side, and neither side ever got a notification or saw the request.

### Root Cause
Three separate causes:
1. **Three of the four "Maç İste" buttons were fake.** `PlayerProfileScreen`, `ConversationScreen` (app-bar tennis icon) and `MapScreen`'s player sheet only showed a "maç isteği gönderildi!" snackbar. Nothing was written to `matches` or `notifications`. Only the Match tab's `_RequestSheet` called `dataService.sendMatchRequest()`.
2. **The receiver never re-read notifications.** `MockDataService` fetched them in its constructor, which can run before login (`uid == null` → cached empty list). After that it only fetched them in `NotificationsScreen.initState`, which runs once because `IndexedStack` keeps the tab mounted. `warmCache()` didn't include notifications. So a notification inserted while B was already in the app never reached B's badge or list.
3. **No live refresh of any kind.** `warmCache()` ran once in `MainShell.initState`. Nothing re-read `matches`/`notifications` afterwards, and there's no Supabase Realtime subscription.

Also found: the notification's Kabul/Reddet buttons only changed local widget state. `matches.status` stayed `pending`, and the choice was lost on reload.

### Solution
- Moved the sheet to `lib/widgets/match_request_sheet.dart` (`MatchRequestSheet` + `showMatchRequestSheet()`). All four entry points now use it.
- `warmCache()` now also runs `_refreshNotifications()`.
- Added `DataService.refreshLive()`. It re-fetches conversations, sessions and notifications and bumps `cacheVersion` only when a signature of the data actually changed. `MainShell` polls it every 10s while in the foreground, stops on `paused`, and refreshes right away on `resumed`. `NotificationsScreen` listens to `cacheVersion` and reloads silently.
- Added `DataService.respondToMatchRequest()`. It updates `matches.status` (confirmed/cancelled) with `.select('id')`, so an RLS-blocked update (0 rows, no error) throws instead of passing silently. It then rewrites the notification to `matchConfirmed`/`matchDeclined`, so the buttons don't come back on reload.

### Prevention
- Never ship a button whose only effect is a success snackbar. Grep for the snackbar text when auditing a flow end-to-end.
- Any data another user can change must be re-read after login (polling or Realtime), not only at shell init.
- Verified in the DB on 2026-09-27: (a) the matchRequest notifications INSERT policy is live; (b) `matches` has a "Match participants can update" policy (player1 OR player2); (c) the `notif_type` enum includes `matchConfirmed`/`matchDeclined`, and users can update their own notifications. No migration needed. So the "no notification" bug came from the app side: fake buttons plus the missing refresh.

---

## Chat Messages "Disappear" for the Sender and Never Reach the Receiver Live
**Date:** 2026-09-27
**Severity:** Critical

### Problem
The same two accounts messaged each other:
- "Merhaba" showed up for the receiver about 20s later.
- After the sender left the chat and came back, "Merhaba" was gone on the sender's side.
- The second message never appeared for the receiver.
- The sender's Mesajlar inbox stayed empty. The receiver's inbox only ever showed "Merhaba".

### Root Cause
- **Stale, write-once cache.** `_refreshConversations()` only ran in `warmCache()` at `MainShell` init. `ConversationScreen._send()` inserted the row but never refreshed the cache, so the sender's inbox didn't know the thread existed.
- **Chat screen seeded from a snapshot.** `ConversationScreen` copied `widget.conversation.messages` into local state. Opened from a profile, that is a throwaway `Conversation(id: 'new_…', messages: [])`. The sent message lived only in that widget's state and was gone once the screen was popped, so on reopen it looked deleted.
- **No refresh on the receiving side.** Same as the match-request bug: no polling and no Realtime. The receiver only saw "Merhaba" because their session re-ran `warmCache()` (reload/re-login). They never refreshed again, so the second message never arrived.
- **Send errors were swallowed.** `catch (_) {}` around the insert meant a failed insert looked the same as a successful one. We can't rule out that the second message failed too.

### Solution
- Added `DataService.sendMessage()`. It inserts the message, then re-reads conversations and bumps `cacheVersion`. It throws on a failed insert. A failed re-read after a successful insert is only logged, so the user never retries a message that was already delivered.
- `ConversationScreen` now treats the DataService cache as the source of truth. It listens to `cacheVersion` and merges the cached thread (matched by `other.id`, so a `new_…` conversation picks up its thread once it exists) with local pending messages. While open it polls `refreshLive()` every 4s. Failed sends show `error_outline` and a snackbar, and tapping the bubble retries.
- `_refreshConversations()` uses a fetch sequence number, so a poll that started before a send can't overwrite the newer post-send result. The inbox is now sorted by latest message.

### Prevention
- Never `catch (_) {}` around a write the user is waiting on. Surface the error and let them retry.
- A screen must not keep a private copy of shared data. Read it from DataService and listen to `cacheVersion`.
- Follow-up: replace polling with Supabase Realtime once `messages`/`notifications` are confirmed to be in the `supabase_realtime` publication.

---

## New Signups Create No Profile Row (`initials` NOT NULL)
**Date:** 2026-09-27
**Severity:** Critical

### Problem
The web log showed `SIGNUP PROFILE SAVE ERROR: null value in column "initials" of relation "profiles" violates not-null constraint (23502)`. Signup still "completed" in the UI, but no `profiles` row was created.

### Root Cause
`SignupScreen._finish()`'s upsert never sent `initials`, and `profiles.initials` is NOT NULL. The error was only `debugPrint`ed and `onComplete()` ran anyway. With no profile row, the user fails the `matches.player1_id`/`messages.sender_id` FKs (→ `profiles.id`), is missing from other users' player lists, and `updateMyProfile()` (an UPDATE) matches 0 rows and silently does nothing.

### Solution
Moved the private `_initialsOf` out of `data_service.dart` into `lib/utils/initials.dart` as `initialsOf()`. The signup upsert now sends `'initials': initialsOf(name)`. Accounts that already failed signup have to redo the "Kayıt ol" flow (the upsert is idempotent) or get their profile row added by hand.

### Prevention
Before writing a `profiles` insert/upsert, check the NOT NULL columns (`list_tables` verbose). Signup must not call `onComplete()` when the profile save failed.

---

## Profile Not Editable After Signup
**Date:** 2026-09-27
**Severity:** High

### Problem
After the signup wizard, users could never change their name, location, sports, level or availability again.

### Root Cause
Every entry point on `ProfileScreen` was fake and only showed a "Profil düzenleme yakında" snackbar: the hero "Profili Düzenle" button, the completeness banner and the HESAP → "Profili Düzenle" row. "Müsaitlik" said "Müsaitlik ayarları yakında". No edit screen existed. `Player` didn't even carry the signup fields (`sports`, `skill_level`, `available_days`, `time_prefs`), so nothing could be pre-filled.

### Solution
- New `lib/screens/edit_profile_screen.dart` (`EditProfileScreen`). It edits name, location, bio (`about`), sports, level, days and time of day, pre-filled from `dataService.getCurrentPlayer()`. Save is disabled while name or location is empty. It pops `true` on success, and a failed save shows an error snackbar instead of being swallowed.
- `DataService.updateMyProfile()` updates `profiles` (and `initials` from the name), then re-reads the current player and bumps `cacheVersion`. `ntrp_rating` is reset from the level **only when the level changed**, so editing the bio doesn't wipe a rating earned in matches.
- `Player` gained `sports`, `skillLevel`, `availableDays` and `timePrefs` (fromJson/toJson, with empty defaults).
- The option lists and `ntrpBySkillLevel` moved to `lib/config/profile_options.dart`, shared by `SignupScreen` and `EditProfileScreen`, so both write identical values. Signup had two drifting copies of each list, and some were unused.
- All four profile entry points above now open the editor. If the profile isn't loaded yet, the user gets a "Profil yükleniyor" snackbar and `warmCache()` is retried.

### Prevention
- Same lesson as the match-request bug: grep for "yakında" snackbars when auditing a flow. A button that only shows a snackbar is not a feature.
- Any value a wizard writes must also be readable into the model, or it can never be edited later.
- **Open:** `updateMyProfile()` doesn't use `.select()`, so an UPDATE that matches 0 rows (missing profile row, see the `initials` bug above, or RLS) "succeeds" silently. Add `.select('id')` and throw on an empty result, as `respondToMatchRequest()` does.

---

## Profile Screen Didn't Show Saved Availability / Bio
**Date:** 2026-09-27
**Severity:** Medium

### Problem
On the S25 Ultra the user edited their availability, saved (no error in logcat), and saw no change on the profile screen.

### Root Cause
The save worked, but `ProfileScreen` never rendered the data:
- The "Müsaitlik" row subtitle was the static text "Haftalık programını ayarla".
- `about` was not shown anywhere.
- The completeness banner and avatar ring were hardcoded (`_completeness = 65`, `_missingFields = ['fotoğraf', 'biyografi', 'müsaitlik']`), so they said "müsaitlik" was missing whatever the user saved.

### Solution
- "Müsaitlik" subtitle → `_availabilitySummary(me)`, e.g. "Pzt, Çar, Cmt · Akşam". `EditProfileScreen` saves days and times in canonical option order, so the summary reads naturally.
- The bio is shown under the location in the hero (max 3 lines).
- The completeness score and missing list are computed from the real `Player` (`_missingFieldsOf`, `_completenessOf`). The banner hides itself once nothing is missing. The photo is deliberately not counted until upload exists, so the banner never asks for something the user can't provide.

### Prevention
When adding an editor for a field, check that some screen actually displays that field. Never hardcode completeness or "missing" state; derive it from the model.

---

## Phone Kept Running a Stale Build After `flutter run`
**Date:** 2026-09-27
**Severity:** Low (dev environment)

### Problem
The user ran `flutter run` after the profile-edit changes and saw "nothing changed". The old "yakında" behaviour was still on the phone.

### Root Cause
No new build was made. `build/app/outputs/flutter-apk/app-debug.apk` was timestamped 20:17, before the edits at 20:39–20:45. An earlier `flutter run` session was most likely still attached, so the phone kept running the old code.

A related hazard came up the same evening. A `flutter build`/`run` started at 22:10 failed with `getCurrentPlayer isn't defined`. Another session had just run `git checkout main` + `pull` and re-applied the uncommitted changes, and the compile landed in the moment the files were reverted.

### Solution
- Quit the old session (`q`) and run `flutter run` again, or press `R` (hot restart; `r` isn't enough when a service interface changes). Confirm with `adb shell dumpsys package com.rallymatch.app | grep lastUpdateTime`.
- A backgrounded `flutter run` (no stdin) exits once the app is installed ("Lost connection to device"). The app keeps running, but hot reload is gone. For the web, `flutter build web` + a static server (`python -m http.server 8080` in `build/web`) is more reliable than a detached `flutter run -d chrome`.

### Prevention
- When "nothing changed" on device, compare the APK / `lastUpdateTime` timestamp with the source edit time before debugging code.
- Don't run two agents or sessions against the same working tree at once. A branch switch in one breaks builds and edits in the other.

---

<!-- Add new bugs above this line -->

## OTP Screen Overflows When Keyboard Is Open
**Date:** 2026-09-27
**Severity:** Low

### Problem
On the S25 Ultra, the OTP entry screen ("E-postanı kontrol et") threw "A RenderFlex overflowed by 5.5 pixels on the bottom" (yellow/black stripe) once the number keyboard opened.

### Root Cause
`_AuthOtpScreenState.build()` in `auth_screen.dart` used a fixed `Padding > Column` inside `SafeArea`. With the keyboard up the body shrank to ~384px, shorter than the Column's natural height.

### Solution
Swapped `Padding` for `SingleChildScrollView(padding: EdgeInsets.all(28))`. The Column has no `Expanded`/`Spacer` children, so layout is unchanged when there's room.

### Prevention
Any form screen with a text field needs a scrollable body. The email screen in the same file already does this (`Expanded > SingleChildScrollView`).
