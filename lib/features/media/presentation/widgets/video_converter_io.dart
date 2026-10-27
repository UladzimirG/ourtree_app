import 'dart:typed_data';

import 'video_converter_model.dart';

/// На мобильных/desktop для конвертации нужен FFmpeg, которого пока нет.
const bool videoConversionSupported = false;

Future<VideoConversionResult?> convertVideoToWebm(
  Uint8List bytes, {
  String? name,
  void Function(double progress)? onProgress,
}) async =>
    null;
