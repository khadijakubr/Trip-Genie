import 'package:shared_preferences/shared_preferences.dart';


class AppPreferences {
  
  static const String _hasSeenOnboarding = 'has_seen_onboarding';  
  static const String _isLoggedIn = 'is_logged_in';

  // ONBOARDING
  static Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboarding, value);
  }

  static Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboarding) ?? false;
  }

  // LOGIN STATE
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedIn, value);
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedIn) ?? false;
  }

  // LOGOUT — hapus semua data lokal
  // hasSeenOnboarding tidak dihapus agar user tidak lihat onboarding lagi
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedIn);
  }
}