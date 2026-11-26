import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/presentation/providers/admin_provider.dart';

/// Unified Owner Admin Bottom Navigation Bar shared across all admin tabs.
class AdminBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/products');
        break;
      case 2:
        context.go('/admin/orders');
        break;
      case 3:
        context.go('/admin/payments');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(adminAnalyticsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBlack,
        border: Border(
          top: BorderSide(color: Color(0xFF2B2B2B), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _navigate(context, i),
        backgroundColor: AppColors.primaryBlack,
        selectedItemColor: AppColors.luxuryBeige,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 10.5,
        unselectedFontSize: 10,
        items: [
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.dashboard_outlined, size: 21),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.dashboard, size: 21),
            ),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: _BadgedAdminIcon(
              icon: Icons.checkroom_outlined,
              badgeCount: analytics.lowStockProductsCount,
              badgeColor: AppColors.warning,
            ),
            activeIcon: _BadgedAdminIcon(
              icon: Icons.checkroom,
              badgeCount: analytics.lowStockProductsCount,
              badgeColor: AppColors.warning,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: _BadgedAdminIcon(
              icon: Icons.local_shipping_outlined,
              badgeCount: analytics.pendingOrdersCount,
              badgeColor: AppColors.error,
            ),
            activeIcon: _BadgedAdminIcon(
              icon: Icons.local_shipping,
              badgeCount: analytics.pendingOrdersCount,
              badgeColor: AppColors.error,
            ),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.qr_code_scanner, size: 21),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(Icons.qr_code_2, size: 21),
            ),
            label: 'Finance',
          ),
        ],
      ),
    );
  }
}

class _BadgedAdminIcon extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final Color badgeColor;

  const _BadgedAdminIcon({
    required this.icon,
    required this.badgeCount,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Icon(icon, size: 21),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -7,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 15, minHeight: 14),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
