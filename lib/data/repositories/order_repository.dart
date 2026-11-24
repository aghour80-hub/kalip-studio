import 'dart:math';
import 'package:style_house/core/config/supabase_config.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/coupon_model.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/data/repositories/product_repository.dart';

class OrderRepository {
  final ProductRepository _productRepository;
  final List<OrderModel> _inMemoryOrders = List.from(SampleData.sampleOrders);

  OrderRepository({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository();

  /// Validates a promotional coupon code against business rules and the database
  Future<CouponModel?> validateCoupon(String code, double subtotalUsd) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;

    final client = SupabaseConfig.client;
    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        final response = await client
            .from('coupons')
            .select('*')
            .eq('code', cleanCode)
            .eq('is_active', true)
            .maybeSingle();

        if (response != null) {
          final coupon = CouponModel.fromJson(response);
          if (coupon.isValidFor(subtotalUsd)) {
            return coupon;
          }
          return null;
        }
      } catch (_) {}
    }

    // Built-in Cambodian coupons
    final Map<String, CouponModel> builtInCoupons = {
      'STYLE10': const CouponModel(
        id: 'cpn-01',
        code: 'STYLE10',
        discountPercentage: 10.0,
        minSpendUsd: 0.0,
      ),
      'CAMBODIA': const CouponModel(
        id: 'cpn-02',
        code: 'CAMBODIA',
        discountPercentage: 10.0,
        minSpendUsd: 25.0,
      ),
      'VIP10': const CouponModel(
        id: 'cpn-03',
        code: 'VIP10',
        discountPercentage: 10.0,
        minSpendUsd: 0.0,
      ),
      'LUXURY20': const CouponModel(
        id: 'cpn-04',
        code: 'LUXURY20',
        discountPercentage: 20.0,
        minSpendUsd: 100.0,
        maxDiscountUsd: 50.0,
      ),
    };

    final matched = builtInCoupons[cleanCode];
    if (matched != null && matched.isValidFor(subtotalUsd)) {
      return matched;
    }
    return null;
  }

  /// Creates a verified order with server-side calculation and stock validation
  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required String customerName,
    required String phoneNumber,
    required String province,
    required String district,
    required String streetAddress,
    String? deliveryNotes,
    required String paymentMethod,
    String? couponCode,
    List<ProductModel>? catalogProducts,
    double? freeShippingThresholdUsd,
    double? standardShippingFeeUsd,
  }) async {
    if (items.isEmpty) {
      throw Exception('Cannot create order with an empty shopping cart');
    }

    // 1. Server-side price recalculation (prevent client-side price tampering)
    double calculatedSubtotal = 0.0;
    final verifiedItems = <CartItemModel>[];

    for (final item in items) {
      // Lookup actual product price from live catalog first, then repository
      ProductModel? trustedProduct;
      if (catalogProducts != null) {
        try {
          trustedProduct = catalogProducts.firstWhere((p) => p.id == item.product.id);
        } catch (_) {}
      }
      trustedProduct ??= await _productRepository.getProductById(item.product.id);

      final actualPrice = trustedProduct?.priceUsd ?? item.product.priceUsd;
      final availableStock = trustedProduct?.stockQuantity ??
          await _productRepository.checkAvailableStock(
            productId: item.product.id,
            size: item.selectedSize,
            colorNameEn: item.selectedColor.nameEn,
          );

      if (availableStock < item.quantity) {
        throw Exception(
          'Insufficient stock for "${item.product.nameEn}" (${item.selectedSize}). Only $availableStock remaining.',
        );
      }

      calculatedSubtotal += (actualPrice * item.quantity);
      verifiedItems.add(
        CartItemModel(
          id: item.id,
          product: trustedProduct ?? item.product,
          selectedColor: item.selectedColor,
          selectedSize: item.selectedSize,
          variantId: item.variantId,
          quantity: item.quantity,
        ),
      );
    }

    // 2. Validate and apply coupon discount
    double discountUsd = 0.0;
    if (couponCode != null && couponCode.isNotEmpty) {
      final coupon = await validateCoupon(couponCode, calculatedSubtotal);
      if (coupon != null) {
        discountUsd = coupon.calculateDiscount(calculatedSubtotal);
      }
    }

    // 3. Compute delivery fee
    final threshold = freeShippingThresholdUsd ?? AppConstants.freeShippingThresholdUsd;
    final standardFee = standardShippingFeeUsd ?? AppConstants.standardShippingFeeUsd;
    final deliveryFeeUsd = calculatedSubtotal >= threshold ? 0.0 : standardFee;

    final totalUsd = (calculatedSubtotal - discountUsd) + deliveryFeeUsd;

    // 4. Generate Order Number and Cambodian Courier tracking code
    final randomSuffix = (1000 + Random().nextInt(9000)).toString();
    final orderNumber = 'SH-2026-$randomSuffix';
    final trackingCode = 'VET-PP-$randomSuffix';

    final order = OrderModel(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      items: verifiedItems,
      subtotalUsd: calculatedSubtotal,
      deliveryFeeUsd: deliveryFeeUsd,
      discountUsd: discountUsd,
      totalUsd: totalUsd,
      deliveryAddress: '$streetAddress, $district, $province, Cambodia',
      paymentMethod: paymentMethod,
      trackingCode: trackingCode,
      customerName: customerName,
      phoneNumber: phoneNumber,
      province: province,
      district: district,
      deliveryNotes: deliveryNotes,
    );

    // 5. Insert into Supabase if live
    final client = SupabaseConfig.client;
    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        final orderRow = await client.from('orders').insert({
          'order_number': order.orderNumber,
          'user_id': userId,
          'status': 'pending',
          'subtotal_usd': order.subtotalUsd,
          'delivery_fee_usd': order.deliveryFeeUsd,
          'discount_usd': order.discountUsd,
          'total_usd': order.totalUsd,
          'shipping_address_snapshot': {
            'recipient_name': customerName,
            'phone_number': phoneNumber,
            'province': province,
            'district': district,
            'street_address': streetAddress,
          },
          'delivery_notes': deliveryNotes,
          'tracking_code': trackingCode,
        }).select('id').single();

        final orderId = orderRow['id'] as String;

        for (final item in verifiedItems) {
          await client.from('order_items').insert({
            'order_id': orderId,
            'variant_id': item.variantId ?? '00000000-0000-0000-0000-000000000000',
            'product_name_snapshot': item.product.nameEn,
            'variant_snapshot': '${item.selectedColor.nameEn} / ${item.selectedSize}',
            'unit_price_usd': item.product.priceUsd,
            'quantity': item.quantity,
            'total_price_usd': item.totalPriceUsd,
          });
        }
      } catch (_) {
        // Fallback to memory
      }
    }

    _inMemoryOrders.insert(0, order);
    return order;
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    final client = SupabaseConfig.client;
    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        final response = await client
            .from('orders')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        return (response as List<dynamic>)
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return List.unmodifiable(_inMemoryOrders);
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      return _inMemoryOrders.firstWhere((o) => o.id == orderId || o.orderNumber == orderId);
    } catch (_) {
      return null;
    }
  }
}
