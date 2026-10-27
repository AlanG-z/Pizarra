import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizarra/src/models/truco_style.dart';
import 'package:pizarra/src/pages/chinchon/score_page.dart';
import 'package:pizarra/src/pages/chinchon/setup_page.dart';
import 'package:pizarra/src/pages/inicio_page.dart';
import 'package:pizarra/src/pages/truco/score_page.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart';
import 'package:pizarra/src/pages/truco/style_page.dart';
import 'package:pizarra/src/theme/app_palette.dart';

/// Pantallas de la app para verificar que entren en un celular común.
final Map<String, Widget> _pages = {
  'inicio': const InicioPage(),
  'truco-setup': const SetupPage(),
  'truco-score-2': const ScorePage(
    teamAName: 'Nosotros',
    teamBName: 'Ellos',
    playersPerTeam: 2,
  ),
  'truco-score-3': const ScorePage(
    teamAName: 'Nosotros',
    teamBName: 'Ellos',
    playersPerTeam: 3,
    teamCName: 'Verde',
  ),
  'chinchon-setup': const ChinchonSetupPage(),
  'chinchon-score-2': const ChinchonScorePage(
    playerNames: ['Rojo', 'Azul'],
    target: 100,
  ),
  'chinchon-score-6': const ChinchonScorePage(
    playerNames: [
      'Rojo',
      'Azul',
      'Verde',
      'Amarillo',
      'Naranja',
      'Rosa',
    ],
    target: 100,
  ),
  'estilo': const StylePage(settings: StyleSettings()),
};

void main() {
  const sizes = <String, Size>{
    '390x844': Size(390, 844),
    '360x640': Size(360, 640),
  };

  for (final theme in AppThemeType.values) {
    for (final entry in _pages.entries) {
      for (final sizeEntry in sizes.entries) {
        testWidgets(
            '${theme.label} / ${entry.key} entra en ${sizeEntry.key}',
            (WidgetTester tester) async {
          tester.view.physicalSize = sizeEntry.value;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(theme),
              home: entry.value,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
