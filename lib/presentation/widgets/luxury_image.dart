import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/theme/app_colors.dart';

/// Renders product and boutique images seamlessly across:
/// 1) Free uploaded Data URIs (`data:image/...;base64,...`) with in-memory decode cache
/// 2) Local bundled assets (`assets/...`)
/// 3) Remote HTTPS URLs (`CachedNetworkImage`)
class LuxuryImage extends StatelessWidget {
  static final Map<String, Uint8List> _decodedCache = <String, Uint8List>{};

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

  static bool isDataUri(String url) => url.startsWith('data:image/');
  static bool isAssetPath(String url) => url.startsWith('assets/');

  static Uint8List? _decodeDataUri(String dataUri) {
    final cached = _decodedCache[dataUri];
    if (cached != null) return cached;

    try {
      final commaIndex = dataUri.indexOf(',');
      if (commaIndex == -1) return null;
      final bytes = base64Decode(dataUri.substring(commaIndex + 1));
      if (_decodedCache.length >= 80) {
        _decodedCache.remove(_decodedCache.keys.first);
      }
      _decodedCache[dataUri] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.warmSand,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textMuted,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget;

    if (isDataUri(imageUrl)) {
      final bytes = _decodeDataUri(imageUrl);
      if (bytes != null) {
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _buildErrorPlaceholder(),
        );
      } else {
        imageWidget = _buildErrorPlaceholder();
      }
    } else if (isAssetPath(imageUrl)) {
      imageWidget = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _buildErrorPlaceholder(),
      );
    } else {
      imageWidget = CachedNetworkImage(
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
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
