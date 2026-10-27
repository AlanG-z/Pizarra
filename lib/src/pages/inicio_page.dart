import 'package:flutter/material.dart';
import 'package:pizarra/src/models/chinchon_game.dart';
import 'package:pizarra/src/models/truco_game.dart';
import 'package:pizarra/src/pages/chinchon/score_page.dart';
import 'package:pizarra/src/pages/truco/score_page.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart' show PlayingCardsIcon;
import 'package:pizarra/src/services/game_storage.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final GameStorage _storage = GameStorage.instance;

  TrucoGame? _savedTruco;
  ChinchonGame? _savedChinchon;

  @override
  void initState() {
    super.initState();
    _reloadSavedGames();
  }

  void _reloadSavedGames() {
    final truco = _storage.loadTruco();
    final chinchon = _storage.loadChinchon();
    _savedTruco = truco != null && truco.hasProgress ? truco : null;
    _savedChinchon =
        chinchon != null && chinchon.hasProgress ? chinchon : null;
  }

  Future<void> _openGame(String route) async {
    await Navigator.of(context).pushNamed(route);
    if (!mounted) return;
    setState(_reloadSavedGames);
  }

  Future<void> _resumeTruco() async {
    final game = _savedTruco;
    if (game == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScorePage(
          teamAName: game.teamNames[0],
          teamBName: game.teamNames[1],
          playersPerTeam: game.teamCount,
          teamCName: game.teamCount == 3 ? game.teamNames[2] : null,
          resume: true,
        ),
      ),
    );
    if (!mounted) return;
    setState(_reloadSavedGames);
  }

  Future<void> _resumeChinchon() async {
    final game = _savedChinchon;
    if (game == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChinchonScorePage(
          playerNames: game.playerNames.toList(),
          target: game.target,
          resume: true,
        ),
      ),
    );
    if (!mounted) return;
    setState(_reloadSavedGames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B3D2E), Color(0xFF06231B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PlayingCardsIcon(size: 64),
                    const SizedBox(height: 12),
                    Text(
                      'PIZARRA',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: const Color(0xFFFFD54F),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Elegí el anotador',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _GameCard(
                      title: 'TRUCO',
                      subtitle: 'Partida a 30 puntos',
                      color: const Color(0xFFE53935),
                      onTap: () => _openGame('/setup'),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      title: 'CHINCHÓN',
                      subtitle: 'Gana el último en pie · límite 100',
                      color: const Color(0xFF42A5F5),
                      onTap: () => _openGame('/chinchon-setup'),
                    ),
                    if (_savedTruco != null || _savedChinchon != null) ...[
                      const SizedBox(height: 28),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'PARTIDAS EN CURSO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_savedTruco != null)
                        _ResumeTile(
                          icon: Icons.play_arrow,
                          label: 'Continuar Truco',
                          detail: '${_savedTruco!.teamNames.join(' · ')}  '
                              '${_savedTruco!.scores.join(' - ')}',
                          color: const Color(0xFFE53935),
                          onTap: _resumeTruco,
                        ),
                      if (_savedChinchon != null) ...[
                        if (_savedTruco != null) const SizedBox(height: 10),
                        _ResumeTile(
                          icon: Icons.play_arrow,
                          label: 'Continuar Chinchón',
                          detail: '${_savedChinchon!.playerCount} jugadores · '
                              'límite ${_savedChinchon!.target}',
                          color: const Color(0xFF42A5F5),
                          onTap: _resumeChinchon,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Icon(Icons.circle, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumeTile extends StatelessWidget {
  const _ResumeTile({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.4), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
