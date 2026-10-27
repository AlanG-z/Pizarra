import 'package:flutter/material.dart';

/// Tipografía manuscrita incluida como asset (`assets/fonts/PatrickHand-Regular.ttf`).
const String kDisplayFontFamily = 'PatrickHand';

/// Temas visuales disponibles en la app.
enum AppThemeType {
  felt('Paño verde'),
  chalkboard('Pizarrón'),
  paper('Papel'),
  amoled('AMOLED');

  const AppThemeType(this.label);

  final String label;

  static AppThemeType fromName(String? name) => values.firstWhere(
        (theme) => theme.name == name,
        orElse: () => felt,
      );
}

/// Paleta semántica de un tema. Se registra como [ThemeExtension] para que las
/// pantallas la lean con `AppPalette.of(context)`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.themeType,
    required this.brightness,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.accent,
    required this.accentOn,
    required this.surface,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.red,
    required this.blue,
    required this.green,
    required this.chalk,
  });

  /// Tema al que pertenece esta paleta. Ojo: no se llama `type` porque
  /// `ThemeExtension.type` es la clave con la que `Theme.of().extension<T>()`
  /// busca la extensión, y debe devolver el tipo `AppPalette`.
  final AppThemeType themeType;
  final Brightness brightness;
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color accent;
  final Color accentOn;
  final Color surface;
  final Color surfaceBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color red;
  final Color blue;
  final Color green;

  /// Color de los trazos "de tiza" del anotador de Truco.
  final Color chalk;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? appPalettes[AppThemeType.felt]!;

  LinearGradient get background => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [backgroundStart, backgroundEnd],
      );

  Color teamColor(int index) => switch (index % 3) {
        0 => red,
        1 => blue,
        _ => green,
      };

  /// Colores por jugador de Chinchón (Rojo/Azul/Verde/Amarillo/Naranja/Rosa).
  Color playerColor(int index) {
    const yellow = Color(0xFFFFD54F);
    const orange = Color(0xFFFF8A50);
    const pink = Color(0xFFEC407A);
    return [red, blue, green, yellow, orange, pink][index % 6];
  }

  TextStyle display(
    double size, {
    Color? color,
    double? letterSpacing,
    FontWeight weight = FontWeight.w400,
  }) {
    return TextStyle(
      fontFamily: kDisplayFontFamily,
      fontSize: size,
      color: color ?? textPrimary,
      letterSpacing: letterSpacing,
      fontWeight: weight,
      height: 1.1,
    );
  }

  @override
  AppPalette copyWith({
    AppThemeType? themeType,
    Brightness? brightness,
    Color? backgroundStart,
    Color? backgroundEnd,
    Color? accent,
    Color? accentOn,
    Color? surface,
    Color? surfaceBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? red,
    Color? blue,
    Color? green,
    Color? chalk,
  }) {
    return AppPalette(
      themeType: themeType ?? this.themeType,
      brightness: brightness ?? this.brightness,
      backgroundStart: backgroundStart ?? this.backgroundStart,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      accent: accent ?? this.accent,
      accentOn: accentOn ?? this.accentOn,
      surface: surface ?? this.surface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      red: red ?? this.red,
      blue: blue ?? this.blue,
      green: green ?? this.green,
      chalk: chalk ?? this.chalk,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppPalette(
      themeType: t < 0.5 ? themeType : other.themeType,
      brightness: t < 0.5 ? brightness : other.brightness,
      backgroundStart: mix(backgroundStart, other.backgroundStart),
      backgroundEnd: mix(backgroundEnd, other.backgroundEnd),
      accent: mix(accent, other.accent),
      accentOn: mix(accentOn, other.accentOn),
      surface: mix(surface, other.surface),
      surfaceBorder: mix(surfaceBorder, other.surfaceBorder),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      divider: mix(divider, other.divider),
      red: mix(red, other.red),
      blue: mix(blue, other.blue),
      green: mix(green, other.green),
      chalk: mix(chalk, other.chalk),
    );
  }
}

