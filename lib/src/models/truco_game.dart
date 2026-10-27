import 'dart:math' as math;

/// Pure scoring model for Truco.
///
/// Holds only the state of a match (team names and scores) and the rules that
/// change it. It has no Flutter dependency, so it can be unit-tested directly.
class TrucoGame {
  TrucoGame({
    required List<String> teamNames,
    List<int>? scores,
    this.target = defaultTarget,
  })  : assert(
          teamNames.length == 2 || teamNames.length == 3,
          'Truco se juega con 2 o 3 equipos',
        ),
        teamNames = List<String>.unmodifiable(teamNames),
        scores = _normalizeScores(scores, teamNames.length);

  /// Puntos necesarios para ganar.
  static const int defaultTarget = 30;

  /// Cuadrados por mitad (3 "malas" abajo, 3 "buenas" arriba).
  static const int squaresPerHalf = 3;

  /// Puntos que representa cada cuadrado.
  static const int pointsPerSquare = 5;

  static List<int> _normalizeScores(List<int>? scores, int teamCount) {
    if (scores == null || scores.length != teamCount) {
      return List<int>.filled(teamCount, 0);
    }
    return List<int>.from(scores);
  }

  final List<String> teamNames;
  final int target;
  final List<int> scores;

  int get teamCount => teamNames.length;

  int scoreFor(int team) => scores[team];

  /// Equipo que llegó al objetivo, o `null` si la partida sigue.
  int? get winnerIndex {
    for (var i = 0; i < scores.length; i++) {
      if (scores[i] >= target) return i;
    }
    return null;
  }

  bool get hasProgress => scores.any((score) => score > 0);

  /// Suma [points] al equipo [team], sin pasar de [target].
  ///
  /// Devuelve `true` si el equipo alcanzó el objetivo con esta jugada.
  bool addPoints(int team, int points) {
    scores[team] = (scores[team] + points).clamp(0, target);
    return scores[team] >= target;
  }

  /// Resta un punto al equipo [team], sin bajar de cero.
  void subtractPoint(int team) {
    scores[team] = (scores[team] - 1).clamp(0, target);
  }

  /// Cantidad de palitos (0 a [pointsPerSquare]) del cuadrado [square] de la
  /// mitad [half] (0 = malas, 1 = buenas) del equipo [team].
  int pointsInSquare(int team, int half, int square) {
    final start = half * squaresPerHalf * pointsPerSquare +
        square * pointsPerSquare;
    final score = scores[team];
    if (score <= start) return 0;
    return math.min(score - start, pointsPerSquare);
  }

  void reset() {
    scores.fillRange(0, scores.length, 0);
  }

  Map<String, dynamic> toJson() => {
        'teamNames': teamNames,
        'scores': scores,
        'target': target,
      };

  factory TrucoGame.fromJson(Map<String, dynamic> json) {
    return TrucoGame(
      teamNames: (json['teamNames'] as List<dynamic>).cast<String>(),
      scores: (json['scores'] as List<dynamic>?)?.cast<int>(),
      target: (json['target'] as num?)?.toInt() ?? defaultTarget,
    );
  }

  @override
  String toString() => 'TrucoGame(${teamNames.join(' / ')}, $scores)';
}
