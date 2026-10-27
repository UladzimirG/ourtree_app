import 'dart:typed_data';

import 'package:video_player/video_player.dart';
import 'video_controller_model.dart';

/// Запасной вариант для платформ без файловой системы/веба.
Future<PreparedVideo> prepareVideo(
  String source,
  Uint8List? bytes,
  String? name,
) async {
  if (bytes != null) {
    return const PreparedVideo(
      controller: null,
      error: 'Local video bytes are not supported on this platform.',
    );
  }
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return PreparedVideo(
      controller: VideoPlayerController.networkUrl(Uri.parse(source)),
    );
  }
  return const PreparedVideo(
    controller: null,
    error: 'Unsupported video source.',
  );
}
