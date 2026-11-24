import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/data/models/user_model.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';
import 'package:style_house/presentation/providers/store_settings_provider.dart';
import 'package:style_house/presentation/widgets/app_bar_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserModel user, bool isKhmer) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phoneNumber ?? '');
    final emailCtrl = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: Text(
          isKhmer ? 'កែប្រែព័ត៌មានគណនី' : 'Edit Profile Information',
          style: AppTypography.headline(isKhmer: isKhmer),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isKhmer ? 'ឈ្មោះពេញ' : 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isKhmer ? 'លេខទូរស័ព្ទ' : 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
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
              await ref.read(authProvider.notifier).updateProfile(
                    fullName: nameCtrl.text,
                    phoneNumber: phoneCtrl.text,
                    email: emailCtrl.text,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile saved for future checkouts'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(isKhmer ? 'រក្សាទុក' : 'Save Profile'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, bool isKhmer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: Text(
          isKhmer ? 'ជ្រើសរើសភាសា' : 'Select Language',
          style: AppTypography.headline(isKhmer: isKhmer),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English (US)'),
              trailing: ref.watch(languageProvider) == 'en'
                  ? const Icon(Icons.check, color: AppColors.primaryBlack)
                  : null,
              onTap: () {
                ref.read(languageProvider.notifier).setLanguage('en');
                Navigator.pop(ctx);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('ភាសាខ្មែរ (Khmer)'),
              trailing: ref.watch(languageProvider) == 'km'
                  ? const Icon(Icons.check, color: AppColors.primaryBlack)
                  : null,
              onTap: () {
                ref.read(languageProvider.notifier).setLanguage('km');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref, bool isKhmer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        title: Text(
          isKhmer ? 'ជ្រើសរើសរូបិយប័ណ្ណ' : 'Select Currency',
          style: AppTypography.headline(isKhmer: isKhmer),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('USD (\$) - US Dollar'),
              subtitle: const Text('Primary store currency'),
              trailing: ref.watch(currencyProvider) == AppCurrency.usd
                  ? const Icon(Icons.check, color: AppColors.primaryBlack)
                  : null,
              onTap: () {
                ref.read(currencyProvider.notifier).setCurrency(AppCurrency.usd);
                Navigator.pop(ctx);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('KHR (៛) - Cambodian Riel'),
              subtitle: const Text('Rate: 1 USD = 4,100 KHR'),
              trailing: ref.watch(currencyProvider) == AppCurrency.khr
                  ? const Icon(Icons.check, color: AppColors.primaryBlack)
                  : null,
              onTap: () {
                ref.read(currencyProvider.notifier).setCurrency(AppCurrency.khr);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressesDialog(BuildContext context, bool isKhmer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isKhmer ? 'អាសយដ្ឋានដឹកជញ្ជូនរបស់អ្នក' : 'SAVED ADDRESSES (CAMBODIA)',
                style: AppTypography.headline(isKhmer: isKhmer),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlack, width: 1.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.home, color: AppColors.primaryBlack),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Home • Default', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: AppColors.luxuryBeigeLight,
                                child: const Text('Phnom Penh', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Street 302, Boeng Keng Kang 1, Chamkar Mon, Phnom Penh',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const Text(
                            'Phone: +855 92 888 999',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight, width: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.business, color: AppColors.textMuted),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Office', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                            'Wat Bo Road, Sala Kamreuk, Siem Reap',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final currentLang = ref.watch(languageProvider);
    final currentCurrency = ref.watch(currencyProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final adminAuth = ref.watch(adminAuthProvider);
    final storeSettings = ref.watch(storeSettingsProvider);

    return Scaffold(
      appBar: AppBarHeader(
        title: tr.tr('profile_title'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Profile Card / Guest Sign In Card
            if (authState.isAuthenticated && user != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.borderLight, width: 0.8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.luxuryBeigeLight,
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'S',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                style: AppTypography.titleMedium(isKhmer: isKhmer),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, size: 16, color: AppColors.luxuryBeigeDark),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.phoneNumber ?? tr.tr('cambodia_phone'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryBlack),
                      tooltip: 'Edit Profile',
                      onPressed: () => _showEditProfileDialog(context, ref, user, isKhmer),
                    ),
                  ],
                ),
              ),
            if (user != null) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () => context.push('/admin/products'),
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.canvasLinen,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: adminAuth.isUnlocked ? AppColors.success : AppColors.borderMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        adminAuth.isUnlocked ? Icons.lock_open : Icons.lock_outline,
                        color: adminAuth.isUnlocked ? AppColors.success : AppColors.primaryBlack,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QUẢN LÝ HÀNG & GIÁ CẢ (PRODUCTS & PRICING)',
                              style: TextStyle(
                                color: AppColors.primaryBlack,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              adminAuth.isUnlocked
                                  ? 'Đã mở khóa Chủ hàng • Bấm để sửa giá, thêm/xóa SP'
                                  : 'Cần mật khẩu Chủ hàng để sửa giá, kho, thêm/xóa SP',
                              style: TextStyle(
                                fontSize: 10,
                                color: adminAuth.isUnlocked ? AppColors.success : AppColors.textSecondary,
                                fontWeight: adminAuth.isUnlocked ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryBlack),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => context.push('/admin'),
                borderRadius: BorderRadius.circular(2),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppColors.luxuryBeige),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        adminAuth.isUnlocked ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
                        color: AppColors.luxuryBeige,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ATELIER ADMIN DASHBOARD',
                              style: TextStyle(
                                color: AppColors.pureWhite,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              adminAuth.isUnlocked
                                  ? 'Owner Unlocked • Revenue, Orders, Security & Password'
                                  : 'Protected by Owner Password • Tap to Unlock',
                              style: const TextStyle(fontSize: 10, color: AppColors.luxuryBeige),
                            ),
                          ],
                        ),
                      ),
                      if (adminAuth.isUnlocked)
                        IconButton(
                          icon: const Icon(Icons.lock, size: 18, color: AppColors.error),
                          tooltip: 'Lock Owner Mode',
                          onPressed: () {
                            ref.read(adminAuthProvider.notifier).lockPortal();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Owner Portal Locked')),
                            );
                          },
                        )
                      else
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.luxuryBeige),
                    ],
                  ),
                ),
              ),
            ],
            if (user == null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.borderLight, width: 0.8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 48, color: AppColors.luxuryBeige),
                    const SizedBox(height: 12),
                    Text(
                      isKhmer ? 'ចូលរួមជាសមាជិក VIP' : 'Join KALIP studio VIP Circle',
                      style: AppTypography.titleMedium(isKhmer: isKhmer),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isKhmer
                          ? 'ចូលគណនីដើម្បីគ្រប់គ្រងការបញ្ជាទិញ និងទទួលបានសិទ្ធិពិសេស។'
                          : 'Sign in to access your orders, track shipments, and receive invitations.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall(isKhmer: isKhmer, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                      child: Text(isKhmer ? 'ចូលគណនី / ចុះឈ្មោះ' : 'Sign In / Register'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
            _buildSectionHeader(isKhmer ? 'ការកំណត់ភាសា & រូបិយប័ណ្ណ' : 'PREFERENCES', isKhmer),
            _buildMenuItem(
              icon: Icons.language,
              title: tr.tr('language'),
              subtitle: currentLang == 'en' ? 'English' : 'ភាសាខ្មែរ (Khmer)',
              onTap: () => _showLanguageDialog(context, ref, isKhmer),
            ),
            _buildMenuItem(
              icon: Icons.attach_money,
              title: tr.tr('currency'),
              subtitle: currentCurrency == AppCurrency.usd
                  ? 'USD (\$) - Rate: 1 USD = ${storeSettings.usdToKhrRate.toInt()} KHR'
                  : 'KHR (៛) - Rate: 1 USD = ${storeSettings.usdToKhrRate.toInt()} KHR',
              onTap: () => _showCurrencyDialog(context, ref, isKhmer),
            ),

            const SizedBox(height: 20),
            _buildSectionHeader(isKhmer ? 'គណនីអតិថិជន' : 'ACCOUNT', isKhmer),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: tr.tr('shipping_addresses'),
              subtitle: 'Phnom Penh & Siem Reap (2 saved)',
              onTap: () => _showAddressesDialog(context, isKhmer),
            ),
            _buildMenuItem(
              icon: Icons.qr_code_2,
              title: tr.tr('payment_methods'),
              subtitle: 'Bakong KHQR, Cash on Delivery (COD), Cards',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('KHQR and Cash on Delivery are active for all Cambodian orders'),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            _buildSectionHeader(isKhmer ? 'សេវាកម្មអតិថិជន AI' : 'AI CONCIERGE & STORE', isKhmer),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
              ),
              child: Material(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(2),
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome, color: AppColors.luxuryBeige),
                  title: Text(
                    tr.tr('ai_concierge'),
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    tr.tr('ai_concierge_desc'),
                    style: const TextStyle(color: AppColors.luxuryBeigeLight, fontSize: 11),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.luxuryBeige),
                  onTap: () => context.push('/ai-concierge'),
                ),
              ),
            ),
            _buildMenuItem(
              icon: Icons.storefront_outlined,
              title: tr.tr('boutique_locations'),
              subtitle: 'Street 302, BKK1, Phnom Penh (Open daily 9 AM - 9 PM)',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.pureWhite,
                    title: const Text('KALIP studio Boutiques'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. Phnom Penh Flagship (BKK1)', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Street 302, Boeng Keng Kang 1, Phnom Penh\nHours: 9:00 AM - 9:00 PM daily', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        SizedBox(height: 12),
                        Text('2. Siem Reap Heritage Showroom', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Wat Bo Road, Sala Kamreuk, Siem Reap\nHours: 10:00 AM - 8:00 PM daily', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    actions: [
                      ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: tr.tr('faq_and_support'),
              subtitle: 'Telegram: @KalipStudioKH • Tel: 092 888 999',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.pureWhite,
                    title: const Text('KALIP studio Client Care'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• Express Delivery: 2-4 hours inside Phnom Penh, 1-2 days nationwide via Virak Buntham / J&T.', style: TextStyle(fontSize: 12)),
                        SizedBox(height: 8),
                        Text('• Payment: Zero-fee Bakong KHQR, Cash on Delivery (USD/KHR), or Visa/Mastercard.', style: TextStyle(fontSize: 12)),
                        SizedBox(height: 8),
                        Text('• Exchanges: Free 7-day size exchange at BKK1 Flagship.', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push('/ai-concierge');
                        },
                        child: const Text('Ask AI Concierge'),
                      ),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            if (authState.isAuthenticated) ...[
              OutlinedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isKhmer ? 'បានចាកចេញពីគណនី' : 'Signed out')),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderMedium),
                ),
                child: Text(
                  tr.tr('sign_out'),
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: Text(isKhmer ? 'ចូលគណនី' : 'SIGN IN'),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isKhmer) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.luxuryBeigeDark,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
      ),
      child: Material(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(2),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryBlack, size: 20),
          title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
          onTap: onTap,
        ),
      ),
    );
  }
}
