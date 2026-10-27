import 'package:flutter/material.dart';
import 'package:pizarra/src/pages/truco/score_page.dart';
import 'package:pizarra/src/theme/app_palette.dart';
import 'package:pizarra/src/widgets/app_background.dart';
import 'package:pizarra/src/widgets/fade_slide_in.dart';

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

  InputDecoration _field(
    AppPalette palette, {
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: palette.textSecondary),
      counterStyle: TextStyle(color: palette.textSecondary),
      prefixIcon: Icon(icon, color: color, size: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.surfaceBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.backgroundStart,
      appBar: AppBar(
        title: const Text('Truco'),
        backgroundColor: Colors.transparent,
        foregroundColor: palette.accent,
        elevation: 0,
      ),
      body: AppBackground(
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
                      style: palette.display(
                        44,
                        color: palette.accent,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Partida a 30 puntos',
                      style: TextStyle(
                        fontSize: 15,
                        color: palette.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 26),
                    FadeSlideIn(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: palette.surfaceBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jugadores por equipo',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<int>(
                              style: SegmentedButton.styleFrom(
                                foregroundColor:
                                    palette.textPrimary.withValues(alpha: 0.9),
                                selectedForegroundColor: palette.accentOn,
                                selectedBackgroundColor: palette.accent,
                                side: BorderSide(color: palette.surfaceBorder),
                              ),
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
                              style: TextStyle(color: palette.textPrimary),
                              decoration: _field(
                                palette,
                                label: 'Equipo rojo',
                                icon: Icons.circle,
                                color: palette.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _teamBController,
                              maxLength: 12,
                              style: TextStyle(color: palette.textPrimary),
                              decoration: _field(
                                palette,
                                label: 'Equipo azul',
                                icon: Icons.circle,
                                color: palette.blue,
                              ),
                            ),
                            if (_playersPerTeam == 3) ...[
                              const SizedBox(height: 4),
                              TextField(
                                controller: _teamCController,
                                maxLength: 12,
                                style: TextStyle(color: palette.textPrimary),
                                decoration: _field(
                                  palette,
                                  label: 'Equipo verde',
                                  icon: Icons.circle,
                                  color: palette.green,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _start,
                        style: FilledButton.styleFrom(
                          backgroundColor: palette.accent,
                          foregroundColor: palette.accentOn,
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
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _showHelp(palette),
                      icon: Icon(Icons.help_outline, color: palette.accent),
                      label: Text(
                        'Cómo se anota',
                        style: TextStyle(color: palette.accent),
                      ),
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

  void _showHelp(AppPalette palette) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Cómo se anota?'),
        content: Text(
          '• Mano ganada: 1 punto\n'
          '• Envido: 1, 2 o 3 puntos\n'
          '• Truco: 1, 2 o 3 puntos\n'
          '• Sumá y restá con los botones.\n'
          '• El primero en llegar a 30 gana.',
          style: TextStyle(color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
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
            // El símbolo de pica no está en todas las fuentes del sistema.
            fontFamilyFallback: const [
              'Roboto',
              'Noto Sans Symbols 2',
              'DejaVu Sans',
              'Segoe UI Symbol',
            ],
            color: color == Colors.white ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
