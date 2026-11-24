import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';

class LuxuryImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const LuxuryImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: AppColors.shimmerBase,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.luxuryBeige),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: AppColors.warmSand,
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.textMuted,
          size: 28,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
