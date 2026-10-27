import 'package:flutter/material.dart';

/// Cómo se dibuja cada palito del anotador de Truco.
enum StickStyle { match, stick, dot }

/// Preferencias visuales del anotador de Truco.
class StyleSettings {
  const StyleSettings({
    this.backgroundColor,
    this.stickColor = const Color(0xFFD4A574),
    this.stickStyle = StickStyle.match,
  });

  final Color? backgroundColor;
  final Color stickColor;
  final StickStyle stickStyle;

  StyleSettings copyWith({
    Color? backgroundColor,
    Color? stickColor,
    StickStyle? stickStyle,
  }) {
    return StyleSettings(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      stickColor: stickColor ?? this.stickColor,
      stickStyle: stickStyle ?? this.stickStyle,
    );
  }

  Map<String, dynamic> toJson() => {
        'backgroundColor': backgroundColor?.toARGB32(),
        'stickColor': stickColor.toARGB32(),
        'stickStyle': stickStyle.name,
      };

  factory StyleSettings.fromJson(Map<String, dynamic> json) {
    final background = (json['backgroundColor'] as num?)?.toInt();
    final stick = (json['stickColor'] as num?)?.toInt();
    return StyleSettings(
      backgroundColor: background == null ? null : Color(background),
      stickColor: stick == null ? const Color(0xFFD4A574) : Color(stick),
      stickStyle: StickStyle.values.firstWhere(
        (style) => style.name == json['stickStyle'],
        orElse: () => StickStyle.match,
      ),
    );
  }
}
