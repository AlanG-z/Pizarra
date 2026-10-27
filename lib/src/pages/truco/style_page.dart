import 'package:flutter/material.dart';
import 'package:pizarra/src/models/truco_style.dart';
import 'package:pizarra/src/theme/app_palette.dart';
import 'package:pizarra/src/theme/theme_controller.dart';
import 'package:pizarra/src/widgets/app_background.dart';
import 'package:pizarra/src/widgets/match_painter.dart';

class StylePage extends StatefulWidget {
  const StylePage({super.key, required this.settings});

  final StyleSettings settings;

  @override
  State<StylePage> createState() => _StylePageState();
}

class _StylePageState extends State<StylePage> {
  static const List<(String, Color)> _stickColors = [
    ('Madera', Color(0xFFD4A574)),
    ('Blanco', Color(0xFFF5F5F0)),
    ('Rojo', Color(0xFFE53935)),
    ('Azul', Color(0xFF42A5F5)),
    ('Verde', Color(0xFF43A047)),
    ('Dorado', Color(0xFFFFD54F)),
  ];

  late StyleSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.backgroundStart,
      appBar: AppBar(
        title: const Text('Estilo'),
        backgroundColor: Colors.transparent,
        foregroundColor: palette.accent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _settings),
            child: Text(
              'Listo',
              style: TextStyle(
                color: palette.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle(palette, 'Tema de la app'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in AppThemeType.values)
                  _choiceChip(
                    palette,
                    label: type.label,
                    selected: ThemeController.instance.theme.value == type,
                    onSelected: () => ThemeController.instance.select(type),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'El tema se aplica a toda la app y queda guardado.',
              style: TextStyle(fontSize: 12, color: palette.textSecondary),
            ),
            const SizedBox(height: 24),
            _sectionTitle(palette, 'Diseño'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final style in StickStyle.values)
                  _choiceChip(
                    palette,
                    label: style.label,
                    selected: _settings.stickStyle == style,
                    onSelected: () {
                      setState(() {
                        _settings = _settings.copyWith(stickStyle: style);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle(palette, 'Color de palitos'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _choiceChip(
                  palette,
                  label: 'Automático',
                  selected: _settings.stickColor == null,
                  onSelected: () {
                    setState(() {
                      _settings = _settings.copyWith(clearStickColor: true);
                    });
                  },
                ),
                for (final entry in _stickColors)
                  _choiceChip(
                    palette,
                    label: entry.$1,
                    selected: _settings.stickColor == entry.$2,
                    swatch: entry.$2,
                    onSelected: () {
                      setState(() {
                        _settings = _settings.copyWith(stickColor: entry.$2);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 28),
            _buildPreview(palette),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(AppPalette palette, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: palette.accent,
        ),
      ),
    );
  }

  Widget _choiceChip(
    AppPalette palette, {
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    Color? swatch,
  }) {
    return ChoiceChip(
      avatar: swatch == null
          ? null
          : CircleAvatar(backgroundColor: swatch, radius: 8),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      backgroundColor: palette.surface,
      selectedColor: palette.accent.withValues(alpha: 0.28),
      labelStyle: TextStyle(
        color: selected ? palette.accent : palette.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? palette.accent : palette.surfaceBorder,
      ),
    );
  }

  Widget _buildPreview(AppPalette palette) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.surfaceBorder),
      ),
      child: Column(
        children: [
          Text(
            'Vista previa',
            style: TextStyle(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _previewSquare(palette, 2),
              _previewSquare(palette, 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewSquare(AppPalette palette, int points) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.divider, width: 1.2),
      ),
      child: CustomPaint(
        painter: MatchStrokesPainter(
          points,
          resolveStickColor(_settings, palette),
          _settings.stickStyle,
        ),
      ),
    );
  }
}
