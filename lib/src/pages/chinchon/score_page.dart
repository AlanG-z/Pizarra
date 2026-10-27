import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizarra/src/models/chinchon_game.dart';
import 'package:pizarra/src/services/game_storage.dart';

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
  static const _colors = [
    Color(0xFFE53935),
    Color(0xFF42A5F5),
    Color(0xFF43A047),
    Color(0xFFFFD54F),
    Color(0xFFFF8A50),
    Color(0xFFEC407A),
  ];

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

  Color _colorFor(int i) => _colors[i % _colors.length];

  Color _foregroundOn(Color bg) =>
      bg == const Color(0xFFFFD54F) ? Colors.black87 : Colors.white;

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
    final eliminatedNow = _game.addPoints(player, value);
    setState(() {});
    _persist();
    _scrollToBottom(player);
    if (eliminatedNow) _showElimination(player);
  }

  void _subtractTen(int player) {
    setState(() => _game.subtractTen(player));
    _persist();
    _scrollToBottom(player);
  }

  void _showElimination(int player) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¡Eliminado!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💀', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              widget.playerNames[player],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Llegó a ${_game.target} puntos',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
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

  void _backToPicker() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  String _formatMove(int move) => move >= 0 ? '+$move' : '$move';

  @override
  Widget build(BuildContext context) {
    if (_winnerIndex != null && !_winnerShown) {
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
                const Text(
                  'Quedó último en pie',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildColumns(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _backToPicker,
            tooltip: 'Juegos',
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              'CHINCHÓN · LÍMITE ${_game.target}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: Color(0xFF0B3D2E),
              ),
            ),
          ),
          IconButton(
            onPressed: _reset,
            tooltip: 'Reiniciar',
            icon: const Icon(Icons.refresh, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildColumns() {
    final columns = <Widget>[];
    for (int i = 0; i < _game.playerCount; i++) {
      if (i > 0) {
        columns.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: VerticalDivider(thickness: 1.5, color: Colors.grey),
          ),
        );
      }
      columns.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildPlayerColumn(i),
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columns,
    );
  }

  Widget _buildPlayerColumn(int i) {
    final color = _colorFor(i);
    final eliminated = _game.eliminated[i];
    final displayColor = eliminated ? Colors.grey : color;
    final total = _game.totals[i];
    final moves = _game.moves[i];
    return Semantics(
      key: ValueKey('chinchon-player-$i'),
      container: true,
      label: _game.playerNames[i],
      value: '$total ${total == 1 ? 'punto' : 'puntos'}',
      hint: eliminated ? 'Eliminado' : 'Tocá para anotar puntos',
      child: Column(
        children: [
          Text(
            _game.playerNames[i].toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: displayColor,
            ),
          ),
          if (eliminated)
            Text(
              'ELIMINADO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: Colors.red.withValues(alpha: 0.8),
              ),
            ),
          const SizedBox(height: 6),
          if (!eliminated)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: ValueKey('add-points-$i'),
                    onPressed: () => _addPoints(i),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: _foregroundOn(color),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('+'),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    key: ValueKey('subtract-ten-$i'),
                    onPressed: () => _subtractTen(i),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB71C1C),
                      side: const BorderSide(color: Color(0xFFB71C1C)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('-10'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Text(
            '$total',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: displayColor,
            ),
          ),
          const Divider(height: 1, thickness: 1.5, color: Colors.grey),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              controller: _scrollControllers[i],
              children: [
                for (int j = 0; j < moves.length; j++)
                  Text(
                    _formatMove(moves[j]),
                    key: ValueKey('chinchon-entry-$i-$j'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: moves[j] < 0
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFF1B5E20),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Puntos de la ronda',
            ),
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
