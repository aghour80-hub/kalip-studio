import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/core/utils/image_upload_service.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

/// Full-featured Luxury Modal Sheet for Adding & Editing Products
/// with 100% FREE local/web multi-photo upload, auto-compression,
/// size/color pickers, and live USD/KHR pricing calculator.
class AdminProductEditorSheet extends ConsumerStatefulWidget {
  final ProductModel? existingProduct;

  const AdminProductEditorSheet({
    super.key,
    this.existingProduct,
  });

  static Future<void> show(BuildContext context, {ProductModel? product}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminProductEditorSheet(existingProduct: product),
    );
  }

  @override
  ConsumerState<AdminProductEditorSheet> createState() => _AdminProductEditorSheetState();
}

class _AdminProductEditorSheetState extends ConsumerState<AdminProductEditorSheet> {
  static const List<String> _presetImages = [
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1584917865442-de89df76afd3?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?q=80&w=800&auto=format&fit=crop',
  ];

  static const List<String> _allSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'];

  static final List<ProductColor> _colorPalette = [
    ProductColor.fromHex(nameEn: 'Obsidian Black', nameKm: 'ខ្មៅប្រណីត', hex: '#141414'),
    ProductColor.fromHex(nameEn: 'Champagne Gold', nameKm: 'មាសស្រាល', hex: '#D6BE9B'),
    ProductColor.fromHex(nameEn: 'Ivory White', nameKm: 'សភ្លុក', hex: '#F7F5EF'),
    ProductColor.fromHex(nameEn: 'Warm Sand', nameKm: 'ខ្សាច់កក់ក្តៅ', hex: '#D8C7AF'),
    ProductColor.fromHex(nameEn: 'Midnight Navy', nameKm: 'ខៀវចាស់', hex: '#1E2A3A'),
    ProductColor.fromHex(nameEn: 'Olive Ochre', nameKm: 'អូលីវ', hex: '#6E6950'),
    ProductColor.fromHex(nameEn: 'Burgundy Wine', nameKm: 'ក្រហមស្រា', hex: '#6B1F2B'),
    ProductColor.fromHex(nameEn: 'Emerald Silk', nameKm: 'បៃតងមរកត', hex: '#1B4D3E'),
  ];

  static const List<Map<String, String>> _categoryOptions = [
    {'id': 'women', 'label': 'Women Collection'},
    {'id': 'men', 'label': 'Men Collection'},
    {'id': 'tailoring', 'label': 'Tailoring & Blazers'},
    {'id': 'dresses', 'label': 'Dresses'},
    {'id': 'tops', 'label': 'Tops & Shirts'},
    {'id': 'outerwear', 'label': 'Outerwear'},
    {'id': 'pants', 'label': 'Pants'},
    {'id': 'bags', 'label': 'Leather Bags'},
    {'id': 'footwear', 'label': 'Footwear'},
    {'id': 'accessories', 'label': 'Silk & Accessories'},
  ];

  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _nameKmCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _origPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _materialCtrl;
  late final TextEditingController _descCtrl;
  final TextEditingController _urlInputCtrl = TextEditingController();

  late List<String> _images;
  late List<String> _selectedSizes;
  late List<ProductColor> _selectedColors;
  late String _selectedCategory;
  late String _selectedGender;
  late bool _isActive;
  late bool _isNewArrival;
  late bool _isBestSeller;
  late bool _isFeatured;

  bool _isUploading = false;
  bool _showUrlOrPresetBox = false;
  String? _uploadInfoText;

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameEnCtrl = TextEditingController(text: p?.nameEn ?? '');
    _nameKmCtrl = TextEditingController(text: p?.nameKm ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.priceUsd.toStringAsFixed(2) : '');
    _origPriceCtrl = TextEditingController(
      text: p?.originalPriceUsd != null ? p!.originalPriceUsd!.toStringAsFixed(2) : '',
    );
    _stockCtrl = TextEditingController(text: p != null ? '${p.stockQuantity}' : '15');
    _materialCtrl = TextEditingController(text: p?.materialEn ?? 'Cambodian Silk & Linen Blend');
    _descCtrl = TextEditingController(text: p?.descriptionEn ?? '');

