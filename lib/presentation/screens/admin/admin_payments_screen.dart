import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/data/services/payment_service.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';

class AdminPaymentsScreen extends ConsumerStatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  ConsumerState<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
  final PaymentService _paymentService = PaymentService();
  final Set<String> _verifyingOrderIds = {};
  String _filter = 'all'; // 'all', 'pending', 'cleared'

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
    final rate = ref.watch(storeSettingsProvider).usdToKhrRate;

    final filtered = orders.where((o) {
      if (_filter == 'pending') return o.status == OrderStatus.pending;
      if (_filter == 'cleared') return o.status != OrderStatus.pending && o.status != OrderStatus.cancelled;
      return true;
    }).toList();

    final clearedTotal = orders
        .where((o) => o.status != OrderStatus.pending && o.status != OrderStatus.cancelled)
        .fold<double>(0.0, (sum, o) => sum + o.totalUsd);
    final pendingTotal = orders
        .where((o) => o.status == OrderStatus.pending)
        .fold<double>(0.0, (sum, o) => sum + o.totalUsd);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        title: const Text(
          'PAYMENT AUDITS & SLIPS',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined, size: 20),
            tooltip: 'Admin Dashboard',
            onPressed: () => context.push('/admin'),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline, size: 20, color: AppColors.error),
            tooltip: 'Lock Owner Mode',
            onPressed: () {
              ref.read(adminAuthProvider.notifier).lockPortal();
              context.go('/');
            },
          ),
          IconButton(
            icon: const Icon(Icons.storefront_outlined, size: 20),
            tooltip: 'Boutique Storefront',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('\$${clearedTotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15)),
                    const Text('CLEARED', style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1.0)),
                  ],
                ),
                Container(width: 1, height: 24, color: Colors.white24),
                Column(
                  children: [
                    Text('\$${pendingTotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 15)),
                    const Text('PENDING AUDIT', style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1.0)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.canvasLinen,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                for (final f in [
                  {'id': 'all', 'label': 'ALL'},
                  {'id': 'pending', 'label': 'PENDING'},
                  {'id': 'cleared', 'label': 'CLEARED'},
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f['label']!),
                      selected: _filter == f['id'],
                      selectedColor: AppColors.primaryBlack,
                      labelStyle: TextStyle(
                        color: _filter == f['id'] ? AppColors.pureWhite : AppColors.primaryBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      onSelected: (_) => setState(() => _filter = f['id']!),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = filtered[index];
                final isKhqr = order.paymentMethod.contains('KHQR');
                final isCod = order.paymentMethod.contains('COD') || order.paymentMethod.contains('Delivery');
                final isVerifying = _verifyingOrderIds.contains(order.id);
                final khrAmount = (order.totalUsd * rate / 100).round() * 100;

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
                              color: order.status == OrderStatus.pending
                                  ? AppColors.warning
                                  : (order.status == OrderStatus.cancelled ? AppColors.error : AppColors.success),
                            ),
                          ),
                          if (order.status == OrderStatus.pending)
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
                                  : Text(isCod ? 'Mark Paid' : 'Verify Slip', style: const TextStyle(fontSize: 11)),
                            )
                          else if (order.status == OrderStatus.cancelled)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Text(
                                'CANCELLED',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.error),
                              ),
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
          ),
        ],
      ),
    );
  }
}
