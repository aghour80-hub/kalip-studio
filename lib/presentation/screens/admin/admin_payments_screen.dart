import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/services/payment_service.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';

class AdminPaymentsScreen extends ConsumerStatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  ConsumerState<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
  final PaymentService _paymentService = PaymentService();
  final Set<String> _verifyingOrderIds = {};

  Future<void> _verifyPayment(OrderModel order) async {
    setState(() => _verifyingOrderIds.add(order.id));

    final result = await _paymentService.verifyKhqrPaymentServerSide(
      orderId: order.id,
      orderNumber: order.orderNumber,
      amountUsd: order.totalUsd,
    );

    if (result.isSuccessful) {
      ref.read(ordersProvider.notifier).updateOrderStatus(order.orderNumber, OrderStatus.confirmed);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verified for ${order.orderNumber}. Ref: ${result.transactionRef}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _verifyingOrderIds.remove(order.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PAYMENT AUDITS & SLIPS',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          final isKhqr = order.paymentMethod.contains('KHQR');
          final isCod = order.paymentMethod.contains('COD') || order.paymentMethod.contains('Delivery');
          final isVerifying = _verifyingOrderIds.contains(order.id);
          final khrAmount = (order.totalUsd * AppConstants.usdToKhrRate / 100).round() * 100;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isKhqr ? Icons.qr_code_scanner : (isCod ? Icons.payments_outlined : Icons.credit_card),
                          size: 18,
                          color: AppColors.primaryBlack,
                        ),
                        const SizedBox(width: 8),
                        Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(order.totalUsd, currency),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Method: ${order.paymentMethod}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Dual Total: \$${order.totalUsd.toStringAsFixed(2)} ≈ ${khrAmount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} ៛',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  'Customer: ${order.customerName ?? "VIP Guest"} • Phone: ${order.phoneNumber ?? "No phone"}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ${order.status.code.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: order.status == OrderStatus.pending ? AppColors.warning : AppColors.success,
                      ),
                    ),
                    if (isKhqr && order.status == OrderStatus.pending)
                      ElevatedButton(
                        onPressed: isVerifying ? null : () => _verifyPayment(order),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: isVerifying
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pureWhite),
                              )
                            : const Text('Verify Slip', style: TextStyle(fontSize: 11)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'CLEARED',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
