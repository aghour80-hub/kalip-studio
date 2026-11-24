import 'package:flutter_test/flutter_test.dart';
import 'package:style_house/data/models/user_model.dart';
import 'package:style_house/data/services/supabase_auth_service.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel fromJson and toJson serialization works correctly', () {
      final json = {
        'id': 'user-123',
        'email': 'customer@stylehouse.kh',
        'full_name': 'Sophea Pich',
        'phone_number': '+855 12 345 678',
        'avatar_url': 'https://example.com/avatar.jpg',
        'role': 'customer',
        'created_at': '2026-11-22T08:00:00Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'customer@stylehouse.kh');
      expect(user.fullName, 'Sophea Pich');
      expect(user.phoneNumber, '+855 12 345 678');
      expect(user.role, UserRole.customer);
      expect(user.isAdmin, isFalse);

      final outputJson = user.toJson();
      expect(outputJson['id'], 'user-123');
      expect(outputJson['full_name'], 'Sophea Pich');
      expect(outputJson['role'], 'customer');
    });

    test('UserModel recognizes admin and manager roles', () {
      final admin = UserModel.fromJson({
        'id': 'admin-01',
        'email': 'admin@stylehouse.kh',
        'full_name': 'Atelier Manager',
        'role': 'admin',
      });
      expect(admin.isAdmin, isTrue);

      final manager = UserModel.fromJson({
        'id': 'mgr-01',
        'email': 'manager@stylehouse.kh',
        'full_name': 'Floor Manager',
        'role': 'manager',
      });
      expect(manager.role, UserRole.manager);
      expect(manager.isAdmin, isTrue);

      final customer = UserModel.fromJson({
        'id': 'cust-01',
        'email': 'customer@stylehouse.kh',
        'full_name': 'Normal Shopper',
        'role': 'customer',
      });
      expect(customer.role, UserRole.customer);
      expect(customer.isAdmin, isFalse);
    });
  });

  group('AuthNotifier State Transitions', () {
    late SupabaseAuthService authService;
    late AuthNotifier authNotifier;

    setUp(() {
      authService = SupabaseAuthService();
      authNotifier = AuthNotifier(authService);
    });

    test('Initial state is authenticated with default VIP guest member', () {
      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user?.email, 'vip.member@stylehouse.com.kh');
      expect(authNotifier.state.isAuthenticated, isTrue);
    });

    test('Sign out transitions to unauthenticated status and clears user', () async {
      await authNotifier.signOut();

      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      expect(authNotifier.state.user, isNull);
      expect(authNotifier.state.isAuthenticated, isFalse);
    });

    test('Guest mode transitions to authenticated guest shopper', () {
      authNotifier.continueAsGuest();

      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user?.fullName, 'Guest Shopper');
      expect(authNotifier.state.isAuthenticated, isTrue);
    });

    test('SignIn in mock mode successfully authenticates user', () async {
      final success = await authNotifier.signIn('sophal@stylehouse.kh', 'SecretPassword123');

      expect(success, isTrue);
      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user?.email, 'sophal@stylehouse.kh');
    });

    test('SignUp in mock mode successfully registers and authenticates user', () async {
      final success = await authNotifier.signUp(
        email: 'chann@stylehouse.kh',
        password: 'Password123',
        fullName: 'Chann Vathana',
        phoneNumber: '+855 98 765 432',
      );

      expect(success, isTrue);
      expect(authNotifier.state.status, AuthStatus.authenticated);
      expect(authNotifier.state.user?.fullName, 'Chann Vathana');
      expect(authNotifier.state.user?.phoneNumber, '+855 98 765 432');
    });
  });
}
