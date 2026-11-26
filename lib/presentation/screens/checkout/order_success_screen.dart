import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';
import 'package:style_house/presentation/widgets/khqr_payment_sheet.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class OrderSuccessScreen extends ConsumerWidget {
  final String orderId;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final settings = ref.watch(storeSettingsProvider);
    OrderModel? order;
    try {
      order = orders.firstWhere((o) => o.orderNumber == orderId || o.id == orderId);
    } catch (_) {}

    final isPendingKhqr = order != null &&
        order.paymentMethod.contains('KHQR') &&
        order.status == OrderStatus.pending;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Celebratory Luxury Badge
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.luxuryBeigeLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isPendingKhqr ? Icons.qr_code_scanner : Icons.check,
                    size: 40,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isPendingKhqr ? 'CHỜ CHUYỂN KHOẢN ABA QR' : 'ORDER CONFIRMED',
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Order #$orderId',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.luxuryBeigeDark,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPendingKhqr
                    ? 'Vui lòng quét mã ABA QR bên dưới để hoàn tất chuyển khoản cho đơn hàng của bạn.'
                    : 'Thank you for shopping at KALIP studio.\nYour order has been received by our Phnom Penh Atelier and is being prepared with our signature packaging.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Embedded Real ABA QR Image Card when pending KHQR transfer
              if (order != null && order.paymentMethod.contains('KHQR')) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPendingKhqr ? const Color(0xFF005B7F) : AppColors.success,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (!isPendingKhqr)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          color: AppColors.success.withValues(alpha: 0.12),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: AppColors.success, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Đã xác nhận thanh toán ABA KHQR',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        'Số tiền thanh toán: ${CurrencyFormatter.formatDual(order.totalUsd)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${settings.bankName} • ${settings.bankAccountName} • USD: ${settings.bankAccountUsd} | KHR: ${settings.bankAccountKhr}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      if (isPendingKhqr) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: LuxuryImage(
                              imageUrl: settings.effectiveQrImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            final target = order!;
                            KhqrPaymentSheet.show(
                              context,
                              order: target,
                              qrImageSource: settings.effectiveQrImage,
                              bankName: settings.bankName,
                              accountName: settings.bankAccountName,
                              accountUsd: settings.bankAccountUsd,
                              accountKhr: settings.bankAccountKhr,
                              onPaymentSuccess: () {
                                ref.read(ordersProvider.notifier).updateOrderStatus(
                                      target.orderNumber,
                                      OrderStatus.confirmed,
                                    );
                              },
                            );
                          },
                          icon: const Icon(Icons.qr_code_2, size: 18),
                          label: const Text('XEM MÃ QR LỚN & XÁC NHẬN CHUYỂN KHOẢN'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Estimated Delivery Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.borderLight, width: 0.8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: AppColors.primaryBlack, size: 24),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 2),
                          Text('Same-day in Phnom Penh • Express 2-4 Hours', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton(
                onPressed: () => context.go('/order-details/$orderId'),
                child: const Text('TRACK ORDER STATUS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/'),
                child: const Text('CONTINUE SHOPPING', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
