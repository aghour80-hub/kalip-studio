import 'package:flutter_test/flutter_test.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/cart_provider.dart';

void main() {
  group('Checkout & Order Business Logic Tests', () {
    test('Cart state correctly calculates subtotal and free shipping threshold', () {
      final items = [
        CartItemModel(
          id: 'item-1',
          product: SampleData.products[0], // $185
          selectedColor: SampleData.products[0].colors.first,
          selectedSize: 'S',
          quantity: 1,
        ),
      ];

      final cart = CartState(items: items);
      expect(cart.subtotalUsd, 185.0);
      expect(cart.qualifiesForFreeDelivery, isTrue);
      expect(cart.deliveryFeeUsd, 0.0);
      expect(cart.totalUsd, 185.0);
    });

    test('Promo code discount is applied accurately', () {
      final items = [
        CartItemModel(
          id: 'item-1',
          product: SampleData.products[1], // $115
          selectedColor: SampleData.products[1].colors.first,
          selectedSize: 'M',
          quantity: 1,
        ),
      ];

      final cartWithPromo = CartState(
        items: items,
        promoCode: 'STYLE10',
        discountPercentage: 0.10,
      );

      expect(cartWithPromo.discountUsd, 11.5);
      expect(cartWithPromo.totalUsd, 103.5);
    });

    test('Standard delivery fee applies when subtotal is under threshold', () {
      const cheapProduct = ProductModel(
        id: 'test-cheap',
        nameEn: 'Linen Pocket Square',
        nameKm: 'កន្សែងហោប៉ៅ',
        descriptionEn: 'Small accessory',
        descriptionKm: 'គ្រឿងតុបតែង',
        priceUsd: 30.0,
        categoryId: 'accessories',
        gender: 'all',
        colors: [],
        sizes: ['One Size'],
        images: ['https://example.com/img.jpg'],
        stockQuantity: 10,
        detailsEn: [],
        detailsKm: [],
        materialEn: 'Linen',
        materialKm: 'លីនិន',
      );

      final smallItems = [
        CartItemModel(
          id: 'item-small',
          product: cheapProduct,
          selectedColor: SampleData.products[0].colors.first,
          selectedSize: 'One Size',
          quantity: 1,
        ),
      ];

      final cartUnderThreshold = CartState(items: smallItems);
      expect(cartUnderThreshold.qualifiesForFreeDelivery, isFalse);
      expect(cartUnderThreshold.deliveryFeeUsd, AppConstants.standardShippingFeeUsd);
      expect(cartUnderThreshold.amountNeededForFreeDelivery, 20.0);
      expect(cartUnderThreshold.totalUsd, 32.0);
    });

    test('Order model holds valid Cambodian delivery tracking attributes', () {
      final order = SampleData.sampleOrders.first;
      expect(order.orderNumber.startsWith('SH-'), isTrue);
      expect(order.deliveryAddress.contains('Phnom Penh'), isTrue);
      expect(order.trackingCode.isNotEmpty, isTrue);
      expect(order.status, OrderStatus.delivering);
      expect(order.status.localized(false), 'Out for Delivery (Phnom Penh)');
      expect(order.status.localized(true), 'កំពុងដឹកជញ្ជូន');
    });
  });
}
