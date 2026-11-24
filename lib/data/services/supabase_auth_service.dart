import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:style_house/core/config/supabase_config.dart';
import 'package:style_house/data/models/user_model.dart';

class SupabaseAuthService {
  final SupabaseClient? _client = SupabaseConfig.client;

  bool get isAvailable => _client != null;

  User? get currentAuthUser => _client?.auth.currentUser;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    if (_client == null || SupabaseConfig.isMockMode) {
      // Offline / Mock fallback
      await Future.delayed(const Duration(milliseconds: 600));
      return UserModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber ?? '+855 92 888 999',
        role: UserRole.customer,
      );
    }

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone_number': phoneNumber,
      },
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Registration failed: User could not be created');
    }

    return UserModel(
      id: user.id,
      email: user.email ?? email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      role: UserRole.customer,
    );
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (_client == null || SupabaseConfig.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return UserModel(
        id: 'usr-vip-cambodia',
        email: email,
        fullName: 'Seng Hour (Dr-Creep)',
        phoneNumber: '+855 92 888 999',
        role: UserRole.customer,
      );
    }

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Login failed: Invalid credentials');
    }

    // Fetch profile from public.profiles
    final profileData = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profileData != null) {
      return UserModel.fromJson({
        ...profileData,
        'email': user.email,
      });
    }

    return UserModel(
      id: user.id,
      email: user.email ?? email,
      fullName: user.userMetadata?['full_name'] as String? ?? 'VIP Member',
      phoneNumber: user.userMetadata?['phone_number'] as String?,
    );
  }

  Future<void> signOut() async {
    if (_client != null && !SupabaseConfig.isMockMode) {
      await _client.auth.signOut();
    }
  }

  Future<void> resetPassword(String email) async {
    if (_client != null && !SupabaseConfig.isMockMode) {
      await _client.auth.resetPasswordForEmail(email);
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }
}
