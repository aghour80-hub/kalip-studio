import 'package:flutter_riverpod/legacy.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/product_model.dart';

class WishlistNotifier extends StateNotifier<List<ProductModel>> {
  WishlistNotifier()
      : super([
          SampleData.products[2], // Sculpted Blazer
          SampleData.products[4], // Monogram Bag
        ]);

  bool isInWishlist(String productId) {
    return state.any((p) => p.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  void removeFromWishlist(String productId) {
    state = state.where((p) => p.id != productId).toList();
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<ProductModel>>((ref) {
  return WishlistNotifier();
});
