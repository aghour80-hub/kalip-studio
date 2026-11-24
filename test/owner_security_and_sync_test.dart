import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/payment/khqr_service.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/providers/products_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';
import 'package:style_house/presentation/widgets/admin_gate_wrapper.dart';
import 'package:style_house/presentation/widgets/khqr_payment_sheet.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Owner Password Authentication (AdminAuthNotifier)', () {
    test('Starts locked with default password and tracks failed attempts', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait briefly for async SharedPreferences init
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var state = container.read(adminAuthProvider);
      expect(state.isUnlocked, isFalse);
      expect(state.isUsingDefaultPassword, isTrue);
      expect(state.failedAttempts, 0);

      // Wrong password attempt
      final okWrong = container.read(adminAuthProvider.notifier).unlockWithPassword('wrongpass');
      expect(okWrong, isFalse);
      state = container.read(adminAuthProvider);
      expect(state.isUnlocked, isFalse);
      expect(state.failedAttempts, 1);

      // Unlock with factory default password
      final okDefault = container
          .read(adminAuthProvider.notifier)
          .unlockWithPassword(AppConstants.defaultAdminPassword);
      expect(okDefault, isTrue);
      state = container.read(adminAuthProvider);
      expect(state.isUnlocked, isTrue);
      expect(state.failedAttempts, 0);

      // Lock portal again
      container.read(adminAuthProvider.notifier).lockPortal();
      expect(container.read(adminAuthProvider).isUnlocked, isFalse);
    });

    test('changePassword validates current password, rejects short passwords, and persists new password', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final notifier = container.read(adminAuthProvider.notifier);

      // Wrong current password
      final errWrongCurrent = await notifier.changePassword(
        currentPassword: 'bad',
        newPassword: 'kalip999',
      );
      expect(errWrongCurrent, isNotNull);

      // Too short new password
      final errShort = await notifier.changePassword(
        currentPassword: AppConstants.defaultAdminPassword,
        newPassword: '123',
      );
      expect(errShort, isNotNull);

      // Valid change
      final success = await notifier.changePassword(
        currentPassword: AppConstants.defaultAdminPassword,
        newPassword: 'owner2026',
      );
      expect(success, isNull);
      expect(container.read(adminAuthProvider).isUsingDefaultPassword, isFalse);

      // Old password fails now
      expect(notifier.unlockWithPassword(AppConstants.defaultAdminPassword), isFalse);
      // New password unlocks
      expect(notifier.unlockWithPassword('owner2026'), isTrue);
    });
  });

  group('Catalog Sync, Visibility Toggle & Stock Deduction', () {
    test('Adding, price updating, clearing sale, and hiding product syncs immediately with storefront providers', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final adminNotifier = container.read(adminProductsProvider.notifier);
      final initialActiveCount = container.read(allProductsProvider).length;

      final customProd = ProductModel(
        id: 'test-prod-101',
        nameEn: 'Khmer Royal Tunic',
        nameKm: 'អាវសូត្ររាជវង្ស',
        descriptionEn: 'Crafted in BKK1.',
        descriptionKm: 'ផលិតនៅភ្នំពេញ',
        priceUsd: 80.0,
        originalPriceUsd: 100.0,
        categoryId: 'tops',
        gender: 'women',
        colors: [ProductColor.fromHex(nameEn: 'Gold', nameKm: 'មាស', hex: '#C5A880')],
        sizes: ['S', 'M'],
        images: ['https://example.com/image.jpg'],
        stockQuantity: 10,
        isActive: true,
        detailsEn: const ['Silk'],
        detailsKm: const ['សូត្រ'],
        materialEn: 'Silk',
        materialKm: 'សូត្រ',
      );

      adminNotifier.addProduct(customProd);
      expect(container.read(allProductsProvider).length, initialActiveCount + 1);
      expect(container.read(onSaleProductsProvider).any((p) => p.id == 'test-prod-101'), isTrue);

      // Remove discount via clearOriginalPrice: true
      adminNotifier.updatePrice('test-prod-101', 90.0, clearOriginalPrice: true);
      final updated = container.read(allProductsProvider).firstWhere((p) => p.id == 'test-prod-101');
      expect(updated.priceUsd, 90.0);
      expect(updated.hasDiscount, isFalse);

      // Hide product from storefront
      adminNotifier.toggleProductStatus('test-prod-101');
      expect(container.read(allProductsProvider).any((p) => p.id == 'test-prod-101'), isFalse);
      expect(container.read(adminProductsProvider).products.any((p) => p.id == 'test-prod-101'), isTrue);
    });

    test('createOrder deducts stock and cancelOrder restores stock', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final targetProd = container.read(adminProductsProvider).products.first;
      final startingStock = targetProd.stockQuantity;

      final order = await container.read(ordersProvider.notifier).createOrder(
        userId: 'u-01',
        items: [
          CartItemModel(
            id: 'ci-1',
            product: targetProd,
            selectedColor: targetProd.colors.first,
            selectedSize: targetProd.sizes.first,
            quantity: 2,
          ),
        ],
        customerName: 'Sokha',
        phoneNumber: '092888999',
        province: 'Phnom Penh',
        district: 'Chamkar Mon / BKK',
        streetAddress: 'St 302',
        paymentMethod: 'KHQR',
      );

      final afterCreateStock = container
          .read(adminProductsProvider)
          .products
          .firstWhere((p) => p.id == targetProd.id)
          .stockQuantity;
      expect(afterCreateStock, startingStock - 2);

      // Cancel order restores stock
      container.read(ordersProvider.notifier).cancelOrder(order.orderNumber);
      final afterCancelStock = container
          .read(adminProductsProvider)
          .products
          .firstWhere((p) => p.id == targetProd.id)
          .stockQuantity;
      expect(afterCancelStock, startingStock);

      final cancelledOrder = container
          .read(ordersProvider)
          .firstWhere((o) => o.orderNumber == order.orderNumber);
      expect(cancelledOrder.status, OrderStatus.cancelled);
    });

    test('OrderModel & CartItemModel full JSON serialization roundtrip preserves items', () {
      final prod = ProductModel(
        id: 'p-roundtrip',
        nameEn: 'Test Coat',
        nameKm: 'អាវ',
        descriptionEn: 'Desc',
        descriptionKm: 'ការពិពណ៌នា',
        priceUsd: 120.0,
        categoryId: 'outerwear',
        gender: 'men',
        colors: [ProductColor.fromHex(nameEn: 'Black', nameKm: 'ខ្មៅ', hex: '#000000')],
        sizes: ['M'],
        images: ['https://example.com/a.jpg'],
        stockQuantity: 5,
        isActive: false,
        detailsEn: const ['Warm'],
        detailsKm: const ['កក់ក្តៅ'],
        materialEn: 'Wool',
        materialKm: 'រោមចៀម',
      );
      final order = OrderModel(
        id: 'ord-rt',
        orderNumber: 'SH-2026-9999',
        createdAt: DateTime(2026, 11, 25),
        status: OrderStatus.confirmed,
        items: [
          CartItemModel(
            id: 'c-rt',
            product: prod,
            selectedColor: prod.colors.first,
            selectedSize: 'M',
            quantity: 3,
          ),
        ],
        subtotalUsd: 360.0,
        deliveryFeeUsd: 0.0,
        discountUsd: 0.0,
        totalUsd: 360.0,
        deliveryAddress: 'BKK1, Phnom Penh',
        paymentMethod: 'KHQR',
        trackingCode: 'VET-9999',
        customerName: 'Roth',
        phoneNumber: '092111222',
      );

      final json = order.toJson();
      final decoded = OrderModel.fromJson(json);
      expect(decoded.orderNumber, 'SH-2026-9999');
      expect(decoded.status, OrderStatus.confirmed);
      expect(decoded.items.length, 1);
      expect(decoded.items.first.quantity, 3);
      expect(decoded.items.first.product.isActive, isFalse);
      expect(decoded.customerName, 'Roth');
    });

    test('StoreSettingsNotifier updates live exchange rate', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(storeSettingsProvider.notifier).updateSettings(
        usdToKhrRate: 4150.0,
        freeShippingThresholdUsd: 75.0,
      );

      final s = container.read(storeSettingsProvider);
      expect(s.usdToKhrRate, 4150.0);
      expect(s.freeShippingThresholdUsd, 75.0);
    });
  });

  group('AdminGateWrapper Widget Security Flow', () {
    testWidgets('Shows Password Gate when locked and unlocks child upon entering valid owner password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminGateWrapper(
              sectionTitle: 'Catalog & Pricing',
              child: Scaffold(
                body: Center(child: Text('SECRET_OWNER_CONTENT')),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Secret content must NOT be visible before unlocking
      expect(find.text('SECRET_OWNER_CONTENT'), findsNothing);
      expect(find.text('KALIP studio'), findsOneWidget);

      // Enter invalid password first
      await tester.enterText(find.byType(TextField), '0000');
      await tester.ensureVisible(find.text('MỞ KHÓA QUẢN LÝ (UNLOCK)'));
      await tester.tap(find.text('MỞ KHÓA QUẢN LÝ (UNLOCK)'));
      await tester.pump();
      expect(find.textContaining('Mật khẩu không đúng'), findsOneWidget);
      expect(find.text('SECRET_OWNER_CONTENT'), findsNothing);

      // Enter default password '123456'
      await tester.enterText(find.byType(TextField), AppConstants.defaultAdminPassword);
      await tester.ensureVisible(find.text('MỞ KHÓA QUẢN LÝ (UNLOCK)'));
      await tester.tap(find.text('MỞ KHÓA QUẢN LÝ (UNLOCK)'));
      await tester.pumpAndSettle();

      // Now secret owner content must be visible
      expect(find.text('SECRET_OWNER_CONTENT'), findsOneWidget);
    });
  });

  group('ABA Bank KHQR Payment Sheet', () {
    testWidgets('Displays authentic owner ABA QR asset and account numbers on checkout', (
      WidgetTester tester,
    ) async {
      final order = OrderModel(
        id: 'ord-qr',
        orderNumber: 'SH-2026-7777',
        createdAt: DateTime(2026, 11, 25),
        status: OrderStatus.pending,
        items: const [],
        subtotalUsd: 100.0,
        deliveryFeeUsd: 0.0,
        discountUsd: 0.0,
        totalUsd: 100.0,
        deliveryAddress: 'Phnom Penh',
        paymentMethod: 'ABA Bank KHQR',
        trackingCode: 'VET-7777',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KhqrPaymentSheet(
              order: order,
              onPaymentSuccess: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining(KhqrService.abaAccountName), findsWidgets);
      expect(find.textContaining(KhqrService.abaAccountUsd), findsWidgets);
      expect(find.textContaining(KhqrService.abaAccountKhr), findsWidgets);
      expect(find.textContaining('\$100.00'), findsWidgets);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
