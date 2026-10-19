import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pizarra/src/app.dart';
import 'package:pizarra/src/pages/chinchon/score_page.dart';
import 'package:pizarra/src/pages/truco/score_page.dart';

void main() {
  testWidgets('App arranca en la pantalla de inicio', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('PIZARRA'), findsOneWidget);
    expect(find.text('TRUCO'), findsOneWidget);
    expect(find.text('CHINCHÓN'), findsOneWidget);
  });

  testWidgets('Tocar cada columna suma un punto al equipo correspondiente',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScorePage(
          teamAName: 'Nosotros',
          teamBName: 'Ellos',
          playersPerTeam: 2,
        ),
      ),
    );
    final semantics = tester.ensureSemantics();

    await tester.tap(find.byKey(const ValueKey('team-column-0')));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byKey(const ValueKey('team-column-0'))).value,
      '1 punto',
    );
    expect(
      tester.getSemantics(find.byKey(const ValueKey('team-column-1'))).value,
      '0 puntos',
    );

    await tester.tap(find.byKey(const ValueKey('team-column-1')));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byKey(const ValueKey('team-column-0'))).value,
      '1 punto',
    );
    expect(
      tester.getSemantics(find.byKey(const ValueKey('team-column-1'))).value,
      '1 punto',
    );
    semantics.dispose();
  });

  testWidgets('Anotar puntos suma al total del jugador de chinchon',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChinchonScorePage(
          playerNames: ['Rojo', 'Azul'],
          target: 100,
        ),
      ),
    );
    final semantics = tester.ensureSemantics();

    await tester.tap(find.byKey(const ValueKey('add-points-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('points-field')), '12');
    await tester.tap(find.text('Sumar'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byKey(const ValueKey('chinchon-player-0'))).value,
      '12 puntos',
    );
    expect(
      tester.getSemantics(find.byKey(const ValueKey('chinchon-player-1'))).value,
      '0 puntos',
    );
    expect(find.text('+12'), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('Cada -10 descuenta diez y aparece en el contador',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChinchonScorePage(
          playerNames: ['Rojo', 'Azul'],
          target: 100,
        ),
      ),
    );
    final semantics = tester.ensureSemantics();

    await tester.tap(find.byKey(const ValueKey('add-points-0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('points-field')), '15');
    await tester.tap(find.text('Sumar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('subtract-ten-0')));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('chinchon-player-0'))).value,
      '5 puntos',
    );
    expect(find.byKey(const ValueKey('chinchon-entry-0-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('subtract-ten-0')));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('chinchon-player-0'))).value,
      '-5 puntos',
    );
    expect(find.byKey(const ValueKey('chinchon-entry-0-2')), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('Seis jugadores: columnas estrechas con botones apilados',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChinchonScorePage(
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
      ),
    );
    final semantics = tester.ensureSemantics();

    await tester.tap(find.byKey(const ValueKey('add-points-5')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('points-field')), '7');
    await tester.tap(find.text('Sumar'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.byKey(const ValueKey('chinchon-player-5'))).value,
      '7 puntos',
    );
    expect(find.byKey(const ValueKey('add-points-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('subtract-ten-5')), findsOneWidget);

    semantics.dispose();
  });

  testWidgets('Llegar al limite elimina al jugador y gana el ultimo en pie',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChinchonScorePage(
          playerNames: ['Rojo', 'Azul'],
          target: 10,
        ),
      ),
    );
    final semantics = tester.ensureSemantics();

    await tester.tap(find.byKey(const ValueKey('add-points-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('points-field')), '10');
    await tester.tap(find.text('Sumar'));
    await tester.pumpAndSettle();

    expect(find.text('¡Eliminado!'), findsOneWidget);
    expect(find.text('Azul'), findsWidgets);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('¡Ganador!'), findsOneWidget);
    expect(find.text('Rojo'), findsOneWidget);

    semantics.dispose();
  });
}
