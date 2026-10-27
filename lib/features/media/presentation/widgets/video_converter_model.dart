import 'dart:typed_data';

/// Результат конвертации видео.
class VideoConversionResult {
  const VideoConversionResult({
    required this.bytes,
    required this.extension,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String extension;
  final String mimeType;
}
