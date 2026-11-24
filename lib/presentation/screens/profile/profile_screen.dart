import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';
import 'package:style_house/presentation/widgets/app_bar_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
                  ],
                ),
              ),
            if (user != null) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  if (!user.isAdmin) {
                    ref.read(authProvider.notifier).toggleAdminRole();
                  }
                  context.push('/admin');
                },
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
                      const Icon(Icons.admin_panel_settings_outlined, color: AppColors.luxuryBeige, size: 22),
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
                              user.isAdmin ? 'Role: Authorized Atelier Staff' : 'Tap to switch role & enter Admin Portal',
                              style: const TextStyle(fontSize: 10, color: AppColors.luxuryBeige),
                            ),
                          ],
                        ),
                      ),
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
              subtitle: currentCurrency == AppCurrency.usd ? 'USD (\$) - US Dollar' : 'KHR (៛) - Cambodian Riel',
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.pureWhite,
                        title: Text(
                          isKhmer ? 'ជំនួយការវៃឆ្លាត AI Fashion' : 'KALIP studio Concierge',
                          style: AppTypography.headline(isKhmer: isKhmer),
                        ),
                        content: Text(
                          isKhmer
                              ? 'ប្រព័ន្ធ AI Customer Support នឹងភ្ជាប់ជាមួយ OpenAI API និង n8n Automation ក្នុង Phase 7 ដើម្បីឆ្លើយសំណួរអំពីទំនិញ ទំហំ និងការដឹកជញ្ជូនរហ័ស។'
                              : 'The AI Customer Support Concierge will be fully connected via secure backend and n8n webhooks in Phase 7 to assist with sizing, availability, and orders.',
                          style: AppTypography.bodyMedium(isKhmer: isKhmer),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildMenuItem(
              icon: Icons.storefront_outlined,
              title: tr.tr('boutique_locations'),
              subtitle: 'Street 302, BKK1, Phnom Penh (Open daily 9 AM - 9 PM)',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: tr.tr('faq_and_support'),
              subtitle: 'Telegram: @StyleHouseKH • Tel: 092 888 999',
              onTap: () {},
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
