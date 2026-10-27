import 'package:flutter/material.dart';

import 'package:pizarra/src/pages/chinchon/setup_page.dart';
import 'package:pizarra/src/pages/inicio_page.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart';

/// Rutas con nombre de la aplicación.
Map<String, WidgetBuilder> getApplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (context) => const InicioPage(),
    '/setup': (context) => const SetupPage(),
    '/chinchon-setup': (context) => const ChinchonSetupPage(),
  };
}
