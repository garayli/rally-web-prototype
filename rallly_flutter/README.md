# 🎾 Rallly — Flutter App

Tennis matchmaking app built with Flutter. Runs on Android and iOS from a single codebase.

---

## Project structure

```
rallly_flutter/
├── lib/
│   ├── main.dart                    # Entry point + auth router
│   ├── theme/
│   │   └── app_theme.dart           # Colors, typography, component themes
│   ├── models/
│   │   └── models.dart              # Player, Match, Notification, Message
│   ├── services/
│   │   └── data_service.dart        # Supabase-backed data layer (single swap point)
│   ├── widgets/
│   │   └── shared_widgets.dart      # PlayerAvatar, SkillBadge, RallyButton…
│   └── screens/
│       ├── landing_screen.dart      # Hero + CTA
│       ├── auth_screen.dart         # Email entry + OTP verification
│       ├── main_shell.dart          # Bottom nav scaffold
│       ├── match_screen.dart        # Player discovery + request sheet
│       ├── player_profile_screen.dart
│       ├── schedule_screen.dart     # Calendar strip + sessions
│       ├── notifications_screen.dart
│       ├── messages_screen.dart     # Inbox + conversation
│       └── profile_screen.dart
├── android/
│   └── app/src/main/AndroidManifest.xml
├── ios/
│   └── Runner/Info.plist
├── assets/
│   └── fonts/                       # Add InstrumentSerif font files here
└── pubspec.yaml
```

---

## Prerequisites

1. **Flutter SDK** ≥ 3.0  
   Install: https://docs.flutter.dev/get-started/install

2. **For Android**: Android Studio + Android SDK (API 21+)

3. **For iOS**: Xcode 15+ (macOS only)

4. **Fonts** — Download and place in `assets/fonts/`:
   - `InstrumentSerif-Regular.ttf`
   - `InstrumentSerif-Italic.ttf`
   
   Get them free from: https://fonts.google.com/specimen/Instrument+Serif

---

## Getting started

```bash
# 1. Navigate into the project
cd rallly_flutter

# 2. Install dependencies
flutter pub get

# 3. Check your setup
flutter doctor

# 4. Run on a connected device / simulator
flutter run

# Run specifically on Android or iOS
flutter run -d android
flutter run -d ios
```

---

## Supabase setup

The app uses Supabase for email OTP authentication (same as your HTML prototype).

### 1. Create a Supabase project at https://supabase.com

### 2. Enable email OTP
- Go to **Authentication → Providers → Email**
- Enable **Email OTP**
- Set OTP length to **6 digits**

### 3. Add your credentials to `lib/main.dart`
```dart
await Supabase.initialize(
  url: 'https://YOUR_PROJECT_REF.supabase.co',
  anonKey: 'YOUR_ANON_KEY',
);
```

### 4. Configure redirect URLs

**Android**: Already set in `AndroidManifest.xml` — add `io.supabase.rallly://login-callback` to your Supabase redirect URLs.

**iOS**: Already set in `Info.plist` — same URL scheme.

In Supabase dashboard:
- **Authentication → URL Configuration → Redirect URLs**
- Add: `io.supabase.rallly://login-callback`

### 5. Replace mock auth calls in `lib/screens/auth_screen.dart`

```dart
// In AuthEmailScreen._submit():
await Supabase.instance.client.auth.signInWithOtp(email: email);

// In AuthOtpScreen._verify():
await Supabase.instance.client.auth.verifyOTP(
  email: widget.email,
  token: _code,
  type: OtpType.email,
);
```

---

## Data layer

`lib/services/data_service.dart` is the single swap point for all data access — screens never
query Supabase directly for players/conversations/sessions/notifications. `MockDataService`
(the only current implementation, despite the name) already reads and writes real Supabase
tables: `profiles`, `matches`, `messages`, `notifications`. `warmCache()` fetches
players/conversations/upcoming sessions once per login and caches them; `cacheVersion`
(a `ValueNotifier<int>`) is bumped on every refresh so screens kept alive by `IndexedStack`
can listen and rebuild when the cache changes (e.g. after `sendMatchRequest`).

---

## Building for release

### Android (APK / AAB)
```bash
# APK (sideloading / testing)
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```
Output: `build/app/outputs/`

### iOS (IPA)
```bash
flutter build ios --release
```
Then open `ios/Runner.xcworkspace` in Xcode to archive and submit.

---

## Color palette

| Token | Hex | Usage |
|---|---|---|
| `accent` | `#5A8A00` | Tennis ball green — primary actions |
| `accent2` | `#C8431A` | Clay red — alerts, secondary |
| `accent3` | `#8DB600` | Bright yellow-green — highlights |
| `bg` | `#F5F0E8` | Cream beige — app background |
| `surface2` | `#EDE8DE` | Slightly darker surface |

---

## Demo credentials

The OTP flow accepts **123456** as a valid code (demo fallback, matches HTML prototype).

---

## What's next

- [ ] Wire up real Supabase queries
- [ ] Implement Elo-based dynamic NTRP rating (post-match result)
- [ ] Log Match Result flow with shareable match card
- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Map view for nearby courts (Google Maps / Mapbox)
- [ ] App icon + splash screen
