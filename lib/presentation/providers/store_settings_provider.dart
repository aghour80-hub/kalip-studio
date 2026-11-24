import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/currency/currency_formatter.dart';

class StoreSettingsState {
  final double usdToKhrRate;
  final double freeShippingThresholdUsd;
  final double standardShippingFeeUsd;
  final String customBannerNotice;

  const StoreSettingsState({
    this.usdToKhrRate = AppConstants.usdToKhrRate,
    this.freeShippingThresholdUsd = AppConstants.freeShippingThresholdUsd,
    this.standardShippingFeeUsd = AppConstants.standardShippingFeeUsd,
    this.customBannerNotice = '',
  });

  StoreSettingsState copyWith({
    double? usdToKhrRate,
    double? freeShippingThresholdUsd,
    double? standardShippingFeeUsd,
    String? customBannerNotice,
  }) {
    return StoreSettingsState(
      usdToKhrRate: usdToKhrRate ?? this.usdToKhrRate,
      freeShippingThresholdUsd: freeShippingThresholdUsd ?? this.freeShippingThresholdUsd,
      standardShippingFeeUsd: standardShippingFeeUsd ?? this.standardShippingFeeUsd,
      customBannerNotice: customBannerNotice ?? this.customBannerNotice,
    );
  }

  Map<String, dynamic> toJson() => {
        'usd_to_khr_rate': usdToKhrRate,
        'free_shipping_threshold_usd': freeShippingThresholdUsd,
        'standard_shipping_fee_usd': standardShippingFeeUsd,
        'custom_banner_notice': customBannerNotice,
      };

  factory StoreSettingsState.fromJson(Map<String, dynamic> json) {
    return StoreSettingsState(
      usdToKhrRate: (json['usd_to_khr_rate'] as num?)?.toDouble() ?? AppConstants.usdToKhrRate,
      freeShippingThresholdUsd: (json['free_shipping_threshold_usd'] as num?)?.toDouble() ?? AppConstants.freeShippingThresholdUsd,
      standardShippingFeeUsd: (json['standard_shipping_fee_usd'] as num?)?.toDouble() ?? AppConstants.standardShippingFeeUsd,
      customBannerNotice: json['custom_banner_notice'] as String? ?? '',
    );
  }
}

/// Persists store-wide exchange rate, shipping policy, and custom boutique announcements.
class StoreSettingsNotifier extends StateNotifier<StoreSettingsState> {
  StoreSettingsNotifier() : super(const StoreSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final raw = prefs.getString(AppConstants.keyStoreSettings);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final loaded = StoreSettingsState.fromJson(decoded);
        CurrencyFormatter.liveExchangeRate = loaded.usdToKhrRate;
        state = loaded;
      }
    } catch (_) {}
  }

  Future<void> updateSettings({
    double? usdToKhrRate,
    double? freeShippingThresholdUsd,
    double? standardShippingFeeUsd,
    String? customBannerNotice,
  }) async {
    final updated = state.copyWith(
      usdToKhrRate: usdToKhrRate,
      freeShippingThresholdUsd: freeShippingThresholdUsd,
      standardShippingFeeUsd: standardShippingFeeUsd,
      customBannerNotice: customBannerNotice,
    );
    CurrencyFormatter.liveExchangeRate = updated.usdToKhrRate;
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyStoreSettings, jsonEncode(updated.toJson()));
    } catch (_) {}
  }

  Future<void> resetToDefaults() async {
    const defaults = StoreSettingsState();
    CurrencyFormatter.liveExchangeRate = defaults.usdToKhrRate;
    state = defaults;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyStoreSettings);
    } catch (_) {}
  }
}

final storeSettingsProvider =
    StateNotifierProvider<StoreSettingsNotifier, StoreSettingsState>((ref) {
  return StoreSettingsNotifier();
});
