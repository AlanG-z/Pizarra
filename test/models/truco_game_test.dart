import 'package:flutter_test/flutter_test.dart';
import 'package:pizarra/src/models/truco_game.dart';

void main() {
  group('TrucoGame', () {
    test('empieza en cero y sin ganador', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);

      expect(game.scores, [0, 0]);
      expect(game.winnerIndex, isNull);
      expect(game.hasProgress, isFalse);
      expect(game.teamCount, 2);
    });

    test('suma puntos y avisa cuando se llega al objetivo', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);

      expect(game.addPoints(0, 2), isFalse);
      expect(game.addPoints(0, 3), isFalse);
      expect(game.scores[0], 5);
      expect(game.hasProgress, isTrue);

      expect(game.addPoints(0, 25), isTrue);
      expect(game.scores[0], 30);
      expect(game.winnerIndex, 0);
    });

    test('no pasa de 30 puntos', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);

      game.addPoints(0, 30);
      game.addPoints(0, 5);

      expect(game.scores[0], TrucoGame.defaultTarget);
    });

    test('resta sin bajar de cero', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);

      game.addPoints(1, 2);
      game.subtractPoint(1);
      expect(game.scores[1], 1);

      game.subtractPoint(1);
      game.subtractPoint(1);
      expect(game.scores[1], 0);
    });

    test('no declara ganador antes de llegar al objetivo', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);

      game.addPoints(1, 29);

      expect(game.winnerIndex, isNull);
    });

    test('reparte los puntos en los cuadrados de malas y buenas', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);

      game.addPoints(0, 7);
      expect(game.pointsInSquare(0, 0, 0), 5);
      expect(game.pointsInSquare(0, 0, 1), 2);
      expect(game.pointsInSquare(0, 0, 2), 0);
      expect(game.pointsInSquare(0, 1, 0), 0);

      game.addPoints(0, 15);
      expect(game.pointsInSquare(0, 0, 0), 5);
      expect(game.pointsInSquare(0, 0, 1), 5);
      expect(game.pointsInSquare(0, 0, 2), 5);
      expect(game.pointsInSquare(0, 1, 0), 5);
      expect(game.pointsInSquare(0, 1, 1), 2);
      expect(game.pointsInSquare(0, 1, 2), 0);
    });

    test('un equipo sin puntos no dibuja palitos', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos']);

      for (var half = 0; half < 2; half++) {
        for (var square = 0; square < TrucoGame.squaresPerHalf; square++) {
          expect(game.pointsInSquare(1, half, square), 0);
        }
      }
    });

    test('reset vuelve todos los equipos a cero', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos', 'Verde']);

      game.addPoints(0, 10);
      game.addPoints(1, 20);
      game.addPoints(2, 30);
      game.reset();

      expect(game.scores, [0, 0, 0]);
      expect(game.winnerIndex, isNull);
      expect(game.hasProgress, isFalse);
    });

    test('serializa y deserializa sin perder estado', () {
      final game = TrucoGame(teamNames: ['Nosotros', 'Ellos', 'Verde']);
      game.addPoints(1, 12);

      final restored = TrucoGame.fromJson(game.toJson());

      expect(restored.teamNames, ['Nosotros', 'Ellos', 'Verde']);
      expect(restored.scores, [0, 12, 0]);
      expect(restored.target, TrucoGame.defaultTarget);
    });

    test('ignora puntajes con largo incorrecto', () {
      final game = TrucoGame(
        teamNames: ['Nosotros', 'Ellos'],
        scores: [10],
      );

      expect(game.scores, [0, 0]);
    });
  });
}
