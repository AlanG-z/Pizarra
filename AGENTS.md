# AGENTS.md

## Project

`pizarra` (app name "Pizarra") is a multi-game scorekeeper for Argentine card games.
`InicioPage` (home, title "PIZARRA") lets you pick the game; each game has its own
setup + score pages. All user-facing strings are in Spanish.

## Commands

- `flutter pub get` first; `pubspec.lock` is committed — don't run `flutter pub upgrade`
  casually.
- `flutter test` — unit tests (`test/models/`, `test/services/`) plus widget tests
  (`test/widget_test.dart`, `test/resume_test.dart`, `test/theme_test.dart`,
  `test/layout_test.dart`).
  `layout_test.dart` pumps every screen with the 4 themes at 390×844 and 360×640
  and asserts no overflow (`tester.takeException()` is null).
- Single file: `flutter test test/widget_test.dart`; single group/test:
  `flutter test --plain-name "TrucoGame"`.
- `flutter analyze` — uses `flutter_lints` via `analysis_options.yaml`; excludes
  `build/`, `android/`, `web/`, `linux/`. Keep it clean.
- CI: `.github/workflows/ci.yml` runs `flutter analyze` + `flutter test` on every
  push/PR with Flutter `3.47.7`.
- Platforms: only `linux`, `web`, `android` have platform dirs (no iOS/macOS/Windows).
  Run with e.g. `flutter run -d linux`.

## Structure

- `lib/main.dart` → `lib/src/app.dart` (`MyApp`, Material 3). `main()` is async:
  it awaits `GameStorage.init()` and `ThemeController.instance.load()` before
  `runApp`. `MyApp` wraps `MaterialApp` in a `ValueListenableBuilder` on the theme
  and applies `buildAppTheme(themeType)`. Routes come from
  `lib/src/routes/routes.dart` (`getApplicationRoutes()`): `/` → `InicioPage`
  (game picker), `/setup` → Truco, `/chinchon-setup` → Chinchón.
- `lib/src/theme/` — visual system:
  - `app_palette.dart`: `AppThemeType` (felt/chalkboard/paper/amoled), the
    `AppPalette extends ThemeExtension<AppPalette>` semantic palette (background
    gradient, `surface`/`surfaceBorder`, `textPrimary`/`textSecondary`, `divider`,
    `accent`, `red`/`blue`/`green`, `chalk`), `appPalettes` map, `playerColor(i)`
    (6 Chinchón colors), `display(size)` (Patrick Hand) and `buildAppTheme(type)`.
  - `theme_controller.dart`: `ThemeController.instance.theme` (`ValueNotifier`)
    and `select(type)`, which persists the id.
- `lib/src/widgets/` — `app_background.dart` (theme gradient), `fade_slide_in.dart`
  (card entrance), `match_painter.dart` (`MatchStrokesPainter` for Truco strokes,
  `DashedLinePainter` for dividers, `resolveStickColor`).
- `lib/src/models/` — pure Dart scoring logic, no Flutter widgets:
  - `truco_game.dart` (`TrucoGame`): team names, scores, `target` 30, `addPoints`,
    `subtractPoint`, `pointsInSquare`, `winnerIndex`, `hasProgress`, JSON.
  - `chinchon_game.dart` (`ChinchonGame`): players, totals, `moves` (ledger of int
    deltas), `eliminated`, `addPoints` (returns true when it eliminates),
    `subtractTen`, `lastStandingIndex`, `hasProgress`, JSON.
  - `truco_style.dart` (`StyleSettings`, `StickStyle`): `stickStyle`
    (`chalk`/`match`/`stick`/`dot`, default `chalk`) and a nullable `stickColor`
    (`null` = automatic, uses the theme chalk color); JSON via `toARGB32()`.
    There is **no** `backgroundColor` anymore — the background comes from the theme.
