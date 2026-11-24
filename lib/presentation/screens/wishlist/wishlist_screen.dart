import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/cart_provider.dart';
import 'package:style_house/presentation/providers/wishlist_provider.dart';
import 'package:style_house/presentation/widgets/app_bar_header.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final currency = ref.watch(currencyProvider);
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBarHeader(
        title: '${tr.tr('wishlist_title')} (${wishlist.length})',
      ),
      body: wishlist.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.favorite_outline, size: 64, color: AppColors.luxuryBeige),
                    const SizedBox(height: 16),
                    Text(
                      tr.tr('wishlist_empty_title'),
                      style: AppTypography.headline(isKhmer: isKhmer),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr.tr('wishlist_empty_desc'),
                      style: AppTypography.bodyMedium(isKhmer: isKhmer, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/'),
                      child: Text(tr.tr('continue_shopping')),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.54,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          InkWell(
                            onTap: () => context.push('/product/${product.id}'),
                            child: LuxuryImage(
                              imageUrl: product.images.first,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: InkWell(
                              onTap: () {
                                ref.read(wishlistProvider.notifier).toggleWishlist(product);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite.withAlpha(220),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: AppColors.primaryBlack),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.localizedName(isKhmer),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall(isKhmer: isKhmer, color: AppColors.textPrimary)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(product.priceUsd, currency),
                      style: AppTypography.priceTag(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        ref.read(cartProvider.notifier).addToCart(
                              product,
                              product.colors.first,
                              product.sizes.first,
                            );
                        ref.read(wishlistProvider.notifier).toggleWishlist(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr.tr('added_to_bag')),
                            backgroundColor: AppColors.primaryBlack,
                            action: SnackBarAction(
                              label: tr.tr('shopping_bag'),
                              textColor: AppColors.luxuryBeige,
                              onPressed: () => context.push('/cart'),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(36),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        tr.tr('move_to_bag'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
