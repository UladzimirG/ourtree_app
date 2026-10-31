import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_progress_provider.g.dart';

/// Прогресс выгрузки конкретного файла: `assetId -> 0..1`.
///
/// Живёт только в памяти: после завершения записи удаляется.
@Riverpod(keepAlive: true)
class MediaUploadProgress extends _$MediaUploadProgress {
  @override
  Map<String, double> build() => const <String, double>{};

  void setProgress(String assetId, double value) {
    state = {...state, assetId: value.clamp(0, 1)};
  }

  void clear(String assetId) {
    if (!state.containsKey(assetId)) return;
    final next = Map<String, double>.of(state)..remove(assetId);
    state = next;
  }
}
