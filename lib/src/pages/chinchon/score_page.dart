import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizarra/src/models/chinchon_game.dart';
import 'package:pizarra/src/pages/chinchon/setup_page.dart';
import 'package:pizarra/src/services/game_storage.dart';
import 'package:pizarra/src/theme/app_palette.dart';
import 'package:pizarra/src/widgets/app_background.dart';
import 'package:pizarra/src/widgets/app_pill_bar.dart';
import 'package:pizarra/src/widgets/fade_slide_in.dart';
import 'package:pizarra/src/widgets/match_painter.dart';

class ChinchonScorePage extends StatefulWidget {
  const ChinchonScorePage({
    super.key,
    required this.playerNames,
    required this.target,
    this.resume = false,
  });

  final List<String> playerNames;
  final int target;

  /// Si es `true`, retoma la partida guardada en lugar de empezar de cero.
  final bool resume;

  @override
  State<ChinchonScorePage> createState() => _ChinchonScorePageState();
}

class _ChinchonScorePageState extends State<ChinchonScorePage> {
  final GameStorage _storage = GameStorage.instance;

  late ChinchonGame _game;
  late final List<ScrollController> _scrollControllers;
  int? _winnerIndex;
  bool _winnerShown = false;

  @override
  void initState() {
    super.initState();
    _game = ChinchonGame(
      playerNames: widget.playerNames,
      target: widget.target,
    );
    if (widget.resume) {
      final saved = _storage.loadChinchon();
      if (saved != null && saved.playerCount == widget.playerNames.length) {
        _game = saved;
      }
    }
    _winnerIndex = _game.lastStandingIndex;
    // Una partida ya terminada se muestra sin volver a abrir el diálogo.
    _winnerShown = _winnerIndex != null;
    _scrollControllers = List.generate(
      widget.playerNames.length,
      (_) => ScrollController(),
    );
    _persist();
  }

  @override
  void dispose() {
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _persist() => _storage.saveChinchon(_game);

  Color _colorFor(AppPalette palette, int i) => palette.playerColor(i);

  Color _foregroundOn(Color background) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : Colors.black87;

  void _scrollToBottom(int i) {
    final c = _scrollControllers[i];
    if (!c.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.hasClients) {
        c.animateTo(
          c.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addPoints(int player) async {
    final value = await showDialog<int>(
      context: context,
      builder: (_) => _PointsDialog(playerName: widget.playerNames[player]),
    );
    if (value == null || !mounted) return;
    HapticFeedback.lightImpact();
    final eliminatedNow = _game.addPoints(player, value);
    setState(() {});
    _persist();
    _scrollToBottom(player);
    if (eliminatedNow) _showElimination(player);
  }

  void _subtractTen(int player) {
    HapticFeedback.selectionClick();
    setState(() => _game.subtractTen(player));
    _persist();
    _scrollToBottom(player);
  }

  void _showElimination(int player) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¡Eliminado!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💀', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              widget.playerNames[player],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Llegó a ${_game.target} puntos',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _checkWinner();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _checkWinner() {
    final winner = _game.lastStandingIndex;
    if (winner != null && _winnerIndex == null) {
      setState(() => _winnerIndex = winner);
    }
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

  void _backToPicker() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
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
            label: 'Jugadores',
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ChinchonSetupPage()),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMove(int move) => move >= 0 ? '+$move' : '$move';

  Color _totalColor(AppPalette palette, int total, bool eliminated) {
    if (eliminated || total >= _game.target) return palette.red;
    if (total >= (_game.target * 0.8).ceil()) return palette.accent;
    return palette.textPrimary;
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
              Expanded(child: _buildColumns(palette)),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeShowWinner() {
    if (_winnerIndex == null || _winnerShown) return;
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
                _game.playerNames[_winnerIndex!],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Quedó último en pie',
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        'CHINCHÓN · LÍMITE ${_game.target}',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: palette.display(20, color: palette.accent, letterSpacing: 1),
      ),
    );
  }

  Widget _buildColumns(AppPalette palette) {
    final columns = <Widget>[];
    for (int i = 0; i < _game.playerCount; i++) {
      if (i > 0) columns.add(const SizedBox(width: 6));
      columns.add(
        Expanded(child: FadeSlideIn(child: _buildPlayerCard(i, palette))),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columns,
      ),
    );
  }

  Widget _buildPlayerCard(int i, AppPalette palette) {
    final color = _colorFor(palette, i);
    final eliminated = _game.eliminated[i];
    final displayColor = eliminated ? palette.textSecondary : color;
    final total = _game.totals[i];
    final moves = _game.moves[i];
    return Semantics(
      key: ValueKey('chinchon-player-$i'),
      container: true,
      label: _game.playerNames[i],
      value: '$total ${total == 1 ? 'punto' : 'puntos'}',
      hint: eliminated ? 'Eliminado' : 'Tocá para anotar puntos',
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: eliminated
                ? palette.surfaceBorder
                : color.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _game.playerNames[i].toUpperCase(),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: displayColor,
                  ),
                ),
              ),
            ),
            if (eliminated)
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'ELIMINADO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: palette.red.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            if (!eliminated) ...[
              FilledButton(
                key: ValueKey('add-points-$i'),
                onPressed: () => _addPoints(i),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: _foregroundOn(color),
                  minimumSize: const Size.fromHeight(38),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '+',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 4),
              FilledButton(
                key: ValueKey('subtract-ten-$i'),
                onPressed: () => _subtractTen(i),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.red.withValues(alpha: 0.18),
                  foregroundColor: palette.red,
                  minimumSize: const Size.fromHeight(32),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '-10',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _AnimatedTotal(
                value: total,
                style: palette.display(
                  36,
                  color: _totalColor(palette, total, eliminated),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 7,
              child: CustomPaint(painter: DashedLinePainter(palette.divider)),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                controller: _scrollControllers[i],
                padding: EdgeInsets.zero,
                children: [
                  for (int j = 0; j < moves.length; j++)
                    _LedgerChip(
                      key: ValueKey('chinchon-entry-$i-$j'),
                      label: _formatMove(moves[j]),
                      color: moves[j] < 0 ? palette.red : palette.green,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contador que anima el cambio de total.
class _AnimatedTotal extends StatelessWidget {
  const _AnimatedTotal({required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Text('${animated.round()}', style: style);
      },
    );
  }
}

/// Entrada del registro: chip verde para `+N` y rojo para `-N`.
class _LedgerChip extends StatelessWidget {
  const _LedgerChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _PointsDialog extends StatefulWidget {
  const _PointsDialog({required this.playerName});

  final String playerName;

  @override
  State<_PointsDialog> createState() => _PointsDialogState();
}

class _PointsDialogState extends State<_PointsDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.playerName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const ValueKey('points-field'),
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Puntos de la ronda'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in [0, 5, 10, 20])
                ActionChip(
                  label: Text(v == 0 ? 'Cerró (0)' : '+$v'),
                  onPressed: () => _controller.text = '$v',
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, int.tryParse(_controller.text.trim())),
          child: const Text('Sumar'),
        ),
      ],
    );
  }
}
