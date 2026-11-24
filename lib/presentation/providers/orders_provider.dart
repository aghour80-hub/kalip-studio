import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/repositories/order_repository.dart';

class OrdersNotifier extends StateNotifier<List<OrderModel>> {
  final OrderRepository _orderRepository;

  OrdersNotifier({OrderRepository? orderRepository})
      : _orderRepository = orderRepository ?? OrderRepository(),
        super(List.from(SampleData.sampleOrders));

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
    );

    state = [newOrder, ...state];
    return newOrder;
  }

  void addOrder(OrderModel order) {
    state = [order, ...state];
  }

  void updateOrderStatus(String orderNumber, OrderStatus newStatus) {
    state = state.map((o) {
      if (o.orderNumber == orderNumber || o.id == orderNumber) {
        return OrderModel(
          id: o.id,
          orderNumber: o.orderNumber,
          createdAt: o.createdAt,
          status: newStatus,
          items: o.items,
          subtotalUsd: o.subtotalUsd,
          deliveryFeeUsd: o.deliveryFeeUsd,
          discountUsd: o.discountUsd,
          totalUsd: o.totalUsd,
          deliveryAddress: o.deliveryAddress,
          paymentMethod: o.paymentMethod,
          trackingCode: o.trackingCode,
          customerName: o.customerName,
          phoneNumber: o.phoneNumber,
          province: o.province,
          district: o.district,
          deliveryNotes: o.deliveryNotes,
        );
      }
      return o;
    }).toList();
  }

  Future<void> fetchUserOrders(String userId) async {
    final list = await _orderRepository.getOrders(userId);
    state = list;
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<OrderModel>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrdersNotifier(orderRepository: repository);
});
