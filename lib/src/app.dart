import 'package:flutter/material.dart';
import 'package:pizarra/src/routes/routes.dart';
import 'package:pizarra/src/theme/app_palette.dart';
import 'package:pizarra/src/theme/theme_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeType>(
      valueListenable: ThemeController.instance.theme,
      builder: (context, themeType, _) {
        return MaterialApp(
          title: 'Pizarra',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(themeType),
          routes: getApplicationRoutes(),
        );
      },
    );
  }
}
