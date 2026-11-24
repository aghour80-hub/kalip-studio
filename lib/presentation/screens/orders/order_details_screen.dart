import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/delivery/delivery_service.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/widgets/khqr_payment_sheet.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final currency = ref.watch(currencyProvider);
    final orders = ref.watch(ordersProvider);

    final order = orders.firstWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
      orElse: () => orders.first,
    );

    final isCancelled = order.status == OrderStatus.cancelled;
    final steps = [
      {'title': 'Order Placed', 'desc': 'Order received by KALIP studio', 'done': !isCancelled},
      {'title': 'Confirmed at Atelier', 'desc': 'Verified by boutique team', 'done': !isCancelled && order.status != OrderStatus.pending},
      {'title': 'Preparing & Silk Wrapping', 'desc': 'Packed in luxury gift box', 'done': !isCancelled && (order.status == OrderStatus.processing || order.status == OrderStatus.delivering || order.status == OrderStatus.delivered)},
      {'title': 'Out for Delivery (Phnom Penh)', 'desc': 'Courier on route (${order.trackingCode})', 'done': !isCancelled && (order.status == OrderStatus.delivering || order.status == OrderStatus.delivered)},
      {'title': 'Delivered', 'desc': 'Delivered to recipient', 'done': !isCancelled && order.status == OrderStatus.delivered},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          order.orderNumber,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tracking Progress Timeline Card
            Container(
              padding: const EdgeInsets.all(20),
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
                      const Text(
                        'DELIVERY TRACKING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.luxuryBeigeDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        color: AppColors.luxuryBeigeLight,
                        child: Text(
                          order.status.localized(isKhmer),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Vertical Timeline Steps
                  ...List.generate(steps.length, (index) {
                    final step = steps[index];
                    final isDone = step['done'] as bool;
                    final isLast = index == steps.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? AppColors.primaryBlack : AppColors.pureWhite,
                                border: Border.all(
                                  color: isDone ? AppColors.primaryBlack : AppColors.borderMedium,
                                  width: 1.5,
                                ),
                              ),
                              child: isDone
                                  ? const Icon(Icons.check, size: 12, color: AppColors.pureWhite)
                                  : null,
                            ),
                            if (!isLast)
                              Container(
                                width: 1.5,
                                height: 36,
                                color: isDone ? AppColors.primaryBlack : AppColors.borderLight,
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                    color: isDone ? AppColors.primaryBlack : AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  step['desc'] as String,
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Delivery Logistics & Courier Card
            Builder(builder: (context) {
              final deliveryInfo = DeliveryService.getDeliveryDetails(order.province ?? 'Phnom Penh');
              return Container(
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
                        const Text(
                          'COURIER & LOGISTICS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
                        ),
                        Text(
                          deliveryInfo.estimatedDuration,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(deliveryInfo.providerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Tracking: ${order.trackingCode}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('Hub: ${deliveryInfo.dispatchHub}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 12),
                    const Divider(),
                    const Text(
                      'SHIPPING ADDRESS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
                    ),
                    const SizedBox(height: 6),
                    Text(order.deliveryAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    if (order.phoneNumber != null) ...[
                      const SizedBox(height: 4),
                      Text('Recipient: ${order.customerName ?? "Customer"} • ${order.phoneNumber}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PAYMENT METHOD',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
                            ),
                            const SizedBox(height: 4),
                            Text(order.paymentMethod, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (order.paymentMethod.contains('KHQR') && order.status == OrderStatus.pending)
                          OutlinedButton(
                            onPressed: () {
                              KhqrPaymentSheet.show(
                                context,
                                order: order,
                                onPaymentSuccess: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('KHQR Payment Verified!'), backgroundColor: AppColors.success),
                                  );
                                },
                              );
                            },
                            child: const Text('PAY KHQR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Items in this order
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: AppColors.borderLight, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ORDER ITEMS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 64,
                            child: LuxuryImage(
                              imageUrl: item.product.images.first,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.localizedName(isKhmer),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${item.selectedSize} • ${item.selectedColor.localizedName(isKhmer)} • x${item.quantity}',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.totalPriceUsd, currency),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(CurrencyFormatter.format(order.totalUsd, currency), style: AppTypography.priceTag(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            if (order.status == OrderStatus.pending) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    foregroundColor: AppColors.error,
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(isKhmer ? 'បោះបង់ការបញ្ជាទិញនេះ' : 'Cancel Pending Order'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.pureWhite,
                        title: Text(isKhmer ? 'បោះបង់ការបញ្ជាទិញ?' : 'Cancel Order?'),
                        content: Text('Cancel ${order.orderNumber} and restore items to stock?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Keep Order'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.pureWhite),
                            onPressed: () {
                              ref.read(ordersProvider.notifier).cancelOrder(order.orderNumber);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Confirm Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
