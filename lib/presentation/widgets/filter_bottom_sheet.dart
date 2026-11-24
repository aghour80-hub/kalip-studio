import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/products_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  String? _selectedCategory;
  String? _selectedGender;
  ProductSortOption _sortOption = ProductSortOption.featured;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(productFilterProvider);
    _selectedCategory = filter.categoryId;
    _selectedGender = filter.gender;
    _sortOption = filter.sortOption;
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isKhmer ? 'តម្រង & ការតម្រៀប' : 'FILTER & SORT',
                style: AppTypography.headline(isKhmer: isKhmer),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gender section
          Text(
            isKhmer ? 'ការប្រមូលផ្តុំ' : 'GENDER COLLECTION',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.luxuryBeigeDark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChoiceChip(null, isKhmer ? 'ទាំងអស់' : 'All', _selectedGender == null, (sel) {
                setState(() => _selectedGender = null);
              }),
              const SizedBox(width: 8),
              _buildChoiceChip('women', isKhmer ? 'នារី' : 'Women', _selectedGender == 'women', (sel) {
                setState(() => _selectedGender = 'women');
              }),
              const SizedBox(width: 8),
              _buildChoiceChip('men', isKhmer ? 'បុរស' : 'Men', _selectedGender == 'men', (sel) {
                setState(() => _selectedGender = 'men');
              }),
            ],
          ),

          const SizedBox(height: 16),
          // Categories section
          Text(
            isKhmer ? 'ប្រភេទទំនិញ' : 'CATEGORY',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.luxuryBeigeDark),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(null, isKhmer ? 'ទាំងអស់' : 'All Items', _selectedCategory == null, (sel) {
                setState(() => _selectedCategory = null);
              }),
              _buildChoiceChip('tailoring', isKhmer ? 'អាវធំ Tailoring' : 'Tailoring', _selectedCategory == 'tailoring', (sel) {
                setState(() => _selectedCategory = 'tailoring');
              }),
              _buildChoiceChip('bags', isKhmer ? 'កាបូប Bags' : 'Leather Bags', _selectedCategory == 'bags', (sel) {
                setState(() => _selectedCategory = 'bags');
              }),
              _buildChoiceChip('footwear', isKhmer ? 'ស្បែកជើង' : 'Footwear', _selectedCategory == 'footwear', (sel) {
                setState(() => _selectedCategory = 'footwear');
              }),
              _buildChoiceChip('accessories', isKhmer ? 'សូត្រ & គ្រឿងតុបតែង' : 'Silk & Accessories', _selectedCategory == 'accessories', (sel) {
                setState(() => _selectedCategory = 'accessories');
              }),
            ],
          ),

          const SizedBox(height: 16),
          // Sort Options
          Text(
            isKhmer ? 'តម្រៀបតាម' : 'SORT BY',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.luxuryBeigeDark),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip('featured', 'Featured', _sortOption == ProductSortOption.featured, (sel) {
                setState(() => _sortOption = ProductSortOption.featured);
              }),
              _buildChoiceChip('newest', 'Newest', _sortOption == ProductSortOption.newest, (sel) {
                setState(() => _sortOption = ProductSortOption.newest);
              }),
              _buildChoiceChip('lowHigh', 'Price: Low to High', _sortOption == ProductSortOption.priceLowToHigh, (sel) {
                setState(() => _sortOption = ProductSortOption.priceLowToHigh);
              }),
              _buildChoiceChip('highLow', 'Price: High to Low', _sortOption == ProductSortOption.priceHighToLow, (sel) {
                setState(() => _sortOption = ProductSortOption.priceHighToLow);
              }),
            ],
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(productFilterProvider.notifier).resetFilters();
                    Navigator.pop(context);
                  },
                  child: Text(isKhmer ? 'កំណត់ឡើងវិញ' : 'Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final notifier = ref.read(productFilterProvider.notifier);
                    notifier.setCategory(_selectedCategory);
                    notifier.setGender(_selectedGender);
                    notifier.setSortOption(_sortOption);
                    Navigator.pop(context);
                  },
                  child: Text(isKhmer ? 'អនុវត្តតម្រង' : 'Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(dynamic value, String label, bool isSelected, ValueChanged<bool> onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
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
