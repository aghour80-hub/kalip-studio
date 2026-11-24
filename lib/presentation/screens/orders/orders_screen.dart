import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/widgets/app_bar_header.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.delivering:
        return AppColors.info;
      case OrderStatus.processing:
      case OrderStatus.confirmed:
        return AppColors.luxuryBeigeDark;
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final currency = ref.watch(currencyProvider);
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBarHeader(
        title: tr.tr('orders_title'),
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                tr.tr('no_orders_yet'),
                style: AppTypography.titleMedium(isKhmer: isKhmer),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = _getStatusColor(order.status);

                return InkWell(
                  onTap: () => context.push('/order-details/${order.orderNumber}'),
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppColors.borderLight, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                order.status.localized(isKhmer),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${tr.tr('order_placed')}: ${DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        ...order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  height: 56,
                                  child: LuxuryImage(
                                    imageUrl: item.product.images.first,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.localizedName(isKhmer),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${item.selectedSize}  •  ${item.selectedColor.localizedName(isKhmer)}  •  x${item.quantity}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(item.totalPriceUsd, currency),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.deliveryAddress,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tracking: ${order.trackingCode}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${tr.tr('estimated_total')}: ',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                Text(
                                  CurrencyFormatter.format(order.totalUsd, currency),
                                  style: AppTypography.priceTag(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
