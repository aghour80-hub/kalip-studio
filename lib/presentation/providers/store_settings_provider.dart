import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/payment/khqr_service.dart';

class StoreCoupon {
  final String code;
  final double discountPercent; // e.g. 10.0 = 10%
  final double minSpendUsd;
  final bool isActive;

  const StoreCoupon({
    required this.code,
    required this.discountPercent,
    this.minSpendUsd = 0.0,
    this.isActive = true,
  });

  double get discountFraction => (discountPercent / 100.0).clamp(0.0, 0.9);

  StoreCoupon copyWith({
    String? code,
    double? discountPercent,
    double? minSpendUsd,
    bool? isActive,
  }) {
    return StoreCoupon(
      code: code ?? this.code,
      discountPercent: discountPercent ?? this.discountPercent,
      minSpendUsd: minSpendUsd ?? this.minSpendUsd,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'discount_percent': discountPercent,
        'min_spend_usd': minSpendUsd,
        'is_active': isActive,
      };

  factory StoreCoupon.fromJson(Map<String, dynamic> json) {
    return StoreCoupon(
      code: (json['code'] as String? ?? '').toUpperCase(),
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 10.0,
      minSpendUsd: (json['min_spend_usd'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class StoreSettingsState {
  static const List<StoreCoupon> defaultCoupons = [
    StoreCoupon(code: 'STYLE10', discountPercent: 10, minSpendUsd: 0),
    StoreCoupon(code: 'VIP10', discountPercent: 10, minSpendUsd: 0),
    StoreCoupon(code: 'CAMBODIA', discountPercent: 10, minSpendUsd: 0),
    StoreCoupon(code: 'LUXURY20', discountPercent: 20, minSpendUsd: 100),
  ];

  final double usdToKhrRate;
  final double freeShippingThresholdUsd;
  final double standardShippingFeeUsd;
  final String customBannerNotice;
  final List<StoreCoupon> coupons;
  final String? customQrImageData;
  final String bankName;
  final String bankAccountName;
  final String bankAccountUsd;
  final String bankAccountKhr;

  const StoreSettingsState({
    this.usdToKhrRate = AppConstants.usdToKhrRate,
    this.freeShippingThresholdUsd = AppConstants.freeShippingThresholdUsd,
    this.standardShippingFeeUsd = AppConstants.standardShippingFeeUsd,
    this.customBannerNotice = '',
    this.coupons = defaultCoupons,
    this.customQrImageData,
    this.bankName = KhqrService.abaBankName,
    this.bankAccountName = KhqrService.abaAccountName,
    this.bankAccountUsd = KhqrService.abaAccountUsd,
    this.bankAccountKhr = KhqrService.abaAccountKhr,
  });

  String get effectiveQrImage =>
      (customQrImageData != null && customQrImageData!.isNotEmpty)
          ? customQrImageData!
          : KhqrService.abaQrAssetPath;

  String get bankAccountUsdRaw => bankAccountUsd.replaceAll(' ', '');
  String get bankAccountKhrRaw => bankAccountKhr.replaceAll(' ', '');

  StoreSettingsState copyWith({
    double? usdToKhrRate,
    double? freeShippingThresholdUsd,
    double? standardShippingFeeUsd,
    String? customBannerNotice,
    List<StoreCoupon>? coupons,
    String? customQrImageData,
    bool clearCustomQr = false,
    String? bankName,
    String? bankAccountName,
    String? bankAccountUsd,
    String? bankAccountKhr,
  }) {
    return StoreSettingsState(
      usdToKhrRate: usdToKhrRate ?? this.usdToKhrRate,
      freeShippingThresholdUsd: freeShippingThresholdUsd ?? this.freeShippingThresholdUsd,
      standardShippingFeeUsd: standardShippingFeeUsd ?? this.standardShippingFeeUsd,
      customBannerNotice: customBannerNotice ?? this.customBannerNotice,
      coupons: coupons ?? this.coupons,
      customQrImageData: clearCustomQr ? null : (customQrImageData ?? this.customQrImageData),
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountUsd: bankAccountUsd ?? this.bankAccountUsd,
      bankAccountKhr: bankAccountKhr ?? this.bankAccountKhr,
    );
  }

  Map<String, dynamic> toJson() => {
        'usd_to_khr_rate': usdToKhrRate,
        'free_shipping_threshold_usd': freeShippingThresholdUsd,
        'standard_shipping_fee_usd': standardShippingFeeUsd,
        'custom_banner_notice': customBannerNotice,
        'coupons': coupons.map((c) => c.toJson()).toList(),
        'custom_qr_image_data': customQrImageData,
        'bank_name': bankName,
        'bank_account_name': bankAccountName,
        'bank_account_usd': bankAccountUsd,
        'bank_account_khr': bankAccountKhr,
      };

  factory StoreSettingsState.fromJson(Map<String, dynamic> json) {
    final parsedCoupons = (json['coupons'] as List<dynamic>?)
        ?.whereType<Map<String, dynamic>>()
        .map(StoreCoupon.fromJson)
        .where((c) => c.code.isNotEmpty)
        .toList();

    return StoreSettingsState(
      usdToKhrRate: (json['usd_to_khr_rate'] as num?)?.toDouble() ?? AppConstants.usdToKhrRate,
      freeShippingThresholdUsd: (json['free_shipping_threshold_usd'] as num?)?.toDouble() ?? AppConstants.freeShippingThresholdUsd,
      standardShippingFeeUsd: (json['standard_shipping_fee_usd'] as num?)?.toDouble() ?? AppConstants.standardShippingFeeUsd,
      customBannerNotice: json['custom_banner_notice'] as String? ?? '',
      coupons: (parsedCoupons != null && parsedCoupons.isNotEmpty) ? parsedCoupons : defaultCoupons,
      customQrImageData: json['custom_qr_image_data'] as String?,
      bankName: json['bank_name'] as String? ?? KhqrService.abaBankName,
      bankAccountName: json['bank_account_name'] as String? ?? KhqrService.abaAccountName,
      bankAccountUsd: json['bank_account_usd'] as String? ?? KhqrService.abaAccountUsd,
      bankAccountKhr: json['bank_account_khr'] as String? ?? KhqrService.abaAccountKhr,
    );
  }
}

/// Persists store-wide exchange rate, shipping policy, owner coupons, and custom bank QR.
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
        if (mounted) state = loaded;
      }
    } catch (_) {}
  }

  Future<void> _persist(StoreSettingsState next) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyStoreSettings, jsonEncode(next.toJson()));
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
    if (mounted) state = updated;
    await _persist(updated);
  }

