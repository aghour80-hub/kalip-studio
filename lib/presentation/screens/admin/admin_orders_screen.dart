import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _selectedStatusFilter = 'all';

  void _transitionOrder(OrderModel order) {
    OrderStatus nextStatus;
    String actionLabel;

    switch (order.status) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.confirmed;
        actionLabel = 'Confirm Order';
        break;
      case OrderStatus.confirmed:
        nextStatus = OrderStatus.processing;
        actionLabel = 'Send to Atelier (Wrapping)';
        break;
      case OrderStatus.processing:
        nextStatus = OrderStatus.delivering;
        actionLabel = 'Handover to Courier Rider';
        break;
      case OrderStatus.delivering:
        nextStatus = OrderStatus.delivered;
        actionLabel = 'Mark as Delivered';
        break;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: const Text('Update Order Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Text('Transition order "${order.orderNumber}" from ${order.status.code} to ${nextStatus.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(ordersProvider.notifier).updateOrderStatus(order.orderNumber, nextStatus);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order ${order.orderNumber} updated to ${nextStatus.titleEn}'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final orders = ref.watch(ordersProvider);

    final filtered = orders.where((o) {
      if (_selectedStatusFilter != 'all' && o.status.code != _selectedStatusFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ORDER FULFILLMENT',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['all', 'pending', 'confirmed', 'processing', 'delivering', 'delivered'].map((status) {
                final isSel = _selectedStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status.toUpperCase()),
                    selected: isSel,
                    selectedColor: AppColors.primaryBlack,
                    labelStyle: TextStyle(
                      color: isSel ? AppColors.pureWhite : AppColors.primaryBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    onSelected: (_) => setState(() => _selectedStatusFilter = status),
                  ),
                );
              }).toList(),
            ),
          ),

          // Orders List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No orders matching this status filter.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filtered[index];

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
                                Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  color: AppColors.luxuryBeigeLight,
                                  child: Text(
                                    order.status.code.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Recipient: ${order.customerName ?? "Customer"} (${order.phoneNumber ?? "No phone"})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Address: ${order.deliveryAddress}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              'Payment: ${order.paymentMethod} • Tracking: ${order.trackingCode}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${order.items.length} items • ${CurrencyFormatter.format(order.totalUsd, currency)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
                                  ElevatedButton(
                                    onPressed: () => _transitionOrder(order),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                    child: const Text('Next Status', style: TextStyle(fontSize: 11)),
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
