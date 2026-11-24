import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';

class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTypography.headline(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(160, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
