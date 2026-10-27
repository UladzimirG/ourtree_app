import 'dart:typed_data';

import 'video_converter_model.dart';

/// Конвертация доступна только в веб-версии (MediaRecorder).
const bool videoConversionSupported = false;

Future<VideoConversionResult?> convertVideoToWebm(
  Uint8List bytes, {
  String? name,
  void Function(double progress)? onProgress,
}) async =>
    null;
