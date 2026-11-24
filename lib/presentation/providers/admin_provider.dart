import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';

class AdminAnalyticsState {
  final double totalGmvUsd;
  final int totalOrdersCount;
  final int pendingOrdersCount;
  final int lowStockProductsCount;
  final int activeProductsCount;

  const AdminAnalyticsState({
    required this.totalGmvUsd,
    required this.totalOrdersCount,
    required this.pendingOrdersCount,
    required this.lowStockProductsCount,
    required this.activeProductsCount,
  });

  double get totalGmvKhr => totalGmvUsd * AppConstants.usdToKhrRate;
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
      : super(AdminProductState(products: List.from(SampleData.products)));

  void restockProduct(String productId, int quantityToAdd) {
    state = state.copyWith(
      products: state.products.map((p) {
        if (p.id == productId) {
          final newStock = (p.stockQuantity + quantityToAdd).clamp(0, 9999);
          final updatedJson = p.toJson();
          updatedJson['stock_quantity'] = newStock;
          return ProductModel.fromJson(updatedJson);
        }
        return p;
      }).toList(),
    );
  }

  void toggleProductStatus(String productId) {
    state = state.copyWith(
      products: state.products.map((p) {
        if (p.id == productId) {
          final updatedJson = p.toJson();
          final current = updatedJson['is_active'] as bool? ?? true;
          updatedJson['is_active'] = !current;
          return ProductModel.fromJson(updatedJson);
        }
        return p;
      }).toList(),
    );
  }
}

final adminProductsProvider =
    StateNotifierProvider<AdminProductsNotifier, AdminProductState>((ref) {
  return AdminProductsNotifier();
});

final adminAnalyticsProvider = Provider<AdminAnalyticsState>((ref) {
  final orders = ref.watch(ordersProvider);
  final adminProducts = ref.watch(adminProductsProvider).products;

  final gmv = orders.fold<double>(0.0, (sum, o) => sum + o.totalUsd);
  final pending = orders.where((o) => o.status == OrderStatus.pending).length;
  final lowStock = adminProducts.where((p) => p.isLowStock || p.stockQuantity <= 5).length;

  return AdminAnalyticsState(
    totalGmvUsd: gmv,
    totalOrdersCount: orders.length,
    pendingOrdersCount: pending,
    lowStockProductsCount: lowStock,
    activeProductsCount: adminProducts.length,
  );
});
