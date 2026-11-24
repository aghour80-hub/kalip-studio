import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/models/user_model.dart';
import 'package:style_house/data/services/supabase_auth_service.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';

void main() {
  group('Phase 6: Admin Role-Based Access Control', () {
    late SupabaseAuthService authService;
    late AuthNotifier authNotifier;

    setUp(() {
      authService = SupabaseAuthService();
      authNotifier = AuthNotifier(authService);
    });

    test('Customer role cannot access admin features', () {
      final customer = const UserModel(
        id: 'cust-01',
        email: 'customer@stylehouse.kh',
        fullName: 'VIP Customer',
        role: UserRole.customer,
      );
      expect(customer.isAdmin, isFalse);
    });

    test('Admin and Manager roles have administrative privileges', () {
      final admin = const UserModel(
        id: 'adm-01',
        email: 'admin@stylehouse.kh',
        fullName: 'Atelier Director',
        role: UserRole.admin,
      );
      expect(admin.isAdmin, isTrue);

      final manager = const UserModel(
        id: 'mgr-01',
        email: 'mgr@stylehouse.kh',
        fullName: 'Floor Manager',
        role: UserRole.manager,
      );
      expect(manager.isAdmin, isTrue);
    });

    test('toggleAdminRole toggles user role between customer and admin', () {
      expect(authNotifier.state.user?.isAdmin, isFalse);

      authNotifier.toggleAdminRole();
      expect(authNotifier.state.user?.isAdmin, isTrue);
      expect(authNotifier.state.user?.role, UserRole.admin);

      authNotifier.toggleAdminRole();
      expect(authNotifier.state.user?.isAdmin, isFalse);
      expect(authNotifier.state.user?.role, UserRole.customer);
    });
  });

  group('Phase 6: Admin Analytics & GMV Calculation', () {
    test('AdminAnalyticsState calculates GMV in USD and KHR accurately', () {
      const analytics = AdminAnalyticsState(
        totalGmvUsd: 1000.0,
        totalOrdersCount: 10,
        pendingOrdersCount: 2,
        lowStockProductsCount: 3,
        activeProductsCount: 25,
      );

      expect(analytics.totalGmvUsd, 1000.0);
      expect(analytics.totalGmvKhr, 1000.0 * AppConstants.usdToKhrRate); // 4,100,000 KHR
      expect(analytics.pendingOrdersCount, 2);
      expect(analytics.lowStockProductsCount, 3);
    });

    test('adminAnalyticsProvider aggregates live orders and low-stock count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final analytics = container.read(adminAnalyticsProvider);
      expect(analytics.totalOrdersCount, SampleData.sampleOrders.length);
      expect(analytics.totalGmvUsd, greaterThan(0.0));
    });
  });

  group('Phase 6: Admin Inventory & Catalog Management', () {
    test('restockProduct increases inventory stock count', () {
      final notifier = AdminProductsNotifier();
      final initialProduct = notifier.state.products.first;
      final initialStock = initialProduct.stockQuantity;

      notifier.restockProduct(initialProduct.id, 25);
      final updatedProduct = notifier.state.products.firstWhere((p) => p.id == initialProduct.id);

      expect(updatedProduct.stockQuantity, initialStock + 25);
    });
  });

  group('Phase 6: Order Pipeline & Status Transitions', () {
    test('updateOrderStatus updates order status across pipeline', () {
      final ordersNotifier = OrdersNotifier();
      final targetOrder = ordersNotifier.state.first;
      final orderNumber = targetOrder.orderNumber;

      // Transition to confirmed
      ordersNotifier.updateOrderStatus(orderNumber, OrderStatus.confirmed);
      var current = ordersNotifier.state.firstWhere((o) => o.orderNumber == orderNumber);
      expect(current.status, OrderStatus.confirmed);

      // Transition to processing
      ordersNotifier.updateOrderStatus(orderNumber, OrderStatus.processing);
      current = ordersNotifier.state.firstWhere((o) => o.orderNumber == orderNumber);
      expect(current.status, OrderStatus.processing);

      // Transition to delivering
      ordersNotifier.updateOrderStatus(orderNumber, OrderStatus.delivering);
      current = ordersNotifier.state.firstWhere((o) => o.orderNumber == orderNumber);
      expect(current.status, OrderStatus.delivering);

      // Transition to delivered
      ordersNotifier.updateOrderStatus(orderNumber, OrderStatus.delivered);
      current = ordersNotifier.state.firstWhere((o) => o.orderNumber == orderNumber);
      expect(current.status, OrderStatus.delivered);
    });
  });
}
