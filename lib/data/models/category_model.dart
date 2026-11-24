class CategoryModel {
  final String id;
  final String nameEn;
  final String nameKm;
  final String imageUrl;
  final int itemCount;
  final String gender; // 'women', 'men', 'all', 'accessories'
  final bool isFeatured;

  const CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.imageUrl,
    required this.itemCount,
    required this.gender,
    this.isFeatured = false,
  });

  String localizedName(bool isKhmer) => isKhmer ? nameKm : nameEn;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? json['slug'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameKm: json['name_km'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? 'all',
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_km': nameKm,
      'image_url': imageUrl,
      'item_count': itemCount,
      'gender': gender,
      'is_featured': isFeatured,
    };
  }
}
