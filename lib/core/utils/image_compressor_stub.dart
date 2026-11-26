import 'dart:convert';
import 'dart:typed_data';

/// Non-web fallback: ImagePicker natively compresses mobile images via maxWidth/imageQuality.
Future<String> compressImageToDataUri(
  Uint8List bytes, {
  String mimeType = 'image/jpeg',
  int maxDimension = 760,
  double quality = 0.78,
}) async {
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}
