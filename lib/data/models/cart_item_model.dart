import 'package:material_ui/material_ui.dart';
import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final ProductColor selectedColor;
  final String selectedSize;
  final String? variantId;
  int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    this.variantId,
    this.quantity = 1,
  });

  double get totalPriceUsd => product.priceUsd * quantity;

  CartItemModel copyWith({
    int? quantity,
    ProductColor? selectedColor,
    String? selectedSize,
    String? variantId,
  }) {
    return CartItemModel(
      id: id,
      product: product,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json, ProductModel product) {
    return CartItemModel(
      id: json['id'] as String,
      product: product,
      variantId: json['variant_id'] as String?,
      selectedColor: json['selected_color'] != null
          ? ProductColor.fromHex(
              nameEn: json['selected_color']['name_en'] as String? ?? 'Classic',
              nameKm: json['selected_color']['name_km'] as String? ?? 'ធម្មតា',
              hex: json['selected_color']['hex'] as String? ?? '#000000',
            )
          : (product.colors.isNotEmpty ? product.colors.first : const ProductColor(nameEn: 'Black', nameKm: 'ខ្មៅ', color: Color(0xFF121212))),
      selectedSize: json['selected_size'] as String? ?? 'M',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'variant_id': variantId,
      'selected_color': selectedColor.toJson(),
      'selected_size': selectedSize,
      'quantity': quantity,
      'unit_price_usd': product.priceUsd,
      'total_price_usd': totalPriceUsd,
    };
  }
}
