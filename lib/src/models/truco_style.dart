import 'package:flutter/material.dart';

/// Cómo se dibuja cada palito del anotador de Truco.
enum StickStyle {
  chalk('Tiza'),
  match('Fósforos'),
  stick('Palitos'),
  dot('Puntos');

  const StickStyle(this.label);

  final String label;
}

/// Preferencias visuales del anotador de Truco.
class StyleSettings {
  const StyleSettings({
    this.stickColor,
    this.stickStyle = StickStyle.chalk,
  });

  /// `null` = automático (usa el color de tiza del tema activo).
  final Color? stickColor;
  final StickStyle stickStyle;

  StyleSettings copyWith({
    Color? stickColor,
    StickStyle? stickStyle,
    bool clearStickColor = false,
  }) {
    return StyleSettings(
      stickColor: clearStickColor ? null : (stickColor ?? this.stickColor),
      stickStyle: stickStyle ?? this.stickStyle,
    );
  }

  Map<String, dynamic> toJson() => {
        'stickColor': stickColor?.toARGB32(),
        'stickStyle': stickStyle.name,
      };

  factory StyleSettings.fromJson(Map<String, dynamic> json) {
    final stick = (json['stickColor'] as num?)?.toInt();
    return StyleSettings(
      stickColor: stick == null ? null : Color(stick),
      stickStyle: StickStyle.values.firstWhere(
        (style) => style.name == json['stickStyle'],
        orElse: () => StickStyle.chalk,
      ),
    );
  }
}
