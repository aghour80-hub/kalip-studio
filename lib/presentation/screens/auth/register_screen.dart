import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';
import 'package:style_house/presentation/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(bool isKhmer) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isKhmer ? 'ចុះឈ្មោះបានជោគជ័យ' : 'Account created successfully!'),
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
          isKhmer ? 'បង្កើតគណនី' : 'CREATE ACCOUNT',
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
                        isKhmer ? 'ចូលរួមជាសមាជិក VIP' : 'JOIN THE ATELIER CIRCLE',
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
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                ],

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: isKhmer ? 'ឈ្មោះពេញ *' : 'Full Name *',
                    prefixIcon: const Icon(Icons.person_outline, size: 18),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 14),

                // Email
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
                const SizedBox(height: 14),

                // Phone (Cambodia)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: isKhmer ? 'លេខទូរស័ព្ទ (កម្ពុជា)' : 'Phone Number (Cambodia)',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                    hintText: '092 xxx xxx',
                  ),
                ),
                const SizedBox(height: 14),

                // Password
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
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter password';
                    if (val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Register Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : () => _handleRegister(isKhmer),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pureWhite),
                        )
                      : Text(
                          isKhmer ? 'ចុះឈ្មោះគណនី' : 'CREATE ACCOUNT',
                          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                ),

                const SizedBox(height: 20),
                const Divider(),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isKhmer ? 'មានគណនីរួចហើយ?' : 'Already have an account?',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        isKhmer ? 'ចូលគណនី' : 'Sign In',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
