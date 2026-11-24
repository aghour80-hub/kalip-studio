import 'cart_item_model.dart';

enum OrderStatus {
  pending('pending', 'Pending Confirmation', 'រង់ចាំការបញ្ជាក់'),
  confirmed('confirmed', 'Order Confirmed', 'បានបញ្ជាក់ការកុម្ម៉ង់'),
  processing('processing', 'Preparing at Atelier', 'កំពុងរៀបចំទំនិញ'),
  delivering('delivering', 'Out for Delivery (Phnom Penh)', 'កំពុងដឹកជញ្ជូន'),
  delivered('delivered', 'Delivered', 'បានទទួលទំនិញរួចរាល់'),
  cancelled('cancelled', 'Cancelled', 'បានលុបចោល');

  final String code;
  final String titleEn;
  final String titleKm;

  const OrderStatus(this.code, this.titleEn, this.titleKm);

  String localized(bool isKhmer) => isKhmer ? titleKm : titleEn;

  static OrderStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'delivering':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final OrderStatus status;
  final List<CartItemModel> items;
  final double subtotalUsd;
  final double deliveryFeeUsd;
  final double discountUsd;
  final double totalUsd;
  final String deliveryAddress;
  final String paymentMethod;
  final String trackingCode;
  final String? customerName;
  final String? phoneNumber;
  final String? province;
  final String? district;
  final String? deliveryNotes;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.status,
    required this.items,
    required this.subtotalUsd,
    required this.deliveryFeeUsd,
    required this.discountUsd,
    required this.totalUsd,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.trackingCode,
    this.customerName,
    this.phoneNumber,
    this.province,
    this.district,
    this.deliveryNotes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, [List<CartItemModel>? items]) {
    final addressSnapshot = json['shipping_address_snapshot'] as Map<String, dynamic>?;
    final parsedItems = items ??
        (json['items'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .where((itemJson) => itemJson['product'] != null)
            .map(CartItemModel.fromStoredJson)
            .toList() ??
        [];

    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String? ?? 'SH-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: OrderStatus.fromString(json['status'] as String?),
      items: parsedItems,
      subtotalUsd: (json['subtotal_usd'] as num).toDouble(),
      deliveryFeeUsd: (json['delivery_fee_usd'] as num?)?.toDouble() ?? 0.0,
      discountUsd: (json['discount_usd'] as num?)?.toDouble() ?? 0.0,
      totalUsd: (json['total_usd'] as num).toDouble(),
      deliveryAddress: addressSnapshot?['street_address'] as String? ??
          json['delivery_address'] as String? ??
          'BKK1, Phnom Penh, Cambodia',
      paymentMethod: json['payment_method'] as String? ?? 'khqr',
      trackingCode: json['tracking_code'] as String? ?? 'VET-PP-001',
      customerName: addressSnapshot?['recipient_name'] as String? ?? json['customer_name'] as String?,
      phoneNumber: addressSnapshot?['phone_number'] as String? ?? json['phone_number'] as String?,
      province: addressSnapshot?['province'] as String? ?? json['province'] as String?,
      district: addressSnapshot?['district'] as String? ?? json['district'] as String?,
      deliveryNotes: json['delivery_notes'] as String?,
    );
  }

  OrderModel copyWith({
    OrderStatus? status,
    String? trackingCode,
    String? paymentMethod,
  }) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      createdAt: createdAt,
      status: status ?? this.status,
      items: items,
      subtotalUsd: subtotalUsd,
      deliveryFeeUsd: deliveryFeeUsd,
      discountUsd: discountUsd,
      totalUsd: totalUsd,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingCode: trackingCode ?? this.trackingCode,
      customerName: customerName,
      phoneNumber: phoneNumber,
      province: province,
      district: district,
      deliveryNotes: deliveryNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
      'status': status.code,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal_usd': subtotalUsd,
      'delivery_fee_usd': deliveryFeeUsd,
      'discount_usd': discountUsd,
      'total_usd': totalUsd,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'tracking_code': trackingCode,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'province': province,
      'district': district,
      'delivery_notes': deliveryNotes,
    };
  }
}
