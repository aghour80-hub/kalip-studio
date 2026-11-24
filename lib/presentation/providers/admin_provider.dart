import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';

class AdminAnalyticsState {
  final double totalGmvUsd;
  final double usdToKhrRate;
  final int totalOrdersCount;
  final int pendingOrdersCount;
  final int lowStockProductsCount;
  final int activeProductsCount;
  final int hiddenProductsCount;
  final int onSaleProductsCount;

  const AdminAnalyticsState({
    required this.totalGmvUsd,
    this.usdToKhrRate = AppConstants.usdToKhrRate,
    required this.totalOrdersCount,
    required this.pendingOrdersCount,
    required this.lowStockProductsCount,
    required this.activeProductsCount,
    this.hiddenProductsCount = 0,
    this.onSaleProductsCount = 0,
  });

  double get totalGmvKhr => totalGmvUsd * usdToKhrRate;
}

class AdminProductState {
  final List<ProductModel> products;

  const AdminProductState({required this.products});

  AdminProductState copyWith({List<ProductModel>? products}) {
    return AdminProductState(products: products ?? this.products);
  }
}

class AdminProductsNotifier extends StateNotifier<AdminProductState> {
  AdminProductsNotifier()
      : super(AdminProductState(products: List.from(SampleData.products))) {
    _loadPersistedCatalog();
  }

  Future<void> _loadPersistedCatalog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final raw = prefs.getString(AppConstants.keyCatalogProducts);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final loaded = decoded
            .whereType<Map<String, dynamic>>()
            .map(ProductModel.fromJson)
            .toList();
        if (loaded.isNotEmpty && mounted) {
          state = state.copyWith(products: loaded);
        }
      }
    } catch (_) {}
  }

  Future<void> _persistCatalog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.products.map((p) => p.toJson()).toList());
      await prefs.setString(AppConstants.keyCatalogProducts, encoded);
    } catch (_) {}
  }

  void addProduct(ProductModel product) {
    state = state.copyWith(
      products: [product, ...state.products],
    );
    _persistCatalog();
  }

  void updateProduct(ProductModel updated) {
    state = state.copyWith(
      products: state.products.map((p) => p.id == updated.id ? updated : p).toList(),
    );
    _persistCatalog();
  }

  void updatePrice(
    String productId,
    double newPriceUsd, {
    double? newOriginalPriceUsd,
    bool clearOriginalPrice = false,
  }) {
    state = state.copyWith(
      products: state.products.map((p) {
        if (p.id == productId) {
          return p.copyWith(
            priceUsd: newPriceUsd,
            originalPriceUsd: newOriginalPriceUsd,
            clearOriginalPrice: clearOriginalPrice,
          );
        }
        return p;
      }).toList(),
    );
    _persistCatalog();
  }

  void deleteProduct(String productId) {
    state = state.copyWith(
      products: state.products.where((p) => p.id != productId).toList(),
    );
    _persistCatalog();
  }

  void restockProduct(String productId, int quantityToAdd) {
    state = state.copyWith(
      products: state.products.map((p) {
        if (p.id == productId) {
          final newStock = (p.stockQuantity + quantityToAdd).clamp(0, 9999);
          return p.copyWith(stockQuantity: newStock);
        }
        return p;
      }).toList(),
    );
    _persistCatalog();
  }

  void toggleProductStatus(String productId) {
    state = state.copyWith(
      products: state.products.map((p) {
        if (p.id == productId) {
          return p.copyWith(isActive: !p.isActive);
        }
        return p;
      }).toList(),
    );
    _persistCatalog();
  }

  void deductStockForOrder(List<CartItemModel> items) {
    final qtyByProduct = <String, int>{};
    for (final item in items) {
      qtyByProduct[item.product.id] = (qtyByProduct[item.product.id] ?? 0) + item.quantity;
    }

    state = state.copyWith(
      products: state.products.map((p) {
        final deducted = qtyByProduct[p.id];
        if (deducted != null && deducted > 0) {
          final nextStock = (p.stockQuantity - deducted).clamp(0, 9999);
          return p.copyWith(stockQuantity: nextStock);
        }
        return p;
      }).toList(),
    );
    _persistCatalog();
  }

  void restoreStockForOrder(List<CartItemModel> items) {
    final qtyByProduct = <String, int>{};
    for (final item in items) {
      qtyByProduct[item.product.id] = (qtyByProduct[item.product.id] ?? 0) + item.quantity;
    }

    state = state.copyWith(
      products: state.products.map((p) {
        final restored = qtyByProduct[p.id];
        if (restored != null && restored > 0) {
          final nextStock = (p.stockQuantity + restored).clamp(0, 9999);
          return p.copyWith(stockQuantity: nextStock);
        }
        return p;
      }).toList(),
    );
    _persistCatalog();
  }

  Future<void> resetToDefaults() async {
    state = AdminProductState(products: List.from(SampleData.products));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyCatalogProducts);
    } catch (_) {}
  }
}

final adminProductsProvider =
    StateNotifierProvider<AdminProductsNotifier, AdminProductState>((ref) {
  return AdminProductsNotifier();
});

final adminAnalyticsProvider = Provider<AdminAnalyticsState>((ref) {
  final orders = ref.watch(ordersProvider);
  final adminProducts = ref.watch(adminProductsProvider).products;
  final settings = ref.watch(storeSettingsProvider);

  final activeOrders = orders.where((o) => o.status != OrderStatus.cancelled);
  final gmv = activeOrders.fold<double>(0.0, (sum, o) => sum + o.totalUsd);
  final pending = orders.where((o) => o.status == OrderStatus.pending).length;
  final lowStock = adminProducts.where((p) => p.isLowStock || p.stockQuantity <= 5).length;
  final activeCount = adminProducts.where((p) => p.isActive).length;
  final hiddenCount = adminProducts.where((p) => !p.isActive).length;
  final saleCount = adminProducts.where((p) => p.hasDiscount).length;

  return AdminAnalyticsState(
    totalGmvUsd: gmv,
    usdToKhrRate: settings.usdToKhrRate,
    totalOrdersCount: orders.length,
    pendingOrdersCount: pending,
    lowStockProductsCount: lowStock,
    activeProductsCount: activeCount,
    hiddenProductsCount: hiddenCount,
    onSaleProductsCount: saleCount,
  );
});
