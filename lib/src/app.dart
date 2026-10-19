import 'package:flutter/material.dart';
import 'package:pizarra/src/routes/reoutes.dart';

class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadePageTransitionsBuilder();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizarra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B3D2E),
        ),
        // Transiciones de solo fade en todas las plataformas: evita el flash
        // blanco que producen los builders con zoom/slide por defecto.
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FadePageTransitionsBuilder(),
            TargetPlatform.iOS: _FadePageTransitionsBuilder(),
            TargetPlatform.linux: _FadePageTransitionsBuilder(),
            TargetPlatform.macOS: _FadePageTransitionsBuilder(),
            TargetPlatform.windows: _FadePageTransitionsBuilder(),
            TargetPlatform.fuchsia: _FadePageTransitionsBuilder(),
          },
        ),
      ),
      routes: getAplicationRoutes(),
    );
  }
}
