import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(bool isKhmer) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isKhmer ? 'ចូលគណនីបានជោគជ័យ' : 'Signed in successfully'),
          backgroundColor: AppColors.primaryBlack,
        ),
      );
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(localizationProvider);
    final isKhmer = tr.isKhmer;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKhmer ? 'ចូលគណនី' : 'SIGN IN',
          style: isKhmer
              ? AppTypography.headline(isKhmer: isKhmer)
              : const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'KALIP studio',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isKhmer ? 'ភាពប្រណីតទាន់សម័យ • ភ្នំពេញ' : 'TIMELESS ELEGANCE • PHNOM PENH',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.luxuryBeigeDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                Text(
                  isKhmer ? 'សូមស្វាគមន៍មកកាន់ KALIP studio' : 'Welcome to KALIP studio',
                  style: AppTypography.headline(isKhmer: isKhmer),
                ),
                const SizedBox(height: 6),
                Text(
                  isKhmer
                      ? 'បញ្ចូលអ៊ីមែល និងពាក្យសម្ងាត់ដើម្បីគ្រប់គ្រងការបញ្ជាទិញរបស់អ្នក។'
                      : 'Sign in to access your saved wishlist, orders, and exclusive privileges.',
                  style: AppTypography.bodySmall(isKhmer: isKhmer, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),

                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(20),
                      border: Border.all(color: AppColors.error.withAlpha(80)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(fontSize: 12, color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: isKhmer ? 'អ៊ីមែល *' : 'Email Address *',
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                    hintText: 'name@example.com',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter email';
                    if (!val.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: isKhmer ? 'ពាក្យសម្ងាត់ *' : 'Password *',
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter password' : null,
                ),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text(
                      isKhmer ? 'ភ្លេចពាក្យសម្ងាត់?' : 'Forgot Password?',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign In Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : () => _handleLogin(isKhmer),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pureWhite),
                        )
                      : Text(
                          isKhmer ? 'ចូលគណនី' : 'SIGN IN',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                ),

                const SizedBox(height: 24),
                const Divider(),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isKhmer ? 'មិនទាន់មានគណនីមែនទេ?' : "Don't have an account?",
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: Text(
                        isKhmer ? 'ចុះឈ្មោះឥឡូវនេះ' : 'Create Account',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                // Continue as guest
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).continueAsGuest();
                      context.go('/');
                    },
                    child: Text(
                      isKhmer ? 'បន្តជាភ្ញៀវសិន' : 'Continue as Guest',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
