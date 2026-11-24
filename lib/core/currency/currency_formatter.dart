import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

enum AppCurrency {
  usd('USD', '\$', 'US Dollar'),
  khr('KHR', '៛', 'Cambodian Riel');

  final String code;
  final String symbol;
  final String name;

  const AppCurrency(this.code, this.symbol, this.name);
}

class CurrencyFormatter {
  static double liveExchangeRate = AppConstants.usdToKhrRate;

  static final NumberFormat _usdFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _khrFormat = NumberFormat.currency(
    symbol: ' ៛',
    decimalDigits: 0,
    customPattern: '#,##0 ¤',
  );

  /// Convert USD amount to current currency and format it
  static String format(double amountInUsd, AppCurrency currency, {double? rate}) {
    final activeRate = rate ?? liveExchangeRate;
    if (currency == AppCurrency.khr) {
      final khrAmount = amountInUsd * activeRate;
      // Round to nearest 100 Riels (standard Cambodian cash & QR practice)
      final roundedKhr = (khrAmount / 100).round() * 100;
      return _khrFormat.format(roundedKhr);
    }
    return _usdFormat.format(amountInUsd);
  }

  /// Show dual price display (e.g. "$120.00 ≈ 492,000 ៛") for maximum Cambodian transparency
  static String formatDual(double amountInUsd, {double? rate}) {
    final activeRate = rate ?? liveExchangeRate;
    final usd = _usdFormat.format(amountInUsd);
    final khr = _khrFormat.format((amountInUsd * activeRate / 100).round() * 100);
    return '$usd (≈ $khr)';
  }
}
