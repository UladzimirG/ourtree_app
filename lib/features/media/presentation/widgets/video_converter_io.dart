import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'video_converter_model.dart';

/// На Android, iOS, macOS, Windows и Linux конвертация идёт через FFmpeg.
const bool videoConversionSupported = true;

/// Перекодирует видео в MP4 (H.264 + AAC).
///
/// MP4/H.264 воспроизводится на Android, iOS, macOS, Windows и Linux,
/// поэтому именно этот формат хранится в медиатеке на не-веб-платформах.
Future<VideoConversionResult?> convertVideoToSupportedFormat(
  Uint8List bytes, {
  String? name,
  void Function(double progress)? onProgress,
}) async {
  if (bytes.isEmpty) return null;

  final tempRoot = await getTemporaryDirectory();
  final workDir = await Directory(
    p.join(
      tempRoot.path,
      'ourtree-video-${DateTime.now().microsecondsSinceEpoch}',
    ),
  ).create(recursive: true);

  final inputPath = p.join(workDir.path, 'source${_extension(name)}');
  final outputPath = p.join(workDir.path, 'output.mp4');

  try {
    await File(inputPath).writeAsBytes(bytes, flush: true);
    onProgress?.call(0);

    final session = await FFmpegKit.executeWithArguments(<String>[
      '-y',
      '-hide_banner',
      '-loglevel',
      'error',
      '-i',
      inputPath,
      '-map',
      '0:v:0?',
      '-map',
      '0:a:0?',
      // H.264 требует чётных размеров кадра.
      '-vf',
      'scale=trunc(iw/2)*2:trunc(ih/2)*2',
      '-c:v',
      'libx264',
      '-preset',
      'veryfast',
      '-crf',
      '23',
      '-pix_fmt',
      'yuv420p',
      '-c:a',
      'aac',
      '-b:a',
      '160k',
      '-movflags',
      '+faststart',
      outputPath,
    ]);

    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) return null;

    final output = File(outputPath);
    if (!await output.exists()) return null;
    final converted = await output.readAsBytes();
    if (converted.isEmpty) return null;

    onProgress?.call(1);
    return VideoConversionResult(
      bytes: converted,
      extension: 'mp4',
      mimeType: 'video/mp4',
    );
  } catch (_) {
    return null;
  } finally {
    try {
      if (await workDir.exists()) await workDir.delete(recursive: true);
    } catch (_) {
      // Временные файлы не критичны: система очистит их сама.
    }
  }
}

String _extension(String? name) {
  final extension = p.extension(name ?? '').toLowerCase();
  if (extension.length < 2 || extension.length > 8) return '.video';
  return extension;
}
