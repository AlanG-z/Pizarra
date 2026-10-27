import 'package:flutter/material.dart';
import 'package:pizarra/src/theme/app_palette.dart';

/// Fondo con el degradé del tema activo.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: palette.background),
      child: child,
    );
  }
}
