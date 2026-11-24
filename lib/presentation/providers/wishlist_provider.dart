import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';

class WishlistNotifier extends StateNotifier<List<ProductModel>> {
  final Ref? ref;

  WishlistNotifier({this.ref})
      : super([
          SampleData.products[2], // Sculpted Blazer
          SampleData.products[4], // Monogram Bag
        ]) {
    _loadPersistedWishlist();
  }

  Future<void> _loadPersistedWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final raw = prefs.getString(AppConstants.keyWishlist);
      if (raw != null && raw.isNotEmpty) {
        final ids = (jsonDecode(raw) as List<dynamic>).map((e) => e.toString()).toSet();
        final catalog = ref?.read(adminProductsProvider).products ?? SampleData.products;
        final matched = catalog.where((p) => ids.contains(p.id)).toList();
        if (mounted) {
          state = matched;
        }
      }
    } catch (_) {}
  }

  Future<void> _persistWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = state.map((p) => p.id).toList();
      await prefs.setString(AppConstants.keyWishlist, jsonEncode(ids));
    } catch (_) {}
  }

  bool isInWishlist(String productId) {
    return state.any((p) => p.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
    _persistWishlist();
  }

  void removeFromWishlist(String productId) {
    state = state.where((p) => p.id != productId).toList();
    _persistWishlist();
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, List<ProductModel>>((ref) {
  return WishlistNotifier(ref: ref);
});
