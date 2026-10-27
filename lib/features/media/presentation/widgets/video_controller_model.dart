import 'package:video_player/video_player.dart';

/// Подготовленный источник для `video_player`.
class PreparedVideo {
  const PreparedVideo({
    required this.controller,
    this.cleanup,
  });

  final VideoPlayerController? controller;

  /// Удаляет временный файл/blob после освобождения контроллера.
  final Future<void> Function()? cleanup;
}