const Map<AppThemeType, AppPalette> appPalettes = {
  AppThemeType.felt: AppPalette(
    themeType: AppThemeType.felt,
    brightness: Brightness.dark,
    backgroundStart: Color(0xFF0B3D2E),
    backgroundEnd: Color(0xFF04180F),
    accent: Color(0xFFFFD54F),
    accentOn: Color(0xFF1B5E20),
    surface: Color(0x14FFFFFF),
    surfaceBorder: Color(0x2EFFFFFF),
    textPrimary: Color(0xFFF7F7F2),
    textSecondary: Color(0xB3FFFFFF),
    divider: Color(0x40FFFFFF),
    red: Color(0xFFFF5252),
    blue: Color(0xFF42A5F5),
    green: Color(0xFF66BB6A),
    chalk: Color(0xFFF5F5F0),
  ),
  AppThemeType.chalkboard: AppPalette(
    themeType: AppThemeType.chalkboard,
    brightness: Brightness.dark,
    backgroundStart: Color(0xFF23292B),
    backgroundEnd: Color(0xFF0E1112),
    accent: Color(0xFFFFD54F),
    accentOn: Color(0xFF1B1B1B),
    surface: Color(0x12FFFFFF),
    surfaceBorder: Color(0x24FFFFFF),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xA6FFFFFF),
    divider: Color(0x3DFFFFFF),
    red: Color(0xFFFF6B6B),
    blue: Color(0xFF64B5F6),
    green: Color(0xFF81C784),
    chalk: Color(0xFFF5F5F0),
  ),
  AppThemeType.paper: AppPalette(
    themeType: AppThemeType.paper,
    brightness: Brightness.light,
    backgroundStart: Color(0xFFF7F3E8),
    backgroundEnd: Color(0xFFE9E2D2),
    accent: Color(0xFFB0821F),
    accentOn: Color(0xFFFFFFFF),
    surface: Color(0xB3FFFFFF),
    surfaceBorder: Color(0x1F000000),
    textPrimary: Color(0xFF2E2A24),
    textSecondary: Color(0xFF6B655C),
    divider: Color(0x33000000),
    red: Color(0xFFD32F2F),
    blue: Color(0xFF1976D2),
    green: Color(0xFF388E3C),
    chalk: Color(0xFF3E3A33),
  ),
  AppThemeType.amoled: AppPalette(
    themeType: AppThemeType.amoled,
    brightness: Brightness.dark,
    backgroundStart: Color(0xFF000000),
    backgroundEnd: Color(0xFF000000),
    accent: Color(0xFFFFD54F),
    accentOn: Color(0xFF101010),
    surface: Color(0xFF0F0F0F),
    surfaceBorder: Color(0x24FFFFFF),
    textPrimary: Color(0xFFEDEDED),
    textSecondary: Color(0xA6FFFFFF),
    divider: Color(0x33FFFFFF),
    red: Color(0xFFFF5252),
    blue: Color(0xFF64B5F6),
    green: Color(0xFF81C784),
    chalk: Color(0xFFEDEDED),
  ),
};

/// Transiciones de solo fade: evitan el flash blanco entre rutas.
class FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

/// Arma el [ThemeData] de un tema de Pizarra.
ThemeData buildAppTheme(AppThemeType type) {
  final palette = appPalettes[type]!;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0B3D2E),
    brightness: palette.brightness,
  ).copyWith(
    primary: palette.accent,
    onPrimary: palette.accentOn,
    secondary: palette.accent,
    onSecondary: palette.accentOn,
    surface: palette.backgroundEnd,
    onSurface: palette.textPrimary,
    error: palette.red,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: palette.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.backgroundEnd,
    extensions: [palette],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadePageTransitionsBuilder(),
        TargetPlatform.iOS: FadePageTransitionsBuilder(),
        TargetPlatform.linux: FadePageTransitionsBuilder(),
        TargetPlatform.macOS: FadePageTransitionsBuilder(),
        TargetPlatform.windows: FadePageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadePageTransitionsBuilder(),
      },
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.surface,
      contentTextStyle: TextStyle(color: palette.textPrimary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.brightness == Brightness.dark
          ? Color.lerp(palette.backgroundStart, Colors.black, 0.25)
          : Colors.white,
      titleTextStyle: TextStyle(
        color: palette.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(color: palette.textSecondary, fontSize: 15),
    ),
  );
}