    _images = p != null && p.images.isNotEmpty ? List<String>.from(p.images) : [];
    _selectedSizes = p != null && p.sizes.isNotEmpty ? List<String>.from(p.sizes) : ['S', 'M', 'L'];
    _selectedColors = p != null && p.colors.isNotEmpty
        ? List<ProductColor>.from(p.colors)
        : [_colorPalette[0], _colorPalette[1]];

    final validCatIds = _categoryOptions.map((c) => c['id']!).toSet();
    _selectedCategory = (p != null && validCatIds.contains(p.categoryId)) ? p.categoryId : 'women';
    _selectedGender = (p != null && ['women', 'men', 'unisex'].contains(p.gender)) ? p.gender : 'women';
    _isActive = p?.isActive ?? true;
    _isNewArrival = p?.isNewArrival ?? true;
    _isBestSeller = p?.isBestSeller ?? false;
    _isFeatured = p?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameKmCtrl.dispose();
    _priceCtrl.dispose();
    _origPriceCtrl.dispose();
    _stockCtrl.dispose();
    _materialCtrl.dispose();
    _descCtrl.dispose();
    _urlInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadFromGallery({bool multiple = true}) async {
    setState(() {
      _isUploading = true;
      _uploadInfoText = null;
    });

    try {
      final List<UploadedImageResult> results;
      if (multiple) {
        results = await ImageUploadService.pickMultipleImages(limit: 5);
      } else {
        final single = await ImageUploadService.pickSingleImage(source: ImageSource.gallery);
        results = [?single];
      }

      if (mounted && results.isNotEmpty) {
        final totalKb = results.fold<int>(0, (s, r) => s + (r.approxBytes / 1024).ceil());
        setState(() {
          for (final r in results) {
            if (!_images.contains(r.dataUri)) {
              _images.add(r.dataUri);
            }
          }
          _uploadInfoText = 'Đã tải lên ${results.length} ảnh miễn phí (~$totalKb KB)';
        });
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadFromCamera() async {
    setState(() {
      _isUploading = true;
      _uploadInfoText = null;
    });

    try {
      final result = await ImageUploadService.pickSingleImage(source: ImageSource.camera);
      if (mounted && result != null) {
        setState(() {
          _images.add(result.dataUri);
          _uploadInfoText = 'Đã chụp & tối ưu ảnh miễn phí (${result.formattedSizeKb})';
        });
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _addCustomUrl() {
    final url = _urlInputCtrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('data:image/')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập link ảnh hợp lệ (https://...)')),
      );
      return;
    }
    setState(() {
      if (!_images.contains(url)) _images.add(url);
      _urlInputCtrl.clear();
    });
  }

  void _saveProduct() {
    final title = _nameEnCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên sản phẩm (Product Title)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập giá bán hợp lệ bằng USD'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final rawOrig = _origPriceCtrl.text.trim();
    final origPrice = rawOrig.isEmpty ? null : double.tryParse(rawOrig);
    final validOrig = (origPrice != null && origPrice > price) ? origPrice : null;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 15;

    final finalImages = _images.isNotEmpty ? _images : [_presetImages.first];
    final finalSizes = _selectedSizes.isNotEmpty ? _selectedSizes : ['S', 'M', 'L'];
    final finalColors = _selectedColors.isNotEmpty ? _selectedColors : [_colorPalette.first];

    final existing = widget.existingProduct;
    if (existing != null) {
      final updated = existing.copyWith(
        nameEn: title,
        nameKm: _nameKmCtrl.text.trim().isNotEmpty ? _nameKmCtrl.text.trim() : title,
        descriptionEn: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : existing.descriptionEn,
        priceUsd: price,
        originalPriceUsd: validOrig,
        clearOriginalPrice: validOrig == null,
        categoryId: _selectedCategory,
        gender: _selectedGender,
        colors: finalColors,
        sizes: finalSizes,
        images: finalImages,
        stockQuantity: stock.clamp(0, 9999),
        isActive: _isActive,
        isNewArrival: _isNewArrival,
        isBestSeller: _isBestSeller,
        isFeatured: _isFeatured,
        materialEn: _materialCtrl.text.trim().isNotEmpty ? _materialCtrl.text.trim() : existing.materialEn,
      );
      ref.read(adminProductsProvider.notifier).updateProduct(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật "${updated.nameEn}" & đồng bộ ngay ra cửa hàng!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final created = ProductModel(
        id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
        nameEn: title,
        nameKm: _nameKmCtrl.text.trim().isNotEmpty ? _nameKmCtrl.text.trim() : title,
        descriptionEn: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : 'Handcrafted luxury piece from KALIP studio Phnom Penh Atelier.',
        descriptionKm: 'សម្លៀកបំពាក់ម៉ូដប្រណីតពី KALIP studio ភ្នំពេញ',
        priceUsd: price,
        originalPriceUsd: validOrig,
        categoryId: _selectedCategory,
        gender: _selectedGender,
        colors: finalColors,
        sizes: finalSizes,
        images: finalImages,
        stockQuantity: stock.clamp(0, 9999),
        isNewArrival: _isNewArrival,
        isBestSeller: _isBestSeller,
        isFeatured: _isFeatured,
        isActive: _isActive,
        detailsEn: const ['Designed at KALIP studio Atelier', 'Premium tailored finish'],
        detailsKm: const ['រចនាយ៉ាងពិសេសនៅ KALIP studio ភ្នំពេញ'],
        materialEn: _materialCtrl.text.trim().isNotEmpty ? _materialCtrl.text.trim() : 'Premium Textile',
        materialKm: 'ក្រណាត់ប្រណីត',
      );
      ref.read(adminProductsProvider.notifier).addProduct(created);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đăng bán "${created.nameEn}" (${finalImages.length} ảnh) lên cửa hàng!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final khrRate = ref.watch(storeSettingsProvider).usdToKhrRate;
    final parsedPrice = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final khrVal = ((parsedPrice * khrRate) / 100).round() * 100;
    final khrFormatted = khrVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.93,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Handle & Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            _isEditing ? Icons.edit_outlined : Icons.add_photo_alternate_outlined,
                            color: AppColors.luxuryBeige,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditing ? 'EDIT PRODUCT & PHOTOS' : 'NEW PRODUCT + FREE PHOTO UPLOAD',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const Text(
                                'Tự động nén ảnh miễn phí & đồng bộ trực tiếp ra cửa hàng',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Scrollable Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === SECTION 1: FREE IMAGE UPLOADER ===
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '1. PRODUCT PHOTOS (FREE UPLOAD)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.luxuryBeigeDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              '100% FREE • NO CLOUD FEE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Upload Action Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.canvasLinen,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.luxuryBeige, width: 1.2),
                        ),
                        child: Column(
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlack,
                                    foregroundColor: AppColors.pureWhite,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                  ),
                                  onPressed: _isUploading ? null : () => _uploadFromGallery(multiple: true),
                                  icon: _isUploading
                                      ? const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pureWhite),
                                        )
                                      : const Icon(Icons.cloud_upload_outlined, size: 18, color: AppColors.luxuryBeige),
                                  label: Text(
                                    _isUploading ? 'Đang tải & tối ưu...' : 'Tải ảnh từ Máy / Thư viện (Free)',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (ImageUploadService.supportsCamera)
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    ),
                                    onPressed: _isUploading ? null : _uploadFromCamera,
                                    icon: const Icon(Icons.camera_alt_outlined, size: 17),
                                    label: const Text('Chụp ảnh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            if (_uploadInfoText != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _uploadInfoText!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],

                            // Uploaded / Selected Images Preview Strip
                            if (_images.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 112,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length,
                                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                                  itemBuilder: (_, idx) {
                                    final imgSrc = _images[idx];
                                    final isCover = idx == 0;
                                    final isUploaded = LuxuryImage.isDataUri(imgSrc);
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 86,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isCover ? AppColors.primaryBlack : AppColors.borderMedium,
                                              width: isCover ? 2 : 0.8,
                                            ),
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: LuxuryImage(imageUrl: imgSrc, fit: BoxFit.cover),
                                        ),
                                        // Cover or Set-as-Cover pill
                                        Positioned(
                                          left: 4,
                                          bottom: 4,
                                          child: InkWell(
                                            onTap: isCover
                                                ? null
                                                : () {
                                                    setState(() {
                                                      final chosen = _images.removeAt(idx);
                                                      _images.insert(0, chosen);
                                                    });
                                                  },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isCover ? AppColors.primaryBlack : Colors.black54,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: Text(
                                                isCover ? 'COVER' : 'Set Main',
                                                style: TextStyle(
                                                  color: isCover ? AppColors.luxuryBeige : AppColors.pureWhite,
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (isUploaded)
                                          Positioned(
                                            left: 4,
                                            top: 4,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.success,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: const Text(
                                                'FREE',
                                                style: TextStyle(color: AppColors.pureWhite, fontSize: 7.5, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        // Delete image button
                                        Positioned(
                                          right: -4,
                                          top: -4,
                                          child: InkWell(
                                            onTap: () => setState(() => _images.removeAt(idx)),
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                color: AppColors.error,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close, size: 12, color: AppColors.pureWhite),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Chưa có ảnh nào • Hãy tải ảnh thật từ điện thoại/máy tính hoặc chọn ảnh mẫu bên dưới',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],

                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => setState(() => _showUrlOrPresetBox = !_showUrlOrPresetBox),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _showUrlOrPresetBox ? 'Ẩn ảnh mẫu & Link URL' : 'Hoặc chọn ảnh Studio mẫu / Dán URL',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.luxuryBeigeDark,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  Icon(
                                    _showUrlOrPresetBox ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: AppColors.luxuryBeigeDark,
                                  ),
                                ],
                              ),
                            ),

                            if (_showUrlOrPresetBox) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 54,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _presetImages.length,
                                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                                  itemBuilder: (_, i) {
                                    final url = _presetImages[i];
                                    final added = _images.contains(url);
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (!added) _images.add(url);
                                        });
                                      },
                                      child: Container(
                                        width: 46,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: added ? AppColors.success : AppColors.borderMedium,
                                            width: added ? 2 : 0.8,
                                          ),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: LuxuryImage(imageUrl: url, fit: BoxFit.cover),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _urlInputCtrl,
                                      decoration: const InputDecoration(
                                        hintText: 'https://... (Paste image URL)',
                                        filled: true,
                                        fillColor: AppColors.pureWhite,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: _addCustomUrl,
                                    child: const Text('Add URL', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // === SECTION 2: PRODUCT IDENTITY ===
                      const Text(
                        '2. PRODUCT DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.luxuryBeigeDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameEnCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Product Name (English / Main) *',
                          hintText: 'e.g. Silk Organza Pleated Dress',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameKmCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Khmer Name (Optional)',
                          hintText: 'e.g. រ៉ូបសូត្រប្រណីត',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(labelText: 'Category'),
                              items: _categoryOptions
                                  .map((c) => DropdownMenuItem(value: c['id'], child: Text(c['label']!, style: const TextStyle(fontSize: 12.5))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCategory = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              decoration: const InputDecoration(labelText: 'Collection'),
                              items: const [
                                DropdownMenuItem(value: 'women', child: Text('Women', style: TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: 'men', child: Text('Men', style: TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: 'unisex', child: Text('Unisex', style: TextStyle(fontSize: 12.5))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedGender = val);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // === SECTION 3: PRICING & STOCK ===
                      const Text(
                        '3. PRICING, SALE & STOCK',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.luxuryBeigeDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _priceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Sell Price (USD) *',
                                prefixText: '\$ ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _origPriceCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Original MSRP',
                                prefixText: '\$ ',
                                hintText: 'Optional',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 82,
                            child: TextField(
                              controller: _stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Stock'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Live KHR Equivalent: ≈ $khrFormatted ៛ (Rate: ${khrRate.toInt()} ៛ / USD)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.luxuryBeigeDark),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: [
                          ActionChip(
                            label: const Text('Clear Sale', style: TextStyle(fontSize: 10)),
                            onPressed: () {
                              final base = double.tryParse(_origPriceCtrl.text) ?? parsedPrice;
                              setState(() {
                                if (base > 0) _priceCtrl.text = base.toStringAsFixed(2);
                                _origPriceCtrl.clear();
                              });
                            },
                          ),
                          for (final pct in [10, 20, 30, 50])
                            ActionChip(
                              label: Text('-$pct% Off', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                final base = double.tryParse(_origPriceCtrl.text) ?? parsedPrice;
                                if (base <= 0) return;
                                setState(() {
                                  _origPriceCtrl.text = base.toStringAsFixed(2);
                                  _priceCtrl.text = (base * (1 - pct / 100)).toStringAsFixed(2);
                                });
                              },
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // === SECTION 4: SIZES & COLORS ===
                      const Text(
                        '4. SIZES & COLOR SWATCHES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.luxuryBeigeDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _allSizes.map((sz) {
                          final selected = _selectedSizes.contains(sz);
                          return FilterChip(
                            label: Text(sz, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? AppColors.pureWhite : AppColors.primaryBlack)),
                            selected: selected,
                            selectedColor: AppColors.primaryBlack,
                            checkmarkColor: AppColors.luxuryBeige,
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  _selectedSizes.add(sz);
                                } else if (_selectedSizes.length > 1) {
                                  _selectedSizes.remove(sz);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _colorPalette.map((col) {
                          final selected = _selectedColors.any((c) => c.nameEn == col.nameEn);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  if (_selectedColors.length > 1) {
                                    _selectedColors.removeWhere((c) => c.nameEn == col.nameEn);
                                  }
                                } else {
                                  _selectedColors.add(col);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primaryBlack : AppColors.canvasLinen,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected ? AppColors.primaryBlack : AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: col.color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white70, width: 1),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    col.nameEn,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? AppColors.pureWhite : AppColors.primaryBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // === SECTION 5: MATERIAL, DESCRIPTION & FLAGS ===
                      const Text(
                        '5. FABRIC, DESCRIPTION & STOREFRONT VISIBILITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppColors.luxuryBeigeDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _materialCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Material / Fabric',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Tailoring notes, silk grade, silhouette...',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          FilterChip(
                            label: const Text('Visible in Shop', style: TextStyle(fontSize: 11)),
                            selected: _isActive,
                            onSelected: (v) => setState(() => _isActive = v),
                          ),
                          FilterChip(
                            label: const Text('New Arrival', style: TextStyle(fontSize: 11)),
                            selected: _isNewArrival,
                            onSelected: (v) => setState(() => _isNewArrival = v),
                          ),
                          FilterChip(
                            label: const Text('Best Seller', style: TextStyle(fontSize: 11)),
                            selected: _isBestSeller,
                            onSelected: (v) => setState(() => _isBestSeller = v),
                          ),
                          FilterChip(
                            label: const Text('Featured', style: TextStyle(fontSize: 11)),
                            selected: _isFeatured,
                            onSelected: (v) => setState(() => _isFeatured = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Save Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  color: AppColors.pureWhite,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: AppTypography.titleSmall(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _saveProduct,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          _isEditing ? 'SAVE CHANGES' : 'PUBLISH PRODUCT LIVE',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
