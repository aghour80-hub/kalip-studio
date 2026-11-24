import 'package:style_house/core/constants/app_constants.dart';

class CodService {
  /// Rounds Cambodian Riels to nearest 100 riels according to local currency customs
  static int roundToNearest100Riels(double rielAmount) {
    return ((rielAmount / 100.0).round()) * 100;
  }

  /// Calculates dual cash breakdown for courier cash handover
  static Map<String, dynamic> calculateCashBreakdown({
    required double totalUsd,
    double exchangeRate = AppConstants.usdToKhrRate,
  }) {
    final rawRiels = totalUsd * exchangeRate;
    final roundedRiels = roundToNearest100Riels(rawRiels);

    return {
      'total_usd': totalUsd,
      'formatted_usd': '\$${totalUsd.toStringAsFixed(2)}',
      'total_khr': roundedRiels,
      'formatted_khr': '${roundedRiels.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ៛',
      'exchange_rate': exchangeRate,
      'suggested_usd_notes': getSuggestedUsdNotes(totalUsd),
    };
  }

  static List<String> getSuggestedUsdNotes(double amount) {
    if (amount <= 10) return ['\$10 note', '\$20 note'];
    if (amount <= 20) return ['\$20 note', '\$50 note'];
    if (amount <= 50) return ['\$50 note', '\$100 note'];
    return ['\$100 note', 'Exact amount'];
  }

  static String getHandoverInstructionEn(double totalUsd) {
    final breakdown = calculateCashBreakdown(totalUsd: totalUsd);
    return 'Please prepare either ${breakdown['formatted_usd']} or ${breakdown['formatted_khr']} in cash upon courier arrival.';
  }

  static String getHandoverInstructionKm(double totalUsd) {
    final breakdown = calculateCashBreakdown(totalUsd: totalUsd);
    return 'សូមរៀបចំសាច់ប្រាក់ចំនួន ${breakdown['formatted_usd']} ឬ ${breakdown['formatted_khr']} ពេលអ្នកដឹកជញ្ជូនមកដល់។';
  }
}
