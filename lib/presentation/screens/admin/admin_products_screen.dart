import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';
import 'package:style_house/presentation/widgets/admin_bottom_nav.dart';
import 'package:style_house/presentation/widgets/admin_product_editor_sheet.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

enum _AdminSortMode { newest, priceLow, priceHigh, lowestStock }

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isGridView = false;
  _AdminSortMode _sortMode = _AdminSortMode.newest;

  // QUICK PRICE & DISCOUNT DIALOG
  void _showQuickPriceDialog(BuildContext context, ProductModel product, double khrRate) {
    final priceController = TextEditingController(text: product.priceUsd.toStringAsFixed(2));
    final originalPriceController = TextEditingController(
      text: product.originalPriceUsd != null ? product.originalPriceUsd!.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currentInputPrice = double.tryParse(priceController.text) ?? product.priceUsd;
          final khrEquivalent = ((currentInputPrice * khrRate) / 100).round() * 100;

          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            title: Row(
              children: [
                const Icon(Icons.price_change_outlined, color: AppColors.luxuryBeigeDark),
                const SizedBox(width: 8),
                Expanded(child: Text('Quick Price & Sale', style: AppTypography.titleMedium())),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.nameEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 14),
                  const Text('Selling Price (USD):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                    '≈ ${khrEquivalent.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} ៛ KHR (Rate: ${khrRate.toInt()})',
                    style: const TextStyle(fontSize: 11, color: AppColors.luxuryBeigeDark, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Original Price / MSRP (USD) — Leave blank for regular price:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: originalPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      hintText: 'Empty = no discount',
                      filled: true,
                      fillColor: AppColors.canvasLinen,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                      suffixIcon: originalPriceController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () => setDialogState(() => originalPriceController.clear()),
                            )
                          : null,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [
                      ActionChip(
                        label: const Text('Clear Sale', style: TextStyle(fontSize: 10)),
                        onPressed: () {
                          final base = double.tryParse(originalPriceController.text) ?? currentInputPrice;
                          setDialogState(() {
                            priceController.text = base.toStringAsFixed(2);
                            originalPriceController.clear();
                          });
                        },
                      ),
                      for (final pct in [10, 20, 30, 50])
                        ActionChip(
                          label: Text('-$pct%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            final base = double.tryParse(originalPriceController.text) ?? currentInputPrice;
                            setDialogState(() {
                              originalPriceController.text = base.toStringAsFixed(2);
                              priceController.text = (base * (1 - pct / 100)).toStringAsFixed(2);
                            });
                          },
                        ),
                    ],
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
                  if (newPrice == null || newPrice <= 0) return;
                  final rawOrig = originalPriceController.text.trim();
                  final newOrigPrice = rawOrig.isEmpty ? null : double.tryParse(rawOrig);

                  ref.read(adminProductsProvider.notifier).updatePrice(
                        product.id,
                        newPrice,
                        newOriginalPriceUsd: newOrigPrice,
                        clearOriginalPrice: rawOrig.isEmpty || newOrigPrice == null || newOrigPrice <= newPrice,
                      );

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã cập nhật giá "${product.nameEn}" -> \$${newPrice.toStringAsFixed(2)} USD'),
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

  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: Text(
          'Xóa vĩnh viễn "${product.nameEn}" khỏi cửa hàng và danh mục quản lý?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.pureWhite),
            onPressed: () {
              ref.read(adminProductsProvider.notifier).deleteProduct(product.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa "${product.nameEn}".'), backgroundColor: AppColors.error),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(adminProductsProvider).products;
    final khrRate = ref.watch(storeSettingsProvider).usdToKhrRate;

    final filtered = products.where((p) {
      if (_selectedFilter == 'women' || _selectedFilter == 'men' || _selectedFilter == 'unisex') {
        if (p.gender != _selectedFilter && p.gender != 'unisex') return false;
      } else if (_selectedFilter == 'low_stock') {
        if (p.stockQuantity > 5) return false;
      } else if (_selectedFilter == 'on_sale') {
        if (!p.hasDiscount) return false;
      } else if (_selectedFilter == 'hidden') {
        if (p.isActive) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.nameEn.toLowerCase().contains(q) ||
            p.nameKm.toLowerCase().contains(q) ||
            p.categoryId.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    switch (_sortMode) {
      case _AdminSortMode.priceLow:
        filtered.sort((a, b) => a.priceUsd.compareTo(b.priceUsd));
        break;
      case _AdminSortMode.priceHigh:
        filtered.sort((a, b) => b.priceUsd.compareTo(a.priceUsd));
        break;
      case _AdminSortMode.lowestStock:
        filtered.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case _AdminSortMode.newest:
        break;
    }

    final totalStockUnits = products.fold<int>(0, (sum, p) => sum + p.stockQuantity);
    final lowStockCount = products.where((p) => p.isLowStock || p.stockQuantity <= 5).length;
    final hiddenCount = products.where((p) => !p.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.canvasLinen,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.storefront_outlined, size: 21),
          tooltip: 'Về Cửa hàng (Storefront)',
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'CATALOG & PHOTOS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.4),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined, size: 20),
            tooltip: _isGridView ? 'List View' : 'Grid Gallery View',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          PopupMenuButton<_AdminSortMode>(
            icon: const Icon(Icons.sort, size: 20),
            tooltip: 'Sort Catalog',
            onSelected: (mode) => setState(() => _sortMode = mode),
            itemBuilder: (_) => const [
              PopupMenuItem(value: _AdminSortMode.newest, child: Text('Newest First')),
              PopupMenuItem(value: _AdminSortMode.priceLow, child: Text('Price: Low to High')),
              PopupMenuItem(value: _AdminSortMode.priceHigh, child: Text('Price: High to Low')),
              PopupMenuItem(value: _AdminSortMode.lowestStock, child: Text('Lowest Stock First')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline, size: 20, color: AppColors.error),
            tooltip: 'Lock Owner Mode',
            onPressed: () {
              ref.read(adminAuthProvider.notifier).lockPortal();
              context.go('/');
            },
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.luxuryBeige,
        onPressed: () => AdminProductEditorSheet.show(context),
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 19),
        label: const Text(
          'ADD + UPLOAD PHOTO',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
      ),
      body: Column(
        children: [
          // 1. TOP METRICS STRIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.primaryBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('PRODUCTS', '${products.length} ($hiddenCount Hidden)', AppColors.pureWhite),
                Container(width: 1, height: 22, color: Colors.white24),
                _buildSummaryItem('TOTAL STOCK', '$totalStockUnits Units', AppColors.luxuryBeige),
                Container(width: 1, height: 22, color: Colors.white24),
                _buildSummaryItem(
                  'LOW STOCK',
                  '$lowStockCount Alert',
                  lowStockCount > 0 ? AppColors.warning : AppColors.success,
                ),
              ],
            ),
          ),

          // 2. SEARCH & FILTER TOOLBAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.pureWhite,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm tên sản phẩm, danh mục...',
                    prefixIcon: const Icon(Icons.search, size: 19),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.canvasLinen,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final chip in [
                        {'id': 'all', 'label': 'ALL (${products.length})'},
                        {'id': 'women', 'label': 'WOMEN'},
                        {'id': 'men', 'label': 'MEN'},
                        {'id': 'low_stock', 'label': 'LOW STOCK'},
                        {'id': 'on_sale', 'label': 'ON SALE'},
                        {'id': 'hidden', 'label': 'HIDDEN ($hiddenCount)'},
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(chip['label']!),
                            selected: _selectedFilter == chip['id'],
                            selectedColor: AppColors.primaryBlack,
                            labelStyle: TextStyle(
                              color: _selectedFilter == chip['id'] ? AppColors.pureWhite : AppColors.primaryBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            onSelected: (_) => setState(() => _selectedFilter = chip['id']!),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. PRODUCTS VIEW (LIST OR VISUAL GRID)
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 10),
                        const Text('Không tìm thấy sản phẩm nào', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => AdminProductEditorSheet.show(context),
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                          label: const Text('Đăng sản phẩm mới + Upload ảnh'),
                        ),
                      ],
                    ),
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, idx) => _buildGridCard(filtered[idx], khrRate),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, idx) => _buildListCard(filtered[idx], khrRate),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(ProductModel product, double khrRate) {
    final isLow = product.stockQuantity <= 5;
    final hasFreeUpload = product.images.any(LuxuryImage.isDataUri);

    return Opacity(
      opacity: product.isActive ? 1.0 : 0.65,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => AdminProductEditorSheet.show(context, product: product),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LuxuryImage(imageUrl: product.images.first, fit: BoxFit.cover),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Wrap(
                        spacing: 4,
                        children: [
                          if (!product.isActive)
                            _badge('HIDDEN', AppColors.error)
                          else if (product.hasDiscount)
                            _badge('-${product.discountPercentage}%', AppColors.primaryBlack),
                          if (hasFreeUpload) _badge('UPLOADED', AppColors.success),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${product.images.length} photos',
                          style: const TextStyle(color: AppColors.pureWhite, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameEn,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.priceUsd.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isLow ? AppColors.warning : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => _showQuickPriceDialog(context, product, khrRate),
                        child: const Icon(Icons.price_change_outlined, size: 18),
                      ),
                      InkWell(
                        onTap: () => AdminProductEditorSheet.show(context, product: product),
                        child: const Icon(Icons.edit_outlined, size: 18),
                      ),
                      InkWell(
                        onTap: () => ref.read(adminProductsProvider.notifier).toggleProductStatus(product.id),
                        child: Icon(
                          product.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                          color: product.isActive ? AppColors.primaryBlack : AppColors.textMuted,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showDeleteDialog(context, product),
                        child: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(ProductModel product, double khrRate) {
    final isLow = product.isLowStock || product.stockQuantity <= 5;
    final hasFreeUpload = product.images.any(LuxuryImage.isDataUri);
    final khrPrice = ((product.priceUsd * khrRate) / 100).round() * 100;
    final khrFormatted = khrPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    return Opacity(
      opacity: product.isActive ? 1.0 : 0.65,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: product.isActive ? AppColors.borderLight : AppColors.error.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail (Tap to edit product & upload photos)
                InkWell(
                  onTap: () => AdminProductEditorSheet.show(context, product: product),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 68,
                        height: 86,
                        child: LuxuryImage(
                          imageUrl: product.images.first,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '${product.images.length} 📷',
                            style: const TextStyle(color: AppColors.pureWhite, fontSize: 8.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.nameEn,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!product.isActive) _badge('HIDDEN', AppColors.error),
                          if (hasFreeUpload) ...[
                            const SizedBox(width: 4),
                            _badge('FREE IMG', AppColors.success),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '\$${product.priceUsd.toStringAsFixed(2)} USD',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primaryBlack),
                          ),
                          if (product.hasDiscount)
                            Text(
                              '\$${product.originalPriceUsd!.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 10.5, decoration: TextDecoration.lineThrough, color: AppColors.textMuted),
                            ),
                          Text(
                            '≈ $khrFormatted ៛',
                            style: const TextStyle(fontSize: 11, color: AppColors.luxuryBeigeDark, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Quick Inline Stock Stepper (-1 / +1) & Category Badge
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isLow
                                  ? AppColors.warning.withValues(alpha: 0.14)
                                  : AppColors.success.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => ref.read(adminProductsProvider.notifier).restockProduct(product.id, -1),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    child: Icon(Icons.remove, size: 13),
                                  ),
                                ),
                                Text(
                                  '${product.stockQuantity} in stock',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isLow ? AppColors.warning : AppColors.success,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => ref.read(adminProductsProvider.notifier).restockProduct(product.id, 1),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    child: Icon(Icons.add, size: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${product.gender.toUpperCase()} • ${product.categoryId.toUpperCase()}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 18, thickness: 0.7, color: AppColors.borderLight),

            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                    icon: const Icon(Icons.price_change_outlined, size: 14),
                    label: const Text('Price', style: TextStyle(fontSize: 11)),
                    onPressed: () => _showQuickPriceDialog(context, product, khrRate),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: const Size(0, 32),
                    ),
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 14),
                    label: const Text('Edit / Photo', style: TextStyle(fontSize: 11)),
                    onPressed: () => AdminProductEditorSheet.show(context, product: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_all_outlined, size: 18),
                    tooltip: 'Duplicate Product',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      ref.read(adminProductsProvider.notifier).duplicateProduct(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã nhân bản "${product.nameEn}"!'), backgroundColor: AppColors.success),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      product.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                      color: product.isActive ? AppColors.primaryBlack : AppColors.textMuted,
                    ),
                    tooltip: product.isActive ? 'Hide from Storefront' : 'Show on Storefront',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => ref.read(adminProductsProvider.notifier).toggleProductStatus(product.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    tooltip: 'Delete Product',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _showDeleteDialog(context, product),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.pureWhite, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 0.8)),
      ],
    );
  }
}
