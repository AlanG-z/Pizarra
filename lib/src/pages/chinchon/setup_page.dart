import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizarra/src/pages/chinchon/score_page.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart' show PlayingCardsIcon;

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
  static const _colors = [
    Color(0xFFE53935),
    Color(0xFF42A5F5),
    Color(0xFF43A047),
    Color(0xFFFFD54F),
    Color(0xFFFF8A50),
    Color(0xFFEC407A),
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

  Widget _buildNameField(int i) {
    final color = _colors[i];
    return TextField(
      controller: _nameControllers[i],
      maxLength: 12,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Jugador ${i + 1}',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.circle, color: color, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chinchon'),
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
                      'CHINCHÓN',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
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
                      'Evitá llegar a 100 · gana el último en pie',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
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
                              'Cantidad de jugadores',
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
                                ButtonSegment(value: 4, label: Text('4')),
                                ButtonSegment(value: 5, label: Text('5')),
                                ButtonSegment(value: 6, label: Text('6')),
                              ],
                              selected: {_playerCount},
                              onSelectionChanged: (s) =>
                                  setState(() => _playerCount = s.first),
                            ),
                            const SizedBox(height: 20),
                            for (int i = 0; i < _playerCount; i++) ...[
                              _buildNameField(i),
                              if (i < _playerCount - 1) const SizedBox(height: 12),
                            ],
                            const SizedBox(height: 20),
                            TextField(
                              controller: _targetController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              maxLength: 4,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Puntos de eliminación',
                                labelStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                prefixIcon: const Icon(Icons.emoji_events,
                                    color: Color(0xFFFFD54F), size: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Color(0xFFFFD54F)),
                                ),
                              ),
                            ),
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
                            '• Si cerrás la ronda anotás 0 puntos.\n'
                            '• Si no cerrás, anotá el valor de las cartas '
                            'que te quedaron sueltas.\n'
                            '• El botón -10 descuenta diez puntos.\n'
                            '• El que llega al límite queda eliminado.\n'
                            '• Gana el último jugador que queda en pie.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
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
