# AGENTS.md

## Project

`pizarra` (app name "Pizarra") is a multi-game scorekeeper for Argentine card games.
`InicioPage` (home, title "PIZARRA") lets you pick the game; each game has its own
setup + score pages. All user-facing strings are in Spanish.

## Commands

- `flutter pub get` first; `pubspec.lock` is committed — don't run `flutter pub upgrade`
  casually.
- `flutter test` — unit tests (`test/models/`, `test/services/`) plus widget tests
  (`test/widget_test.dart`, `test/resume_test.dart`).
- Single file: `flutter test test/widget_test.dart`; single group/test:
  `flutter test --plain-name "TrucoGame"`.
- `flutter analyze` — uses `flutter_lints` via `analysis_options.yaml`; excludes
  `build/`, `android/`, `web/`, `linux/`. Keep it clean.
- CI: `.github/workflows/ci.yml` runs `flutter analyze` + `flutter test` on every
  push/PR with Flutter `3.47.7`.
- Platforms: only `linux`, `web`, `android` have platform dirs (no iOS/macOS/Windows).
  Run with e.g. `flutter run -d linux`.

## Structure

- `lib/main.dart` → `lib/src/app.dart` (`MyApp`, Material 3, seed `0xFF0B3D2E`).
  `main()` is async: it awaits `GameStorage.init()` before `runApp`. Routes come
  from `lib/src/routes/routes.dart` (`getApplicationRoutes()`): `/` → `InicioPage`
  (game picker), `/setup` → Truco, `/chinchon-setup` → Chinchón.
- `lib/src/models/` — pure Dart scoring logic, no Flutter widgets:
  - `truco_game.dart` (`TrucoGame`): team names, scores, `target` 30, `addPoints`,
    `subtractPoint`, `pointsInSquare`, `winnerIndex`, `hasProgress`, JSON.
  - `chinchon_game.dart` (`ChinchonGame`): players, totals, `moves` (ledger of int
    deltas), `eliminated`, `addPoints` (returns true when it eliminates),
    `subtractTen`, `lastStandingIndex`, `hasProgress`, JSON.
  - `truco_style.dart` (`StyleSettings`, `StickStyle`): colors and stick style,
    JSON (`toARGB32()` for colors).
