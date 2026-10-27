import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pizarra/src/models/truco_game.dart';
import 'package:pizarra/src/models/truco_style.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart';
import 'package:pizarra/src/pages/truco/style_page.dart';
import 'package:pizarra/src/services/game_storage.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({
    super.key,
    required this.teamAName,
    required this.teamBName,
    required this.playersPerTeam,
    this.teamCName,
    this.resume = false,
  });

  final String teamAName;
  final String teamBName;
  final int playersPerTeam;
  final String? teamCName;

  /// Si es `true`, retoma la partida guardada en lugar de empezar de cero.
  final bool resume;

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  final GameStorage _storage = GameStorage.instance;

  late TrucoGame _game;
  late StyleSettings _style;
  int? _winnerIndex;
  bool _winnerShown = false;

  int get _teamCount => widget.playersPerTeam == 3 ? 3 : 2;

  List<String> get _teamNames => [
        widget.teamAName,
        widget.teamBName,
        if (_teamCount == 3) widget.teamCName ?? 'Verde',
      ];

  @override
  void initState() {
    super.initState();
    _game = TrucoGame(teamNames: _teamNames);
    _style = _storage.loadStyle() ?? const StyleSettings();
    if (widget.resume) {
      final saved = _storage.loadTruco();
      if (saved != null && saved.teamCount == _teamCount) {
        _game = saved;
        _winnerIndex = saved.winnerIndex;
        // Una partida ya terminada se muestra sin volver a abrir el diálogo.
        _winnerShown = _winnerIndex != null;
      }
    }
    _persist();
  }

  void _persist() => _storage.saveTruco(_game);

  void _addPoints(int team, int points) {
    setState(() {
      final reachedTarget = _game.addPoints(team, points);
      if (reachedTarget) _winnerIndex ??= team;
    });
    _persist();
  }

  void _subtractPoint(int team) {
    setState(() {
      _game.subtractPoint(team);
      _winnerIndex = null;
      _winnerShown = false;
    });
    _persist();
  }

  void _newMatch() {
    setState(() {
      _game.reset();
      _winnerIndex = null;
      _winnerShown = false;
    });
    _persist();
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Reiniciar partida?'),
        content: const Text('Se borrarán todos los puntos anotados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newMatch();
            },
            child: const Text('Reiniciar',
                style: TextStyle(color: Color(0xFFB71C1C))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final winnerIndex = _winnerIndex;
    if (winnerIndex != null && !_winnerShown) {
      _winnerShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('¡Ganador!', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  _game.teamNames[winnerIndex],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _game.scores.join(' - '),
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Revancha',
                    style: TextStyle(color: Colors.black54)),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _newMatch();
                },
                child: const Text('Nueva partida'),
              ),
            ],
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: _style.backgroundColor ?? Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildSquares(),
            ),
            _buildControls(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSquares() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final teamCount = _game.teamCount;
        final sizeByWidth = (constraints.maxWidth -
                48 -
                (teamCount - 1) * gap * 2) /
            teamCount;
        final totalSquares = TrucoGame.squaresPerHalf * 2 + 1; // malas + divisoria + buenas
        final sizeByHeight =
            (constraints.maxHeight - (totalSquares - 1) * gap - 20) /
                totalSquares;
        final size =
            math.max(16.0, math.min(sizeByWidth, sizeByHeight)).toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildTeamColumn(0, size, gap)),
              VerticalDivider(
                thickness: 1.5,
                color: Colors.grey[400],
                width: gap * 2,
              ),
              Expanded(child: _buildTeamColumn(1, size, gap)),
              if (teamCount == 3) ...[
                VerticalDivider(
                  thickness: 1.5,
                  color: Colors.grey[400],
                  width: gap * 2,
                ),
                Expanded(child: _buildTeamColumn(2, size, gap)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamColumn(int team, double size, double gap) {
    final score = _game.scoreFor(team);
    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        for (int sq = 0; sq < TrucoGame.squaresPerHalf; sq++) ...[
          _MatchSquare(
            points: _game.pointsInSquare(team, 0, sq),
            size: size,
            style: _style,
          ),
          SizedBox(height: gap),
        ],
        Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
        SizedBox(height: gap),
        for (int sq = 0; sq < TrucoGame.squaresPerHalf; sq++) ...[
          _MatchSquare(
            points: _game.pointsInSquare(team, 1, sq),
            size: size,
            style: _style,
          ),
          if (sq < TrucoGame.squaresPerHalf - 1) SizedBox(height: gap),
        ],
      ],
    );

    final teamName = _game.teamNames[team];
    return Semantics(
      key: ValueKey('team-column-$team'),
      container: true,
      button: true,
      label: teamName,
      value: '$score ${score == 1 ? 'punto' : 'puntos'}',
      hint: 'Tocá para sumar 1 punto',
      onTap: () => _addPoints(team, 1),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _addPoints(team, 1),
        child: column,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.teamAName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Color(0xFFE53935),
              ),
            ),
          ),
          Expanded(
            child: Text(
              widget.teamBName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Color(0xFF42A5F5),
              ),
            ),
          ),
          if (_teamCount == 3)
            Expanded(
              child: Text(
                _game.teamNames[2].toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Color(0xFF43A047),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: _style.backgroundColor ?? Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: _reset,
            tooltip: 'Reiniciar',
            icon: const Icon(Icons.refresh, color: Colors.black87),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SetupPage()),
            ),
            tooltip: 'Configurar',
            icon: const Icon(Icons.settings, color: Colors.black87),
          ),
          IconButton(
            onPressed: _openStyle,
            tooltip: 'Estilo',
            icon: const Icon(Icons.palette, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _openStyle() async {
    final result = await Navigator.of(context).push<StyleSettings>(
      MaterialPageRoute(
        builder: (_) => StylePage(settings: _style),
      ),
    );
    if (result != null) {
      setState(() => _style = result);
      _storage.saveStyle(result);
    }
  }

  Widget _buildControls() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _ControlsRow(
              color: const Color(0xFFE53935),
              onAdd: (p) => _addPoints(0, p),
              onSubtract: () => _subtractPoint(0),
              hideThree: _teamCount == 3,
            ),
          ),
          Expanded(
            child: _ControlsRow(
              color: const Color(0xFF42A5F5),
              onAdd: (p) => _addPoints(1, p),
              onSubtract: () => _subtractPoint(1),
              hideThree: _teamCount == 3,
            ),
          ),
          if (_teamCount == 3)
            Expanded(
              child: _ControlsRow(
                color: const Color(0xFF43A047),
                onAdd: (p) => _addPoints(2, p),
                onSubtract: () => _subtractPoint(2),
                hideThree: true,
              ),
            ),
        ],
      ),
    );
  }
}

