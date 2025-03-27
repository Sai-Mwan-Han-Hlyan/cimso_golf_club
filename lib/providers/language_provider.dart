import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  bool get isThai => _locale.languageCode == 'th';
  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguageFromPrefs();
  }

  // Load the saved language from SharedPreferences
  Future<void> _loadLanguageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    final countryCode = prefs.getString('countryCode') ?? 'US';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  // Save the current language to SharedPreferences
  Future<void> _saveLanguageToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', _locale.languageCode);
    prefs.setString('countryCode', _locale.countryCode ?? '');
  }

  // Toggle between English and Thai
  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('th', 'TH');
    } else {
      _locale = const Locale('en', 'US');
    }
    _saveLanguageToPrefs();
    notifyListeners();
  }

  // Set specific language
  void setLanguage(String languageCode, String countryCode) {
    _locale = Locale(languageCode, countryCode);
    _saveLanguageToPrefs();
    notifyListeners();
  }
}