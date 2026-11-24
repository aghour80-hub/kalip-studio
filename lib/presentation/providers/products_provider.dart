import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:style_house/data/models/category_model.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/data/repositories/category_repository.dart';
import 'package:style_house/data/repositories/product_repository.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';

enum ProductSortOption {
  featured,
  newest,
  priceLowToHigh,
  priceHighToLow,
  rating,
}

class ProductFilterState {
  final String? categoryId;
  final String? gender; // 'women', 'men', 'all'
  final String searchQuery;
  final ProductSortOption sortOption;

  const ProductFilterState({
    this.categoryId,
    this.gender,
    this.searchQuery = '',
    this.sortOption = ProductSortOption.featured,
  });

  ProductFilterState copyWith({
    String? categoryId,
    String? gender,
    String? searchQuery,
    ProductSortOption? sortOption,
    bool clearCategory = false,
    bool clearGender = false,
  }) {
    return ProductFilterState(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      gender: clearGender ? null : (gender ?? this.gender),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class ProductFilterNotifier extends StateNotifier<ProductFilterState> {
  ProductFilterNotifier() : super(const ProductFilterState());

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearCategory: categoryId == null);
  }

  void setGender(String? gender) {
    state = state.copyWith(gender: gender, clearGender: gender == null);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(ProductSortOption sort) {
    state = state.copyWith(sortOption: sort);
  }

  void resetFilters() {
    state = const ProductFilterState();
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productFilterProvider =
    StateNotifierProvider<ProductFilterNotifier, ProductFilterState>((ref) {
  return ProductFilterNotifier();
});

final categoriesListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories();
});

final allProductsProvider = Provider<List<ProductModel>>((ref) {
  return ref
      .watch(adminProductsProvider)
      .products
      .where((p) => p.isActive)
      .toList();
});

final onSaleProductsProvider = Provider<List<ProductModel>>((ref) {
  return ref.watch(allProductsProvider).where((p) => p.hasDiscount).toList();
});

final filteredProductsProvider = Provider<List<ProductModel>>((ref) {
  final all = ref.watch(allProductsProvider);
  final filter = ref.watch(productFilterProvider);

  var list = all.where((product) {
    if (filter.categoryId != null && filter.categoryId != 'all') {
      if (product.categoryId != filter.categoryId && filter.categoryId != product.gender) {
        return false;
      }
    }

    if (filter.gender != null && filter.gender != 'all') {
      if (product.gender != filter.gender && product.gender != 'unisex') {
        return false;
      }
    }

    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      final matchName = product.nameEn.toLowerCase().contains(q) ||
          product.nameKm.toLowerCase().contains(q);
      final matchDesc = product.descriptionEn.toLowerCase().contains(q) ||
          product.descriptionKm.toLowerCase().contains(q);
      if (!matchName && !matchDesc) return false;
    }

    return true;
  }).toList();

  switch (filter.sortOption) {
    case ProductSortOption.newest:
      list.sort((a, b) => (b.isNewArrival ? 1 : 0).compareTo(a.isNewArrival ? 1 : 0));
      break;
    case ProductSortOption.priceLowToHigh:
      list.sort((a, b) => a.priceUsd.compareTo(b.priceUsd));
      break;
    case ProductSortOption.priceHighToLow:
      list.sort((a, b) => b.priceUsd.compareTo(a.priceUsd));
      break;
    case ProductSortOption.rating:
      list.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case ProductSortOption.featured:
      list.sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
      break;
  }

  return list;
});

final newArrivalsProvider = Provider<List<ProductModel>>((ref) {
  return ref.watch(allProductsProvider).where((p) => p.isNewArrival).toList();
});

final bestSellersProvider = Provider<List<ProductModel>>((ref) {
  return ref.watch(allProductsProvider).where((p) => p.isBestSeller).toList();
});

final productDetailProvider = Provider.family<ProductModel?, String>((ref, id) {
  final products = ref.watch(allProductsProvider);
  try {
    return products.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});