  Future<void> updateBankQr({
    String? customQrImageData,
    bool clearCustomQr = false,
    String? bankName,
    String? bankAccountName,
    String? bankAccountUsd,
    String? bankAccountKhr,
  }) async {
    final updated = state.copyWith(
      customQrImageData: customQrImageData,
      clearCustomQr: clearCustomQr,
      bankName: bankName,
      bankAccountName: bankAccountName,
      bankAccountUsd: bankAccountUsd,
      bankAccountKhr: bankAccountKhr,
    );
    if (mounted) state = updated;
    await _persist(updated);
  }

  Future<void> addOrUpdateCoupon(StoreCoupon coupon) async {
    final normalized = coupon.copyWith(code: coupon.code.trim().toUpperCase());
    if (normalized.code.isEmpty) return;

    final exists = state.coupons.any((c) => c.code == normalized.code);
    final nextList = exists
        ? state.coupons.map((c) => c.code == normalized.code ? normalized : c).toList()
        : [normalized, ...state.coupons];

    final updated = state.copyWith(coupons: nextList);
    if (mounted) state = updated;
    await _persist(updated);
  }

  Future<void> toggleCoupon(String code) async {
    final nextList = state.coupons.map((c) {
      if (c.code == code) return c.copyWith(isActive: !c.isActive);
      return c;
    }).toList();
    final updated = state.copyWith(coupons: nextList);
    if (mounted) state = updated;
    await _persist(updated);
  }

  Future<void> deleteCoupon(String code) async {
    final nextList = state.coupons.where((c) => c.code != code).toList();
    final updated = state.copyWith(coupons: nextList);
    if (mounted) state = updated;
    await _persist(updated);
  }

  Future<void> resetToDefaults() async {
    const defaults = StoreSettingsState();
    CurrencyFormatter.liveExchangeRate = defaults.usdToKhrRate;
    if (mounted) state = defaults;
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
