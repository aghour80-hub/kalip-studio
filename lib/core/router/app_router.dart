import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:style_house/presentation/screens/admin/admin_orders_screen.dart';
import 'package:style_house/presentation/screens/admin/admin_payments_screen.dart';
import 'package:style_house/presentation/screens/admin/admin_products_screen.dart';
import 'package:style_house/presentation/screens/ai_chat/ai_chat_screen.dart';
import 'package:style_house/presentation/screens/auth/forgot_password_screen.dart';
import 'package:style_house/presentation/screens/auth/login_screen.dart';
import 'package:style_house/presentation/screens/auth/register_screen.dart';
import 'package:style_house/presentation/screens/cart/cart_screen.dart';
import 'package:style_house/presentation/screens/categories/categories_screen.dart';
import 'package:style_house/presentation/screens/checkout/checkout_screen.dart';
import 'package:style_house/presentation/screens/checkout/order_success_screen.dart';
import 'package:style_house/presentation/screens/home/home_screen.dart';
import 'package:style_house/presentation/screens/main_shell_screen.dart';
import 'package:style_house/presentation/screens/orders/order_details_screen.dart';
import 'package:style_house/presentation/screens/orders/orders_screen.dart';
import 'package:style_house/presentation/screens/product/product_details_screen.dart';
import 'package:style_house/presentation/screens/profile/profile_screen.dart';
import 'package:style_house/presentation/screens/search/search_screen.dart';
import 'package:style_house/presentation/screens/wishlist/wishlist_screen.dart';
import 'package:style_house/presentation/widgets/admin_gate_wrapper.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      // Allow seamless atelier admin portal access for catalog, inventory, and pricing management
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailsScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderSuccessScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/order-details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderDetailsScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/admin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminGateWrapper(
          sectionTitle: 'Dashboard',
          child: AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/products',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminGateWrapper(
          sectionTitle: 'Catalog & Pricing',
          child: AdminProductsScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/orders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminGateWrapper(
          sectionTitle: 'Order Fulfillment',
          child: AdminOrdersScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/payments',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminGateWrapper(
          sectionTitle: 'Payment Audits',
          child: AdminPaymentsScreen(),
        ),
      ),
      GoRoute(
        path: '/ai-concierge',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiChatScreen(),
      ),
    ],
  );
});
