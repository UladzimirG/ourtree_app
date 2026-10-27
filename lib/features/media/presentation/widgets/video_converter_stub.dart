import 'dart:typed_data';

import 'video_converter_model.dart';

/// Конвертация недоступна только на платформах без FFmpeg и браузера.
const bool videoConversionSupported = false;

Future<VideoConversionResult?> convertVideoToSupportedFormat(
  Uint8List bytes, {
  String? name,
  void Function(double progress)? onProgress,
}) async =>
    null;
