import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/widgets/admin_bottom_nav.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        return AppColors.luxuryBeigeDark;
      case OrderStatus.delivering:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

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

    final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
    final deliveringCount = orders.where((o) => o.status == OrderStatus.delivering).length;
    final deliveredCount = orders.where((o) => o.status == OrderStatus.delivered).length;

    return Scaffold(
      backgroundColor: AppColors.canvasLinen,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.storefront_outlined, size: 21),
          tooltip: 'Về Cửa hàng',
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'ORDER FULFILLMENT',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.4),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, size: 20, color: AppColors.error),
            tooltip: 'Lock Owner Mode',
            onPressed: () {
              ref.read(adminAuthProvider.notifier).lockPortal();
              context.go('/');
            },
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
      body: Column(
        children: [
          // Top Order Metrics Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.primaryBlack,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('PENDING', '$pendingCount', AppColors.warning),
                Container(width: 1, height: 22, color: Colors.white24),
                _stat('DELIVERING', '$deliveringCount', AppColors.luxuryBeige),
                Container(width: 1, height: 22, color: Colors.white24),
                _stat('DELIVERED', '$deliveredCount', AppColors.success),
              ],
            ),
          ),

          // Search Bar & Filter Tabs
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.pureWhite,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm theo mã đơn, tên khách hoặc SĐT...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    filled: true,
                    fillColor: AppColors.canvasLinen,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
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
                    child: Text('Không có đơn hàng nào khớp bộ lọc.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      final color = _statusColor(order.status);

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withValues(alpha: 0.35)),
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
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    order.status.code.toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${order.customerName ?? "Customer"} • ${order.phoneNumber ?? "No phone"}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (order.phoneNumber != null && order.phoneNumber!.isNotEmpty)
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: order.phoneNumber!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Copied phone: ${order.phoneNumber}')),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: Row(
                                        children: [
                                          Icon(Icons.copy, size: 13, color: AppColors.luxuryBeigeDark),
                                          SizedBox(width: 3),
                                          Text('Copy SĐT', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.luxuryBeigeDark)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
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
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 50,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: order.items.length,
                                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                                  itemBuilder: (_, i) {
                                    final item = order.items[i];
                                    return Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.canvasLinen,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 34,
                                            height: 42,
                                            child: LuxuryImage(
                                              imageUrl: item.product.images.first,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.product.nameEn,
                                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'x${item.quantity} • Size ${item.selectedSize}',
                                                style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                      ),
                                    );
                                  },
                                ),
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
                                          borderRadius: BorderRadius.circular(3),
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

  Widget _stat(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 0.8)),
      ],
    );
  }
}
