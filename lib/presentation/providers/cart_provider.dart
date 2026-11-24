import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/data/repositories/cart_repository.dart';

class CartState {
  final List<CartItemModel> items;
  final String? promoCode;
  final double discountPercentage;
  final String? warningMessage;

  const CartState({
    required this.items,
    this.promoCode,
    this.discountPercentage = 0.0,
    this.warningMessage,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalUsd =>
      items.fold(0.0, (sum, item) => sum + item.totalPriceUsd);

  bool get qualifiesForFreeDelivery =>
      subtotalUsd >= AppConstants.freeShippingThresholdUsd;

  double get deliveryFeeUsd {
    if (items.isEmpty) return 0.0;
    return qualifiesForFreeDelivery ? 0.0 : AppConstants.standardShippingFeeUsd;
  }

  double get discountUsd => subtotalUsd * discountPercentage;

  double get totalUsd {
    if (items.isEmpty) return 0.0;
    return (subtotalUsd - discountUsd) + deliveryFeeUsd;
  }

  double get amountNeededForFreeDelivery {
    final diff = AppConstants.freeShippingThresholdUsd - subtotalUsd;
    return diff > 0 ? diff : 0.0;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    String? promoCode,
    double? discountPercentage,
    String? warningMessage,
    bool clearPromo = false,
    bool clearWarning = false,
  }) {
    return CartState(
      items: items ?? this.items,
      promoCode: clearPromo ? null : (promoCode ?? this.promoCode),
      discountPercentage: clearPromo ? 0.0 : (discountPercentage ?? this.discountPercentage),
      warningMessage: clearWarning ? null : (warningMessage ?? this.warningMessage),
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _cartRepository;

  CartNotifier({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? CartRepository(),
        super(CartState(items: List.from(SampleData.initialCart)));

  bool addToCart(
    ProductModel product,
    ProductColor color,
    String size, {
    int quantity = 1,
  }) {
    // Inventory Stock Validation Check
    if (product.stockQuantity <= 0) {
      state = state.copyWith(warningMessage: 'This item is currently out of stock.');
      return false;
    }

    final existingIndex = state.items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor.nameEn == color.nameEn &&
          item.selectedSize == size,
    );

    if (existingIndex >= 0) {
      final currentQty = state.items[existingIndex].quantity;
      if (currentQty + quantity > product.stockQuantity) {
        state = state.copyWith(
          warningMessage: 'Cannot add more. Maximum available stock is ${product.stockQuantity}.',
        );
        return false;
      }
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        quantity: currentQty + quantity,
      );
      state = state.copyWith(items: updatedList, clearWarning: true);
      _cartRepository.updateQuantity('default-user', updatedList[existingIndex].id, currentQty + quantity);
    } else {
      if (quantity > product.stockQuantity) {
        state = state.copyWith(
          warningMessage: 'Cannot add more. Maximum available stock is ${product.stockQuantity}.',
        );
        return false;
      }
      final newItem = CartItemModel(
        id: 'cart-${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        selectedColor: color,
        selectedSize: size,
        quantity: quantity,
      );
      state = state.copyWith(items: [...state.items, newItem], clearWarning: true);
      _cartRepository.addItem('default-user', newItem);
    }
    return true;
  }

  bool updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return true;
    }

    final itemIndex = state.items.indexWhere((item) => item.id == cartItemId);
    if (itemIndex >= 0) {
      final item = state.items[itemIndex];
      if (newQuantity > item.product.stockQuantity) {
        state = state.copyWith(
          warningMessage: 'Only ${item.product.stockQuantity} items in stock.',
        );
        return false;
      }

      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[itemIndex] = item.copyWith(quantity: newQuantity);
      state = state.copyWith(items: updatedList, clearWarning: true);
      _cartRepository.updateQuantity('default-user', cartItemId, newQuantity);
      return true;
    }
    return false;
  }

  void removeItem(String cartItemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != cartItemId).toList(),
      clearWarning: true,
    );
    _cartRepository.removeItem('default-user', cartItemId);
  }

  void clearCart() {
    state = const CartState(items: []);
    _cartRepository.clearCart('default-user');
  }

  bool applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'STYLE10' || clean == 'VIP10' || clean == 'CAMBODIA') {
      state = state.copyWith(promoCode: clean, discountPercentage: 0.10, clearWarning: true);
      return true;
    } else if (clean == 'LUXURY20') {
      if (state.subtotalUsd < 100) {
        state = state.copyWith(warningMessage: 'LUXURY20 requires minimum order of \$100.00');
        return false;
      }
      state = state.copyWith(promoCode: clean, discountPercentage: 0.20, clearWarning: true);
      return true;
    }
    state = state.copyWith(warningMessage: 'Invalid or expired promotional code.');
    return false;
  }

  void removePromoCode() {
    state = state.copyWith(clearPromo: true, clearWarning: true);
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return CartNotifier(cartRepository: repository);
});
