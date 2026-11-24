import 'package:style_house/core/config/supabase_config.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/product_model.dart';

class ProductRepository {
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? gender,
    bool? isNewArrival,
    bool? isBestSeller,
    bool? isFeatured,
    String? searchQuery,
  }) async {
    final client = SupabaseConfig.client;

    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        var query = client.from('products').select('''
          *,
          product_images(image_url, display_order, is_primary),
          product_variants(id, color_name_en, color_name_km, color_hex, size, sku_variant, price_override_usd)
        ''').eq('is_active', true);

        if (categoryId != null && categoryId != 'all') {
          query = query.eq('category_id', categoryId);
        }
        if (gender != null && gender != 'all') {
          query = query.or('gender.eq.$gender,gender.eq.unisex');
        }
        if (isNewArrival == true) {
          query = query.eq('is_new_arrival', true);
        }
        if (isBestSeller == true) {
          query = query.eq('is_best_seller', true);
        }
        if (isFeatured == true) {
          query = query.eq('is_featured', true);
        }

        final response = await query;
        final products = (response as List<dynamic>)
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return products;
      } catch (_) {
        // Fallback to sample data on error
      }
    }

    // Fallback/Mock mode with in-memory filtering
    var list = List<ProductModel>.from(SampleData.products);

    if (categoryId != null && categoryId != 'all') {
      list = list.where((p) => p.categoryId == categoryId || p.gender == categoryId).toList();
    }
    if (gender != null && gender != 'all') {
      list = list.where((p) => p.gender == gender || p.gender == 'unisex').toList();
    }
    if (isNewArrival == true) {
      list = list.where((p) => p.isNewArrival).toList();
    }
    if (isBestSeller == true) {
      list = list.where((p) => p.isBestSeller).toList();
    }
    if (isFeatured == true) {
      list = list.where((p) => p.isFeatured).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) {
        return p.nameEn.toLowerCase().contains(q) ||
            p.nameKm.toLowerCase().contains(q) ||
            p.descriptionEn.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  Future<ProductModel?> getProductById(String id) async {
    final client = SupabaseConfig.client;

    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        final response = await client.from('products').select('''
          *,
          product_images(image_url, display_order, is_primary),
          product_variants(id, color_name_en, color_name_km, color_hex, size, sku_variant, price_override_usd)
        ''').eq('id', id).maybeSingle();

        if (response != null) {
          return ProductModel.fromJson(response);
        }
      } catch (_) {}
    }

    try {
      return SampleData.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Verifies available stock for a specific size and color combination
  Future<int> checkAvailableStock({
    required String productId,
    required String size,
    required String colorNameEn,
  }) async {
    final client = SupabaseConfig.client;

    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        final variantResp = await client
            .from('product_variants')
            .select('id, inventory(stock_quantity, reserved_quantity)')
            .eq('product_id', productId)
            .eq('size', size)
            .eq('color_name_en', colorNameEn)
            .maybeSingle();

        if (variantResp != null && variantResp['inventory'] != null) {
          final inv = variantResp['inventory'];
          final stock = (inv['stock_quantity'] as num).toInt();
          final reserved = (inv['reserved_quantity'] as num?)?.toInt() ?? 0;
          return (stock - reserved).clamp(0, 9999);
        }
      } catch (_) {}
    }

    // In mock mode, check product total stock or default 12
    final product = await getProductById(productId);
    return product?.stockQuantity ?? 12;
  }
}
