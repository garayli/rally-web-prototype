# Key Facts

Project configuration, credentials, and constants.

## Supabase Configuration

| Key | Value |
|-----|-------|
| `supabaseUrl` | (fill in) |
| `supabaseAnon` | (fill in) |
| Redirect URL | `io.supabase.rallly://login-callback/` |

## Build Configuration

| Item | Value |
|------|-------|
| Flutter Project | `rallly_flutter/` |
| Min Android SDK | 21 |
| Target Android SDK | 34 |

## Firebase / Google Cloud

| Item | Value |
|------|-------|
| Project ID | `rallymatch` (owner: the Google account used for `firebase login` / `gcloud auth login`) |
| Android package | `com.rallymatch.app` |
| Config files | `rallly_flutter/lib/firebase_options.dart`, `rallly_flutter/android/app/google-services.json` — **gitignored** (GitHub secret scanning flagged the keys in commit `489ab8f`). Regenerate with `flutterfire configure`; placeholder template at `lib/firebase_options.dart.example` |
| Keys console | https://console.cloud.google.com/apis/credentials?project=rallymatch (sign in as the owner account) |

### API key restrictions

Firebase client keys aren't real secrets, but they must be restricted so a key copied from git history is useless elsewhere. All three keys have a Firebase-only API allowlist. App restrictions as of 2026-09-21:

| Key | App restriction |
|-----|-----------------|
| Android | package `com.rallymatch.app` + the debug and upload SHA-1s |
| iOS | **none** — set once the iOS bundle ID is final (no Xcode project yet; `firebase_options.dart` says `rallymatch`) |
| Browser | **none** — no domain yet. Add HTTP referrers when the web build is hosted, or delete the key if web is never shipped |

Key IDs and fingerprint values are deliberately not recorded here. Look up key IDs with `gcloud services api-keys list --project=rallymatch --format="table(displayName,uid)"`, and see what the Android key allows with `gcloud services api-keys describe <KEY_ID> --project=rallymatch --format="yaml(restrictions.androidKeyRestrictions)"`.

SHA-1 fingerprints the Android key allows, and where each comes from (`keytool` is in `C:\Program Files\Android\Android Studio\jbr\bin\` and is not on PATH):

| Certificate | How to get its SHA-1 |
|-------------|----------------------|
| Debug (this PC) | `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android` |
| Upload | `keytool -list -v -keystore android/app/upload-keystore.jks -alias upload` (password is in `android/key.properties`) |
| **Play app signing** | **⚠ NOT ADDED YET — required at first Play upload (below)** |

A different PC has a different debug keystore, so its debug builds are blocked until that machine's SHA-1 is added too.

#### ⚠ At first Play Store upload: add Play's app-signing SHA-1

Google Play re-signs every build it distributes (internal-testing track included) with its own certificate, so Play-installed builds carry a SHA-1 the Android key does not allow yet. Firebase calls from those builds fail with `403 Requests from this Android client application … are blocked`, while sideloaded builds signed with the debug/upload key keep working — so it stays invisible until testers install from Play.

1. Play Console → your app → Test and release → App integrity → Play app signing → copy the SHA-1 of the **App signing key certificate** (menu names shift between Console versions).
2. Add it to the Android key. Pass all three fingerprints (the update sets the whole list; lowercase hex, no colons):

   ```bash
   KEY_ID=$(gcloud services api-keys list --project=rallymatch --filter="displayName:Android" --format="value(uid)")
   gcloud services api-keys update "$KEY_ID" --project=rallymatch \
     --allowed-application=sha1_fingerprint=<DEBUG_SHA1>,package_name=com.rallymatch.app \
     --allowed-application=sha1_fingerprint=<UPLOAD_SHA1>,package_name=com.rallymatch.app \
     --allowed-application=sha1_fingerprint=<PLAY_SHA1>,package_name=com.rallymatch.app
   ```

   Or in the Console: Credentials → Android key → Application restrictions → Add an item.
3. Install from the Play track and confirm Firebase events arrive, then update the table above.

## External Resources

| Resource | URL |
|----------|-----|
| InstrumentSerif Font | Google Fonts |
| Plus Jakarta Sans | Google Fonts |

## Figma MCP

| Key | Value |
|-----|-------|
| Account | leyla.garayli@gmail.com |
| Team | Lei La's team (Starter plan) |
| Seat | View (read-only) |
| Token scope | Read only — write-back unavailable on free plan |
| Token storage | Environment variable `$env:FIGMA_TOKEN` in local scripts only — never commit |

## Connected Devices

| Device | ID |
|--------|----|
| SM A566B (Android 16) | `R5CY41DEJZZ` |

---

## Supabase Table Schemas

### `matches`
| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid | PK, default `gen_random_uuid()` |
| `player1_id` | uuid | Requester — FK → `profiles.id` (NOT auth.users) |
| `player2_id` | uuid | Opponent — nullable (mock IDs not UUIDs, see ADR-005) |
| `date_time` | timestamptz | NOT NULL |
| `court` | text | NOT NULL |
| `status` | enum | `'pending'` \| `'confirmed'` \| `'completed'` \| `'cancelled'` |
| `format` | enum | `'singles'` \| `'doubles'` |
| `winner_id` | uuid | nullable FK → `profiles.id` — set on match completion |
| `sets` | jsonb | nullable — set scores |
| `rating_delta` | real | nullable |
| `opponent_name` | text | nullable — unregistered opponent display name |
| `opponent_phone` | text | nullable — unregistered opponent phone (min 10 digits) |
| `created_at` | timestamptz | auto |
| `updated_at` | timestamptz | auto |

### `lobbies`
| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid | PK, default `gen_random_uuid()` |
| `creator_id` | uuid | FK → `auth.users`, NOT NULL |
| `sport` | text | `'Tenis'` \| `'Padel'` \| `'Badminton'` \| `'Squash'` |
| `skill_level` | text | `'Her seviye'` \| `'Başlangıç'` \| `'Orta Seviye'` \| `'İleri Seviye'` |
| `date_time` | timestamptz | NOT NULL |
| `court` | text | NOT NULL |
| `notes` | text | nullable |
| `is_public` | bool | NOT NULL, default true |
| `status` | text | `'open'` \| `'full'` \| `'cancelled'`, default `'open'` |
| `created_at` | timestamptz | auto |
RLS: anyone can SELECT where `is_public=true AND status='open'`; only `creator_id=auth.uid()` can INSERT/UPDATE.

### `messages`
| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid | PK |
| `sender_id` | uuid | FK → `profiles.id` |
| `receiver_id` | uuid | Nullable FK → `profiles.id` (see ADR-004) |
| `text` | text | |
| `timestamp` | timestamptz | |
| `is_read` | bool | default false |

---

---

## Key Dependencies (non-obvious)

| Package | Version | Purpose |
|---------|---------|---------|
| `shared_preferences` | ^2.2.0 | Persists per-tab onboarding seen-state (`onboarding_seen` key, `List<String>` of tab indices) |
| `flutter_animate` | ^4.5.0 | Fade/slide animations on cards and overlays |
| `flutter_map` | ^6.0.1 | Map screen (OpenStreetMap tiles) |

---

## Notes

- Update this file when configuration changes
- Never commit actual credentials to version control