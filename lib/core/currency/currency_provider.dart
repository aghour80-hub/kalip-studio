import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/currency/currency_formatter.dart';

class CurrencyNotifier extends StateNotifier<AppCurrency> {
  CurrencyNotifier() : super(AppCurrency.usd) {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(AppConstants.keyCurrency);
      if (code != null) {
        state = AppCurrency.values.firstWhere(
          (c) => c.code == code,
          orElse: () => AppCurrency.usd,
        );
      }
    } catch (_) {}
  }

  Future<void> setCurrency(AppCurrency currency) async {
    if (currency == state) return;
    state = currency;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyCurrency, currency.code);
    } catch (_) {}
  }

  void toggleCurrency() {
    setCurrency(state == AppCurrency.usd ? AppCurrency.khr : AppCurrency.usd);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, AppCurrency>((ref) {
  return CurrencyNotifier();
});
