import 'package:shared_preferences/shared_preferences.dart';

/// Cached, synchronously-readable copy of settings that are checked
/// on hot paths (e.g. every button tap) where an async prefs lookup
/// would be too slow. Loaded once at startup and kept in sync by
/// [setHaptic] whenever the user changes it in Settings.
class AppSettings {
  AppSettings._();

  static bool haptic = true;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    haptic = p.getBool('haptic') ?? true;
  }

  static Future<void> setHaptic(bool value) async {
    haptic = value;
    final p = await SharedPreferences.getInstance();
    await p.setBool('haptic', value);
  }
}
