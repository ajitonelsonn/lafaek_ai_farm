import 'dart:typed_data';

/// What the analysis screen receives: a captured photo (bytes) or a bundled
/// sample asset path when no camera is available.
class ScanRequest {
  const ScanRequest({this.bytes, this.assetPath, this.sourceLabel = 'Camera'});

  final Uint8List? bytes;
  final String? assetPath;

  /// "Camera", "Gallery" or "Sample photo" — shown on the analysis screen.
  final String sourceLabel;

  bool get isSample => bytes == null && assetPath != null;
}
