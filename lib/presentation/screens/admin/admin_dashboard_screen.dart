import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref, bool isUsingDefault) {
    final currentCtrl = TextEditingController(text: isUsingDefault ? '123456' : '');
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    String? errorMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            title: Row(
              children: [
                const Icon(Icons.vpn_key_outlined, color: AppColors.luxuryBeigeDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Change Owner Password',
                    style: AppTypography.titleMedium(),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUsingDefault
                        ? 'Hiện tại đang dùng mật khẩu mặc định (123456). Hãy đặt mật khẩu riêng để bảo mật cổng Chủ hàng.'
                        : 'Đổi mật khẩu truy cập cổng quản lý Chủ hàng KALIP studio.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: currentCtrl,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu hiện tại (Current Password)',
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                        onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới (New Password, min 4)',
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: obscureNew,
                    decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới (Confirm)',
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMsg!,
                      style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newCtrl.text.trim() != confirmCtrl.text.trim()) {
                    setDialogState(() {
                      errorMsg = 'Mật khẩu xác nhận không khớp (Passwords do not match)';
                    });
                    return;
                  }
                  final err = await ref.read(adminAuthProvider.notifier).changePassword(
                        currentPassword: currentCtrl.text,
                        newPassword: newCtrl.text,
                      );
                  if (err != null) {
                    setDialogState(() => errorMsg = err);
                    return;
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật mật khẩu Chủ hàng thành công!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text('Save Password'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStoreSettingsDialog(BuildContext context, WidgetRef ref, StoreSettingsState current) {
    final rateCtrl = TextEditingController(text: current.usdToKhrRate.toInt().toString());
    final thresholdCtrl = TextEditingController(text: current.freeShippingThresholdUsd.toStringAsFixed(0));
    final feeCtrl = TextEditingController(text: current.standardShippingFeeUsd.toStringAsFixed(2));
    final bannerCtrl = TextEditingController(text: current.customBannerNotice);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: Text('Store Rate & Delivery Config', style: AppTypography.titleMedium()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: rateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Exchange Rate (1 USD = ? KHR)',
                  hintText: '4100',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: thresholdCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Free Ship >= (\$)',
                        hintText: '50',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: feeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Delivery Fee (\$)',
                        hintText: '2.00',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bannerCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Custom Home Notice Banner (Optional)',
                  hintText: 'Leave blank for default Phnom Penh Express notice',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final rate = double.tryParse(rateCtrl.text) ?? current.usdToKhrRate;
              final threshold = double.tryParse(thresholdCtrl.text) ?? current.freeShippingThresholdUsd;
              final fee = double.tryParse(feeCtrl.text) ?? current.standardShippingFeeUsd;

              await ref.read(storeSettingsProvider.notifier).updateSettings(
                    usdToKhrRate: rate > 100 ? rate : current.usdToKhrRate,
                    freeShippingThresholdUsd: threshold >= 0 ? threshold : current.freeShippingThresholdUsd,
                    standardShippingFeeUsd: fee >= 0 ? fee : current.standardShippingFeeUsd,
                    customBannerNotice: bannerCtrl.text.trim(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Store settings saved & applied across storefront!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Apply Settings'),
          ),
        ],
      ),
    );
  }

  void _showResetDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: const Text('Reset Store Data?'),
        content: const Text(
          'Restore sample products and sample orders back to initial factory demo state? Custom edits to catalog and orders will be cleared.',
          style: TextStyle(fontSize: 12.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.pureWhite),
            onPressed: () async {
              await ref.read(adminProductsProvider.notifier).resetToDefaults();
              await ref.read(ordersProvider.notifier).resetToDefaults();
              await ref.read(storeSettingsProvider.notifier).resetToDefaults();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Restored initial KALIP studio demo catalog & orders.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Reset Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(adminAnalyticsProvider);
    final products = ref.watch(adminProductsProvider).products;
    final orders = ref.watch(ordersProvider);
    final adminAuth = ref.watch(adminAuthProvider);
    final storeSettings = ref.watch(storeSettingsProvider);

    final lowStockItems = products.where((p) => p.isLowStock || p.stockQuantity <= 5).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'ATELIER ADMIN',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Products & Pricing',
            onPressed: () => context.push('/admin/products'),
          ),
          IconButton(
            icon: const Icon(Icons.lock_outline, color: AppColors.error),
            tooltip: 'Lock Owner Mode',
            onPressed: () {
              ref.read(adminAuthProvider.notifier).lockPortal();
              context.go('/');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã khóa chế độ Chủ hàng (Owner Mode Locked)')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
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
                          'KALIP studio — OWNER PORTAL',
                          style: TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          adminAuth.isUsingDefaultPassword
                              ? 'Password: Default (Change recommended)'
                              : 'Security: Custom Owner Password Active',
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
                      'UNLOCKED',
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
                    'GROSS MERCHANDISE VALUE (ACTIVE GMV)',
                    style: AppTypography.bodySmall(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        '\$${analytics.totalGmvUsd.toStringAsFixed(2)}',
                        style: AppTypography.priceTag(fontSize: 26),
                      ),
                      Text(
                        '≈ ${CurrencyFormatter.format(analytics.totalGmvUsd, AppCurrency.khr, rate: analytics.usdToKhrRate)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.luxuryBeigeDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Live Rate: 1 USD = ${analytics.usdToKhrRate.toInt()} KHR • ${analytics.activeProductsCount} Active / ${analytics.hiddenProductsCount} Hidden • ${analytics.onSaleProductsCount} On Sale',
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
                    subtitle: 'Low Stock (<=5)',
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
                    title: 'Products & Pricing',
                    desc: 'Add, edit, price, delete',
                    onTap: () => context.push('/admin/products'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.local_shipping_outlined,
                    title: 'Order Fulfillment',
                    desc: 'Status, cancel, search',
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
                    desc: 'KHQR slips & COD cash',
                    onTap: () => context.push('/admin/payments'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.auto_awesome,
                    title: 'AI Concierge',
                    desc: 'Test boutique assistant',
                    onTap: () => context.push('/ai-concierge'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Owner Security & Store Settings Section
            const Text(
              'OWNER SECURITY & STORE SETTINGS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.vpn_key_outlined,
                    title: 'Owner Password',
                    desc: adminAuth.isUsingDefaultPassword ? 'Default (123456) • Change' : 'Custom password active',
                    badge: adminAuth.isUsingDefaultPassword ? 'DEFAULT' : 'SECURED',
                    badgeColor: adminAuth.isUsingDefaultPassword ? AppColors.warning : AppColors.success,
                    onTap: () => _showChangePasswordDialog(context, ref, adminAuth.isUsingDefaultPassword),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.lock_outline,
                    title: 'Lock Portal',
                    desc: 'Require password again',
                    onTap: () {
                      ref.read(adminAuthProvider.notifier).lockPortal();
                      context.go('/');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Owner mode locked.')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.currency_exchange,
                    title: 'Rate & Shipping',
                    desc: '1 USD = ${storeSettings.usdToKhrRate.toInt()} ៛ • Free >= \$${storeSettings.freeShippingThresholdUsd.toInt()}',
                    onTap: () => _showStoreSettingsDialog(context, ref, storeSettings),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.restore,
                    title: 'Reset Demo Data',
                    desc: 'Restore default catalog',
                    onTap: () => _showResetDataDialog(context, ref),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT ORDERS STREAM',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
                ),
                TextButton(
                  onPressed: () => context.push('/admin/orders'),
                  child: const Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

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
    String? badge,
    Color? badgeColor,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 22, color: AppColors.primaryBlack),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    color: (badgeColor ?? AppColors.primaryBlack).withValues(alpha: 0.15),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: badgeColor ?? AppColors.primaryBlack,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
