import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/products_provider.dart';
import 'package:style_house/presentation/widgets/app_bar_header.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';
import 'package:style_house/presentation/widgets/product_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerController = PageController();
  int _activeCategoryIndex = 0;

  final List<Map<String, String>> _heroBanners = [
    {
      'titleEn': 'SPRING / SUMMER 2026',
      'titleKm': 'រដូវផ្ការីក / រដូវក្តៅ ២០២៦',
      'subtitleEn': 'THE ATELIER SILHOUETTE',
      'subtitleKm': 'ភាពប្រណីតនៃសិល្បៈកាត់ដេរ',
      'tagEn': 'NEW COLLECTION',
      'tagKm': 'បណ្តុំម៉ូដថ្មី',
      'image': 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=1200&auto=format&fit=crop',
    },
    {
      'titleEn': 'CAMBODIAN SILK HERITAGE',
      'titleKm': 'មរតកសូត្រខ្មែរប្រណីត',
      'subtitleEn': 'HANDWOVEN IN TAKEO',
      'subtitleKm': 'ត្បាញដោយដៃនៅខេត្តតាកែវ',
      'tagEn': 'EXCLUSIVE ATELIER',
      'tagKm': 'ស្នាដៃពិសេសផ្តាច់មុខ',
      'image': 'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?q=80&w=1200&auto=format&fit=crop',
    },
    {
      'titleEn': 'MODERN TAILORING',
      'titleKm': 'ម៉ូដកាត់ដេរសម័យទំនើប',
      'subtitleEn': 'SHARP LINES • NOBLE FABRICS',
      'subtitleKm': 'បន្ទាត់កាត់ដេរច្បាស់ • ក្រណាត់ថ្លៃថ្នូរ',
      'tagEn': 'TIMELESS ESSENTIALS',
      'tagKm': 'ភាពស្រស់ស្អាតមិនចេះរីងស្ងួត',
      'image': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?q=80&w=1200&auto=format&fit=crop',
    },
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final newArrivals = ref.watch(newArrivalsProvider);
    final bestSellers = ref.watch(bestSellersProvider);

    final categoryTabs = [
      {'id': 'all', 'nameEn': 'All', 'nameKm': 'ទាំងអស់'},
      {'id': 'women', 'nameEn': 'Women', 'nameKm': 'នារី'},
      {'id': 'men', 'nameEn': 'Men', 'nameKm': 'បុរស'},
      {'id': 'tailoring', 'nameEn': 'Tailoring', 'nameKm': 'អាវធំ'},
      {'id': 'bags', 'nameEn': 'Bags', 'nameKm': 'កាបូប'},
      {'id': 'accessories', 'nameEn': 'Silk & Gifts', 'nameKm': 'សូត្រ & កាដូ'},
    ];

    return Scaffold(
      appBar: const AppBarHeader(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ai-concierge'),
        backgroundColor: AppColors.primaryBlack,
        icon: const Icon(Icons.auto_awesome, color: AppColors.luxuryBeige, size: 18),
        label: Text(
          isKhmer ? 'ជំនួយការ AI' : 'AI Concierge',
          style: const TextStyle(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontSize: 12,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Delivery Notice Strip
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primaryBlack,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, color: AppColors.luxuryBeige, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tr.tr('express_delivery_banner'),
                      style: TextStyle(
                        color: AppColors.luxuryBeigeLight,
                        fontSize: isKhmer ? 11 : 10.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: isKhmer ? 0 : 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Hero Editorial Banner Carousel
          SliverToBoxAdapter(
            child: SizedBox(
              height: 380,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _bannerController,
                    itemCount: _heroBanners.length,
                    itemBuilder: (context, index) {
                      final banner = _heroBanners[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          LuxuryImage(imageUrl: banner['image']!),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withAlpha(20),
                                  Colors.black.withAlpha(160),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 40,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  color: AppColors.luxuryBeige,
                                  child: Text(
                                    isKhmer ? banner['tagKm']! : banner['tagEn']!,
                                    style: const TextStyle(
                                      color: AppColors.primaryBlack,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isKhmer ? banner['titleKm']! : banner['titleEn']!,
                                  style: AppTypography.displayMedium(
                                    isKhmer: isKhmer,
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isKhmer ? banner['subtitleKm']! : banner['subtitleEn']!,
                                  style: const TextStyle(
                                    color: AppColors.warmSand,
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                OutlinedButton(
                                  onPressed: () => context.go('/categories'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.pureWhite, width: 1.2),
                                    foregroundColor: AppColors.pureWhite,
                                    minimumSize: const Size(130, 38),
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  child: Text(
                                    tr.tr('discover'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                    bottom: 14,
                    child: SmoothPageIndicator(
                      controller: _bannerController,
                      count: _heroBanners.length,
                      effect: const ExpandingDotsEffect(
                        dotWidth: 6,
                        dotHeight: 4,
                        activeDotColor: AppColors.luxuryBeige,
                        dotColor: Colors.white54,
                        spacing: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Quick Category Horizontal Chips
          SliverToBoxAdapter(
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(top: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categoryTabs.length,
                itemBuilder: (context, index) {
                  final cat = categoryTabs[index];
                  final isSelected = _activeCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(isKhmer ? cat['nameKm']! : cat['nameEn']!),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _activeCategoryIndex = index;
                        });
                        ref.read(productFilterProvider.notifier).setCategory(
                              cat['id'] == 'all' ? null : cat['id'],
                            );
                      },
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.pureWhite : AppColors.textPrimary,
                      ),
                      selectedColor: AppColors.primaryBlack,
                      backgroundColor: AppColors.pureWhite,
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryBlack : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Section: New Arrivals
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COLLECTION 2026',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppColors.luxuryBeigeDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.tr('new_arrivals'),
                        style: AppTypography.headline(isKhmer: isKhmer),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.go('/categories'),
                    child: Row(
                      children: [
                        Text(
                          tr.tr('see_all'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal New Arrivals Carousel
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: newArrivals.length,
                itemBuilder: (context, index) {
                  final product = newArrivals[index];
                  return Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 12),
                    child: ProductCard(
                      product: product,
                      onTap: () => context.push('/product/${product.id}'),
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. Editorial Split Banners: Men's vs Women's Collections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        ref.read(productFilterProvider.notifier).setGender('women');
                        context.go('/categories');
                      },
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const LuxuryImage(
                              imageUrl:
                                  'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?q=80&w=800&auto=format&fit=crop',
                            ),
                            Container(
                              color: Colors.black.withAlpha(90),
                            ),
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tr.tr('women_collection'),
                                    style: AppTypography.titleMedium(
                                      isKhmer: isKhmer,
                                      color: AppColors.pureWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tr.tr('shop_women'),
                                    style: const TextStyle(
                                      color: AppColors.luxuryBeigeLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        ref.read(productFilterProvider.notifier).setGender('men');
                        context.go('/categories');
                      },
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const LuxuryImage(
                              imageUrl:
                                  'https://images.unsplash.com/photo-1617137984095-74e4e5e3613f?q=80&w=800&auto=format&fit=crop',
                            ),
                            Container(
                              color: Colors.black.withAlpha(90),
                            ),
                            Positioned(
                              left: 12,
                              right: 12,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tr.tr('men_collection'),
                                    style: AppTypography.titleMedium(
                                      isKhmer: isKhmer,
                                      color: AppColors.pureWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tr.tr('shop_men'),
                                    style: const TextStyle(
                                      color: AppColors.luxuryBeigeLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Section: Curated Highlights & Best Sellers
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURATED SELECTION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.luxuryBeigeDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr.tr('best_sellers'),
                    style: AppTypography.headline(isKhmer: isKhmer),
                  ),
                ],
              ),
            ),
          ),

          // 2-Column Staggered Grid for Best Sellers
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = bestSellers[index];
                  return ProductCard(
                    product: product,
                    onTap: () => context.push('/product/${product.id}'),
                  );
                },
                childCount: bestSellers.length,
              ),
            ),
          ),

          // 7. Brand Atelier Statement Footer
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 36, bottom: 24),
              padding: const EdgeInsets.all(28),
              color: AppColors.pureWhite,
              child: Column(
                children: [
                  Text(
                    'KALIP studio',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4.0,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isKhmer ? 'ភាពប្រណីតទាន់សម័យ • គុណភាពលំដាប់ខ្ពស់' : 'TIMELESS ELEGANCE • MODERN LUXURY',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.luxuryBeigeDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr.tr('atelier_statement'),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(isKhmer: isKhmer, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.luxuryBeigeDark),
                      SizedBox(width: 4),
                      Text(
                        'BKK1 Flagship • Phnom Penh, Cambodia',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