- `lib/src/services/game_storage.dart` (`GameStorage.instance`) persists the
  in-progress match and the Truco style in `shared_preferences` as JSON. It needs
  `await GameStorage.init()`; if it was not initialized (e.g. a widget test that
  doesn't test persistence) reads return `null` and writes are no-ops.
- `lib/src/pages/truco/` — Truco: `setup_page.dart`, `score_page.dart`, `style_page.dart`.
- `lib/src/pages/chinchon/` — Chinchón: `setup_page.dart`, `score_page.dart`.
- `assets/static.png` — source app icon (2000×2000). Registered in `pubspec.yaml`;
  Android launcher icons generated under `android/app/src/main/res/mipmap-*`,
  web icons under `web/icons/`.
- Pages import each other by package path (e.g.
  `package:pizarra/src/pages/truco/setup_page.dart`). `PlayingCardsIcon` is defined
  in `truco/setup_page.dart` and reused by the picker and Chinchón setup.
- Android `namespace`/`applicationId` and Linux `APPLICATION_ID` are
  `io.github.alangz.pizarra`; the Kotlin activity lives under
  `android/app/src/main/kotlin/io/github/alangz/pizarra/`. The application ID is
  irreversible once published on Google Play — don't change it casually.
- The package was renamed `truccapp` → `pizarra` (pubspec `name`, all imports,
  MaterialApp title, web manifest/title, Linux BINARY_NAME). `.idea/` and `*.iml`
  are gitignored and untracked (they may still hold stale local names — they
  regenerate; don't hand-edit them). `build/` and `.dart_tool/` artifacts also
  regenerate.
- Both setup pages (Truco and Chinchón) have an AppBar with a back arrow that
  returns to the picker. Score pages also expose a back button
  (`pushNamedAndRemoveUntil('/', ...)`).

## Persistence

- `ScorePage` and `ChinchonScorePage` take a `resume` flag (default `false`).
  With `resume: true` they load the saved game from `GameStorage` (only if the
  team/player count matches); with `false` they start fresh and immediately
  overwrite the saved game.
- `InicioPage` is stateful: it reads the saved games in `initState` and shows the
  `PARTIDAS EN CURSO` section with "Continuar Truco" / "Continuar Chinchón" only
  when the saved game `hasProgress` (any score/total/move). Resuming passes the
  saved names/target plus `resume: true`.
- Every mutation calls `_persist()`; reset and "Nueva partida" persist too.
- A finished game stays saved; on resume the winner dialog is not shown again
  (`_winnerShown` starts as true).
- Storage keys: `pizarra.truco.game.v1`, `pizarra.chinchon.game.v1`,
  `pizarra.truco.style.v1`. Corrupt or old JSON is ignored (`GameStorage._read`
  catches errors and returns `null`).
- The Truco style is a global preference: loaded on every `ScorePage` start and
  saved when the style page returns.
- `shared_preferences` is the only non-Flutter runtime dependency (plus
  `cupertino_icons`).

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
- Truco scoring lives in `TrucoGame`: target 30; each team column shows 6 squares of
  5 points split "malas"/"buenas"; controls are `-1`, `+2`, `+3` (Truco/Envido
  values); tapping a column adds 1. Scores clamp to `[0, 30]` inside the model.
- `_MatchSquare` animation: adding points pops the square in (`forward(from: 0)`);
  removing points must keep it fully visible (`_controller.value = 1.0`). Never
  `reverse()` on subtraction — it fades the whole square out.
- Team colors: red `0xFFE53935`, blue `0xFF42A5F5`, green `0xFF43A047`,
  accent `0xFFFFD54F`.
- Chinchón: individual game, 2–6 players. It's elimination-style — reaching the
  limit (default 100, configurable as "Puntos de eliminación") eliminates the
  player ("¡Eliminado!" dialog, 💀, greyed column, buttons hidden); the last player
  standing wins ("¡Ganador!", "Quedó último en pie"). `ChinchonGame.addPoints`
  returns whether the move eliminated the player; the widget shows the dialog and
  only checks the winner after that dialog closes (otherwise the two dialogs
  would stack).
- Chinchón display: one vertical column per player — name on top, directly below
  it the buttons (`+` and `-10`, always stacked one above the other regardless of
  player count), then the big total, then the divider and the ledger of moves
  (`+N` green / `-N` red) growing downward (oldest top, newest at the bottom,
  auto-scrolled via a per-column `ScrollController`).
- Chinchón totals have **no clamp**: `-10` always deducts from the counter, so a
  total can go negative (user corrections). Invariant: each player's total equals
  the sum of that player's `moves`. `addPoints` doesn't clamp either, so the
  invariant holds — don't reintroduce `clamp(0, ...)`.
- Chinchón `-10` button: each tap immediately deducts 10 from the player's total
  (the counter reflects it right away, even going negative) and appends its own
  `-10` move. No accumulation/merging. Sums via the "+" dialog
  (`ValueKey('points-field')`, keyboard input, chips 0/+5/+10/+20, "Cerró (0)")
  are recorded as their own `+N` moves.
- Chinchón widget keys: player columns `ValueKey('chinchon-player-N')`
  (`Semantics.value` = "<total> punto(s)"), `+` buttons `ValueKey('add-points-N')`,
  `-10` buttons `ValueKey('subtract-ten-N')`, ledger entries
  `ValueKey('chinchon-entry-<player>-<index>')` (index 0 = oldest). Player names
  default to colors: Rojo/Azul/Verde/Amarillo/Naranja/Rosa (6-color palette, reused
  for player index modulo 6).
- `find.text('-10')` is ambiguous in Chinchón tests (the button labels match), so
  assert ledger values through their `ValueKey`s or `tester.widget<Text>(...)`.
- Page transitions use a custom fade-only `PageTransitionsTheme`
  (`_FadePageTransitionsBuilder` in `lib/src/app.dart`) on all platforms — the
  default zoom/slide builders cause a white flash between routes. Don't remove
  the theme entry.
