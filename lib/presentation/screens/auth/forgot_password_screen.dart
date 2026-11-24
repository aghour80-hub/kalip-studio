import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).resetPassword(_emailController.text.trim());
    setState(() => _isSubmitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKhmer ? 'កំណត់ពាក្យសម្ងាត់ឡើងវិញ' : 'RESET PASSWORD',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _isSubmitted
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 56, color: AppColors.luxuryBeige),
                    const SizedBox(height: 16),
                    Text(
                      isKhmer ? 'បានផ្ញើតំណភ្ជាប់រួចរាល់' : 'Password Reset Email Sent',
                      style: AppTypography.headline(isKhmer: isKhmer),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isKhmer
                          ? 'យើងខ្ញុំបានផ្ញើតំណភ្ជាប់កំណត់ពាក្យសម្ងាត់ឡើងវិញទៅកាន់ ${_emailController.text}។ សូមពិនិត្យមើលប្រអប់សំបុត្ររបស់អ្នក។'
                          : 'We have sent a password reset link to ${_emailController.text}. Please check your inbox.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: Text(isKhmer ? 'ត្រឡប់ទៅចូលគណនី' : 'Back to Sign In'),
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isKhmer ? 'ភ្លេចពាក្យសម្ងាត់របស់អ្នកមែនទេ?' : 'Reset Your Password',
                      style: AppTypography.headline(isKhmer: isKhmer),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isKhmer
                          ? 'សូមបញ្ចូលអ៊ីមែលដែលបានចុះឈ្មោះ។ យើងខ្ញុំនឹងផ្ញើតំណភ្ជាប់ដើម្បីបង្កើតពាក្យសម្ងាត់ថ្មី។'
                          : 'Enter your registered email address and we will send you instructions to reset your password.',
                      style: AppTypography.bodySmall(isKhmer: isKhmer, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: isKhmer ? 'អ៊ីមែល *' : 'Email Address *',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter email';
                        if (!val.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(
                        isKhmer ? 'ផ្ញើតំណភ្ជាប់' : 'SEND RESET LINK',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
