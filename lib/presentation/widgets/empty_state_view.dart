import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';
import 'package:style_house/core/theme/app_typography.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.luxuryBeigeLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primaryBlack),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTypography.headline(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
