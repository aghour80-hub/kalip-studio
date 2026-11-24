import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  String _searchQuery = '';
  String _selectedGender = 'all';

  // 1. QUICK PRICE CHANGE DIALOG
  void _showQuickPriceDialog(BuildContext context, ProductModel product) {
    final priceController = TextEditingController(text: product.priceUsd.toStringAsFixed(2));
    final originalPriceController = TextEditingController(
      text: product.originalPriceUsd != null ? product.originalPriceUsd!.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currentInputPrice = double.tryParse(priceController.text) ?? product.priceUsd;
          final khrEquivalent = (currentInputPrice * AppConstants.usdToKhrRate).toStringAsFixed(0);

          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            title: Row(
              children: [
                const Icon(Icons.price_change_outlined, color: AppColors.luxuryBeigeDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Update Price & Discount',
                    style: AppTypography.titleMedium(),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameEn,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Selling Price (USD)
                  const Text(
                    'Selling Price (USD):',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: AppColors.canvasLinen,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '≈ $khrEquivalent ៛ KHR (at rate 1 USD = 4,100 KHR)',
                    style: const TextStyle(fontSize: 11, color: AppColors.luxuryBeigeDark, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Original Price (USD) for Discount Badge
                  const Text(
                    'Original Price / MSRP (USD) (Optional):',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: originalPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      hintText: 'Leave empty if no discount',
                      filled: true,
                      fillColor: AppColors.canvasLinen,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final newPrice = double.tryParse(priceController.text);
                  if (newPrice == null || newPrice <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid price in USD.')),
                    );
                    return;
                  }
                  final newOrigPrice = double.tryParse(originalPriceController.text);

                  ref.read(adminProductsProvider.notifier).updatePrice(
                        product.id,
                        newPrice,
                        newOriginalPriceUsd: newOrigPrice,
                      );

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated price for "${product.nameEn}" to \$${newPrice.toStringAsFixed(2)}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Save Price'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 2. EDIT PRODUCT DETAILS DIALOG
  void _showEditProductDialog(BuildContext context, ProductModel product) {
    final nameEnController = TextEditingController(text: product.nameEn);
    final nameKmController = TextEditingController(text: product.nameKm);
    final priceController = TextEditingController(text: product.priceUsd.toStringAsFixed(2));
    final originalPriceController = TextEditingController(
      text: product.originalPriceUsd != null ? product.originalPriceUsd!.toStringAsFixed(2) : '',
    );
    final stockController = TextEditingController(text: product.stockQuantity.toString());
    final descEnController = TextEditingController(text: product.descriptionEn);
    final imageController = TextEditingController(text: product.images.first);
    String selectedCat = product.categoryId;
    String selectedGender = product.gender;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            title: Row(
              children: [
                const Icon(Icons.edit_note_outlined, color: AppColors.primaryBlack),
                const SizedBox(width: 8),
                Text('Edit Product Details', style: AppTypography.titleMedium()),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // English Name
                    const Text('Product Title (English):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameEnController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Khmer Name
                    const Text('Product Title (Khmer):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameKmController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price & Stock Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Price (USD):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Original Price (USD):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: originalPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  hintText: 'Optional',
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Stock Units:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: stockController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category & Gender Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Category:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCat,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'dresses', child: Text('Dresses')),
                                  DropdownMenuItem(value: 'tops', child: Text('Tops & Shirts')),
                                  DropdownMenuItem(value: 'outerwear', child: Text('Outerwear')),
                                  DropdownMenuItem(value: 'pants', child: Text('Pants & Tailoring')),
                                  DropdownMenuItem(value: 'bags', child: Text('Bags')),
                                  DropdownMenuItem(value: 'accessories', child: Text('Accessories')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedCat = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Gender Collection:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedGender,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'women', child: Text('Women')),
                                  DropdownMenuItem(value: 'men', child: Text('Men')),
                                  DropdownMenuItem(value: 'unisex', child: Text('Unisex')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedGender = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Image URL
                    const Text('Image URL (Web):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: imageController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    const Text('Description (English):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: descEnController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final newPrice = double.tryParse(priceController.text) ?? product.priceUsd;
                  final newOrigPrice = double.tryParse(originalPriceController.text);
                  final newStock = int.tryParse(stockController.text) ?? product.stockQuantity;

                  final updated = product.copyWith(
                    nameEn: nameEnController.text.trim().isEmpty ? product.nameEn : nameEnController.text.trim(),
                    nameKm: nameKmController.text.trim().isEmpty ? product.nameKm : nameKmController.text.trim(),
                    priceUsd: newPrice,
                    originalPriceUsd: newOrigPrice,
                    stockQuantity: newStock,
                    categoryId: selectedCat,
                    gender: selectedGender,
                    descriptionEn: descEnController.text.trim(),
                    images: imageController.text.trim().isNotEmpty
                        ? [imageController.text.trim(), ...product.images.skip(1)]
                        : product.images,
                  );

                  ref.read(adminProductsProvider.notifier).updateProduct(updated);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully updated "${updated.nameEn}".'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 3. ADD NEW PRODUCT DIALOG
  void _showAddProductDialog(BuildContext context) {
    final nameEnController = TextEditingController();
    final nameKmController = TextEditingController();
    final priceController = TextEditingController();
    final originalPriceController = TextEditingController();
    final stockController = TextEditingController(text: '20');
    final descEnController = TextEditingController();
    final imageController = TextEditingController(
      text: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=800&auto=format&fit=crop',
    );
    String selectedCat = 'dresses';
    String selectedGender = 'women';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            title: Row(
              children: [
                const Icon(Icons.add_circle_outline, color: AppColors.luxuryBeigeDark),
                const SizedBox(width: 8),
                Text('Add New Fashion Product', style: AppTypography.titleMedium()),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Title (English):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameEnController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Silk Organza Pleated Gown',
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Product Title (Khmer):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameKmController,
                      decoration: InputDecoration(
                        hintText: 'e.g. រ៉ូបសូត្រប្រណីតម៉ូដថ្មី',
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Price (USD):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  hintText: '145.00',
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Original Price (USD):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: originalPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  hintText: 'Optional',
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Stock Units:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              TextField(
                                controller: stockController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Category:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCat,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'dresses', child: Text('Dresses')),
                                  DropdownMenuItem(value: 'tops', child: Text('Tops & Shirts')),
                                  DropdownMenuItem(value: 'outerwear', child: Text('Outerwear')),
                                  DropdownMenuItem(value: 'pants', child: Text('Pants & Tailoring')),
                                  DropdownMenuItem(value: 'bags', child: Text('Bags')),
                                  DropdownMenuItem(value: 'accessories', child: Text('Accessories')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedCat = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Gender Collection:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedGender,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.canvasLinen,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'women', child: Text('Women')),
                                  DropdownMenuItem(value: 'men', child: Text('Men')),
                                  DropdownMenuItem(value: 'unisex', child: Text('Unisex')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedGender = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text('Image URL:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: imageController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text('Description (English):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: descEnController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter tailoring fabric details...',
                        filled: true,
                        fillColor: AppColors.canvasLinen,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = nameEnController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a product title.')),
                    );
                    return;
                  }
                  final price = double.tryParse(priceController.text) ?? 95.0;
                  final origPrice = double.tryParse(originalPriceController.text);
                  final stock = int.tryParse(stockController.text) ?? 20;

                  final newProd = ProductModel(
                    id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                    nameEn: title,
                    nameKm: nameKmController.text.trim().isNotEmpty ? nameKmController.text.trim() : title,
                    descriptionEn: descEnController.text.trim().isNotEmpty
                        ? descEnController.text.trim()
                        : 'Handcrafted luxury apparel from KALIP studio BKK1 atelier.',
                    descriptionKm: 'សម្លៀកបំពាក់ម៉ូដប្រណីតពី KALIP studio ភ្នំពេញ',
                    priceUsd: price,
                    originalPriceUsd: origPrice,
                    categoryId: selectedCat,
                    gender: selectedGender,
                    colors: [
                      ProductColor.fromHex(nameEn: 'Obsidian Black', nameKm: 'ខ្មៅ', hex: '#121212'),
                      ProductColor.fromHex(nameEn: 'Luxury Beige', nameKm: 'បន៍មាស', hex: '#C5A880'),
                    ],
                    sizes: ['S', 'M', 'L', 'XL'],
                    images: [
                      imageController.text.trim().isNotEmpty
                          ? imageController.text.trim()
                          : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=800&auto=format&fit=crop',
                    ],
                    stockQuantity: stock,
                    isNewArrival: true,
                    detailsEn: ['Designed in Phnom Penh Atelier', 'Dry clean recommended'],
                    detailsKm: ['រចនាយ៉ាងពិសេសនៅភ្នំពេញ'],
                    materialEn: 'Cambodian Silk & Linen Blend',
                    materialKm: 'ក្រណាត់សូត្រ និងកប្បាសលីនិន',
                  );

                  ref.read(adminProductsProvider.notifier).addProduct(newProd);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created new product "${newProd.nameEn}".'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Create Product'),
              ),
            ],
          );
        },
      ),
    );
  }

  // 4. DELETE PRODUCT CONFIRMATION DIALOG
  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete "${product.nameEn}"?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              'This item will be removed immediately from the boutique storefront, catalog, and search results.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.pureWhite,
            ),
            onPressed: () {
              ref.read(adminProductsProvider.notifier).deleteProduct(product.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${product.nameEn}" from catalog.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  // 5. RESTOCK DIALOG
  void _showRestockDialog(BuildContext context, String productId, String productName, int currentStock) {
    int restockQty = 10;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            title: Text(
              'Restock Flagship Inventory',
              style: AppTypography.titleMedium(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current Physical Stock: $currentStock units',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Units to Add (BKK1 Flagship Hub):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.luxuryBeigeDark),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [5, 10, 25, 50].map((qty) {
                    final isSelected = restockQty == qty;
                    return ChoiceChip(
                      label: Text('+$qty'),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBlack,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.pureWhite : AppColors.primaryBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setDialogState(() => restockQty = qty),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(adminProductsProvider.notifier).restockProduct(productId, restockQty);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added +$restockQty units to "$productName". New stock: ${currentStock + restockQty}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Confirm Restock'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(adminProductsProvider).products;

    final filtered = products.where((p) {
      if (_selectedGender != 'all' && p.gender != _selectedGender && p.gender != 'unisex') {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.nameEn.toLowerCase().contains(q) ||
            p.nameKm.toLowerCase().contains(q) ||
            p.categoryId.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    final totalStockUnits = products.fold<int>(0, (sum, p) => sum + p.stockQuantity);
    final lowStockCount = products.where((p) => p.isLowStock || p.stockQuantity <= 5).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CATALOG & PRICING',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlack,
              backgroundColor: AppColors.luxuryBeige,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'ADD PRODUCT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8),
            ),
            onPressed: () => _showAddProductDialog(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // 1. TOP METRICS STRIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.primaryBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('TOTAL ITEMS', '${products.length}', AppColors.pureWhite),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildSummaryItem('TOTAL STOCK', '$totalStockUnits Units', AppColors.luxuryBeige),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildSummaryItem(
                  'LOW STOCK',
                  '$lowStockCount Items',
                  lowStockCount > 0 ? AppColors.warning : AppColors.success,
                ),
              ],
            ),
          ),

          // 2. SEARCH & GENDER FILTER TOOLBAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.canvasLinen,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by product name, category, or SKU...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.pureWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'women', 'men', 'unisex'].map((gender) {
                      final isSel = _selectedGender == gender;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(gender.toUpperCase()),
                          selected: isSel,
                          selectedColor: AppColors.primaryBlack,
                          labelStyle: TextStyle(
                            color: isSel ? AppColors.pureWhite : AppColors.primaryBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          onSelected: (_) => setState(() => _selectedGender = gender),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 3. PRODUCTS LIST WITH FULL MANAGEMENT
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'No products found matching criteria',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => _showAddProductDialog(context),
                          child: const Text('+ Add New Product'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final isLow = product.isLowStock || product.stockQuantity <= 5;
                      final khrPrice = (product.priceUsd * AppConstants.usdToKhrRate).toStringAsFixed(0);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail
                                SizedBox(
                                  width: 64,
                                  height: 80,
                                  child: LuxuryImage(
                                    imageUrl: product.images.first,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.nameEn,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product.nameKm,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),

                                      // Price Row (USD + KHR)
                                      Row(
                                        children: [
                                          Text(
                                            '\$${product.priceUsd.toStringAsFixed(2)} USD',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: AppColors.primaryBlack,
                                            ),
                                          ),
                                          if (product.hasDiscount) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '\$${product.originalPriceUsd!.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                decoration: TextDecoration.lineThrough,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(width: 6),
                                          Text(
                                            '≈ $khrPrice ៛',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.luxuryBeigeDark,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Stock & Category Badges
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            color: isLow
                                                ? AppColors.warning.withValues(alpha: 0.15)
                                                : AppColors.success.withValues(alpha: 0.15),
                                            child: Text(
                                              '${product.stockQuantity} IN STOCK',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isLow ? AppColors.warning : AppColors.success,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            color: AppColors.canvasLinen,
                                            child: Text(
                                              '${product.gender.toUpperCase()} • ${product.categoryId.toUpperCase()}',
                                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 20, thickness: 0.7, color: AppColors.borderLight),

                            // Action Buttons Row (English Menu)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 1. Quick Price Button
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  icon: const Icon(Icons.price_change_outlined, size: 14),
                                  label: const Text('Price', style: TextStyle(fontSize: 11)),
                                  onPressed: () => _showQuickPriceDialog(context, product),
                                ),
                                const SizedBox(width: 6),

                                // 2. Edit Details Button
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  icon: const Icon(Icons.edit_note_outlined, size: 14),
                                  label: const Text('Edit', style: TextStyle(fontSize: 11)),
                                  onPressed: () => _showEditProductDialog(context, product),
                                ),
                                const SizedBox(width: 6),

                                // 3. Restock Button
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  icon: const Icon(Icons.add_box_outlined, size: 14),
                                  label: const Text('Restock', style: TextStyle(fontSize: 11)),
                                  onPressed: () => _showRestockDialog(
                                    context,
                                    product.id,
                                    product.nameEn,
                                    product.stockQuantity,
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // 4. Delete Button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  tooltip: 'Delete Product',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _showDeleteDialog(context, product),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 0.8),
        ),
      ],
    );
  }
}
