import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';

import 'video_converter_stub.dart'
    if (dart.library.io) 'video_converter_io.dart'
    if (dart.library.html) 'video_converter_web.dart';

/// Файл, готовый к сохранению в медиатеке.
class PreparedMediaUpload {
  const PreparedMediaUpload({
    required this.bytes,
    required this.name,
    required this.type,
  });

  final Uint8List bytes;
  final String name;
  final MediaType type;
}

/// Приводит видео к формату, который воспроизводится на текущей платформе.
///
/// Фото возвращаются без изменений. Для видео, которое не удалось
/// подготовить, возвращается `null` — вызывающая сторона показывает ошибку.
Future<PreparedMediaUpload?> prepareMediaUpload(
  Uint8List bytes,
  String name, {
  void Function(double progress)? onProgress,
}) async {
  final isVideo = isVideoMediaName(name);
  if (!isVideo || !videoConversionSupported) {
    return PreparedMediaUpload(
      bytes: bytes,
      name: name,
      type: isVideo ? MediaType.video : MediaType.image,
    );
  }

  final result = await convertVideoToSupportedFormat(
    bytes,
    name: name,
    onProgress: onProgress,
  );
  if (result == null || result.bytes.isEmpty) return null;

  final base = p.basenameWithoutExtension(name).trim();
  final safeBase = base.isEmpty ? 'video' : base;
  return PreparedMediaUpload(
    bytes: result.bytes,
    name: '$safeBase.${result.extension}',
    type: MediaType.video,
  );
}

bool isVideoMediaName(String name) {
  final lower = name.toLowerCase();
  return ['.mp4', '.webm', '.mov', '.m4v', '.avi', '.mkv'].any(lower.endsWith);
}

MediaType mediaTypeForName(String name) =>
    isVideoMediaName(name) ? MediaType.video : MediaType.image;
