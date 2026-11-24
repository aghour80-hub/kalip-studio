import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/localization/app_localizations.dart';

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(AppConstants.keyLanguage);
      if (savedLang != null) {
        state = savedLang;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    if (code == state) return;
    state = code;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLanguage, code);
    } catch (_) {}
  }

  void toggleLanguage() {
    setLanguage(state == 'en' ? 'km' : 'en');
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

final localizationProvider = Provider<AppLocalizations>((ref) {
  final langCode = ref.watch(languageProvider);
  return AppLocalizations(langCode);
});
