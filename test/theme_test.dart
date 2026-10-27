import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizarra/src/app.dart';
import 'package:pizarra/src/pages/inicio_page.dart';
import 'package:pizarra/src/pages/truco/score_page.dart';
import 'package:pizarra/src/services/game_storage.dart';
import 'package:pizarra/src/theme/app_palette.dart';
import 'package:pizarra/src/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppPalette', () {
    testWidgets('cada tema expone su paleta vía ThemeExtension',
        (WidgetTester tester) async {
      for (final type in AppThemeType.values) {
        await tester.pumpWidget(
          MaterialApp(theme: buildAppTheme(type), home: const InicioPage()),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(InicioPage));
        final palette = AppPalette.of(context);

        expect(palette.themeType, type);
        expect(palette.backgroundStart, appPalettes[type]!.backgroundStart);
        expect(palette.backgroundEnd, appPalettes[type]!.backgroundEnd);
        expect(palette.brightness, appPalettes[type]!.brightness);
      }
    });

    testWidgets('sin la extensión cae en el paño verde', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: InicioPage()));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(InicioPage));
      expect(AppPalette.of(context).themeType, AppThemeType.felt);
    });

    test('AppThemeType.fromName ignora ids desconocidos', () {
      expect(AppThemeType.fromName('paper'), AppThemeType.paper);
      expect(AppThemeType.fromName('amoled'), AppThemeType.amoled);
      expect(AppThemeType.fromName('otro'), AppThemeType.felt);
      expect(AppThemeType.fromName(null), AppThemeType.felt);
    });

    test('los cuatro temas tienen etiqueta y colores propios', () {
      expect(AppThemeType.values.length, 4);
      for (final type in AppThemeType.values) {
        expect(type.label, isNotEmpty);
        expect(appPalettes[type], isNotNull);
        expect(appPalettes[type]!.themeType, type);
      }
      expect(
        appPalettes.values.map((p) => p.backgroundStart).toSet().length,
        AppThemeType.values.length,
      );
    });

    test('playerColor reparte los seis colores de Chinchón', () {
      final palette = appPalettes[AppThemeType.felt]!;
      final colors = [for (int i = 0; i < 6; i++) palette.playerColor(i)];
      expect(colors.toSet().length, 6);
      expect(palette.playerColor(6), colors.first);
    });
  });

  group('ThemeController', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await GameStorage.init();
      ThemeController.instance.theme.value = AppThemeType.felt;
    });

    tearDown(() => ThemeController.instance.theme.value = AppThemeType.felt);

    test('select cambia el tema y lo guarda', () {
      ThemeController.instance.select(AppThemeType.paper);

      expect(ThemeController.instance.theme.value, AppThemeType.paper);
      expect(GameStorage.instance.loadThemeId(), 'paper');
    });

    testWidgets('elegir un tema en la página de estilo repinta la app',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('TRUCO'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('COMENZAR'));
      await tester.tap(find.text('COMENZAR'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Estilo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Papel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ScorePage));
      expect(AppPalette.of(context).themeType, AppThemeType.paper);
      expect(GameStorage.instance.loadThemeId(), 'paper');
      expect(
        tester
            .widget<MaterialApp>(find.byType(MaterialApp))
            .theme!
            .extension<AppPalette>()!
            .themeType,
        AppThemeType.paper,
      );
    });
  });
}
