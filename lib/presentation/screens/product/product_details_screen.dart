import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/cart_provider.dart';
import 'package:style_house/presentation/providers/products_provider.dart';
import 'package:style_house/presentation/providers/wishlist_provider.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';
import 'package:style_house/presentation/widgets/reviews_list_view.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  final PageController _imageController = PageController();
  late ProductColor _selectedColor;
  late String _selectedSize;
  final int _quantity = 1;

  @override
  void initState() {
    super.initState();
    final product = ref.read(productDetailProvider(widget.productId));
    if (product != null) {
      _selectedColor = product.colors.first;
      _selectedSize = product.sizes.first;
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _showSizeGuide(BuildContext context, bool isKhmer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isKhmer ? 'តារាងវាស់ទំហំ' : 'SIZE & FIT GUIDE',
                    style: AppTypography.headline(isKhmer: isKhmer),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                isKhmer
                    ? 'ម៉ូដសម្លៀកបំពាក់ KALIP studio ត្រូវនឹងទំហំស្តង់ដារអន្តរជាតិ (International Fit)។'
                    : 'KALIP studio garments are tailored true to international sizing.',
                style: AppTypography.bodyMedium(isKhmer: isKhmer, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: AppColors.borderLight),
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.luxuryBeigeLight),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Chest (cm)', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Waist (cm)', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Hips (cm)', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('XS')),
                      Padding(padding: EdgeInsets.all(8), child: Text('82 - 86')),
                      Padding(padding: EdgeInsets.all(8), child: Text('64 - 68')),
                      Padding(padding: EdgeInsets.all(8), child: Text('88 - 92')),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('S')),
                      Padding(padding: EdgeInsets.all(8), child: Text('86 - 90')),
                      Padding(padding: EdgeInsets.all(8), child: Text('68 - 72')),
                      Padding(padding: EdgeInsets.all(8), child: Text('92 - 96')),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('M')),
                      Padding(padding: EdgeInsets.all(8), child: Text('90 - 96')),
                      Padding(padding: EdgeInsets.all(8), child: Text('72 - 78')),
                      Padding(padding: EdgeInsets.all(8), child: Text('96 - 102')),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('L')),
                      Padding(padding: EdgeInsets.all(8), child: Text('96 - 104')),
                      Padding(padding: EdgeInsets.all(8), child: Text('78 - 86')),
                      Padding(padding: EdgeInsets.all(8), child: Text('102 - 110')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final currency = ref.watch(currencyProvider);
    final product = ref.watch(productDetailProvider(widget.productId));

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Not Found')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final isWishlisted = ref.watch(wishlistProvider.notifier).isInWishlist(product.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.pureWhite.withAlpha(220),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.primaryBlack),
            onPressed: () => context.pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withAlpha(220),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isWishlisted ? AppColors.error : AppColors.primaryBlack,
              ),
              onPressed: () {
                ref.read(wishlistProvider.notifier).toggleWishlist(product);
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withAlpha(220),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.primaryBlack),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 480,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _imageController,
                    itemCount: product.images.length,
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: index == 0 ? 'product-img-${product.id}' : 'product-img-${product.id}-$index',
                        child: LuxuryImage(
                          imageUrl: product.images[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      child: SmoothPageIndicator(
                        controller: _imageController,
                        count: product.images.length,
                        effect: const ExpandingDotsEffect(
                          dotWidth: 6,
                          dotHeight: 4,
                          activeDotColor: AppColors.primaryBlack,
                          dotColor: Colors.black26,
                          spacing: 4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'KALIP studio • ATELIER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: AppColors.luxuryBeigeDark,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: AppColors.luxuryBeige),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating} (${product.reviewCount})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.localizedName(isKhmer),
                    style: AppTypography.displayMedium(isKhmer: isKhmer),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        CurrencyFormatter.format(product.priceUsd, currency),
                        style: AppTypography.priceTag(fontSize: 22),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(product.originalPriceUsd!, currency),
                          style: const TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: AppColors.primaryBlack,
                          child: Text(
                            '-${product.discountPercentage}%',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatDual(product.priceUsd),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: product.isLowStock
                              ? AppColors.warning
                              : (product.isInStock ? AppColors.success : AppColors.error),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.isLowStock
                            ? '${tr.tr('low_stock')} (${product.stockQuantity} items left)'
                            : (product.isInStock ? tr.tr('in_stock') : tr.tr('out_of_stock')),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: product.isLowStock
                              ? AppColors.warning
                              : (product.isInStock ? AppColors.success : AppColors.error),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Phnom Penh Atelier Stock',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Text(
                    '${tr.tr('select_color')}: ${_selectedColor.localizedName(isKhmer)}',
                    style: AppTypography.titleSmall(isKhmer: isKhmer, color: AppColors.textPrimary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: product.colors.map((colorOption) {
                      final isSelected = _selectedColor.nameEn == colorOption.nameEn;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedColor = colorOption;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBlack : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorOption.color,
                              border: Border.all(color: AppColors.borderMedium, width: 0.5),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${tr.tr('select_size')}: $_selectedSize',
                        style: AppTypography.titleSmall(isKhmer: isKhmer, color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showSizeGuide(context, isKhmer),
                        child: Row(
                          children: [
                            const Icon(Icons.straighten, size: 14, color: AppColors.luxuryBeigeDark),
                            const SizedBox(width: 4),
                            Text(
                              tr.tr('size_guide'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.luxuryBeigeDark,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.sizes.map((size) {
                      final isSelected = _selectedSize == size;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlack : AppColors.pureWhite,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBlack : AppColors.borderMedium,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            size,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.pureWhite : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  ExpansionTile(
                    title: Text(
                      isKhmer ? 'ការពិពណ៌នាអំពីទំនិញ' : 'Description & Fit',
                      style: AppTypography.titleMedium(isKhmer: isKhmer),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    initiallyExpanded: true,
                    children: [
                      Text(
                        product.localizedDesc(isKhmer),
                        style: AppTypography.bodyMedium(isKhmer: isKhmer, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      tr.tr('details_and_care'),
                      style: AppTypography.titleMedium(isKhmer: isKhmer),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    children: [
                      Text(
                        '${isKhmer ? "សម្ភារៈផ្សំ:" : "Material:"} ${product.localizedMaterial(isKhmer)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ...product.localizedDetails(isKhmer).map(
                            (detail) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      detail,
                                      style: AppTypography.bodySmall(isKhmer: isKhmer, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      tr.tr('shipping_and_returns'),
                      style: AppTypography.titleMedium(isKhmer: isKhmer),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    children: [
                      Text(
                        tr.tr('phnom_penh_shipping_info'),
                        style: AppTypography.bodySmall(isKhmer: isKhmer, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      '${tr.tr('reviews')} (${product.reviewCount})',
                      style: AppTypography.titleMedium(isKhmer: isKhmer),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 12),
                    children: [
                      ReviewsListView(
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                        isKhmer: isKhmer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 0.8),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final success = ref.read(cartProvider.notifier).addToCart(
                        product,
                        _selectedColor,
                        _selectedSize,
                        quantity: _quantity,
                      );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.pureWhite, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${tr.tr('added_to_bag')} ($_selectedSize, ${_selectedColor.localizedName(isKhmer)})',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.primaryBlack,
                        action: SnackBarAction(
                          label: tr.tr('shopping_bag'),
                          textColor: AppColors.luxuryBeige,
                          onPressed: () => context.push('/cart'),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    final warning = ref.read(cartProvider).warningMessage ?? 'Stock unavailable';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(warning),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Text(
                  tr.tr('add_to_bag'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final success = ref.read(cartProvider.notifier).addToCart(
                        product,
                        _selectedColor,
                        _selectedSize,
                        quantity: _quantity,
                      );
                  if (success) {
                    context.push('/checkout');
                  } else {
                    final warning = ref.read(cartProvider).warningMessage ?? 'Stock unavailable';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(warning),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Text(
                  tr.tr('buy_now'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
