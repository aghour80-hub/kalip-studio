import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/mock/sample_data.dart';
import 'package:style_house/data/models/category_model.dart';
import 'package:style_house/presentation/providers/products_provider.dart';
import 'package:style_house/presentation/widgets/app_bar_header.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final allCategories = SampleData.categories;

    return Scaffold(
      appBar: AppBarHeader(
        title: tr.tr('explore_categories'),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.pureWhite,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryBlack,
              indicatorWeight: 2,
              labelColor: AppColors.primaryBlack,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: tr.tr('all')),
                Tab(text: tr.tr('women')),
                Tab(text: tr.tr('men')),
                Tab(text: tr.tr('accessories')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(allCategories, isKhmer, tr),
                _buildCategoryList(
                  allCategories.where((c) => c.gender == 'women' || c.gender == 'all').toList(),
                  isKhmer,
                  tr,
                ),
                _buildCategoryList(
                  allCategories.where((c) => c.gender == 'men' || c.gender == 'all').toList(),
                  isKhmer,
                  tr,
                ),
                _buildCategoryList(
                  allCategories.where((c) => c.id == 'accessories' || c.id == 'bags' || c.id == 'footwear').toList(),
                  isKhmer,
                  tr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> categories, bool isKhmer, dynamic tr) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              ref.read(productFilterProvider.notifier).setCategory(category.id);
              context.push('/search');
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                LuxuryImage(imageUrl: category.imageUrl),
                Container(
                  color: Colors.black.withAlpha(100),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category.localizedName(isKhmer),
                            style: AppTypography.displayMedium(
                              isKhmer: isKhmer,
                              color: AppColors.pureWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${category.itemCount} ${tr.tr('items_count')}',
                            style: const TextStyle(
                              color: AppColors.luxuryBeigeLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite.withAlpha(200),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
