import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/product_model.dart';
import 'package:style_house/presentation/providers/wishlist_provider.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isKhmer = ref.watch(localizationProvider).isKhmer;
    final currency = ref.watch(currencyProvider);
    final isWishlisted = ref
        .watch(wishlistProvider.notifier)
        .isInWishlist(product.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'product-img-${product.id}',
                  child: LuxuryImage(
                    imageUrl: product.images.first,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.hasDiscount)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          margin: const EdgeInsets.only(bottom: 4),
                          color: AppColors.primaryBlack,
                          child: Text(
                            '-${product.discountPercentage}%',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (product.isNewArrival && !product.hasDiscount)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          color: AppColors.luxuryBeige,
                          child: Text(
                            isKhmer ? 'ថ្មី' : 'NEW',
                            style: const TextStyle(
                              color: AppColors.primaryBlack,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        ref
                            .read(wishlistProvider.notifier)
                            .toggleWishlist(product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite.withAlpha(
                            (0.85 * 255).round(),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isWishlisted
                              ? AppColors.error
                              : AppColors.primaryBlack,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'KALIP studio',
            style:
                AppTypography.bodySmall(
                  isKhmer: isKhmer,
                  color: AppColors.luxuryBeigeDark,
                ).copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            product.localizedName(isKhmer),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleSmall(
              isKhmer: isKhmer,
              color: AppColors.textPrimary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 2,
            children: [
              Text(
                CurrencyFormatter.format(product.priceUsd, currency),
                style: AppTypography.priceTag(fontSize: 13),
              ),
              if (product.hasDiscount)
                Text(
                  CurrencyFormatter.format(product.originalPriceUsd!, currency),
                  style: const TextStyle(
                    fontSize: 11,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
