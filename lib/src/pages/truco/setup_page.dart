import 'package:flutter/material.dart';
import 'package:pizarra/src/pages/truco/score_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int _playersPerTeam = 2;
  final TextEditingController _teamAController =
      TextEditingController(text: 'Nosotros');
  final TextEditingController _teamBController =
      TextEditingController(text: 'Ellos');
  final TextEditingController _teamCController =
      TextEditingController(text: 'Verde');

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _teamCController.dispose();
    super.dispose();
  }

  void _start() {
    final nameA = _teamAController.text.trim().isEmpty
        ? 'Nosotros'
        : _teamAController.text.trim();
    final nameB = _teamBController.text.trim().isEmpty
        ? 'Ellos'
        : _teamBController.text.trim();
    final nameC = _teamCController.text.trim().isEmpty
        ? 'Verde'
        : _teamCController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScorePage(
          teamAName: nameA,
          teamBName: nameB,
          playersPerTeam: _playersPerTeam,
          teamCName: _playersPerTeam == 3 ? nameC : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B3D2E),
      appBar: AppBar(
        title: const Text('Truco'),
        backgroundColor: const Color(0xFF0B3D2E),
        foregroundColor: const Color(0xFFFFD54F),
        elevation: 0,
      ),
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
                      'TRUCO',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        color: const Color(0xFFFFD54F),
                        shadows: [
                          Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Partida a 30 puntos',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jugadores por equipo',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<int>(
                              segments: const [
                                ButtonSegment(value: 2, label: Text('2')),
                                ButtonSegment(value: 3, label: Text('3')),
                              ],
                              selected: {_playersPerTeam},
                              onSelectionChanged: (s) =>
                                  setState(() => _playersPerTeam = s.first),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _teamAController,
                              maxLength: 12,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Equipo rojo',
                                labelStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7)),
                                prefixIcon: const Icon(Icons.circle,
                                    color: Color(0xFFE53935), size: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFE53935)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _teamBController,
                              maxLength: 12,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Equipo azul',
                                labelStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7)),
                                prefixIcon: const Icon(Icons.circle,
                                    color: Color(0xFF42A5F5), size: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Color(0xFF42A5F5)),
                                ),
                              ),
                            ),
                            if (_playersPerTeam == 3) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _teamCController,
                                maxLength: 12,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Equipo verde',
                                  labelStyle: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7)),
                                  prefixIcon: const Icon(Icons.circle,
                                      color: Color(0xFF43A047), size: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: Color(0xFF43A047)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _start,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD54F),
                          foregroundColor: const Color(0xFF1B5E20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'COMENZAR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF0B3D2E),
                          title: const Text('¿Cómo se anota?',
                              style: TextStyle(color: Colors.white)),
                          content: Text(
                            '• Mano ganada: 1 punto\n'
                            '• Envido: 1, 2 o 3 puntos\n'
                            '• Truco: 1, 2 o 3 puntos\n'
                            '• Sumá y restá con los botones.\n'
                            '• El primero en llegar a 30 gana.',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Entendido',
                                  style:
                                      TextStyle(color: Color(0xFFFFD54F))),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.help_outline,
                          color: Color(0xFFFFD54F)),
                      label: const Text('Cómo se anota',
                          style: TextStyle(color: Color(0xFFFFD54F))),
                    ),
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

class PlayingCardsIcon extends StatelessWidget {
  const PlayingCardsIcon({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.4,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.22,
            child: _card(Colors.white, size),
          ),
          Transform.rotate(
            angle: 0.22,
            child: _card(const Color(0xFFFFD54F), size),
          ),
        ],
      ),
    );
  }

  Widget _card(Color color, double size) {
    return Container(
      width: size * 0.72,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.09),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '♠',
          style: TextStyle(
            fontSize: size * 0.5,
            color: color == Colors.white ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
