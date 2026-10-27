/// Pure scoring model for Chinchón.
///
/// Keeps the totals, the ledger of moves and the elimination state of every
/// player. It has no Flutter dependency, so it can be unit-tested directly.
class ChinchonGame {
  ChinchonGame({
    required List<String> playerNames,
    this.target = defaultTarget,
    List<int>? totals,
    List<List<int>>? moves,
    List<bool>? eliminated,
  })  : assert(playerNames.length >= 2, 'Chinchón necesita al menos 2 jugadores'),
        playerNames = List<String>.unmodifiable(playerNames),
        totals = _normalize(totals, playerNames.length, 0),
        moves = _normalizeMoves(moves, playerNames.length),
        eliminated = _normalize(eliminated, playerNames.length, false);

  /// Puntos de eliminación por defecto.
  static const int defaultTarget = 100;

  /// Puntos que descuenta cada toque del botón `-10`.
  static const int subtractStep = 10;

  static List<T> _normalize<T>(List<T>? values, int length, T fallback) {
    if (values == null || values.length != length) {
      return List<T>.filled(length, fallback);
    }
    return List<T>.from(values);
  }

  static List<List<int>> _normalizeMoves(
    List<List<int>>? moves,
    int playerCount,
  ) {
    if (moves == null || moves.length != playerCount) {
      return List<List<int>>.generate(playerCount, (_) => <int>[]);
    }
    return [for (final playerMoves in moves) List<int>.from(playerMoves)];
  }

  final List<String> playerNames;
  final int target;
  final List<int> totals;
  final List<List<int>> moves;
  final List<bool> eliminated;

  int get playerCount => playerNames.length;

  /// El jugador que quedó solo en pie, o `null` mientras haya más de uno.
  int? get lastStandingIndex {
    final remaining = <int>[
      for (var i = 0; i < eliminated.length; i++)
        if (!eliminated[i]) i,
    ];
    return remaining.length == 1 ? remaining.first : null;
  }

  bool get hasProgress =>
      moves.any((playerMoves) => playerMoves.isNotEmpty) ||
      totals.any((total) => total != 0);

  /// Anota [value] puntos al jugador [player].
  ///
  /// Devuelve `true` si el jugador quedó eliminado con esta jugada. Los totales
  /// no se limitan a cero para que las correcciones del usuario se reflejen.
  bool addPoints(int player, int value) {
    totals[player] += value;
    moves[player].add(value);
    if (eliminated[player] || totals[player] < target) return false;
    eliminated[player] = true;
    return true;
  }

  /// Descuenta [subtractStep] puntos de [player] (puede quedar en negativo).
  void subtractTen(int player) {
    totals[player] -= subtractStep;
    moves[player].add(-subtractStep);
  }

  void reset() {
    totals.fillRange(0, totals.length, 0);
    for (final playerMoves in moves) {
      playerMoves.clear();
    }
    eliminated.fillRange(0, eliminated.length, false);
  }

  Map<String, dynamic> toJson() => {
        'playerNames': playerNames,
        'target': target,
        'totals': totals,
        'moves': moves,
        'eliminated': eliminated,
      };

  factory ChinchonGame.fromJson(Map<String, dynamic> json) {
    return ChinchonGame(
      playerNames: (json['playerNames'] as List<dynamic>).cast<String>(),
      target: (json['target'] as num?)?.toInt() ?? defaultTarget,
      totals: (json['totals'] as List<dynamic>?)?.cast<int>(),
      moves: (json['moves'] as List<dynamic>?)
          ?.map((playerMoves) => (playerMoves as List<dynamic>).cast<int>())
          .toList(),
      eliminated: (json['eliminated'] as List<dynamic>?)?.cast<bool>(),
    );
  }

  @override
  String toString() => 'ChinchonGame(${playerNames.join(' / ')}, $totals)';
}
