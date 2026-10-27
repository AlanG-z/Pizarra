import 'package:flutter/foundation.dart';
import 'package:pizarra/src/services/game_storage.dart';
import 'package:pizarra/src/theme/app_palette.dart';

/// Tema visual activo. Se guarda en `SharedPreferences` y `MyApp` escucha sus
/// cambios para reconstruir toda la app.
class ThemeController {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  final ValueNotifier<AppThemeType> theme =
      ValueNotifier<AppThemeType>(AppThemeType.felt);

  /// Llama a [GameStorage.init] antes.
  void load() {
    theme.value = AppThemeType.fromName(GameStorage.instance.loadThemeId());
  }

  void select(AppThemeType type) {
    if (theme.value == type) return;
    theme.value = type;
    GameStorage.instance.saveThemeId(type.name);
  }
}
