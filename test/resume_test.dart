import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizarra/src/app.dart';
import 'package:pizarra/src/models/truco_game.dart';
import 'package:pizarra/src/services/game_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GameStorage.init();
  });

  testWidgets('La pantalla de inicio ofrece continuar la partida guardada',
      (WidgetTester tester) async {
    final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);
    game.addPoints(0, 7);
    GameStorage.instance.saveTruco(game);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('PARTIDAS EN CURSO'), findsOneWidget);
    expect(find.text('Continuar Truco'), findsOneWidget);

    await tester.tap(find.text('Continuar Truco'));
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('team-column-0'))).value,
      '7 puntos',
    );
    semantics.dispose();
  });

  testWidgets('No ofrece continuar si la partida guardada no tiene progreso',
      (WidgetTester tester) async {
    GameStorage.instance.saveTruco(
      TrucoGame(teamNames: ['Nosotros', 'Ellos']),
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('PARTIDAS EN CURSO'), findsNothing);
    expect(find.text('Continuar Truco'), findsNothing);
  });
}
