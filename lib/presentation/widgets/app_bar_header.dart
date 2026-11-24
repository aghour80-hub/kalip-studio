import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/currency/currency_formatter.dart';
import 'package:style_house/core/currency/currency_provider.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';
import 'package:style_house/presentation/providers/cart_provider.dart';

class AppBarHeader extends ConsumerWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;

  const AppBarHeader({
    super.key,
    this.showBackButton = false,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isKhmer = ref.watch(localizationProvider).isKhmer;
    final currentLang = ref.watch(languageProvider);
    final currentCurrency = ref.watch(currencyProvider);
    final cartCount = ref.watch(cartProvider).totalItemCount;
    final isAdminUnlocked = ref.watch(adminAuthProvider).isUnlocked;

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: isKhmer
                  ? GoogleFonts.kantumruyPro(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlack,
                    )
                  : GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.primaryBlack,
                    ),
            )
          : InkWell(
              onTap: () => context.go('/'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'KALIP studio',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.0,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  Text(
                    isKhmer ? 'រាជធានីភ្នំពេញ' : 'PHNOM PENH • ATELIER',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.luxuryBeigeDark,
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.search, size: 21),
          onPressed: () => context.push('/search'),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(languageProvider.notifier).toggleLanguage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderMedium, width: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              currentLang == 'en' ? 'ខ្មែរ' : 'EN',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(currencyProvider.notifier).toggleCurrency();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderMedium, width: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              currentCurrency == AppCurrency.usd ? '៛ KHR' : '\$ USD',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
        ),
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          constraints: const BoxConstraints(),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isAdminUnlocked ? Icons.inventory_2_outlined : Icons.lock_outline,
                size: 20,
                color: isAdminUnlocked ? AppColors.success : AppColors.primaryBlack,
              ),
              if (isAdminUnlocked)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          tooltip: isAdminUnlocked
              ? 'Quản lý hàng & Giá cả (Đã mở khóa)'
              : 'Quản lý Chủ hàng (Cần mật khẩu)',
          onPressed: () => context.push('/admin/products'),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 22),
              onPressed: () => context.push('/cart'),
            ),
            if (cartCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlack,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: AppColors.pureWhite,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
