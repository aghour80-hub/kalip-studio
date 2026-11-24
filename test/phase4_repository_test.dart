import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/category_model.dart';
import 'package:style_house/data/models/coupon_model.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/data/repositories/cart_repository.dart';
import 'package:style_house/data/repositories/category_repository.dart';
import 'package:style_house/data/repositories/order_repository.dart';
import 'package:style_house/data/repositories/product_repository.dart';
import 'package:style_house/presentation/providers/cart_provider.dart';

void main() {
  group('Phase 4: Models Serialization', () {
    test('ProductModel and ProductVariant serialize and deserialize properly', () {
      final variantJson = {
        'id': 'var-01',
        'product_id': 'prod-01',
        'color_name_en': 'Obsidian Black',
        'color_name_km': 'ខ្មៅ',
        'color_hex': '#121212',
        'size': 'M',
        'sku_variant': 'SKU-001-M-BLK',
        'price_override_usd': null,
        'stock_quantity': 8,
      };

      final variant = ProductVariant.fromJson(variantJson);
      expect(variant.id, 'var-01');
      expect(variant.size, 'M');
      expect(variant.stockQuantity, 8);
      expect(variant.toProductColor.nameEn, 'Obsidian Black');

      final productJson = {
        'id': 'prod-01',
        'name_en': 'Royal Silk Evening Dress',
        'name_km': 'រ៉ូបរាត្រីសមោលសូត្រខ្មែរ',
        'description_en': 'Hand-woven Khmer silk',
        'description_km': 'សូត្រខ្មែរត្បាញដោយដៃ',
        'price_usd': 145.0,
        'original_price_usd': 180.0,
        'category_id': 'women',
        'gender': 'women',
        'is_new_arrival': true,
        'is_best_seller': true,
        'is_featured': true,
        'stock_quantity': 15,
        'variants': [variantJson],
      };

      final product = ProductModel.fromJson(productJson);
      expect(product.id, 'prod-01');
      expect(product.priceUsd, 145.0);
      expect(product.hasDiscount, isTrue);
      expect(product.discountPercentage, 19);
      expect(product.variants.length, 1);
      expect(product.variants.first.size, 'M');
    });

    test('CategoryModel serialize and deserialize properly', () {
      final json = {
        'id': 'cat-tailoring',
        'name_en': 'Atelier Tailoring',
        'name_km': 'ឈុតកាត់ដេរពិសេស',
        'image_url': 'https://example.com/tailor.jpg',
        'item_count': 24,
        'gender': 'all',
        'is_featured': true,
      };

      final category = CategoryModel.fromJson(json);
      expect(category.id, 'cat-tailoring');
      expect(category.nameEn, 'Atelier Tailoring');
      expect(category.itemCount, 24);
      expect(category.isFeatured, isTrue);

      final out = category.toJson();
      expect(out['name_en'], 'Atelier Tailoring');
      expect(out['item_count'], 24);
    });

    test('CouponModel calculates discount and checks minimum spend correctly', () {
      final coupon = CouponModel(
        id: 'cpn-test',
        code: 'LUXURY20',
        discountPercentage: 20.0,
        minSpendUsd: 100.0,
        maxDiscountUsd: 50.0,
      );

      // Under minimum spend
      expect(coupon.isValidFor(80.0), isFalse);
      expect(coupon.calculateDiscount(80.0), 0.0);

      // Meets minimum spend
      expect(coupon.isValidFor(150.0), isTrue);
      expect(coupon.calculateDiscount(150.0), 30.0); // 20% of 150 = 30

      // Exceeds max discount cap ($50 cap)
      expect(coupon.calculateDiscount(300.0), 50.0); // 20% of 300 = 60 -> capped at 50
    });
  });

  group('Phase 4: Repositories', () {
    late CategoryRepository categoryRepo;
    late ProductRepository productRepo;
    late CartRepository cartRepo;
    late OrderRepository orderRepo;

    setUp(() {
      categoryRepo = CategoryRepository();
      productRepo = ProductRepository();
      cartRepo = CartRepository();
      orderRepo = OrderRepository(productRepository: productRepo);
    });

    test('CategoryRepository returns categories and filters by gender', () async {
      final allCategories = await categoryRepo.getCategories();
      expect(allCategories.isNotEmpty, isTrue);

      final womenCategories = await categoryRepo.getCategories(gender: 'women');
      expect(womenCategories.any((c) => c.gender == 'women' || c.gender == 'all'), isTrue);
    });

    test('ProductRepository filters by gender and checks stock', () async {
      final products = await productRepo.getProducts(gender: 'women');
      expect(products.every((p) => p.gender == 'women' || p.gender == 'unisex'), isTrue);

      final stock = await productRepo.checkAvailableStock(
        productId: SampleData.products.first.id,
        size: 'M',
        colorNameEn: SampleData.products.first.colors.first.nameEn,
      );
      expect(stock, greaterThan(0));
    });

    test('CartRepository performs CRUD operations', () async {
      final item = CartItemModel(
        id: 'cart-test-01',
        product: SampleData.products.first,
        selectedColor: SampleData.products.first.colors.first,
        selectedSize: 'M',
        quantity: 2,
      );

      await cartRepo.addItem('user-1', item);
      var cart = await cartRepo.getCart('user-1');
      expect(cart.any((i) => i.id == 'cart-test-01' || i.product.id == item.product.id), isTrue);

      await cartRepo.updateQuantity('user-1', 'cart-test-01', 4);
      cart = await cartRepo.getCart('user-1');
      final updated = cart.firstWhere((i) => i.id == 'cart-test-01');
      expect(updated.quantity, 4);

      await cartRepo.removeItem('user-1', 'cart-test-01');
      cart = await cartRepo.getCart('user-1');
      expect(cart.any((i) => i.id == 'cart-test-01'), isFalse);
    });

    test('OrderRepository enforces server-side pricing and validates coupons', () async {
      final product = SampleData.products.first;
      final cartItem = CartItemModel(
        id: 'test-cart-item',
        product: product,
        selectedColor: product.colors.first,
        selectedSize: product.sizes.first,
        quantity: 1,
      );

      final order = await orderRepo.createOrder(
        userId: 'user-vip',
        items: [cartItem],
        customerName: 'Chann Vathana',
        phoneNumber: '098 765 432',
        province: 'Phnom Penh',
        district: 'Chamkar Mon / BKK',
        streetAddress: 'Street 302, House 15',
        paymentMethod: 'KHQR (Bakong Payment)',
        couponCode: 'STYLE10',
      );

      expect(order.orderNumber, startsWith('SH-2026-'));
      expect(order.trackingCode, startsWith('VET-PP-'));
      expect(order.subtotalUsd, product.priceUsd);
      expect(order.discountUsd, closeTo(product.priceUsd * 0.10, 0.01));
      expect(order.paymentMethod, 'KHQR (Bakong Payment)');
      expect(order.status, OrderStatus.pending);
    });

    test('OrderRepository rejects empty cart', () async {
      expect(
        () => orderRepo.createOrder(
          userId: 'user-vip',
          items: [],
          customerName: 'Nobody',
          phoneNumber: '012 345 678',
          province: 'Phnom Penh',
          district: 'BKK',
          streetAddress: 'None',
          paymentMethod: 'cod',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Phase 4: Cart State & Inventory Validation', () {
    late CartNotifier cartNotifier;

    setUp(() {
      cartNotifier = CartNotifier(cartRepository: CartRepository());
    });

    test('CartNotifier prevents adding quantity exceeding available stock', () {
      final limitedProduct = ProductModel(
        id: 'prod-scarce',
        nameEn: 'Limited Silk Scarf',
        nameKm: 'ក្រមាសូត្រកម្រ',
        descriptionEn: 'Rare piece',
        descriptionKm: 'កម្រ',
        priceUsd: 40.0,
        categoryId: 'accessories',
        gender: 'all',
        colors: [const ProductColor(nameEn: 'Gold', nameKm: 'មាស', color: Color(0xFFD4AF37))],
        sizes: ['One Size'],
        images: ['https://example.com/scarf.jpg'],
        stockQuantity: 2, // only 2 in stock!
        detailsEn: [],
        detailsKm: [],
        materialEn: 'Silk',
        materialKm: 'សូត្រ',
      );

      // Attempting to add 5 when only 2 exist
      final success = cartNotifier.addToCart(
        limitedProduct,
        limitedProduct.colors.first,
        'One Size',
        quantity: 5,
      );

      expect(success, isFalse);
      expect(cartNotifier.state.warningMessage, contains('Maximum available stock is 2'));
    });

    test('CartNotifier properly calculates promo discounts and minimum spend', () {
      cartNotifier.clearCart();
      expect(cartNotifier.state.subtotalUsd, 0.0);

      // Apply LUXURY20 on subtotal 0 -> should fail minimum spend
      final success = cartNotifier.applyPromoCode('LUXURY20');
      expect(success, isFalse);
      expect(cartNotifier.state.warningMessage, contains('requires minimum order of \$100.00'));

      // Apply STYLE10 -> works with no minimum spend
      final successStyle = cartNotifier.applyPromoCode('STYLE10');
      expect(successStyle, isTrue);
      expect(cartNotifier.state.discountPercentage, 0.10);
    });
  });
}
