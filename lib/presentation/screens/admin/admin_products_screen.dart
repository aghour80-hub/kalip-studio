import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
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

  void _showRestockDialog(BuildContext context, String productId, String productName, int currentStock) {
    int restockQty = 10;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            title: Text(
              'Restock Inventory',
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
        return p.nameEn.toLowerCase().contains(q) || p.nameKm.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CATALOG & INVENTORY',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.canvasLinen,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search product by name or SKU...',
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
                Row(
                  children: ['all', 'women', 'men'].map((gender) {
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
              ],
            ),
          ),

          // Products List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = filtered[index];
                final isLow = product.isLowStock || product.stockQuantity <= 5;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 54,
                        height: 70,
                        child: LuxuryImage(
                          imageUrl: product.images.first,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 14),
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
                              '\$${product.priceUsd.toStringAsFixed(2)} • ${product.gender.toUpperCase()} • ${product.categoryId}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  color: isLow
                                      ? AppColors.warning.withValues(alpha: 0.15)
                                      : AppColors.success.withValues(alpha: 0.15),
                                  child: Text(
                                    '${product.stockQuantity} IN STOCK',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isLow ? AppColors.warning : AppColors.success,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${product.sizes.length} Sizes • ${product.colors.length} Colors',
                                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_box_outlined, color: AppColors.primaryBlack),
                        tooltip: 'Restock Product',
                        onPressed: () => _showRestockDialog(
                          context,
                          product.id,
                          product.nameEn,
                          product.stockQuantity,
                        ),
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
}
