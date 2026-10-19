# Pizarra

Scorekeeper app for Argentine card games, built with Flutter.

## What it does

Pizarra lets you keep score of two card games popular in Argentina:

- **Truco** — team-based scorekeeper for 2 or 3 players per side. Track points
  with tap controls (+2, +3, -1, tap column for +1), animated stick squares,
  and a style page. First team to 30 wins.
- **Chinchón** — individual scorekeeper for 2–6 players. Elimination-style:
  players try NOT to reach 100 points (configurable limit). The last player
  standing wins. Round points via keyboard input (+), corrections with the
  -10 button, and a per-player ledger showing all moves like a running account.

## Tech Stack

- **Flutter** 3.47+ (Dart 3.13+) — single codebase for Android, Linux, and Web
- **Material 3** design with custom theme (dark green seed)
- No external state management — plain `StatefulWidget`
- No external dependencies beyond `cupertino_icons` and `flutter_lints`
- Custom `PageTransitionsTheme` (fade-only) for smooth navigation

## Project Structure

```
lib/
├── main.dart                    # Entry point
└── src/
    ├── app.dart                 # MaterialApp, theme, routes
    ├── routes/reoutes.dart      # Named route map
    └── pages/
        ├── inicio_page.dart     # Game picker (home)
        ├── truco/               # Truco setup, score, style pages
        └── chinchon/            # Chinchón setup, score pages
```

## Getting Started

```bash
flutter pub get
flutter test
flutter analyze
flutter run -d linux   # or -d chrome, -d emulator
```

## Building for Release

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Or split by ABI for smaller downloads:

```bash
flutter build apk --split-per-abi --release
# Output: build/app/outputs/flutter-apk/app-{arm64-v8a,armeabi-v7a,x86_64}-release.apk
```

### Android App Bundle (for Google Play)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Web

```bash
flutter build web --release
# Output: build/web/
```

## Platforms

| Platform | Status      |
|----------|-------------|
| Android  | ✅ Supported |
| Linux    | ✅ Supported |
| Web      | ✅ Supported |
| iOS      | ⚠️ Not configured (no platform dir) |
| Windows  | ⚠️ Not configured |
| macOS    | ⚠️ Not configured |

## App Icon

`assets/static.png` (2000×2000) is the source icon. It is registered in
`pubspec.yaml` and used directly as the Android launcher icon (all density
buckets generated under `android/app/src/main/res/mipmap-*`) and as the web
favicon.

## License

Private project — not intended for distribution.
