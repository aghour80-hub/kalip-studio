import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/core/utils/image_upload_service.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';
import 'package:style_house/presentation/widgets/admin_bottom_nav.dart';
import 'package:style_house/presentation/widgets/admin_product_editor_sheet.dart';
import 'package:style_house/presentation/widgets/luxury_image.dart';

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
                Expanded(child: Text('Change Owner Password', style: AppTypography.titleMedium())),
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
                      labelText: 'Mật khẩu hiện tại (Current)',
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
                      labelText: 'Mật khẩu mới (min 4 chars)',
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
                    decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
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
                    setDialogState(() => errorMsg = 'Mật khẩu xác nhận không khớp');
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

  void _showBankQrManagerDialog(BuildContext context, WidgetRef ref, StoreSettingsState current) {
    final bankCtrl = TextEditingController(text: current.bankName);
    final nameCtrl = TextEditingController(text: current.bankAccountName);
    final usdCtrl = TextEditingController(text: current.bankAccountUsd);
    final khrCtrl = TextEditingController(text: current.bankAccountKhr);
    String? tempCustomQr = current.customQrImageData;
    bool clearQr = false;
    bool uploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final previewSource = (!clearQr && tempCustomQr != null && tempCustomQr!.isNotEmpty)
              ? tempCustomQr!
              : current.effectiveQrImage;

          return AlertDialog(
            backgroundColor: AppColors.pureWhite,
            title: Row(
              children: [
                const Icon(Icons.qr_code_2, color: Color(0xFF005B7F)),
                const SizedBox(width: 8),
                Expanded(child: Text('Store Payment QR (Free Upload)', style: AppTypography.titleMedium())),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.canvasLinen,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: LuxuryImage(imageUrl: previewSource, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: uploading
                              ? null
                              : () async {
                                  setDialogState(() => uploading = true);
                                  final picked = await ImageUploadService.pickSingleImage(
                                    source: ImageSource.gallery,
                                    maxDimension: 900,
                                    quality: 0.85,
                                  );
                                  setDialogState(() {
                                    uploading = false;
                                    if (picked != null) {
                                      tempCustomQr = picked.dataUri;
                                      clearQr = false;
                                    }
                                  });
                                },
                          icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                          label: Text(uploading ? 'Uploading...' : 'Upload New QR (Free)', style: const TextStyle(fontSize: 11)),
                        ),
                        if (tempCustomQr != null && !clearQr)
                          OutlinedButton(
                            onPressed: () => setDialogState(() {
                              clearQr = true;
                              tempCustomQr = null;
                            }),
                            child: const Text('Use Default ABA QR', style: TextStyle(fontSize: 11)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: bankCtrl,
                      decoration: const InputDecoration(labelText: 'Bank Name (e.g. ABA BANK)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Account Holder Name'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: usdCtrl,
                            decoration: const InputDecoration(labelText: 'USD Account #'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: khrCtrl,
                            decoration: const InputDecoration(labelText: 'KHR Account #'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(storeSettingsProvider.notifier).updateBankQr(
                        customQrImageData: tempCustomQr,
                        clearCustomQr: clearQr,
                        bankName: bankCtrl.text.trim(),
                        bankAccountName: nameCtrl.text.trim(),
                        bankAccountUsd: usdCtrl.text.trim(),
                        bankAccountKhr: khrCtrl.text.trim(),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật ảnh QR & Tài khoản nhận tiền!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text('Save QR & Bank'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCouponsManagerSheet(BuildContext context, WidgetRef ref) {
    final codeCtrl = TextEditingController();
    final pctCtrl = TextEditingController(text: '15');
    final minSpendCtrl = TextEditingController(text: '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Consumer(
        builder: (context, modalRef, _) {
          final coupons = modalRef.watch(storeSettingsProvider).coupons;
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PROMO COUPONS MANAGER',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Text(
                    'Mã giảm giá đang bật sẽ tự hiển thị trong Giỏ hàng của khách.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: codeCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(labelText: 'Code (e.g. KALIP15)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: pctCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '% Off'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: minSpendCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Min \$'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final code = codeCtrl.text.trim().toUpperCase();
                        final pct = double.tryParse(pctCtrl.text.trim()) ?? 10.0;
                        final minS = double.tryParse(minSpendCtrl.text.trim()) ?? 0.0;
                        if (code.isEmpty || pct <= 0 || pct > 90) return;
                        await modalRef.read(storeSettingsProvider.notifier).addOrUpdateCoupon(
                              StoreCoupon(code: code, discountPercent: pct, minSpendUsd: minS),
                            );
                        codeCtrl.clear();
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('ADD PROMO CODE'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  ...coupons.map((c) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${c.code}  •  -${c.discountPercent.toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        c.minSpendUsd > 0 ? 'Min order: \$${c.minSpendUsd.toStringAsFixed(0)}' : 'No minimum spend',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: c.isActive,
                            activeThumbColor: AppColors.primaryBlack,
                            onChanged: (_) => modalRef.read(storeSettingsProvider.notifier).toggleCoupon(c.code),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            onPressed: () => modalRef.read(storeSettingsProvider.notifier).deleteCoupon(c.code),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
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
                      decoration: const InputDecoration(labelText: 'Free Ship >= (\$)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: feeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Delivery Fee (\$)'),
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
          'Restore sample products, coupons, and sample orders back to initial factory demo state?',
          style: TextStyle(fontSize: 12.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
    final clearedRevenue = orders
        .where((o) => o.status != OrderStatus.pending && o.status != OrderStatus.cancelled)
        .fold<double>(0.0, (s, o) => s + o.totalUsd);
    final pendingRevenue = orders
        .where((o) => o.status == OrderStatus.pending)
        .fold<double>(0.0, (s, o) => s + o.totalUsd);
    final totalPipeline = (clearedRevenue + pendingRevenue) > 0 ? (clearedRevenue + pendingRevenue) : 1.0;
    final clearedRatio = (clearedRevenue / totalPipeline).clamp(0.0, 1.0);
    final activeCouponsCount = storeSettings.coupons.where((c) => c.isActive).length;

    return Scaffold(
      backgroundColor: AppColors.canvasLinen,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.storefront_outlined, size: 21),
          tooltip: 'Về Cửa hàng (Boutique)',
          onPressed: () => context.go('/'),
        ),
        title: Column(
          children: [
            Text(
              'KALIP studio',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                color: AppColors.primaryBlack,
              ),
            ),
            const Text(
              'OWNER CONTROL CENTER',
              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: AppColors.error, size: 21),
            tooltip: 'Khóa chế độ Chủ hàng',
            onPressed: () {
              ref.read(adminAuthProvider.notifier).lockPortal();
              context.go('/');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã khóa chế độ Chủ hàng (Owner Mode Locked)')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Luxury Obsidian Hero Command Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF141414), Color(0xFF26231F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ACTIVE STORE REVENUE (GMV)',
                        style: TextStyle(
                          color: AppColors.luxuryBeige,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.success, width: 0.8),
                        ),
                        child: const Text(
                          '● LIVE SHOP',
                          style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      Text(
                        '\$${analytics.totalGmvUsd.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '≈ ${CurrencyFormatter.format(analytics.totalGmvUsd, AppCurrency.khr, rate: analytics.usdToKhrRate)}',
                        style: const TextStyle(
                          color: AppColors.luxuryBeige,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Visual Cleared vs Pending Revenue Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: clearedRatio,
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.luxuryBeige),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cleared: \$${clearedRevenue.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                      ),
                      Text(
                        'Pending: \$${pendingRevenue.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppColors.luxuryBeigeLight, fontSize: 10.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Primary CTA: Upload & Publish New Product
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.luxuryBeige,
                            foregroundColor: AppColors.primaryBlack,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onPressed: () => AdminProductEditorSheet.show(context),
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                          label: const Text(
                            'ĐĂNG SP + UPLOAD ẢNH FREE',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Live KPI Tiles Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'ACTIVE ITEMS',
                    value: '${analytics.activeProductsCount}',
                    subtitle: '${analytics.onSaleProductsCount} On Sale • ${analytics.hiddenProductsCount} Hidden',
                    icon: Icons.checkroom,
                    accentColor: AppColors.primaryBlack,
                    onTap: () => context.go('/admin/products'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: 'ORDERS',
                    value: '${analytics.totalOrdersCount}',
                    subtitle: '${analytics.pendingOrdersCount} Waiting Review',
                    icon: Icons.receipt_long,
                    accentColor: analytics.pendingOrdersCount > 0 ? AppColors.error : AppColors.success,
                    onTap: () => context.go('/admin/orders'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 3. Owner Tools & Studio Controls
            const Text(
              'OWNER STUDIO TOOLS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.qr_code_2,
                    title: 'Payment QR',
                    desc: '${storeSettings.bankName} • Upload Free',
                    badge: 'QR',
                    badgeColor: const Color(0xFF005B7F),
                    onTap: () => _showBankQrManagerDialog(context, ref, storeSettings),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.local_offer_outlined,
                    title: 'Promo Codes',
                    desc: '$activeCouponsCount active coupons',
                    badge: 'SALE',
                    badgeColor: AppColors.success,
                    onTap: () => _showCouponsManagerSheet(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.vpn_key_outlined,
                    title: 'Owner Password',
                    desc: adminAuth.isUsingDefaultPassword ? 'Default (123456) • Tap' : 'Custom password active',
                    badge: adminAuth.isUsingDefaultPassword ? 'DEFAULT' : 'SECURED',
                    badgeColor: adminAuth.isUsingDefaultPassword ? AppColors.warning : AppColors.success,
                    onTap: () => _showChangePasswordDialog(context, ref, adminAuth.isUsingDefaultPassword),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.currency_exchange,
                    title: 'Rate & Ship',
                    desc: '1\$ = ${storeSettings.usdToKhrRate.toInt()} ៛ • Free >= \$${storeSettings.freeShippingThresholdUsd.toInt()}',
                    onTap: () => _showStoreSettingsDialog(context, ref, storeSettings),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.auto_awesome,
                    title: 'AI Concierge',
                    desc: 'Test boutique assistant',
                    onTap: () => context.push('/ai-concierge'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.restore,
                    title: 'Reset Demo',
                    desc: 'Restore default catalog',
                    onTap: () => _showResetDataDialog(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 4. Low Stock Quick Restock Section
            if (lowStockItems.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LOW STOCK ALERTS (<= 5 UNITS)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.4, color: AppColors.warning),
                  ),
                  Text('${lowStockItems.length} items', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 10),
              ...lowStockItems.map((product) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 54,
                        child: LuxuryImage(
                          imageUrl: product.images.first,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.nameEn,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${product.stockQuantity} left • \$${product.priceUsd.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () {
                          ref.read(adminProductsProvider.notifier).restockProduct(product.id, 10);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Restocked +10 units for "${product.nameEn}".'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: const Text('+10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // 5. Recent Orders Stream
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT ORDERS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.luxuryBeigeDark),
                ),
                TextButton(
                  onPressed: () => context.go('/admin/orders'),
                  child: const Text('Manage All ->', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            ...orders.take(4).map((order) {
              return InkWell(
                onTap: () => context.go('/admin/orders'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(6),
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
                            Text(
                              '${order.customerName ?? "Customer"} • ${order.province ?? "Phnom Penh"}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${order.totalUsd.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.luxuryBeigeLight,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              order.status.code.toUpperCase(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(6),
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
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: accentColor)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
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
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 21, color: AppColors.primaryBlack),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AppColors.primaryBlack).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(3),
                    ),
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
            const SizedBox(height: 9),
            Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
