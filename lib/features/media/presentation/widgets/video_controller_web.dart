// Для blob-URL нужен dart:html; на Flutter Web это по-прежнему рабочий путь.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:video_player/video_player.dart';
import 'video_controller_model.dart';

/// В браузере байты превращаются в blob-URL, который понимает video-элемент.
Future<PreparedVideo> prepareVideo(
  String source,
  Uint8List? bytes,
  String? name,
) async {
  if (bytes != null) {
    final blob = html.Blob([bytes], _mime(name ?? source));
    final url = html.Url.createObjectUrlFromBlob(blob);
    return PreparedVideo(
      controller: VideoPlayerController.networkUrl(Uri.parse(url)),
      cleanup: () async => html.Url.revokeObjectUrl(url),
    );
  }

  if (source.startsWith('http://') || source.startsWith('https://')) {
    return PreparedVideo(
      controller: VideoPlayerController.networkUrl(Uri.parse(source)),
    );
  }

  return const PreparedVideo(controller: null);
}

String _mime(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('.webm')) return 'video/webm';
  if (lower.contains('.mov')) return 'video/quicktime';
  return 'video/mp4';
}
