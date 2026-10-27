import 'package:flutter/material.dart';
import 'package:pizarra/src/app.dart';
import 'package:pizarra/src/services/game_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameStorage.init();
  runApp(const MyApp());
}
