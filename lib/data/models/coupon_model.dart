class CouponModel {
  final String id;
  final String code;
  final double discountPercentage;
  final double minSpendUsd;
  final double? maxDiscountUsd;
  final bool isActive;
  final DateTime? expiresAt;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountPercentage,
    this.minSpendUsd = 0.0,
    this.maxDiscountUsd,
    this.isActive = true,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool isValidFor(double subtotalUsd) {
    if (!isActive || isExpired) return false;
    return subtotalUsd >= minSpendUsd;
  }

  double calculateDiscount(double subtotalUsd) {
    if (!isValidFor(subtotalUsd)) return 0.0;
    final rawDiscount = subtotalUsd * (discountPercentage / 100.0);
    if (maxDiscountUsd != null && rawDiscount > maxDiscountUsd!) {
      return maxDiscountUsd!;
    }
    return rawDiscount;
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String,
      code: (json['code'] as String).toUpperCase(),
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      minSpendUsd: (json['min_spend_usd'] as num?)?.toDouble() ?? 0.0,
      maxDiscountUsd: (json['max_discount_usd'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_percentage': discountPercentage,
      'min_spend_usd': minSpendUsd,
      'max_discount_usd': maxDiscountUsd,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
