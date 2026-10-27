import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pizarra/src/models/truco_style.dart';
import 'package:pizarra/src/theme/app_palette.dart';

/// Color con el que se dibujan los puntos del Truco. Si el usuario no eligió un
/// color ("Automático"), se usa el del tema: tiza clara en los temas oscuros y
/// carbón en el tema claro.
Color resolveStickColor(StyleSettings settings, AppPalette palette) {
  if (settings.stickColor != null) return settings.stickColor!;
  return settings.stickStyle == StickStyle.match
      ? const Color(0xFFD4A574)
      : palette.chalk;
}

/// Dibuja un cuadrado de palitos (0 a 5) con el estilo elegido.
class MatchStrokesPainter extends CustomPainter {
  MatchStrokesPainter(this.points, this.color, this.style);

  final int points;
  final Color color;
  final StickStyle style;

  static const Color _wood = Color(0xFFD4A574);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final pad = s * 0.1;

    final tl = Offset(pad, pad);
    final tr = Offset(s - pad, pad);
    final bl = Offset(pad, s - pad);
    final br = Offset(s - pad, s - pad);

    void chalkLine(Offset from, Offset to, int seed) {
      final jitter = s * 0.022;

      Offset wobble(Offset point, int axis) => Offset(
            point.dx + math.sin(seed * 12.9898 + axis * 4.1414) * jitter,
            point.dy + math.cos(seed * 78.233 + axis * 2.7183) * jitter,
          );

      final start = wobble(from, 1);
      final end = wobble(to, 2);

      final main = Paint()
        ..color = color.withValues(alpha: 0.95)
        ..strokeWidth = s * 0.055
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, end, main);

      // Segunda pasada apenas corrida: da la textura irregular de la tiza.
      final grain = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        start.translate(jitter * 0.6, jitter * 0.4),
        end.translate(-jitter * 0.3, jitter * 0.5),
        grain,
      );
    }

    void element(Offset from, Offset to, int seed) {
      switch (style) {
        case StickStyle.dot:
          final paint = Paint()..color = color;
          canvas.drawCircle(from, s * 0.055, paint);
          canvas.drawCircle(to, s * 0.055, paint);
        case StickStyle.chalk:
          chalkLine(from, to, seed);
        case StickStyle.match:
          final paint = Paint()
            ..color = _wood
            ..strokeWidth = s * 0.07
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(from, to, paint);
          canvas.drawCircle(from, s * 0.075, Paint()..color = color);
        case StickStyle.stick:
          final paint = Paint()
            ..color = color
            ..strokeWidth = s * 0.06
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(from, to, paint);
      }
    }

    if (points >= 1) element(tl, tr, 1);
    if (points >= 2) element(tl, bl, 2);
    if (points >= 3) element(tr, br, 3);
    if (points >= 4) element(bl, br, 4);
    if (points >= 5) element(tl, br, 5);
  }

  @override
  bool shouldRepaint(covariant MatchStrokesPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.style != style;
}

/// Línea punteada, como una rayita de tiza entre las malas y las buenas.
class DashedLinePainter extends CustomPainter {
  DashedLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const dash = 5.0;
    const gap = 5.0;
    final y = size.height / 2;
    for (double x = 0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dash, size.width), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
