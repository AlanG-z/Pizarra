import 'package:flutter/material.dart';
import 'package:pizarra/src/models/truco_style.dart';

class StylePage extends StatefulWidget {
  const StylePage({super.key, required this.settings});

  final StyleSettings settings;

  @override
  State<StylePage> createState() => _StylePageState();
}

class _StylePageState extends State<StylePage> {
  late StyleSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estilo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _settings),
            child: const Text('Listo',
                style: TextStyle(color: Color(0xFF0B3D2E))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Fondo'),
          Wrap(
            spacing: 8,
            children: [
              _colorOption(Colors.white, 'Blanco'),
              _colorOption(const Color(0xFFF5F0E1), 'Crema'),
              _colorOption(const Color(0xFF0B3D2E), 'Verde'),
              _colorOption(Colors.grey[900]!, 'Oscuro'),
              _colorOption(const Color(0xFFE9E9E7), 'Gris'),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Color de palitos'),
          Wrap(
            spacing: 8,
            children: [
              _colorOption(const Color(0xFFD4A574), 'Madera'),
              _colorOption(const Color(0xFFE53935), 'Rojo'),
              _colorOption(const Color(0xFF42A5F5), 'Azul'),
              _colorOption(const Color(0xFF43A047), 'Verde'),
              _colorOption(const Color(0xFFFFD54F), 'Dorado'),
              _colorOption(const Color(0xFF8D6E63), 'Marrón'),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Diseño'),
          Wrap(
            spacing: 8,
            children: [
              _styleOption(StickStyle.match, 'Fósforos', Icons.local_fire_department),
              _styleOption(StickStyle.stick, 'Palitos', Icons.remove),
              _styleOption(StickStyle.dot, 'Puntos', Icons.fiber_manual_record),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _settings.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                const Text('Vista previa',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _previewSquare(2),
                    _previewSquare(5),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0B3D2E),
        ),
      ),
    );
  }

  Widget _colorOption(Color color, String label) {
    final selected = _settings.stickColor == color ||
        _settings.backgroundColor == color;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          // Distingo fondo vs color de palito por el section title anterior
          // Uso un truco: si el color ya es el stickColor, cambio fondo
          if (_settings.backgroundColor == color) {
            _settings = _settings.copyWith(backgroundColor: null);
          } else if (_settings.stickColor == color) {
            _settings = _settings.copyWith(stickColor: color);
          } else {
            //默认: cambio stickColor
            _settings = _settings.copyWith(stickColor: color);
          }
        });
      },
      selectedColor: color.withValues(alpha: 0.2),
    );
  }

  Widget _styleOption(StickStyle style, String label, IconData icon) {
    final selected = _settings.stickStyle == style;
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _settings = _settings.copyWith(stickStyle: style)),
    );
  }

  Widget _previewSquare(int points) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[600]!, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: _PreviewPainter(
          points,
          _settings.stickColor,
          _settings.stickStyle,
        ),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.points, this.color, this.style);

  final int points;
  final Color color;
  final StickStyle style;

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
      final paint = Paint()
        ..color = style == StickStyle.match ? const Color(0xFFD4A574) : color
        ..strokeWidth = style == StickStyle.match ? s * 0.07 : s * 0.06
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, paint);
      if (style == StickStyle.match) {
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
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.style != style;
}
