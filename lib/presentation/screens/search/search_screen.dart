import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/products_provider.dart';
import 'package:style_house/presentation/widgets/filter_bottom_sheet.dart';
import 'package:style_house/presentation/widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final filteredProducts = ref.watch(filteredProductsProvider);
    final filterState = ref.watch(productFilterProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            ref.read(productFilterProvider.notifier).setSearchQuery('');
            context.pop();
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (val) {
              ref.read(productFilterProvider.notifier).setSearchQuery(val);
            },
            decoration: InputDecoration(
              hintText: tr.tr('search_hint'),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(productFilterProvider.notifier).setSearchQuery('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            color: AppColors.pureWhite,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildGenderFilterChip('all', tr.tr('all')),
                const SizedBox(width: 8),
                _buildGenderFilterChip('women', tr.tr('women')),
                const SizedBox(width: 8),
                _buildGenderFilterChip('men', tr.tr('men')),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredProducts.length} ${tr.tr('items_count')}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const FilterBottomSheet(),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.tune, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            tr.tr('filter'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    PopupMenuButton<ProductSortOption>(
                      initialValue: filterState.sortOption,
                      onSelected: (option) {
                        ref.read(productFilterProvider.notifier).setSortOption(option);
                      },
                      child: Row(
                        children: [
                          Text(
                            tr.tr('sort_by'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 16),
                        ],
                      ),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: ProductSortOption.featured,
                          child: Text('Featured'),
                        ),
                        PopupMenuItem(
                          value: ProductSortOption.newest,
                          child: Text('Newest'),
                        ),
                        PopupMenuItem(
                          value: ProductSortOption.priceLowToHigh,
                          child: Text('Price: Low to High'),
                        ),
                        PopupMenuItem(
                          value: ProductSortOption.priceHighToLow,
                          child: Text('Price: High to Low'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          isKhmer ? 'រកមិនឃើញទំនិញដែលអ្នកស្វែងរកទេ' : 'No products found',
                          style: AppTypography.titleMedium(isKhmer: isKhmer),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isKhmer ? 'សូមសាកល្បងពាក្យគន្លឹះផ្សេងទៀត' : 'Try searching for linen, silk, bag, or dress',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderFilterChip(String value, String label) {
    final current = ref.watch(productFilterProvider).gender ?? 'all';
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(productFilterProvider.notifier).setGender(value == 'all' ? null : value);
      },
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.pureWhite : AppColors.textPrimary,
      ),
      selectedColor: AppColors.primaryBlack,
      backgroundColor: AppColors.canvasLinen,
      side: BorderSide(
        color: isSelected ? AppColors.primaryBlack : AppColors.borderLight,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      showCheckmark: false,
    );
  }
}
