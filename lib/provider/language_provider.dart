import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _preferredLanguageKey = 'preferredLanguage';
  
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  bool get isSwahili => _currentLocale.languageCode == 'sw';
  bool get isEnglish => _currentLocale.languageCode == 'en';
  
  LanguageProvider() {
    _loadPreferredLanguage();
  }
  
  Future<void> _loadPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_preferredLanguageKey);
    final legacyLanguage = prefs.getString('selected_language');
    final languageCode = savedCode ??
        (legacyLanguage == 'Kiswahili' ? 'sw' : legacyLanguage == 'English' ? 'en' : 'en');
    _currentLocale = Locale(languageCode);
    if (savedCode == null && legacyLanguage != null) {
      await prefs.setString(_preferredLanguageKey, languageCode);
    }
    notifyListeners();
  }
  
  Future<void> _savePreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredLanguageKey, _currentLocale.languageCode);
  }
  
  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await _savePreferredLanguage();
    notifyListeners();
  }
  
  Future<void> setEnglish() async {
    await setLanguage('en');
  }
  
  Future<void> setSwahili() async {
    await setLanguage('sw');
  }
  
  void toggleLanguage() {
    if (isEnglish) {
      setSwahili();
    } else {
      setEnglish();
    }
  }
}
