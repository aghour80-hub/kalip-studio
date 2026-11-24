import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';
import 'package:style_house/data/models/user_model.dart';
import 'package:style_house/data/services/supabase_auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.authenticated, // Default to VIP guest profile for seamless shopping
    this.user = const UserModel(
      id: 'vip-001',
      email: 'vip.member@stylehouse.com.kh',
      fullName: 'VIP Fashion Member',
      phoneNumber: '+855 (0) 92 888 999',
      role: UserRole.customer,
    ),
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseAuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final raw = prefs.getString(AppConstants.keyUserProfile);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final user = UserModel.fromJson(map);
        if (mounted) {
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
        }
      }
    } catch (_) {}
  }

  Future<void> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? email,
  }) async {
    final current = state.user;
    if (current == null) return;
    final updated = current.copyWith(
      fullName: fullName.trim().isNotEmpty ? fullName.trim() : current.fullName,
      phoneNumber: phoneNumber?.trim(),
      email: email != null && email.trim().isNotEmpty ? email.trim() : current.email,
    );
    state = state.copyWith(status: AuthStatus.authenticated, user: updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyUserProfile, jsonEncode(updated.toJson()));
    } catch (_) {}
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _authService.signIn(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
    );
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void continueAsGuest() {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: const UserModel(
        id: 'guest-guest',
        email: 'guest@stylehouse.com.kh',
        fullName: 'Guest Shopper',
        phoneNumber: '+855 00 000 000',
        role: UserRole.customer,
      ),
    );
  }

  void toggleAdminRole() {
    if (state.user == null) return;
    final isCurrentlyAdmin = state.user!.isAdmin;
    final newRole = isCurrentlyAdmin ? UserRole.customer : UserRole.admin;
    state = state.copyWith(
      user: state.user!.copyWith(role: newRole),
    );
  }
}

final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});
