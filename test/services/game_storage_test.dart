import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizarra/src/models/chinchon_game.dart';
import 'package:pizarra/src/models/truco_game.dart';
import 'package:pizarra/src/models/truco_style.dart';
import 'package:pizarra/src/services/game_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GameStorage.init();
  });

  test('guarda y recupera la partida de truco', () {
    final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);
    game.addPoints(1, 7);

    GameStorage.instance.saveTruco(game);
    final restored = GameStorage.instance.loadTruco();

    expect(restored, isNotNull);
    expect(restored!.teamNames, ['Nosotros', 'Ellos']);
    expect(restored.scores, [0, 7]);
  });

  test('guarda y recupera la partida de chinchón', () {
    final game = ChinchonGame(
      playerNames: ['Rojo', 'Azul'],
      target: 100,
    );
    game.addPoints(0, 12);
    game.subtractTen(1);

    GameStorage.instance.saveChinchon(game);
    final restored = GameStorage.instance.loadChinchon();

    expect(restored, isNotNull);
    expect(restored!.playerNames, ['Rojo', 'Azul']);
    expect(restored.totals, [12, -10]);
    expect(restored.moves, [
      [12],
      [-10],
    ]);
  });

  test('guarda y recupera el estilo del anotador', () {
    const style = StyleSettings(
      stickColor: Color(0xFFE53935),
      stickStyle: StickStyle.dot,
    );

    GameStorage.instance.saveStyle(style);
    final restored = GameStorage.instance.loadStyle();

    expect(restored, isNotNull);
    expect(restored!.stickColor, const Color(0xFFE53935));
    expect(restored.stickStyle, StickStyle.dot);
  });

  test('guarda y recupera el tema de la app', () {
    expect(GameStorage.instance.loadThemeId(), isNull);

    GameStorage.instance.saveThemeId('paper');

    expect(GameStorage.instance.loadThemeId(), 'paper');
  });

  test('devuelve null cuando no hay partida guardada', () {
    expect(GameStorage.instance.loadTruco(), isNull);
    expect(GameStorage.instance.loadChinchon(), isNull);
    expect(GameStorage.instance.loadStyle(), isNull);
  });

  test('ignora datos corruptos o incompatibles', () async {
    SharedPreferences.setMockInitialValues({
      GameStorage.trucoKey: 'esto no es JSON',
      GameStorage.chinchonKey: '{"playerNames": "no es una lista"}',
      GameStorage.styleKey: '{"stickStyle": 42}',
    });
    await GameStorage.init();

    expect(GameStorage.instance.loadTruco(), isNull);
    expect(GameStorage.instance.loadChinchon(), isNull);
    expect(GameStorage.instance.loadStyle(), isNotNull);
  });

  test('limpiar una partida la borra del almacenamiento', () {
    final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);
    game.addPoints(0, 3);
    GameStorage.instance.saveTruco(game);

    GameStorage.instance.clearTruco();

    expect(GameStorage.instance.loadTruco(), isNull);
  });
}