/// Un cuadrado de palitos: muestra de 0 a 5 palitos.
/// Con 5 palitos se dibuja la diagonal que cierra el cuadrado.
class _MatchSquare extends StatefulWidget {
  const _MatchSquare({
    required this.points,
    required this.size,
    required this.style,
  });

  final int points;
  final double size;
  final StyleSettings style;

  @override
  State<_MatchSquare> createState() => _MatchSquareState();
}

class _MatchSquareState extends State<_MatchSquare>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _lastPoints = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _lastPoints = widget.points;
    if (widget.points > 0) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _MatchSquare oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points != _lastPoints) {
      _lastPoints = widget.points;
      if (widget.points > oldWidget.points) {
        _controller.forward(from: 0);
      } else {
        // Al restar puntos el cuadrado queda visible con los palitos restantes.
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Transform.scale(
            scale: 0.6 + 0.4 * _controller.value,
            child: CustomPaint(
              painter: _MatchPainter(
                widget.points,
                widget.style.stickColor,
                widget.style.stickStyle,
              ),
              size: Size.square(widget.size),
            ),
          ),
        );
      },
    );
  }
}

class _MatchPainter extends CustomPainter {
  _MatchPainter(this.points, this.color, this.style);

  final int points;
  final Color color;
  final StickStyle style;

  static const _wood = Color(0xFFD4A574);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final pad = s * 0.08;

    void drawElement(Offset from, Offset to) {
      if (style == StickStyle.dot) {
        canvas.drawCircle(from, s * 0.05, Paint()..color = color);
        canvas.drawCircle(to, s * 0.05, Paint()..color = color);
        return;
      }
      final isMatch = style == StickStyle.match;
      final paint = Paint()
        ..color = isMatch ? _wood : color
        ..strokeWidth = isMatch ? s * 0.07 : s * 0.06
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, paint);
      if (isMatch) {
        canvas.drawCircle(from, s * 0.075, Paint()..color = color);
      }
    }

    final tl = Offset(pad, pad);
    final tr = Offset(s - pad, pad);
    final bl = Offset(pad, s - pad);
    final br = Offset(s - pad, s - pad);

    if (points >= 1) drawElement(tl, tr);
    if (points >= 2) drawElement(tl, bl);
    if (points >= 3) drawElement(tr, br);
    if (points >= 4) drawElement(bl, br);
    if (points >= 5) drawElement(tl, br);
  }

  @override
  bool shouldRepaint(covariant _MatchPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.style != style;
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.color,
    required this.onAdd,
    required this.onSubtract,
    this.hideThree = false,
  });

  final Color color;
  final void Function(int points) onAdd;
  final void Function() onSubtract;
  final bool hideThree;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(label: '-1', color: color, onTap: onSubtract),
        _ControlButton(label: '+2', color: color, onTap: () => onAdd(2)),
        if (!hideThree)
          _ControlButton(label: '+3', color: color, onTap: () => onAdd(3)),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
