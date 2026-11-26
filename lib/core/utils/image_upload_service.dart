import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'image_compressor_stub.dart'
    if (dart.library.js_interop) 'image_compressor_web.dart' as compressor;

class UploadedImageResult {
  final String dataUri;
  final int approxBytes;
  final String fileName;

  const UploadedImageResult({
    required this.dataUri,
    required this.approxBytes,
    required this.fileName,
  });

  String get formattedSizeKb => '${(approxBytes / 1024).ceil()} KB';
}

/// 100% Free local & web product photo upload service.
/// Picks images from device gallery, computer files, or camera, auto-optimizes
/// resolution & JPEG quality, and encodes to a portable Data URI stored for free.
class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();

  static String _inferMimeType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  static int estimateDataUriBytes(String dataUri) {
    final commaIdx = dataUri.indexOf(',');
    if (commaIdx == -1) return dataUri.length;
    final b64Len = dataUri.length - commaIdx - 1;
    return (b64Len * 3) ~/ 4;
  }

  /// Picks a single photo from Gallery/Files or Camera and optimizes it.
  static Future<UploadedImageResult?> pickSingleImage({
    ImageSource source = ImageSource.gallery,
    int maxDimension = 760,
    double quality = 0.78,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: maxDimension.toDouble(),
        maxHeight: (maxDimension * 1.25).toDouble(),
        imageQuality: (quality * 100).round(),
      );
      if (picked == null) return null;
      return await _processXFile(picked, maxDimension: maxDimension, quality: quality);
    } catch (_) {
      return null;
    }
  }

  /// Picks multiple product photos at once from Gallery/Files and optimizes each.
  static Future<List<UploadedImageResult>> pickMultipleImages({
    int maxDimension = 760,
    double quality = 0.78,
    int limit = 5,
  }) async {
    try {
      final pickedList = await _picker.pickMultiImage(
        maxWidth: maxDimension.toDouble(),
        maxHeight: (maxDimension * 1.25).toDouble(),
        imageQuality: (quality * 100).round(),
        limit: limit,
      );
      if (pickedList.isEmpty) return [];
      final results = <UploadedImageResult>[];
      for (final file in pickedList.take(limit)) {
        final processed = await _processXFile(
          file,
          maxDimension: maxDimension,
          quality: quality,
        );
        if (processed != null) {
          results.add(processed);
        }
      }
      return results;
    } catch (_) {
      // Fallback to single picker on platforms without multi-select support
      final single = await pickSingleImage(maxDimension: maxDimension, quality: quality);
      return single != null ? [single] : [];
    }
  }

  static Future<UploadedImageResult?> _processXFile(
    XFile file, {
    required int maxDimension,
    required double quality,
  }) async {
    final Uint8List rawBytes = await file.readAsBytes();
    if (rawBytes.isEmpty) return null;

    final mime = _inferMimeType(file.name);
    final dataUri = await compressor.compressImageToDataUri(
      rawBytes,
      mimeType: mime,
      maxDimension: maxDimension,
      quality: quality,
    );

    return UploadedImageResult(
      dataUri: dataUri,
      approxBytes: estimateDataUriBytes(dataUri),
      fileName: file.name,
    );
  }

  /// Directly encodes raw bytes for testing or clipboard/drag-drop flows.
  static Future<UploadedImageResult> encodeBytes(
    Uint8List bytes, {
    String fileName = 'product.jpg',
    int maxDimension = 760,
    double quality = 0.78,
  }) async {
    final mime = _inferMimeType(fileName);
    final dataUri = await compressor.compressImageToDataUri(
      bytes,
      mimeType: mime,
      maxDimension: maxDimension,
      quality: quality,
    );
    return UploadedImageResult(
      dataUri: dataUri,
      approxBytes: estimateDataUriBytes(dataUri),
      fileName: fileName,
    );
  }

  static bool get supportsCamera => !kIsWeb;
}