- `lib/src/services/game_storage.dart` (`GameStorage.instance`) persists the
  in-progress matches, the Truco style and the theme id in `shared_preferences`
  (theme as a plain string). It needs `await GameStorage.init()`; if it was not
  initialized (e.g. a widget test that doesn't test persistence) reads return
  `null` and writes are no-ops.
- `lib/src/pages/truco/` — Truco: `setup_page.dart`, `score_page.dart`, `style_page.dart`.
- `lib/src/pages/chinchon/` — Chinchón: `setup_page.dart`, `score_page.dart`.
- `assets/static.png` — source app icon (2000×2000). Registered in `pubspec.yaml`;
  Android launcher icons generated under `android/app/src/main/res/mipmap-*`,
  web icons under `web/icons/`.
- `assets/fonts/PatrickHand-Regular.ttf` (+ `OFL.txt`) — bundled handwriting font,
  registered as family `PatrickHand`. Only applied to titles/totals through
  `palette.display(...)`; body text keeps the platform font.
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
  `pizarra.truco.style.v1`, `pizarra.theme.v1`. Corrupt or old JSON is ignored
  (`GameStorage._read` catches errors and returns `null`).
- The Truco style is a global preference: loaded on every `ScorePage` start and
  saved when the style page returns.
- The theme is global too: `ThemeController.select()` stores
  `pizarra.theme.v1`; unknown/missing ids fall back to `AppThemeType.felt`.
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
- Truco drawing: `_MatchSquare` renders `MatchStrokesPainter(points, color, style)`
  on a translucent card; the 7th row is a `DashedLinePainter` between "malas" and
  "buenas". `_ControlButton`s are 56 px tall, filled with the team color at low
  opacity. The bottom action bar is a pill; its `_PillAction`s sit in `Expanded`
  with ellipsized labels so long labels can't overflow.
- `_MatchSquare` animation: adding points pops the square in (`forward(from: 0)`);
  removing points must keep it fully visible (`_controller.value = 1.0`). Never
  `reverse()` on subtraction — it fades the whole square out.
- Colors are never hardcoded in pages: read `AppPalette.of(context)` (falls back to
  the "felt" palette when a test pumps a bare `MaterialApp`, so widget tests keep
  working). Team colors come from `palette.teamColor(0..2)` (red/blue/green);
  Chinchón players from `palette.playerColor(i)` (Rojo/Azul/Verde/Amarillo/
  Naranja/Rosa, index modulo 6). Adding a field to `AppPalette` means updating the
  constructor, `copyWith`, `lerp` and all 4 entries of `appPalettes`.
- Haptics: `HapticFeedback.lightImpact()` when adding Truco points / Chinchón round
  points, `selectionClick()` for `-10`.
- Chinchón: individual game, 2–6 players. It's elimination-style — reaching the
  limit (default 100, configurable as "Puntos de eliminación") eliminates the
  player ("¡Eliminado!" dialog, 💀, greyed column, buttons hidden); the last player
  standing wins ("¡Ganador!", "Quedó último en pie"). `ChinchonGame.addPoints`
  returns whether the move eliminated the player; the widget shows the dialog and
  only checks the winner after that dialog closes (otherwise the two dialogs
  would stack).
- Chinchón display: one vertical column per player, styled as a dark card — name on
  top, directly below it the buttons (`+` filled with the player color, `-10` tonal
  red, always stacked one above the other regardless of player count), then the big
  animated total (`_AnimatedTotal`, `FittedBox` so 3 digits fit), then a dashed
  divider and the ledger of moves as chips (`+N` green / `-N` red) growing downward
  (oldest top, newest at the bottom, auto-scrolled via a per-column
  `ScrollController`).
- Chinchón total color: `textPrimary` below 80 % of the target, `accent` (yellow)
  from 80 %, and `red` at/over the target or when eliminated.
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
  Ledger entries live in `_LedgerChip` widgets.
- Page transitions use a custom fade-only `PageTransitionsTheme`
  (`FadePageTransitionsBuilder`, now in `lib/src/theme/app_palette.dart`) on all
  platforms — the default zoom/slide builders cause a white flash between routes.
  Don't remove the theme entry.
- `test/layout_test.dart` is the guard against overflow regressions: any new screen
  or dense row should be added there. Note `flutter test` uses the Ahem test font
  (very wide glyphs), so text-heavy rows can fail there even when they look fine on
  a real device — that's a signal to make the row flexible (e.g. `Expanded` +
  ellipsis) rather than to loosen the test.
- Theming gotchas: the palette's theme id field is `AppPalette.themeType`, **not**
  `type` — `ThemeExtension.type` is the key used by
  `Theme.of(context).extension<AppPalette>()`, so overriding it with anything other
  than the `AppPalette` type makes every lookup return `null` (the app then silently
  falls back to `appPalettes[AppThemeType.felt]`). `test/theme_test.dart` guards
  this (palette resolution per theme + live theme switch from the style page).
  `GameStorage.init()` must run before `ThemeController.instance.load()` (it reads
  the saved id); tests that pump `MyApp` without init get the default palette.
- `DashedLinePainter` is used through `SizedBox(width: double.infinity, height: 7,
  child: CustomPaint(...))`: a `CustomPaint` without a child sizes to `Size.zero`,
  so without the explicit width the divider paints nothing.
