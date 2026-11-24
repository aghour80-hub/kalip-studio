import 'package:style_house/core/config/supabase_config.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/cart_item_model.dart';

class CartRepository {
  // In-memory fallback cart for guest or mock runs
  final List<CartItemModel> _localCart = List.from(SampleData.initialCart);

  Future<List<CartItemModel>> getCart(String userId) async {
    final client = SupabaseConfig.client;

    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        final cartResp = await client
            .from('carts')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();

        if (cartResp != null) {
          final cartId = cartResp['id'] as String;
          final itemsResp = await client.from('cart_items').select('''
            id,
            quantity,
            variant_id,
            product_variants(
              color_name_en,
              color_name_km,
              color_hex,
              size,
              products(
                *
              )
            )
          ''').eq('cart_id', cartId);

          if (itemsResp.isNotEmpty) {
            // Note: Map Supabase joined response if present
          }
        }
      } catch (_) {
        // Fallback to local
      }
    }

    return List.unmodifiable(_localCart);
  }

  Future<void> addItem(String userId, CartItemModel item) async {
    final existingIndex = _localCart.indexWhere(
      (i) =>
          i.product.id == item.product.id &&
          i.selectedColor.nameEn == item.selectedColor.nameEn &&
          i.selectedSize == item.selectedSize,
    );

    if (existingIndex >= 0) {
      final existing = _localCart[existingIndex];
      _localCart[existingIndex] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      _localCart.add(item);
    }

    final client = SupabaseConfig.client;
    if (client != null && !SupabaseConfig.isMockMode && item.variantId != null) {
      try {
        // Ensure user cart exists
        final cart = await client
            .from('carts')
            .upsert({'user_id': userId})
            .select('id')
            .single();

        await client.from('cart_items').upsert({
          'cart_id': cart['id'],
          'variant_id': item.variantId,
          'quantity': item.quantity,
        });
      } catch (_) {}
    }
  }

  Future<void> updateQuantity(String userId, String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(userId, cartItemId);
      return;
    }

    final index = _localCart.indexWhere((i) => i.id == cartItemId);
    if (index >= 0) {
      _localCart[index] = _localCart[index].copyWith(quantity: quantity);
    }

    final client = SupabaseConfig.client;
    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        await client
            .from('cart_items')
            .update({'quantity': quantity})
            .eq('id', cartItemId);
      } catch (_) {}
    }
  }

  Future<void> removeItem(String userId, String cartItemId) async {
    _localCart.removeWhere((i) => i.id == cartItemId);

    final client = SupabaseConfig.client;
    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        await client.from('cart_items').delete().eq('id', cartItemId);
      } catch (_) {}
    }
  }

  Future<void> clearCart(String userId) async {
    _localCart.clear();

    final client = SupabaseConfig.client;
    if (client != null && !SupabaseConfig.isMockMode) {
      try {
        final cart = await client
            .from('carts')
            .select('id')
            .eq('user_id', userId)
            .maybeSingle();
        if (cart != null) {
          await client.from('cart_items').delete().eq('cart_id', cart['id']);
        }
      } catch (_) {}
    }
  }
}
