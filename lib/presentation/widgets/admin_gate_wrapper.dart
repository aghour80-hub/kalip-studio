import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/presentation/providers/admin_auth_provider.dart';

/// Wraps administrative screens with a password protection gate for the Store Owner.
class AdminGateWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String sectionTitle;

  const AdminGateWrapper({
    super.key,
    required this.child,
    this.sectionTitle = 'Owner Portal',
  });

  @override
  ConsumerState<AdminGateWrapper> createState() => _AdminGateWrapperState();
}

class _AdminGateWrapperState extends ConsumerState<AdminGateWrapper> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptUnlock(bool isKhmer) {
    final input = _passwordController.text;
    if (input.trim().isEmpty) {
      setState(() {
        _errorMessage = isKhmer
            ? 'សូមបញ្ចូលពាក្យសម្ងាត់ម្ចាស់ហាង'
            : 'Vui lòng nhập mật khẩu Chủ hàng (Enter owner password)';
      });
      return;
    }

    final ok = ref.read(adminAuthProvider.notifier).unlockWithPassword(input);
    if (ok) {
      _passwordController.clear();
      setState(() => _errorMessage = null);
    } else {
      final attempts = ref.read(adminAuthProvider).failedAttempts;
      setState(() {
        _errorMessage = isKhmer
            ? 'ពាក្យសម្ងាត់មិនត្រឹមត្រូវ (សាកល្បងលើកទី $attempts)'
            : 'Mật khẩu không đúng (Sai lần $attempts)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthProvider);
    final isKhmer = ref.watch(localizationProvider).isKhmer;

    if (authState.isUnlocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColors.canvasLinen,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          tooltip: 'Back to Boutique',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          isKhmer ? 'សោសុវត្ថិភាពម្ចាស់ហាង' : 'OWNER SECURITY GATE',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlack,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: AppColors.luxuryBeige,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'KALIP studio',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.0,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isKhmer
                        ? 'ច្រកចូលគ្រប់គ្រងម្ចាស់ហាង • ${widget.sectionTitle}'
                        : 'CỔNG QUẢN TRỊ CHỦ HÀNG • ${widget.sectionTitle.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                      color: AppColors.luxuryBeigeDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isKhmer
                        ? 'តំបន់នេះត្រូវបានការពារដោយពាក្យសម្ងាត់។ សូមបញ្ចូលលេខកូដសម្ងាត់ដើម្បីកែតម្លៃ គ្រប់គ្រងស្តុក និងមើលការបញ្ជាទិញ។'
                        : 'Khu vực riêng tư cho Chủ hàng. Nhập mật khẩu để mở khóa quản lý giá cả, kho hàng, đơn hàng và cài đặt.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Default Password Info Banner (only shown while using factory default)
                  if (authState.isUsingDefaultPassword) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.luxuryBeigeLight,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AppColors.luxuryBeige),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.key_outlined, size: 18, color: AppColors.primaryBlack),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isKhmer
                                  ? 'លេខកូដសម្ងាត់ដំបូង: 123456\nសូមប្តូរពាក្យសម្ងាត់ថ្មីនៅក្នុង Admin Dashboard បន្ទាប់ពីចូល។'
                                  : 'Mật khẩu mặc định lần đầu: 123456\nBạn có thể đổi mật khẩu riêng sau khi mở khóa vào trong.',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlack,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _attemptUnlock(isKhmer),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: isKhmer ? 'ពាក្យសម្ងាត់ម្ចាស់ហាង *' : 'Mật khẩu Chủ hàng (Owner Password) *',
                      prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      errorText: _errorMessage,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.lock_open, size: 18),
                      label: Text(
                        isKhmer ? 'បើកសោគ្រប់គ្រង' : 'MỞ KHÓA QUẢN LÝ (UNLOCK)',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 12),
                      ),
                      onPressed: () => _attemptUnlock(isKhmer),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: Text(
                        isKhmer ? 'ត្រឡប់ទៅហាងវិញ' : 'Về cửa hàng (Return to Boutique)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => context.go('/'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
