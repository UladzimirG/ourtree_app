// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'video_converter_model.dart';

const bool videoConversionSupported = true;

const html.EventStreamProvider<html.BlobEvent> _dataEvent =
    html.EventStreamProvider<html.BlobEvent>('dataavailable');
const html.EventStreamProvider<html.Event> _stopEvent =
    html.EventStreamProvider<html.Event>('stop');

/// Перекодирует видео в поддерживаемый браузером контейнер (MediaRecorder).
///
/// Сначала пробуем MP4/H.264: его понимают и мобильные платформы. Если браузер
/// не умеет записывать MP4, остаётся WebM — родной формат для веба.
Future<VideoConversionResult?> convertVideoToSupportedFormat(
  Uint8List bytes, {
  String? name,
  void Function(double progress)? onProgress,
}) async {
  final sourceUrl = html.Url.createObjectUrlFromBlob(
    html.Blob([bytes.buffer], _mime(name ?? 'video.mp4')),
  );
  final video = html.VideoElement()
    ..src = sourceUrl
    ..muted = true
    ..autoplay = false
    ..controls = false
    ..style.display = 'none';
  html.document.body?.append(video);

  html.MediaStream? stream;
  html.MediaRecorder? recorder;
  StreamSubscription<html.Event>? dataSub;
  StreamSubscription<html.Event>? stopSub;

  try {
    await video.onLoadedMetadata.first;
    stream = video.captureStream();
    final format = _supportedFormat();
    recorder = html.MediaRecorder(stream, {'mimeType': format.mimeType});
    final chunks = <html.Blob>[];
    final stopped = Completer<void>();

    dataSub = _dataEvent.forTarget(recorder).listen((event) {
      if (event.data != null && event.data!.size > 0) {
        chunks.add(event.data!);
      }
    });
    stopSub = _stopEvent.forTarget(recorder).listen((_) {
      if (!stopped.isCompleted) stopped.complete();
    });

    recorder.start(500);
    await video.play();
    final seconds = video.duration.isFinite ? video.duration : 0;
    final totalMs = seconds * 1000;
    if (totalMs > 0) {
      video.onTimeUpdate.listen((_) {
        onProgress?.call(
          (((video.currentTime * 1000) / totalMs).clamp(0.0, 1.0)).toDouble(),
        );
      });
    }
    await Future.any([
      video.onEnded.first,
      video.onError.first,
      Future<void>.delayed(
        Duration(seconds: seconds.ceil() + 10),
      ),
    ]);
    recorder.stop();
    await stopped.future.timeout(const Duration(seconds: 15));
    if (chunks.isEmpty) return null;

    final output = html.Blob(chunks, format.mimeType);
    final converted = await _blobBytes(output);
    onProgress?.call(1);
    return VideoConversionResult(
      bytes: converted,
      extension: format.extension,
      mimeType: format.mimeType,
    );
  } catch (_) {
    return null;
  } finally {
    await dataSub?.cancel();
    await stopSub?.cancel();
    try {
      recorder?.stop();
    } catch (_) {
      // Рекордер уже остановлен.
    }
    try {
      video.pause();
      video.remove();
    } catch (_) {
      // Элемент уже удалён.
    }
    html.Url.revokeObjectUrl(sourceUrl);
    stream?.getTracks().forEach((track) => track.stop());
  }
}

Future<Uint8List> _blobBytes(html.Blob blob) {
  final completer = Completer<Uint8List>();
  final reader = html.FileReader();
  reader.onLoadEnd.first.then((_) {
    final result = reader.result;
    if (result is ByteBuffer) {
      completer.complete(Uint8List.view(result));
    } else if (result is Uint8List) {
      completer.complete(result);
    } else {
      completer.complete(Uint8List(0));
    }
  });
  reader.onError.first.then((_) {
    if (!completer.isCompleted) completer.complete(Uint8List(0));
  });
  reader.readAsArrayBuffer(blob);
  return completer.future;
}

_RecordingFormat _supportedFormat() {
  const candidates = <_RecordingFormat>[
    _RecordingFormat(
      'video/mp4;codecs=avc1.42E01E,mp4a.40.2',
      'mp4',
    ),
    _RecordingFormat('video/mp4', 'mp4'),
    _RecordingFormat('video/webm;codecs=vp9,opus', 'webm'),
    _RecordingFormat('video/webm;codecs=vp8,opus', 'webm'),
    _RecordingFormat('video/webm', 'webm'),
  ];
  for (final format in candidates) {
    if (html.MediaRecorder.isTypeSupported(format.mimeType)) return format;
  }
  return const _RecordingFormat('video/webm', 'webm');
}

class _RecordingFormat {
  const _RecordingFormat(this.mimeType, this.extension);

  final String mimeType;
  final String extension;
}

String _mime(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.mov')) return 'video/quicktime';
  if (lower.endsWith('.mkv')) return 'video/x-matroska';
  if (lower.endsWith('.avi')) return 'video/x-msvideo';
  if (lower.endsWith('.webm')) return 'video/webm';
  return 'video/mp4';
}
