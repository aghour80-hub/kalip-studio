import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/cart_provider.dart';
import 'package:style_house/presentation/widgets/app_bar_header.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  String? _promoMessage;
  bool _isPromoSuccess = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo(bool isKhmer) {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    final success = ref.read(cartProvider.notifier).applyPromoCode(code);
    final cart = ref.read(cartProvider);
    setState(() {
      _isPromoSuccess = success;
      final pct = (cart.discountPercentage * 100).toInt();
      _promoMessage = success
          ? (isKhmer ? 'ទទួលបានការបញ្ចុះតម្លៃ $pct% ជោគជ័យ' : 'Promo code applied ($pct% OFF)')
          : (cart.warningMessage ?? (isKhmer ? 'កូដបញ្ចុះតម្លៃមិនត្រឹមត្រូវ (សាកល្បង: STYLE10)' : 'Invalid code (Try: STYLE10)'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final currency = ref.watch(currencyProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBarHeader(
        showBackButton: true,
        title: '${tr.tr('shopping_bag')} (${cartState.totalItemCount})',
      ),
      body: cartState.items.isEmpty
          ? _buildEmptyCart(context, tr, isKhmer)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.luxuryBeigeLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_shipping, size: 18, color: AppColors.primaryBlack),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cartState.qualifiesForFreeDelivery
                                    ? tr.tr('free_shipping_unlocked')
                                    : tr.tr('free_shipping_hint', params: {
                                        'amount': CurrencyFormatter.format(
                                          cartState.amountNeededForFreeDelivery,
                                          currency,
                                        ),
                                      }),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (cartState.subtotalUsd / cartState.freeShippingThresholdUsd).clamp(0.0, 1.0),
                            backgroundColor: AppColors.warmSand,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 28),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => context.push('/product/${item.product.id}'),
                            child: SizedBox(
                              width: 84,
                              height: 110,
                              child: LuxuryImage(
                                imageUrl: item.product.images.first,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'KALIP studio',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: AppColors.luxuryBeigeDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.product.localizedName(isKhmer),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.titleSmall(isKhmer: isKhmer, color: AppColors.textPrimary)
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.selectedSize}  •  ${item.selectedColor.localizedName(isKhmer)}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(item.totalPriceUsd, currency),
                                      style: AppTypography.priceTag(fontSize: 15),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.borderMedium, width: 0.8),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              ref.read(cartProvider.notifier).updateQuantity(
                                                    item.id,
                                                    item.quantity - 1,
                                                  );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.remove, size: 14),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              ref.read(cartProvider.notifier).updateQuantity(
                                                    item.id,
                                                    item.quantity + 1,
                                                  );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.add, size: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                            onPressed: () {
                              ref.read(cartProvider.notifier).removeItem(item.id);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: isKhmer ? 'កូដបញ្ចុះតម្លៃ (ឧ. STYLE10)' : 'Promo Code (e.g. STYLE10)',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _applyPromo(isKhmer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlack,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: Text(tr.tr('apply')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final code in ['STYLE10 (-10%)', 'VIP10 (-10%)', 'LUXURY20 (-20%)'])
                        InkWell(
                          onTap: () {
                            _promoController.text = code.split(' ').first;
                            _applyPromo(isKhmer);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.canvasLinen,
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              code,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryBlack),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_promoMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _promoMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isPromoSuccess ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  Text(
                    isKhmer ? 'សេចក្តីសង្ខេបការបញ្ជាទិញ' : 'Order Summary',
                    style: AppTypography.titleMedium(isKhmer: isKhmer),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr.tr('subtotal'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        CurrencyFormatter.format(cartState.subtotalUsd, currency),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr.tr('delivery_fee'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(
                        cartState.qualifiesForFreeDelivery
                            ? tr.tr('free_delivery')
                            : CurrencyFormatter.format(cartState.deliveryFeeUsd, currency),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: cartState.qualifiesForFreeDelivery ? AppColors.success : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (cartState.discountPercentage > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${tr.tr('discount')} (${(cartState.discountPercentage * 100).toInt()}%)',
                          style: const TextStyle(color: AppColors.success, fontSize: 13),
                        ),
                        Text(
                          '-${CurrencyFormatter.format(cartState.discountUsd, currency)}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        tr.tr('estimated_total'),
                        style: AppTypography.titleMedium(isKhmer: isKhmer).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(cartState.totalUsd, currency),
                            style: AppTypography.priceTag(fontSize: 18),
                          ),
                          Text(
                            CurrencyFormatter.formatDual(cartState.totalUsd),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => context.push('/checkout'),
                    child: Text(
                      tr.tr('proceed_to_checkout'),
                      style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.0),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, dynamic tr, bool isKhmer) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.luxuryBeige),
            const SizedBox(height: 16),
            Text(
              tr.tr('bag_empty_title'),
              style: AppTypography.headline(isKhmer: isKhmer),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              tr.tr('bag_empty_desc'),
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
    );
  }
}
