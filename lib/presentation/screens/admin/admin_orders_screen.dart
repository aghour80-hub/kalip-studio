import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';

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
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return o.orderNumber.toLowerCase().contains(q) ||
            (o.customerName ?? '').toLowerCase().contains(q) ||
            (o.phoneNumber ?? '').toLowerCase().contains(q) ||
            o.trackingCode.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        title: const Text(
          'ORDER FULFILLMENT',
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
          // Search Bar & Filter Tabs
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.canvasLinen,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by Order #, customer name, or phone...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: AppColors.pureWhite,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'pending', 'confirmed', 'processing', 'delivering', 'delivered', 'cancelled'].map((status) {
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
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No orders matching filter.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      final isCancelled = order.status == OrderStatus.cancelled;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isCancelled ? AppColors.error.withValues(alpha: 0.4) : AppColors.borderLight,
                          ),
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
                                  color: isCancelled ? AppColors.error.withValues(alpha: 0.15) : AppColors.luxuryBeigeLight,
                                  child: Text(
                                    order.status.code.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isCancelled ? AppColors.error : AppColors.primaryBlack,
                                    ),
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
                            if (order.items.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: order.items.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: AppColors.canvasLinen,
                                    child: Text(
                                      '${item.quantity}x ${item.product.nameEn} (${item.selectedSize})',
                                      style: const TextStyle(fontSize: 10, color: AppColors.textPrimary),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 10),
                            const Divider(),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text(
                                  '${order.items.length} items • ${CurrencyFormatter.format(order.totalUsd, currency)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PopupMenuButton<OrderStatus>(
                                      onSelected: (next) {
                                        ref.read(ordersProvider.notifier).updateOrderStatus(order.orderNumber, next);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Order ${order.orderNumber} set to ${next.titleEn}'),
                                            backgroundColor: next == OrderStatus.cancelled ? AppColors.error : AppColors.success,
                                          ),
                                        );
                                      },
                                      itemBuilder: (_) => OrderStatus.values.map((s) {
                                        return PopupMenuItem(
                                          value: s,
                                          child: Text(s.code.toUpperCase(), style: const TextStyle(fontSize: 12)),
                                        );
                                      }).toList(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.borderMedium),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: const Row(
                                          children: [
                                            Text('Set Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            SizedBox(width: 2),
                                            Icon(Icons.arrow_drop_down, size: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) ...[
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _transitionOrder(order),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        child: const Text('Next Step', style: TextStyle(fontSize: 11)),
                                      ),
                                    ],
                                  ],
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
