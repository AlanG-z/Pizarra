import 'dart:async';
import 'dart:convert';

import 'package:pizarra/src/models/chinchon_game.dart';
import 'package:pizarra/src/models/truco_game.dart';
import 'package:pizarra/src/models/truco_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda la partida en curso y las preferencias visuales en
/// `SharedPreferences`, para poder retomarlas al volver a abrir la app.
///
/// [init] debe llamarse una vez antes de usar la instancia. Si no se inicializó
/// (por ejemplo en un widget test que no prueba persistencia), las lecturas
/// devuelven `null` y las escrituras no hacen nada.
class GameStorage {
  GameStorage._();

  static final GameStorage instance = GameStorage._();

  static const String trucoKey = 'pizarra.truco.game.v1';
  static const String chinchonKey = 'pizarra.chinchon.game.v1';
  static const String styleKey = 'pizarra.truco.style.v1';
  static const String themeKey = 'pizarra.theme.v1';

  SharedPreferences? _prefs;

  bool get isReady => _prefs != null;

  static Future<void> init() async {
    instance._prefs = await SharedPreferences.getInstance();
  }

  TrucoGame? loadTruco() => _read(trucoKey, TrucoGame.fromJson);

  void saveTruco(TrucoGame game) => _write(trucoKey, game.toJson());

  void clearTruco() => _remove(trucoKey);

  ChinchonGame? loadChinchon() => _read(chinchonKey, ChinchonGame.fromJson);

  void saveChinchon(ChinchonGame game) => _write(chinchonKey, game.toJson());

  void clearChinchon() => _remove(chinchonKey);

  StyleSettings? loadStyle() => _read(styleKey, StyleSettings.fromJson);

  void saveStyle(StyleSettings style) => _write(styleKey, style.toJson());

  String? loadThemeId() => _prefs?.getString(themeKey);

  void saveThemeId(String id) => unawaited(_prefs?.setString(themeKey, id));

  T? _read<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs?.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return fromJson(decoded);
    } catch (_) {
      // Datos corruptos o de una versión anterior: se ignoran.
      return null;
    }
  }

  void _write(String key, Map<String, dynamic> json) {
    final prefs = _prefs;
    if (prefs == null) return;
    unawaited(prefs.setString(key, jsonEncode(json)));
  }

  void _remove(String key) {
    unawaited(_prefs?.remove(key));
  }
}
