import 'package:flutter/material.dart';
import 'package:pizarra/src/theme/app_palette.dart';

/// Una acción de la [AppPillBar].
class AppPillAction {
  const AppPillAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Color del ícono y del texto. Por defecto, el texto secundario del tema.
  final Color? color;
}

/// Barra de navegación inferior común a todas las pantallas de Pizarra: una
/// píldora translúcida con el botón de volver (opcional) y las acciones de la
/// pantalla.
class AppPillBar extends StatelessWidget {
  const AppPillBar({
    super.key,
    this.actions = const [],
    this.onBack,
    this.backLabel = 'Volver',
  });

  final List<AppPillAction> actions;

  /// Si es `null` no se muestra el botón de volver (por ejemplo en el inicio,
  /// que es la raíz de la navegación).
  final VoidCallback? onBack;

  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final onBack = this.onBack;
    final items = <Widget>[
      if (onBack != null)
        _PillButton(
          icon: Icons.arrow_back,
          label: backLabel,
          color: palette.textSecondary,
          onTap: onBack,
        ),
      for (final action in actions)
        _PillButton(
          icon: action.icon,
          label: action.label,
          color: action.color ?? palette.textSecondary,
          onTap: action.onTap,
        ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.surfaceBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Flexible (y no Expanded): cada acción usa su ancho natural y se
            // achica con puntos suspensivos si no entra.
            for (final item in items) Flexible(child: item),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
