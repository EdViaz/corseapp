import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _darkModeKey = 'dark_mode';
  static const String _favoritesKey = 'favorite_drivers';
  static const String _primaryColorKey = 'primary_color';
  static const String _fontSizeKey = 'font_size';
  static const String _welcomeKey = 'welcome_shown';

  // Singleton pattern
  static final PreferencesService _instance = PreferencesService._internal();

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();


  // Gestione piloti preferiti
  Future<List<int>> getFavoriteDrivers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesStr = prefs.getStringList(_favoritesKey);
    if (favoritesStr == null) return [];

    return favoritesStr
        .map((str) => int.tryParse(str))
        .where((id) => id != null)
        .map((id) => id!)
        .toList();
  }

  Future<void> addFavoriteDriver(int driverId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesStr = prefs.getStringList(_favoritesKey) ?? [];

    if (!favoritesStr.contains(driverId.toString())) {
      favoritesStr.add(driverId.toString());
      await prefs.setStringList(_favoritesKey, favoritesStr);
    }
  }

  Future<void> removeFavoriteDriver(int driverId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesStr = prefs.getStringList(_favoritesKey) ?? [];

    favoritesStr.remove(driverId.toString());
    await prefs.setStringList(_favoritesKey, favoritesStr);
  }

  Future<bool> isDriverFavorite(int driverId) async {
    final favorites = await getFavoriteDrivers();
    return favorites.contains(driverId);
  }

  // Gestione colore primario dell'app
  Future<int> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    // Colore rosso F1 come default
    return prefs.getInt(_primaryColorKey) ?? 0xFFE10600;
  }

  Future<void> setPrimaryColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, colorValue);
  }

  // Gestione dimensione font
  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    // Dimensione font predefinita
    return prefs.getDouble(_fontSizeKey) ?? 1.0;
  }

  Future<void> setFontSize(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, scale);
  }

  // Gestione schermata di benvenuto
  Future<bool> isWelcomeShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeKey) ?? false;
  }

  Future<void> setWelcomeShown(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, value);
  }

  // Resetta tutte le preferenze
  Future<void> resetAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_darkModeKey);
    await prefs.remove(_favoritesKey);
    await prefs.remove(_primaryColorKey);
    await prefs.remove(_fontSizeKey);
    await prefs.remove(_welcomeKey);
  }
}
