import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart';
import 'package:pizarra/src/pages/truco/style_page.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({
    super.key,
    required this.teamAName,
    required this.teamBName,
    required this.playersPerTeam,
    this.teamCName,
  });

  final String teamAName;
  final String teamBName;
  final int playersPerTeam;
  final String? teamCName;

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  static const int target = 30;
  static const int squaresPerHalf = 3;
  static const int pointsPerSquare = 5;

  int _scoreA = 0;
  int _scoreB = 0;
  int _scoreC = 0;

  String? _winner;
  bool _winnerShown = false;
  StyleSettings _style = const StyleSettings(
    stickColor: Color(0xFFD4A574),
    stickStyle: StickStyle.match,
  );

  void _addPoints(int team, int points) {
    setState(() {
      if (team == 0) {
        _scoreA = (_scoreA + points).clamp(0, target);
        if (_scoreA >= target) _winner = widget.teamAName;
      } else if (team == 1) {
        _scoreB = (_scoreB + points).clamp(0, target);
        if (_scoreB >= target) _winner = widget.teamBName;
      } else {
        _scoreC = (_scoreC + points).clamp(0, target);
        if (_scoreC >= target) _winner = widget.teamCName!;
      }
    });
  }

  void _subtractPoint(int team) {
    setState(() {
      if (team == 0) {
        _scoreA = (_scoreA - 1).clamp(0, target);
      } else if (team == 1) {
        _scoreB = (_scoreB - 1).clamp(0, target);
      } else {
        _scoreC = (_scoreC - 1).clamp(0, target);
      }
      _winner = null;
      _winnerShown = false;
    });
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
              setState(() {
                _scoreA = 0;
                _scoreB = 0;
                _scoreC = 0;
                _winner = null;
                _winnerShown = false;
              });
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
    if (_winner != null && !_winnerShown) {
      _winnerShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                  _winner!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.playersPerTeam == 3
                      ? '$_scoreA - $_scoreB - $_scoreC'
                      : '$_scoreA - $_scoreB',
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
                  setState(() {
                    _scoreA = 0;
                    _scoreB = 0;
                    _winner = null;
                    _winnerShown = false;
                  });
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
        final teamCount = widget.playersPerTeam == 3 ? 3 : 2;
        final sizeByWidth = (constraints.maxWidth - 48 - (teamCount - 1) * gap * 2) / teamCount;
        final totalSquares = squaresPerHalf * 2 + 1; // 3 malas + divisoria + 3 buenas
        final sizeByHeight =
            (constraints.maxHeight - (totalSquares - 1) * gap - 20) / totalSquares;
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
              if (widget.playersPerTeam == 3) ...[
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
    final score = team == 0 ? _scoreA : team == 1 ? _scoreB : _scoreC;
    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        for (int sq = 0; sq < squaresPerHalf; sq++) ...[
          _MatchSquare(
            points: _pointsInSquare(team, 0, sq),
            size: size,
            style: _style,
          ),
          SizedBox(height: gap),
        ],
        Divider(height: 1, thickness: 1.5, color: Colors.grey[400]),
        SizedBox(height: gap),
        for (int sq = 0; sq < squaresPerHalf; sq++) ...[
          _MatchSquare(
            points: _pointsInSquare(team, 1, sq),
            size: size,
            style: _style,
          ),
          if (sq < squaresPerHalf - 1) SizedBox(height: gap),
        ],
      ],
    );

    final teamName = team == 0
        ? widget.teamAName
        : team == 1
            ? widget.teamBName
            : widget.teamCName!;
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

  int _pointsInSquare(int team, int half, int col) {
    final score = team == 0 ? _scoreA : team == 1 ? _scoreB : _scoreC;
    final base = half * squaresPerHalf * pointsPerSquare;
    final squareStart = base + col * pointsPerSquare;
    if (score <= squareStart) return 0;
    return math.min(score - squareStart, pointsPerSquare);
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
          if (widget.playersPerTeam == 3)
            Expanded(
              child: Text(
                widget.teamCName!.toUpperCase(),
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
              hideThree: widget.playersPerTeam == 3,
            ),
          ),
          Expanded(
            child: _ControlsRow(
              color: const Color(0xFF42A5F5),
              onAdd: (p) => _addPoints(1, p),
              onSubtract: () => _subtractPoint(1),
              hideThree: widget.playersPerTeam == 3,
            ),
          ),
          if (widget.playersPerTeam == 3)
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
