
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Output of preprocessing: a flat float32 buffer in NHWC order.
class PreprocessedImage {
  const PreprocessedImage({
    required this.data,
    required this.width,
    required this.height,
    required this.sourceWidth,
    required this.sourceHeight,
  });

  final Float32List data;
  final int width;
  final int height;
  final int sourceWidth;
  final int sourceHeight;
}

class ImagePreprocessorConfig {
  const ImagePreprocessorConfig({
    this.width = 224,
    this.height = 224,
    this.scale = 1.0,
    this.offset = 0.0,
    this.centerCrop = true,
  });

  final int width;
  final int height;

  /// pixel * scale + offset. Our MobileNetV3 export includes its own scaling,
  /// so the default feeds raw 0–255 values.
  final double scale;
  final double offset;

  /// Centre-crop to a square before resizing (instead of letterboxing).
  final bool centerCrop;
}

/// Decodes a photo and converts it to the tensor layout the CV model expects.
///
/// Pipeline: decode → bake EXIF orientation → centre crop → resize → float.
/// Runs on a background isolate via [run] so decoding large camera photos
/// never janks the UI.
class ImagePreprocessor {
  const ImagePreprocessor([this.config = const ImagePreprocessorConfig()]);

  final ImagePreprocessorConfig config;

  /// Preprocess on a background isolate.
  Future<PreprocessedImage> run(Uint8List bytes) =>
      compute(_preprocess, _Job(bytes, config));

  /// Synchronous variant for tests and small images.
  PreprocessedImage runSync(Uint8List bytes) => _preprocess(_Job(bytes, config));

  static PreprocessedImage _preprocess(_Job job) {
    final cfg = job.config;
    img.Image? decoded;
    try {
      decoded = img.decodeImage(job.bytes);
    } catch (_) {
      decoded = null;
    }
    if (decoded == null) {
      throw const FormatException('Unsupported or corrupt image');
    }
    decoded = img.bakeOrientation(decoded);
    final sw = decoded.width, sh = decoded.height;

    img.Image work = decoded;
    if (cfg.centerCrop && sw != sh) {
      final side = sw < sh ? sw : sh;
      work = img.copyCrop(
        work,
        x: (sw - side) ~/ 2,
        y: (sh - side) ~/ 2,
        width: side,
        height: side,
      );
    }
    if (work.width != cfg.width || work.height != cfg.height) {
      work = img.copyResize(
        work,
        width: cfg.width,
        height: cfg.height,
        interpolation: img.Interpolation.linear,
      );
    }

    final out = Float32List(cfg.width * cfg.height * 3);
    var i = 0;
    for (var y = 0; y < cfg.height; y++) {
      for (var x = 0; x < cfg.width; x++) {
        final px = work.getPixel(x, y);
        out[i++] = px.r * cfg.scale + cfg.offset;
        out[i++] = px.g * cfg.scale + cfg.offset;
        out[i++] = px.b * cfg.scale + cfg.offset;
      }
    }
    return PreprocessedImage(
      data: out,
      width: cfg.width,
      height: cfg.height,
      sourceWidth: sw,
      sourceHeight: sh,
    );
  }
}

class _Job {
  const _Job(this.bytes, this.config);
  final Uint8List bytes;
  final ImagePreprocessorConfig config;
}
