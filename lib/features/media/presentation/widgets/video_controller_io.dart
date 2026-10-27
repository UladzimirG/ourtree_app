import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'video_controller_model.dart';

/// Пишет байты во временный файл: мобильные плееры не умеют data-URI.
Future<PreparedVideo> prepareVideo(
  String source,
  Uint8List? bytes,
  String? name,
) async {
  if (bytes != null) {
    final dir = await getTemporaryDirectory();
    final extension = _extension(name ?? source);
    final file = File(
      '${dir.path}/video-${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    await file.writeAsBytes(bytes, flush: true);
    return PreparedVideo(
      controller: VideoPlayerController.file(file),
      cleanup: () async {
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {
          // Временный файл не критичен.
        }
      },
    );
  }

  if (source.startsWith('http://') || source.startsWith('https://')) {
    return PreparedVideo(
      controller: VideoPlayerController.networkUrl(Uri.parse(source)),
    );
  }

  return const PreparedVideo(controller: null);
}

String _extension(String name) {
  final lower = name.toLowerCase();
  for (final extension in ['.mp4', '.webm', '.mov', '.m4v', '.avi', '.mkv']) {
    if (lower.contains(extension)) return extension;
  }
  return '.mp4';
}
