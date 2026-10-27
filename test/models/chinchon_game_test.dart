import 'package:flutter_test/flutter_test.dart';
import 'package:pizarra/src/models/chinchon_game.dart';

void main() {
  group('ChinchonGame', () {
    test('empieza en cero y sin eliminados', () {
      final game = ChinchonGame(playerNames: ['Rojo', 'Azul']);

      expect(game.totals, [0, 0]);
      expect(game.moves, [[], []]);
      expect(game.eliminated, [false, false]);
      expect(game.hasProgress, isFalse);
      expect(game.lastStandingIndex, isNull);
    });

    test('anota puntos en el total y en la cuenta del jugador', () {
      final game = ChinchonGame(playerNames: ['Rojo', 'Azul']);

      final eliminated = game.addPoints(0, 12);

      expect(eliminated, isFalse);
      expect(game.totals[0], 12);
      expect(game.totals[1], 0);
      expect(game.moves[0], [12]);
      expect(game.hasProgress, isTrue);
    });

    test('llegar al límite elimina al jugador una sola vez', () {
      final game = ChinchonGame(playerNames: ['Rojo', 'Azul'], target: 50);

      expect(game.addPoints(0, 30), isFalse);
      expect(game.eliminated[0], isFalse);

      expect(game.addPoints(0, 20), isTrue);
      expect(game.totals[0], 50);
      expect(game.eliminated[0], isTrue);

      expect(game.addPoints(0, 5), isFalse);
      expect(game.eliminated[0], isTrue);
      expect(game.totals[0], 55);
    });

    test('el -10 descuenta siempre, incluso por debajo de cero', () {
      final game = ChinchonGame(playerNames: ['Rojo', 'Azul']);

      game.subtractTen(0);

      expect(game.totals[0], -10);
      expect(game.moves[0], [-10]);

      game.addPoints(0, 15);
      game.subtractTen(0);

      expect(game.totals[0], -5);
      expect(game.moves[0], [-10, 15, -10]);
    });

    test('los totales siempre coinciden con la suma de la cuenta', () {
      final game = ChinchonGame(playerNames: ['Rojo', 'Azul', 'Verde']);

      game.addPoints(0, 7);
      game.addPoints(0, 3);
      game.subtractTen(0);
      game.subtractTen(1);
      game.addPoints(2, 0);

      for (var i = 0; i < game.playerCount; i++) {
        expect(game.totals[i], game.moves[i].fold<int>(0, (a, b) => a + b));
      }
    });

    test('queda un ganador cuando solo sobrevive un jugador', () {
      final game = ChinchonGame(
        playerNames: ['Rojo', 'Azul', 'Verde'],
        target: 10,
      );

      game.addPoints(0, 10);
      expect(game.lastStandingIndex, isNull);

      game.addPoints(1, 10);
      expect(game.lastStandingIndex, 2);
    });

    test('reset limpia totales, cuentas y eliminados', () {
      final game = ChinchonGame(playerNames: ['Rojo', 'Azul'], target: 10);

      game.addPoints(0, 10);
      game.subtractTen(1);
      game.reset();

      expect(game.totals, [0, 0]);
      expect(game.moves, [[], []]);
      expect(game.eliminated, [false, false]);
      expect(game.lastStandingIndex, isNull);
      expect(game.hasProgress, isFalse);
    });

    test('serializa y deserializa sin perder estado', () {
      final game = ChinchonGame(
        playerNames: ['Rojo', 'Azul', 'Verde'],
        target: 80,
      );
      game.addPoints(1, 15);
      game.subtractTen(1);
      game.addPoints(2, 80);

      final restored = ChinchonGame.fromJson(game.toJson());

      expect(restored.playerNames, ['Rojo', 'Azul', 'Verde']);
      expect(restored.target, 80);
      expect(restored.totals, [0, 5, 80]);
      expect(restored.moves, [
        <int>[],
        [15, -10],
        [80],
      ]);
      expect(restored.eliminated, [false, false, true]);
      expect(restored.lastStandingIndex, isNull);
    });

    test('ignora listas con largo incorrecto', () {
      final game = ChinchonGame(
        playerNames: ['Rojo', 'Azul'],
        totals: [10],
        eliminated: [true],
      );

      expect(game.totals, [0, 0]);
      expect(game.eliminated, [false, false]);
    });
  });
}
