import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Celebratory Luxury Badge
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.luxuryBeigeLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 46,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'ORDER CONFIRMED',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order #$orderId',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.luxuryBeigeDark,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for shopping at KALIP studio.\nYour order has been received by our Phnom Penh Atelier and is being prepared with our signature packaging.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Estimated Delivery Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.borderLight, width: 0.8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: AppColors.primaryBlack, size: 24),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimated Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(height: 2),
                          Text('Same-day in Phnom Penh • Express 2-4 Hours', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              ElevatedButton(
                onPressed: () => context.go('/order-details/$orderId'),
                child: const Text('TRACK ORDER STATUS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/'),
                child: const Text('CONTINUE SHOPPING', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
