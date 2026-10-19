import 'package:flutter/material.dart';
import 'package:pizarra/src/pages/chinchon/setup_page.dart';
import 'package:pizarra/src/pages/inicio_page.dart';
import 'package:pizarra/src/pages/truco/setup_page.dart';

Map<String,WidgetBuilder>getAplicationRoutes(){
  return <String,WidgetBuilder>{
    '/': (context) => const InicioPage(),
    '/setup': (context) => const SetupPage(),
    '/chinchon-setup': (context) => const ChinchonSetupPage(),
  };
}