import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/presentation/providers/wishlist_provider.dart';

class MainShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(localizationProvider);
    final wishlistCount = ref.watch(wishlistProvider).length;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          border: Border(
            top: BorderSide(color: AppColors.borderLight, width: 0.8),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          backgroundColor: AppColors.pureWhite,
          selectedItemColor: AppColors.primaryBlack,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.home),
              ),
              label: tr.tr('nav_home'),
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.grid_view_outlined),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.grid_view_rounded),
              ),
              label: tr.tr('nav_categories'),
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.favorite_outline),
                  ),
                  if (wishlistCount > 0)
                    Positioned(
                      right: -6,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlack,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                        child: Center(
                          child: Text(
                            '$wishlistCount',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.favorite),
              ),
              label: tr.tr('nav_wishlist'),
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.local_shipping_outlined),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.local_shipping),
              ),
              label: tr.tr('nav_orders'),
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.person),
              ),
              label: tr.tr('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
