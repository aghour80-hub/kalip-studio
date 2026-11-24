import 'package:material_ui/material_ui.dart';

class ProductColor {
  final String nameEn;
  final String nameKm;
  final Color color;

  const ProductColor({
    required this.nameEn,
    required this.nameKm,
    required this.color,
  });

  String localizedName(bool isKhmer) => isKhmer ? nameKm : nameEn;

  static Color parseHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF000000);
    }
  }

  factory ProductColor.fromHex({
    required String nameEn,
    required String nameKm,
    required String hex,
  }) {
    return ProductColor(
      nameEn: nameEn,
      nameKm: nameKm,
      color: parseHex(hex),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_en': nameEn,
      'name_km': nameKm,
      // ignore: deprecated_member_use
      'hex': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    };
  }
}

class ProductVariant {
  final String id;
  final String productId;
  final String colorNameEn;
  final String colorNameKm;
  final String colorHex;
  final String size;
  final String skuVariant;
  final double? priceOverrideUsd;
  final int stockQuantity;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.colorNameEn,
    required this.colorNameKm,
    required this.colorHex,
    required this.size,
    required this.skuVariant,
    this.priceOverrideUsd,
    this.stockQuantity = 10,
  });

  ProductColor get toProductColor => ProductColor.fromHex(
        nameEn: colorNameEn,
        nameKm: colorNameKm,
        hex: colorHex,
      );

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? '',
      colorNameEn: json['color_name_en'] as String? ?? 'Classic',
      colorNameKm: json['color_name_km'] as String? ?? 'ធម្មតា',
      colorHex: json['color_hex'] as String? ?? '#000000',
      size: json['size'] as String? ?? 'M',
      skuVariant: json['sku_variant'] as String? ?? '',
      priceOverrideUsd: (json['price_override_usd'] as num?)?.toDouble(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'color_name_en': colorNameEn,
      'color_name_km': colorNameKm,
      'color_hex': colorHex,
      'size': size,
      'sku_variant': skuVariant,
      'price_override_usd': priceOverrideUsd,
      'stock_quantity': stockQuantity,
    };
  }
}

class ProductModel {
  final String id;
  final String nameEn;
  final String nameKm;
  final String descriptionEn;
  final String descriptionKm;
  final double priceUsd;
  final double? originalPriceUsd;
  final String categoryId;
  final String gender; // 'women', 'men', 'unisex'
  final List<ProductColor> colors;
  final List<String> sizes;
  final List<String> images;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final bool isNewArrival;
  final bool isBestSeller;
  final bool isFeatured;
  final List<String> detailsEn;
  final List<String> detailsKm;
  final String materialEn;
  final String materialKm;
  final List<ProductVariant> variants;

  const ProductModel({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.descriptionEn,
    required this.descriptionKm,
    required this.priceUsd,
    this.originalPriceUsd,
    required this.categoryId,
    required this.gender,
    required this.colors,
    required this.sizes,
    required this.images,
    required this.stockQuantity,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.isFeatured = false,
    required this.detailsEn,
    required this.detailsKm,
    required this.materialEn,
    required this.materialKm,
    this.variants = const [],
  });

  String localizedName(bool isKhmer) => isKhmer ? nameKm : nameEn;
  String localizedDesc(bool isKhmer) => isKhmer ? descriptionKm : descriptionEn;
  String localizedMaterial(bool isKhmer) => isKhmer ? materialKm : materialEn;
  List<String> localizedDetails(bool isKhmer) => isKhmer ? detailsKm : detailsEn;

