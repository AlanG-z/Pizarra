import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizarra/src/pages/chinchon/score_page.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart' show PlayingCardsIcon;
import 'package:pizarra/src/theme/app_palette.dart';
import 'package:pizarra/src/widgets/app_background.dart';
import 'package:pizarra/src/widgets/fade_slide_in.dart';

class ChinchonSetupPage extends StatefulWidget {
  const ChinchonSetupPage({super.key});

  @override
  State<ChinchonSetupPage> createState() => _ChinchonSetupPageState();
}

class _ChinchonSetupPageState extends State<ChinchonSetupPage> {
  static const _defaults = [
    'Rojo',
    'Azul',
    'Verde',
    'Amarillo',
    'Naranja',
    'Rosa',
  ];

  int _playerCount = 2;
  late final List<TextEditingController> _nameControllers;
  final TextEditingController _targetController =
      TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _nameControllers = [
      for (final name in _defaults)
        TextEditingController(text: name),
    ];
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    _targetController.dispose();
    super.dispose();
  }

  void _start() {
    final names = [
      for (int i = 0; i < _playerCount; i++)
        _nameControllers[i].text.trim().isEmpty
            ? _defaults[i]
            : _nameControllers[i].text.trim(),
    ];
    final target = int.tryParse(_targetController.text.trim()) ?? 100;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ChinchonScorePage(playerNames: names, target: target),
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
        title: const Text('Chinchón'),
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
                      'CHINCHÓN',
                      style: palette.display(
                        44,
                        color: palette.accent,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Evitá llegar al límite · gana el último en pie',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: palette.textSecondary,
                        letterSpacing: 1.2,
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
                              'Cantidad de jugadores',
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
                                ButtonSegment(value: 4, label: Text('4')),
                                ButtonSegment(value: 5, label: Text('5')),
                                ButtonSegment(value: 6, label: Text('6')),
                              ],
                              selected: {_playerCount},
                              onSelectionChanged: (s) =>
                                  setState(() => _playerCount = s.first),
                            ),
                            const SizedBox(height: 18),
                            for (int i = 0; i < _playerCount; i++) ...[
                              TextField(
                                controller: _nameControllers[i],
                                maxLength: 12,
                                style: TextStyle(color: palette.textPrimary),
                                decoration: _field(
                                  palette,
                                  label: 'Jugador ${i + 1}',
                                  icon: Icons.circle,
                                  color: palette.playerColor(i),
                                ),
                              ),
                              if (i < _playerCount - 1)
                                const SizedBox(height: 2),
                            ],
                            const SizedBox(height: 6),
                            TextField(
                              controller: _targetController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 4,
                              style: TextStyle(color: palette.textPrimary),
                              decoration: _field(
                                palette,
                                label: 'Puntos de eliminación',
                                icon: Icons.emoji_events_outlined,
                                color: palette.accent,
                              ),
                            ),
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
          '• Si cerrás la ronda anotás 0 puntos.\n'
          '• Si no cerrás, anotá el valor de las cartas '
          'que te quedaron sueltas.\n'
          '• El botón -10 descuenta diez puntos.\n'
          '• El que llega al límite queda eliminado.\n'
          '• Gana el último jugador que queda en pie.',
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
