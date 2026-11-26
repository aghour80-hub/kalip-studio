import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/data/repositories/cart_repository.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';

class CartState {
  final List<CartItemModel> items;
  final String? promoCode;
  final double discountPercentage;
  final String? warningMessage;
  final double freeShippingThresholdUsd;
  final double standardShippingFeeUsd;

  const CartState({
    required this.items,
    this.promoCode,
    this.discountPercentage = 0.0,
    this.warningMessage,
    this.freeShippingThresholdUsd = AppConstants.freeShippingThresholdUsd,
    this.standardShippingFeeUsd = AppConstants.standardShippingFeeUsd,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalUsd =>
      items.fold(0.0, (sum, item) => sum + item.totalPriceUsd);

  bool get qualifiesForFreeDelivery => subtotalUsd >= freeShippingThresholdUsd;

  double get deliveryFeeUsd {
    if (items.isEmpty) return 0.0;
    return qualifiesForFreeDelivery ? 0.0 : standardShippingFeeUsd;
  }

  double get discountUsd => subtotalUsd * discountPercentage;

  double get totalUsd {
    if (items.isEmpty) return 0.0;
    return (subtotalUsd - discountUsd) + deliveryFeeUsd;
  }

  double get amountNeededForFreeDelivery {
    final diff = freeShippingThresholdUsd - subtotalUsd;
    return diff > 0 ? diff : 0.0;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    String? promoCode,
    double? discountPercentage,
    String? warningMessage,
    double? freeShippingThresholdUsd,
    double? standardShippingFeeUsd,
    bool clearPromo = false,
    bool clearWarning = false,
  }) {
    return CartState(
      items: items ?? this.items,
      promoCode: clearPromo ? null : (promoCode ?? this.promoCode),
      discountPercentage: clearPromo ? 0.0 : (discountPercentage ?? this.discountPercentage),
      warningMessage: clearWarning ? null : (warningMessage ?? this.warningMessage),
      freeShippingThresholdUsd: freeShippingThresholdUsd ?? this.freeShippingThresholdUsd,
      standardShippingFeeUsd: standardShippingFeeUsd ?? this.standardShippingFeeUsd,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _cartRepository;
  List<StoreCoupon> _activeCoupons;

  CartNotifier({
    CartRepository? cartRepository,
    double freeShippingThresholdUsd = AppConstants.freeShippingThresholdUsd,
    double standardShippingFeeUsd = AppConstants.standardShippingFeeUsd,
    List<StoreCoupon> coupons = StoreSettingsState.defaultCoupons,
  })  : _cartRepository = cartRepository ?? CartRepository(),
        _activeCoupons = coupons,
        super(CartState(
          items: List.from(SampleData.initialCart),
          freeShippingThresholdUsd: freeShippingThresholdUsd,
          standardShippingFeeUsd: standardShippingFeeUsd,
        )) {
    _loadPersistedCart();
  }

  Future<void> _loadPersistedCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final raw = prefs.getString(AppConstants.keyCart);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final rawItems = (decoded['items'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .where((j) => j['product'] != null)
            .map(CartItemModel.fromStoredJson)
            .toList();
        final promo = decoded['promo_code'] as String?;
        final pct = (decoded['discount_percentage'] as num?)?.toDouble() ?? 0.0;
        if (mounted) {
          state = state.copyWith(
            items: rawItems,
            promoCode: promo,
            discountPercentage: pct,
            clearPromo: promo == null,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _persistCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'items': state.items.map((i) => i.toJson()).toList(),
        'promo_code': state.promoCode,
        'discount_percentage': state.discountPercentage,
      });
      await prefs.setString(AppConstants.keyCart, payload);
    } catch (_) {}
  }

  void updateStoreConfig(double threshold, double fee, List<StoreCoupon> coupons) {
    _activeCoupons = coupons;
    state = state.copyWith(
      freeShippingThresholdUsd: threshold,
      standardShippingFeeUsd: fee,
    );
  }

  bool addToCart(
    ProductModel product,
    ProductColor color,
    String size, {
    int quantity = 1,
  }) {
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
    _persistCart();
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
      _persistCart();
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
    _persistCart();
  }

  void clearCart() {
    state = state.copyWith(
      items: [],
      clearPromo: true,
      clearWarning: true,
    );
    _cartRepository.clearCart('default-user');
    _persistCart();
  }

  bool applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    StoreCoupon? matched;
    for (final c in _activeCoupons) {
      if (c.isActive && c.code.toUpperCase() == clean) {
        matched = c;
        break;
      }
    }

    if (matched != null) {
      if (state.subtotalUsd < matched.minSpendUsd) {
        state = state.copyWith(
          warningMessage: '${matched.code} requires minimum order of \$${matched.minSpendUsd.toStringAsFixed(2)}',
        );
        return false;
      }
      state = state.copyWith(
        promoCode: matched.code,
        discountPercentage: matched.discountFraction,
        clearWarning: true,
      );
      _persistCart();
      return true;
    }

    state = state.copyWith(warningMessage: 'Invalid or expired promotional code.');
    return false;
  }

  void removePromoCode() {
    state = state.copyWith(clearPromo: true, clearWarning: true);
    _persistCart();
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  final initialSettings = ref.read(storeSettingsProvider);
  final notifier = CartNotifier(
    cartRepository: repository,
    freeShippingThresholdUsd: initialSettings.freeShippingThresholdUsd,
    standardShippingFeeUsd: initialSettings.standardShippingFeeUsd,
    coupons: initialSettings.coupons,
  );
  ref.listen<StoreSettingsState>(storeSettingsProvider, (_, next) {
    notifier.updateStoreConfig(
      next.freeShippingThresholdUsd,
      next.standardShippingFeeUsd,
      next.coupons,
    );
  });
  return notifier;
});