  bool get hasDiscount => originalPriceUsd != null && originalPriceUsd! > priceUsd;
  int get discountPercentage => hasDiscount
      ? (((originalPriceUsd! - priceUsd) / originalPriceUsd!) * 100).round()
      : 0;

  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  ProductModel copyWith({
    String? id,
    String? nameEn,
    String? nameKm,
    String? descriptionEn,
    String? descriptionKm,
    double? priceUsd,
    double? originalPriceUsd,
    String? categoryId,
    String? gender,
    List<ProductColor>? colors,
    List<String>? sizes,
    List<String>? images,
    int? stockQuantity,
    double? rating,
    int? reviewCount,
    bool? isNewArrival,
    bool? isBestSeller,
    bool? isFeatured,
    List<String>? detailsEn,
    List<String>? detailsKm,
    String? materialEn,
    String? materialKm,
    List<ProductVariant>? variants,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameKm: nameKm ?? this.nameKm,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionKm: descriptionKm ?? this.descriptionKm,
      priceUsd: priceUsd ?? this.priceUsd,
      originalPriceUsd: originalPriceUsd ?? this.originalPriceUsd,
      categoryId: categoryId ?? this.categoryId,
      gender: gender ?? this.gender,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      images: images ?? this.images,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isFeatured: isFeatured ?? this.isFeatured,
      detailsEn: detailsEn ?? this.detailsEn,
      detailsKm: detailsKm ?? this.detailsKm,
      materialEn: materialEn ?? this.materialEn,
      materialKm: materialKm ?? this.materialKm,
      variants: variants ?? this.variants,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesList = (json['images'] as List<dynamic>?)
            ?.map((e) => e is Map ? e['image_url'] as String : e as String)
            .toList() ??
        (json['product_images'] as List<dynamic>?)
            ?.map((e) => (e as Map)['image_url'] as String)
            .toList() ??
        [];

    final rawVariants = (json['variants'] as List<dynamic>?)
            ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList() ??
        (json['product_variants'] as List<dynamic>?)
            ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];

    // Build color swatches from variants or colors json
    final colorsList = <ProductColor>[];
    if (json['colors'] != null) {
      for (final c in json['colors'] as List<dynamic>) {
        if (c is Map<String, dynamic>) {
          colorsList.add(ProductColor.fromHex(
            nameEn: c['name_en'] as String? ?? 'Classic',
            nameKm: c['name_km'] as String? ?? 'ធម្មតា',
            hex: c['hex'] as String? ?? '#000000',
          ));
        }
      }
    } else if (rawVariants.isNotEmpty) {
      final seenColorNames = <String>{};
      for (final v in rawVariants) {
        if (!seenColorNames.contains(v.colorNameEn)) {
          seenColorNames.add(v.colorNameEn);
          colorsList.add(v.toProductColor);
        }
      }
    }

    final sizesList = (json['sizes'] as List<dynamic>?)
            ?.map((s) => s.toString())
            .toList() ??
        (rawVariants.isNotEmpty
            ? rawVariants.map((v) => v.size).toSet().toList()
            : ['S', 'M', 'L', 'XL']);

    final totalStock = (json['stock_quantity'] as num?)?.toInt() ??
        (rawVariants.isNotEmpty
            ? rawVariants.fold<int>(0, (sum, v) => sum + v.stockQuantity)
            : 15);

    return ProductModel(
      id: json['id'] as String,
      nameEn: json['name_en'] as String? ?? '',
      nameKm: json['name_km'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionKm: json['description_km'] as String? ?? '',
      priceUsd: (json['price_usd'] as num).toDouble(),
      originalPriceUsd: (json['original_price_usd'] as num?)?.toDouble(),
      categoryId: json['category_id'] as String? ?? '',
      gender: json['gender'] as String? ?? 'all',
      colors: colorsList.isNotEmpty
          ? colorsList
          : [
              ProductColor.fromHex(
                nameEn: 'Obsidian Black',
                nameKm: 'ខ្មៅប្រណីត',
                hex: '#121212',
              ),
            ],
      sizes: sizesList,
      images: imagesList.isNotEmpty
          ? imagesList
          : ['https://images.unsplash.com/photo-1594938298603-c8148c4dae35?q=80&w=800&auto=format&fit=crop'],
      stockQuantity: totalStock,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      isNewArrival: json['is_new_arrival'] as bool? ?? false,
      isBestSeller: json['is_best_seller'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      detailsEn: (json['details_en'] as List<dynamic>?)
              ?.map((d) => d.toString())
              .toList() ??
          [],
      detailsKm: (json['details_km'] as List<dynamic>?)
              ?.map((d) => d.toString())
              .toList() ??
          [],
      materialEn: json['material_en'] as String? ?? 'Premium Textile',
      materialKm: json['material_km'] as String? ?? 'សាច់ក្រណាត់ប្រណីត',
      variants: rawVariants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_km': nameKm,
      'description_en': descriptionEn,
      'description_km': descriptionKm,
      'price_usd': priceUsd,
      'original_price_usd': originalPriceUsd,
      'category_id': categoryId,
      'gender': gender,
      'stock_quantity': stockQuantity,
      'rating': rating,
      'review_count': reviewCount,
      'is_new_arrival': isNewArrival,
      'is_best_seller': isBestSeller,
      'is_featured': isFeatured,
      'details_en': detailsEn,
      'details_km': detailsKm,
      'material_en': materialEn,
      'material_km': materialKm,
      'colors': colors.map((c) => c.toJson()).toList(),
      'sizes': sizes,
      'images': images,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }
}
