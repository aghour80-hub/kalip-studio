import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(adminAnalyticsProvider);
    final products = ref.watch(adminProductsProvider).products;
    final orders = ref.watch(ordersProvider);

    final lowStockItems = products.where((p) => p.isLowStock || p.stockQuantity <= 5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ATELIER ADMIN',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Return to Boutique',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Atelier Flagship Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: AppColors.luxuryBeige, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KALIP studio — BKK1 FLAGSHIP',
                          style: TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Management & Operations Portal',
                          style: AppTypography.bodySmall(color: AppColors.luxuryBeige),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.luxuryBeige,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Revenue KPI Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.canvasLinen,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GROSS MERCHANDISE VALUE (GMV)',
                    style: AppTypography.bodySmall(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${analytics.totalGmvUsd.toStringAsFixed(2)}',
                        style: AppTypography.priceTag(fontSize: 26),
                      ),
                      Text(
                        '≈ ${CurrencyFormatter.format(analytics.totalGmvUsd, AppCurrency.khr)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.luxuryBeigeDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configured Rate: 1 USD = ${AppConstants.usdToKhrRate.toInt()} KHR (Cambodia Standard)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metrics Grid (Orders & Inventory)
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'TOTAL ORDERS',
                    value: '${analytics.totalOrdersCount}',
                    subtitle: '${analytics.pendingOrdersCount} Pending',
                    icon: Icons.receipt_long,
                    accentColor: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'INVENTORY ALERT',
                    value: '${analytics.lowStockProductsCount}',
                    subtitle: 'Low Stock (<5)',
                    icon: Icons.inventory_2_outlined,
                    accentColor: analytics.lowStockProductsCount > 0 ? AppColors.warning : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Admin Modules Navigation
            const Text(
              'MANAGEMENT MODULES',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.checkroom,
                    title: 'Products & Stock',
                    desc: 'Catalog, sizes, inventory',
                    onTap: () => context.push('/admin/products'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.local_shipping_outlined,
                    title: 'Fulfillment',
                    desc: 'Orders, delivery SLA',
                    onTap: () => context.push('/admin/orders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.qr_code_scanner,
                    title: 'Payment Audits',
                    desc: 'KHQR slips & COD',
                    onTap: () => context.push('/admin/payments'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.auto_awesome,
                    title: 'AI & Automations',
                    desc: 'n8n webhooks, bot',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI Automation & n8n module configured for Phase 7.')),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Low Stock Atelier Restock Section
            if (lowStockItems.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LOW STOCK INVENTORY (BKK1 HUB)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.warning),
                  ),
                  Text('${lowStockItems.length} items need restock', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 12),
              ...lowStockItems.map((product) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: AppColors.warning.withValues(alpha: 0.15),
                        child: Text(
                          '${product.stockQuantity} LEFT',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.nameEn, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('\$${product.priceUsd.toStringAsFixed(2)} • ${product.gender.toUpperCase()}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ref.read(adminProductsProvider.notifier).restockProduct(product.id, 10);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Restocked +10 units for "${product.nameEn}". Current: ${product.stockQuantity + 10}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: const Text('+10 UNITS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Recent Orders Overview
            const Text(
              'RECENT ORDERS STREAM',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
            ),
            const SizedBox(height: 12),

            ...orders.take(4).map((order) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_mall_outlined, size: 20, color: AppColors.primaryBlack),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${order.customerName ?? "Customer"} • ${order.province ?? "Phnom Penh"}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${order.totalUsd.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: AppColors.luxuryBeigeLight,
                          child: Text(
                            order.status.code.toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: AppColors.primaryBlack),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
