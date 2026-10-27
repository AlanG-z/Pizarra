import 'package:flutter/material.dart';
import 'package:pizarra/src/app.dart';
import 'package:pizarra/src/services/game_storage.dart';
import 'package:pizarra/src/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameStorage.init();
  ThemeController.instance.load();
  runApp(const MyApp());
}
