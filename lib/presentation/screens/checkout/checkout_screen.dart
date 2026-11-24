import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/payment/cod_service.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/order_model.dart';
import 'package:style_house/presentation/providers/ai_chat_provider.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';
import 'package:style_house/presentation/providers/cart_provider.dart';
import 'package:style_house/presentation/providers/orders_provider.dart';
import 'package:style_house/presentation/widgets/khqr_payment_sheet.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _addressController = TextEditingController(text: 'Street 302, Sangkat Boeng Keng Kang 1');
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? 'Seng Hour');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '092 888 999');
  }

  String _selectedProvince = 'Phnom Penh';
  String _selectedDistrict = 'Chamkar Mon / BKK';
  String _selectedPaymentMethod = 'khqr'; // 'khqr', 'cod', 'card'
  bool _isSubmitting = false;
  bool _orderCompleted = false;

  final List<String> _provinces = [
    'Phnom Penh',
    'Siem Reap',
    'Battambang',
    'Sihanoukville',
    'Kampot',
    'Kandal',
  ];

  final Map<String, List<String>> _districtsByProvince = {
    'Phnom Penh': ['Chamkar Mon / BKK', 'Daun Penh', 'Tuol Kork', 'Sen Sok', 'Chbar Ampov', 'Prampir Makara'],
    'Siem Reap': ['Siem Reap Central', 'Wat Bo Area', 'Svay Dangkum', 'Sala Kamreuk'],
    'Battambang': ['Battambang City', 'Rotanak', 'Svay Pao'],
    'Sihanoukville': ['Mittapheap', 'Prey Nob', 'Otres Beach Area'],
    'Kampot': ['Kampot Riverside', 'Tuek Chhou'],
    'Kandal': ['Ta Khmau', 'Kien Svay'],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder(dynamic tr, bool isKhmer, CartState cart, AppCurrency currency) async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authProvider).user;
      final userId = user?.id ?? 'guest-customer';
      final paymentTitle = _selectedPaymentMethod == 'khqr'
          ? 'KHQR (Bakong Payment)'
          : (_selectedPaymentMethod == 'cod' ? 'Cash on Delivery (COD)' : 'Credit / Debit Card');

      final newOrder = await ref.read(ordersProvider.notifier).createOrder(
        userId: userId,
        items: List.from(cart.items),
        customerName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        province: _selectedProvince,
        district: _selectedDistrict,
        streetAddress: _addressController.text.trim(),
        deliveryNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        paymentMethod: paymentTitle,
        couponCode: cart.promoCode,
      );

      // Trigger n8n automated store dispatch webhook
      ref.read(n8nWebhookServiceProvider).notifyOrderCreated(newOrder);

      _orderCompleted = true;
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        if (_selectedPaymentMethod == 'khqr') {
          var paymentConfirmed = false;
          await KhqrPaymentSheet.show(
            context,
            order: newOrder,
            onPaymentSuccess: () {
              paymentConfirmed = true;
              ref.read(ordersProvider.notifier).updateOrderStatus(
                    newOrder.orderNumber,
                    OrderStatus.confirmed,
                  );
              if (mounted) {
                context.go('/order-success/${newOrder.orderNumber}');
              }
            },
          );
          // Even if buyer dismisses modal early, proceed cleanly to Order Success so they can reopen QR anytime
          if (!paymentConfirmed && mounted) {
            context.go('/order-success/${newOrder.orderNumber}');
          }
        } else {
          context.go('/order-success/${newOrder.orderNumber}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final currency = ref.watch(currencyProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKhmer ? 'ការទូទាត់ប្រាក់' : 'CHECKOUT',
          style: isKhmer
              ? AppTypography.headline(isKhmer: isKhmer)
              : const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
        centerTitle: true,
      ),
      body: (cart.items.isEmpty && !_orderCompleted)
          ? Center(
              child: Text(
                tr.tr('bag_empty_title'),
                style: AppTypography.titleMedium(isKhmer: isKhmer),
              ),
            )
          : _orderCompleted
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryBlack),
                      SizedBox(height: 14),
                      Text('Đang mở thông tin thanh toán QR...'),
                    ],
                  ),
                )
              : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 1: Customer Contact Information
                    _buildSectionTitle(isKhmer ? '១. ព័ត៌មានអតិថិជន' : '1. CUSTOMER INFORMATION', isKhmer),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: isKhmer ? 'ឈ្មោះអតិថិជន *' : 'Full Name *',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: isKhmer ? 'លេខទូរស័ព្ទ (កម្ពុជា) *' : 'Phone Number (Cambodia) *',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        hintText: '092 xxx xxx',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter phone number';
                        if (val.trim().length < 8) return 'Enter a valid Cambodian phone number';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    const Divider(),

                    // Step 2: Delivery Location (Cambodia)
                    _buildSectionTitle(isKhmer ? '២. អាសយដ្ឋានដឹកជញ្ជូន' : '2. DELIVERY ADDRESS (CAMBODIA)', isKhmer),
                    const SizedBox(height: 12),
                    // Province Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProvince,
                      decoration: InputDecoration(
                        labelText: isKhmer ? 'រាជធានី / ខេត្ត *' : 'Province / City *',
                        prefixIcon: const Icon(Icons.map_outlined, size: 20),
                      ),
                      items: _provinces
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedProvince = val;
                            _selectedDistrict = _districtsByProvince[val]!.first;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // District Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      decoration: InputDecoration(
                        labelText: isKhmer ? 'ខណ្ឌ / ស្រុក *' : 'District / Khan *',
                        prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
                      ),
                      items: (_districtsByProvince[_selectedProvince] ?? ['Central'])
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDistrict = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: isKhmer ? 'លេខផ្ទះ និងផ្លូវ *' : 'Street & Building / House No. *',
                        prefixIcon: const Icon(Icons.home_outlined, size: 20),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your street address' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: isKhmer ? 'កំណត់សម្គាល់សម្រាប់អ្នកដឹកជញ្ជូន (ជម្រើស)' : 'Delivery Notes (Optional)',
                        prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                        hintText: 'e.g., Call when arriving at security gate',
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),

                    // Step 3: Payment Method in Cambodia
                    _buildSectionTitle(isKhmer ? '៣. វិធីសាស្ត្រទូទាត់ប្រាក់' : '3. PAYMENT METHOD', isKhmer),
                    const SizedBox(height: 12),

                    // KHQR (ABA Bank Transfer QR) Option
                    _buildPaymentOption(
                      id: 'khqr',
                      title: 'ABA Bank KHQR (SENGHOUR PRAK)',
                      subtitle: isKhmer
                          ? 'បង្ហាញរូបភាព ABA QR ដើម្បីស្កេនផ្ទេរប្រាក់ភ្លាមៗ (USD: 000 817 811 / KHR: 014 042 356)'
                          : 'Hiện hình ảnh mã ABA QR để quét chuyển khoản (USD: 000 817 811 / KHR: 014 042 356)',
                      icon: Icons.qr_code_scanner,
                      badge: 'RECOMMENDED',
                    ),
                    const SizedBox(height: 10),

                    // Cash on Delivery Option
                    _buildPaymentOption(
                      id: 'cod',
                      title: isKhmer ? 'ទូទាត់ប្រាក់ពេលទំនិញមកដល់ (COD)' : 'Cash on Delivery (COD)',
                      subtitle: isKhmer ? 'ទូទាត់ជាប្រាក់ដុល្លារ ឬរៀលពេលអ្នកដឹកជញ្ជូនប្រគល់ទំនិញ' : 'Pay in cash (USD or KHR) upon receiving your package',
                      icon: Icons.payments_outlined,
                    ),
                    if (_selectedPaymentMethod == 'cod') ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.canvasLinen,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: AppColors.luxuryBeigeDark),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isKhmer
                                    ? CodService.getHandoverInstructionKm(cart.totalUsd)
                                    : CodService.getHandoverInstructionEn(cart.totalUsd),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Credit / Debit Card Option
                    _buildPaymentOption(
                      id: 'card',
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, Mastercard, UnionPay',
                      icon: Icons.credit_card_outlined,
                    ),

                    const SizedBox(height: 24),
                    const Divider(),

                    // Step 4: Final Summary
                    _buildSectionTitle(isKhmer ? '៤. សេចក្តីសង្ខេបតម្លៃ' : '4. SUMMARY', isKhmer),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr.tr('subtotal'), style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(CurrencyFormatter.format(cart.subtotalUsd, currency), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr.tr('delivery_fee'), style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(
                          cart.qualifiesForFreeDelivery
                              ? tr.tr('free_delivery')
                              : CurrencyFormatter.format(cart.deliveryFeeUsd, currency),
                          style: TextStyle(
                            color: cart.qualifiesForFreeDelivery ? AppColors.success : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (cart.discountPercentage > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr.tr('discount'), style: const TextStyle(color: AppColors.success, fontSize: 13)),
                          Text('-${CurrencyFormatter.format(cart.discountUsd, currency)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr.tr('estimated_total'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(CurrencyFormatter.format(cart.totalUsd, currency), style: AppTypography.priceTag(fontSize: 20)),
                            Text(CurrencyFormatter.formatDual(cart.totalUsd), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Submit Order Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submitOrder(tr, isKhmer, cart, currency),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.pureWhite,
                              ),
                            )
                          : Text(
                              _selectedPaymentMethod == 'khqr'
                                  ? (isKhmer ? 'បញ្ជាទិញ & បង្ហាញ ABA QR' : 'MUA NGAY & HIỆN MÃ QR CHUYỂN KHOẢN')
                                  : (isKhmer ? 'បញ្ជាក់ការកុម្ម៉ង់ទំនិញ' : 'CONFIRM & PLACE ORDER'),
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, bool isKhmer) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.luxuryBeigeDark,
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlack : AppColors.borderLight,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryBlack : AppColors.textMuted, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: AppColors.luxuryBeige,
                          child: Text(
                            badge,
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primaryBlack : AppColors.borderMedium,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
