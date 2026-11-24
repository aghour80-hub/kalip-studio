import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:style_house/core/constants/app_constants.dart';

class AdminAuthState {
  final String ownerPassword;
  final bool isUnlocked;
  final int failedAttempts;
  final bool isInitialized;

  const AdminAuthState({
    this.ownerPassword = AppConstants.defaultAdminPassword,
    this.isUnlocked = false,
    this.failedAttempts = 0,
    this.isInitialized = false,
  });

  bool get isUsingDefaultPassword => ownerPassword == AppConstants.defaultAdminPassword;

  AdminAuthState copyWith({
    String? ownerPassword,
    bool? isUnlocked,
    int? failedAttempts,
    bool? isInitialized,
  }) {
    return AdminAuthState(
      ownerPassword: ownerPassword ?? this.ownerPassword,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Manages store owner password security and portal lock/unlock session.
class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  AdminAuthNotifier() : super(const AdminAuthState()) {
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final saved = prefs.getString(AppConstants.keyAdminPassword);
      if (saved != null && saved.isNotEmpty) {
        state = state.copyWith(ownerPassword: saved, isInitialized: true);
        return;
      }
    } catch (_) {}
    if (mounted) {
      state = state.copyWith(isInitialized: true);
    }
  }

  bool unlockWithPassword(String inputPassword) {
    final trimmed = inputPassword.trim();
    if (trimmed == state.ownerPassword) {
      state = state.copyWith(isUnlocked: true, failedAttempts: 0);
      return true;
    } else {
      state = state.copyWith(
        isUnlocked: false,
        failedAttempts: state.failedAttempts + 1,
      );
      return false;
    }
  }

  void lockPortal() {
    state = state.copyWith(isUnlocked: false, failedAttempts: 0);
  }

  /// Validates current password, updates and persists the new owner password.
  /// Returns null on success, or an error string on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.trim() != state.ownerPassword) {
      return 'Mật khẩu hiện tại không đúng (Incorrect current password)';
    }
    final cleanNew = newPassword.trim();
    if (cleanNew.length < 4) {
      return 'Mật khẩu mới phải từ 4 ký tự trở lên (Minimum 4 characters)';
    }
    if (!mounted) return null;
    state = state.copyWith(ownerPassword: cleanNew);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAdminPassword, cleanNew);
    } catch (_) {}
    return null;
  }

  Future<void> resetToDefaultPassword() async {
    if (!mounted) return;
    state = state.copyWith(ownerPassword: AppConstants.defaultAdminPassword);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAdminPassword, AppConstants.defaultAdminPassword);
    } catch (_) {}
  }
}

final adminAuthProvider =
    StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) {
  return AdminAuthNotifier();
});
