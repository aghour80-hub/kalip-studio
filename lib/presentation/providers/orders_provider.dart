import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/coupon_model.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/repositories/order_repository.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';

class OrdersNotifier extends StateNotifier<List<OrderModel>> {
  final OrderRepository _orderRepository;
  final Ref? ref;

  OrdersNotifier({
    OrderRepository? orderRepository,
    this.ref,
  })  : _orderRepository = orderRepository ?? OrderRepository(),
        super(List.from(SampleData.sampleOrders)) {
    _loadPersistedOrders();
  }

  Future<void> _loadPersistedOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final raw = prefs.getString(AppConstants.keyOrders);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final loaded = decoded
            .whereType<Map<String, dynamic>>()
            .map((j) => OrderModel.fromJson(j))
            .toList();
        if (loaded.isNotEmpty && mounted) {
          state = loaded;
        }
      }
    } catch (_) {}
  }

  Future<void> _persistOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.map((o) => o.toJson()).toList());
      await prefs.setString(AppConstants.keyOrders, encoded);
    } catch (_) {}
  }

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
  }) async {
    final catalog = ref?.read(adminProductsProvider).products;
    final settings = ref?.read(storeSettingsProvider);

    final newOrder = await _orderRepository.createOrder(
      userId: userId,
      items: items,
      customerName: customerName,
      phoneNumber: phoneNumber,
      province: province,
      district: district,
      streetAddress: streetAddress,
      deliveryNotes: deliveryNotes,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
      catalogProducts: catalog,
      freeShippingThresholdUsd: settings?.freeShippingThresholdUsd,
      standardShippingFeeUsd: settings?.standardShippingFeeUsd,
      customCoupons: settings?.coupons
          .where((c) => c.isActive)
          .map(
            (c) => CouponModel(
              id: 'owner-${c.code}',
              code: c.code,
              discountPercentage: c.discountPercent,
              minSpendUsd: c.minSpendUsd,
            ),
          )
          .toList(),
    );

    // Deduct stock from Atelier Inventory
    ref?.read(adminProductsProvider.notifier).deductStockForOrder(items);

    state = [newOrder, ...state];
    _persistOrders();
    return newOrder;
  }

  void addOrder(OrderModel order) {
    state = [order, ...state];
    _persistOrders();
  }

  void updateOrderStatus(String orderNumber, OrderStatus newStatus) {
    OrderModel? existing;
    try {
      existing = state.firstWhere((o) => o.orderNumber == orderNumber || o.id == orderNumber);
    } catch (_) {}

    // Restore stock if cancelling a non-cancelled order
    if (existing != null &&
        existing.status != OrderStatus.cancelled &&
        newStatus == OrderStatus.cancelled) {
      ref?.read(adminProductsProvider.notifier).restoreStockForOrder(existing.items);
    }

    state = state.map((o) {
      if (o.orderNumber == orderNumber || o.id == orderNumber) {
        return o.copyWith(status: newStatus);
      }
      return o;
    }).toList();
    _persistOrders();
  }

  void cancelOrder(String orderNumber) {
    updateOrderStatus(orderNumber, OrderStatus.cancelled);
  }

  Future<void> fetchUserOrders(String userId) async {
    final list = await _orderRepository.getOrders(userId);
    state = list;
  }

  Future<void> resetToDefaults() async {
    state = List.from(SampleData.sampleOrders);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyOrders);
    } catch (_) {}
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<OrderModel>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrdersNotifier(orderRepository: repository, ref: ref);
});
