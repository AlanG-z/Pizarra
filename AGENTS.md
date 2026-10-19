# AGENTS.md

## Project

`pizarra` (app name "Pizarra") is a multi-game scorekeeper for Argentine card games.
`InicioPage` (home, title "PIZARRA") lets you pick the game; each game has its own
setup + score pages. All user-facing strings are in Spanish.

## Commands

- `flutter pub get` first; `pubspec.lock` is committed — don't run `flutter pub upgrade`
  casually.
- `flutter test` (widget tests only, no unit/integration tests).
- Single test file: `flutter test test/widget_test.dart`.
- `flutter analyze` — uses `flutter_lints` via `analysis_options.yaml`; excludes
  `build/`, `android/`, `web/`, `linux/`. Keep it clean.
- Platforms: only `linux`, `web`, `android` have platform dirs (no iOS/macOS/Windows).
  Run with e.g. `flutter run -d linux`.

## Structure

- `lib/main.dart` → `lib/src/app.dart` (`MyApp`, Material 3, seed `0xFF0B3D2E`).
  Routes come from `lib/src/routes/reoutes.dart` (`getAplicationRoutes()`): `/` →
  `InicioPage` (game picker), `/setup` → Truco, `/chinchon-setup` → Chinchón.
- `lib/src/pages/truco/` — Truco: `setup_page.dart`, `score_page.dart`, `style_page.dart`.
- `lib/src/pages/chinchon/` — Chinchón: `setup_page.dart`, `score_page.dart`.
- `assets/static.png` — source app icon (2000×2000). Registered in `pubspec.yaml`;
  Android launcher icons generated under `android/app/src/main/res/mipmap-*`,
  web icons under `web/icons/`.
- Pages import each other by package path (e.g.
  `package:pizarra/src/pages/truco/setup_page.dart`). `PlayingCardsIcon` is defined
  in `truco/setup_page.dart` and reused by the picker and Chinchón setup.
- The package was renamed `truccapp` → `pizarra` (pubspec `name`, all imports,
  MaterialApp title, Android namespace/applicationId `com.example.pizarra`, web
  manifest/title, Linux BINARY_NAME/APPLICATION_ID). IDE files (`pizarra.iml`,
  `.idea/modules.xml`) and `build/`/`.dart_tool/` artifacts still reference the old
  name — they regenerate; don't hand-edit them.
- Both setup pages (Truco and Chinchón) have an AppBar with a back arrow that
  returns to the picker. Score pages also expose a back button
  (`pushNamedAndRemoveUntil('/', ...)`).

## Conventions and gotchas

- UI strings, including test expectations, are in Spanish (e.g. "TRUCO", "COMENZAR",
  "punto"/"puntos", default teams "Nosotros"/"Ellos"/"Verde").
- Team columns are wrapped in `Semantics` with `ValueKey('team-column-N')` (N = 0,1,2);
  their `Semantics.value` is the score text. Widget tests must call
  `tester.ensureSemantics()` / `semantics.dispose()` and read scores via
  `tester.getSemantics(find.byKey(const ValueKey('team-column-N'))).value`.
- Tests exercise `ScorePage` directly: pump it inside a `MaterialApp` with
  `teamAName`, `teamBName`, `playersPerTeam` (2 or 3) — `playersPerTeam == 3` adds a
  third green team and hides the `+3` button.
- Scoring model: target 30; each team column shows 6 squares of 5 points split
  "malas"/"buenas"; controls are `-1`, `+2`, `+3` (Truco/Envido values); tapping a
  column adds 1. Scores clamp to `[0, 30]`.
- `_MatchSquare` animation: adding points pops the square in (`forward(from: 0)`);
  removing points must keep it fully visible (`_controller.value = 1.0`). Never
  `reverse()` on subtraction — it fades the whole square out.
- Team colors: red `0xFFE53935`, blue `0xFF42A5F5`, green `0xFF43A047`,
  accent `0xFFFFD54F`.
- Chinchón: individual game, 2–6 players. It's elimination-style — reaching the
  limit (default 100, configurable as "Puntos de eliminación") eliminates the
  player ("¡Eliminado!" dialog, 💀, greyed column, buttons hidden); the last player
  standing wins ("¡Ganador!", "Quedó último en pie"). Winner/elimination dialogs
  offer Revancha / Nueva partida / Continuar, like Truco's.
- Chinchón display: one vertical column per player — name on top, directly below
  it the buttons (`+` and `-10`, always stacked one above the other regardless of
  player count), then the big total, then the divider and the ledger of entries
  (`+N` green / `-N` red) growing downward (oldest top, newest at the bottom,
  auto-scrolled via a per-column `ScrollController`). Totals may go negative
  (no clamp) since corrections are user-driven.
- Chinchón `-10` button: each tap immediately deducts 10 from the player's total
  (the counter reflects it right away, even going negative) and appends a `-10`
  ledger entry. No accumulation/merging. Sums via the "+" dialog
  (`ValueKey('points-field')`, keyboard input, chips 0/+5/+10/+20, "Cerró (0)")
  are recorded as their own `+N` entries.
- Chinchón widget keys: player columns `ValueKey('chinchon-player-N')`
  (`Semantics.value` = "<total> punto(s)"), Anotar buttons `ValueKey('add-points-N')`,
  `-10` buttons `ValueKey('subtract-ten-N')`, ledger entries
  `ValueKey('chinchon-entry-<player>-<index>')` (index 0 = oldest). Player names
  default to colors: Rojo/Azul/Verde/Amarillo/Naranja/Rosa (6-color
  palette, reused for player index modulo 6). Totals clamp at 0.
- Page transitions use a custom fade-only `PageTransitionsTheme`
  (`_FadePageTransitionsBuilder` in `lib/src/app.dart`) on all platforms — the
  default zoom/slide builders cause a white flash between routes. Don't remove
  the theme entry.
