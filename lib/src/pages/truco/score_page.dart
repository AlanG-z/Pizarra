import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizarra/src/models/truco_game.dart';
import 'package:pizarra/src/models/truco_style.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart';
import 'package:pizarra/src/pages/truco/style_page.dart';
import 'package:pizarra/src/services/game_storage.dart';
import 'package:pizarra/src/theme/app_palette.dart';
import 'package:pizarra/src/widgets/app_background.dart';
import 'package:pizarra/src/widgets/app_pill_bar.dart';
import 'package:pizarra/src/widgets/match_painter.dart';

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
    HapticFeedback.lightImpact();
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
    final palette = AppPalette.of(context);
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
            child: Text('Reiniciar', style: TextStyle(color: palette.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    _maybeShowWinner();

    return Scaffold(
      bottomNavigationBar: _buildPillBar(palette),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(palette),
              Expanded(child: _buildSquares(palette)),
              _buildControls(palette),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeShowWinner() {
    final winnerIndex = _winnerIndex;
    if (winnerIndex == null || _winnerShown) return;
    _winnerShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Revancha'),
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

  Widget _buildHeader(AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          for (int team = 0; team < _teamCount; team++)
            Expanded(
              child: Text(
                _game.teamNames[team].toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: palette.display(
                  24,
                  color: palette.teamColor(team),
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSquares(AppPalette palette) {
    final stickColor = resolveStickColor(_style, palette);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final teamCount = _game.teamCount;
        final widthPerTeam =
            (constraints.maxWidth - 24 - (teamCount - 1) * gap) / teamCount;
        final sizeByWidth = widthPerTeam - 24;
        final totalSquares = TrucoGame.squaresPerHalf * 2 + 1;
        final sizeByHeight =
            (constraints.maxHeight - 34 - (totalSquares - 1) * gap) /
            totalSquares;
        final size = math
            .max(14.0, math.min(sizeByWidth, sizeByHeight))
            .toDouble();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int team = 0; team < teamCount; team++) ...[
                if (team > 0) const SizedBox(width: gap),
                Expanded(
                  child: _buildTeamCard(team, size, gap, palette, stickColor),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamCard(
    int team,
    double size,
    double gap,
    AppPalette palette,
    Color stickColor,
  ) {
    final score = _game.scoreFor(team);
    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        for (int sq = 0; sq < TrucoGame.squaresPerHalf; sq++) ...[
          _MatchSquare(
            points: _game.pointsInSquare(team, 0, sq),
            size: size,
            style: _style.stickStyle,
            color: stickColor,
          ),
          SizedBox(height: gap),
        ],
        SizedBox(
          width: double.infinity,
          height: 7,
          child: CustomPaint(painter: DashedLinePainter(palette.divider)),
        ),
        SizedBox(height: gap),
        for (int sq = 0; sq < TrucoGame.squaresPerHalf; sq++) ...[
          _MatchSquare(
            points: _game.pointsInSquare(team, 1, sq),
            size: size,
            style: _style.stickStyle,
            color: stickColor,
          ),
          if (sq < TrucoGame.squaresPerHalf - 1) SizedBox(height: gap),
        ],
      ],
    );

    return Semantics(
      key: ValueKey('team-column-$team'),
      container: true,
      button: true,
      label: _game.teamNames[team],
      value: '$score ${score == 1 ? 'punto' : 'puntos'}',
      hint: 'Tocá para sumar 1 punto',
      onTap: () => _addPoints(team, 1),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _addPoints(team, 1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.surfaceBorder),
          ),
          child: column,
        ),
      ),
    );
  }

  Widget _buildControls(AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: Row(
        children: [
          for (int team = 0; team < _teamCount; team++) ...[
            if (team > 0) const SizedBox(width: 8),
            Expanded(
              child: _ControlsRow(
                color: palette.teamColor(team),
                onAdd: (points) => _addPoints(team, points),
                onSubtract: () => _subtractPoint(team),
                hideThree: _teamCount == 3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPillBar(AppPalette palette) {
    return SafeArea(
      top: false,
      child: AppPillBar(
        onBack: _backToPicker,
        actions: [
          AppPillAction(icon: Icons.refresh, label: 'Reiniciar', onTap: _reset),
          AppPillAction(
            icon: Icons.group_outlined,
            label: 'Equipos',
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SetupPage()),
            ),
          ),
          AppPillAction(
            icon: Icons.palette_outlined,
            label: 'Estilo',
            color: palette.accent,
            onTap: _openStyle,
          ),
        ],
      ),
    );
  }

  void _backToPicker() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  void _openStyle() async {
    final result = await Navigator.of(context).push<StyleSettings>(
      MaterialPageRoute(builder: (_) => StylePage(settings: _style)),
    );
    if (result != null) {
      setState(() => _style = result);
      _storage.saveStyle(result);
    }
  }
}

/// Un cuadrado de palitos: muestra de 0 a 5 palitos.
/// Con 5 palitos se dibuja la diagonal que cierra el cuadrado.
class _MatchSquare extends StatefulWidget {
  const _MatchSquare({
    required this.points,
    required this.size,
    required this.style,
    required this.color,
  });

  final int points;
  final double size;
  final StickStyle style;
  final Color color;

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
              painter: MatchStrokesPainter(
                widget.points,
                widget.color,
                widget.style,
              ),
              size: Size.square(widget.size),
            ),
          ),
        );
      },
    );
  }
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
        Expanded(
          child: _ControlButton(label: '-1', color: color, onTap: onSubtract),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _ControlButton(
            label: '+2',
            color: color,
            onTap: () => onAdd(2),
          ),
        ),
        if (!hideThree) ...[
          const SizedBox(width: 6),
          Expanded(
            child: _ControlButton(
              label: '+3',
              color: color,
              onTap: () => onAdd(3),
            ),
          ),
        ],
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
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
