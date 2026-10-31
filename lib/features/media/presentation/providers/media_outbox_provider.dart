import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ourtree_app/core/media/media_files.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/media/data/media_outbox.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/domain/models/media_outbox_item.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_progress_provider.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_outbox_provider.g.dart';

/// Поток изменений сети — для автоповтора очереди.
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityChanges(Ref ref) =>
    Connectivity().onConnectivityChanged;

/// Очередь выгрузки медиа: постановка, автоповтор, ручной retry.
@Riverpod(keepAlive: true)
class MediaOutboxController extends _$MediaOutboxController {
  final MediaOutbox _outbox = MediaOutbox();
  bool _processing = false;

  @override
  List<MediaOutboxItem> build() {
    // Как только сеть появилась — пробуем отправить накопленное.
    ref.listen(connectivityChangesProvider, (previous, next) {
      final results = next.value;
      if (results == null) return;
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(processQueue());
      }
    });

    // И при старте приложения тоже.
    Future<void>.microtask(processQueue);
    return _outbox.load();
  }

  int get pendingCount => state.length;

  /// Ставит файл в очередь и сразу пытается отправить.
  Future<void> enqueue(MediaOutboxItem item) async {
    state = await _outbox.add(item);
    await processQueue();
  }

  /// Отправляет всё, что накопилось. Ошибки не прерывают очередь.
  Future<void> processQueue() async {
    if (_processing) return;

    final family = ref.read(activeFamilyControllerProvider).value;
    final identity = ref.read(identityControllerProvider).value;
    if (family == null || identity == null) return;

    _processing = true;
    try {
      var items = _outbox.load();
      for (final item in List<MediaOutboxItem>.of(items)) {
        try {
          final bytes = await _readBytes(item);
          if (bytes == null || bytes.isEmpty) {
            // Байтов больше нет — операция бессмысленна.
            items = await _outbox.remove(item.assetId);
            continue;
          }

          final uploaded = await ref.read(mediaRepositoryProvider).uploadAsset(
                asset: MediaAsset(
                  id: item.assetId,
                  source: item.storedId == null
                      ? ''
                      : 'hive://${item.storedId}',
                  type: item.type,
                  name: item.name,
                  createdAt: item.createdAt,
                  size: item.size,
                  hash: item.hash,
                  uploadState: MediaUploadState.queued,
                ),
                bytes: bytes,
                familyId: item.familyId,
                userId: item.userId,
                extension: item.extension,
                onProgress: (value) => ref
                    .read(mediaUploadProgressProvider.notifier)
                    .setProgress(item.assetId, value),
              );
          ref
              .read(mediaUploadProgressProvider.notifier)
              .clear(item.assetId);

          ref.read(familyDataProvider.notifier).upsertMediaAsset(uploaded);
          items = await _outbox.remove(item.assetId);
        } catch (error) {
          ref
              .read(mediaUploadProgressProvider.notifier)
              .clear(item.assetId);
          items = await _outbox.replace(
            item.copyWith(
              attempts: item.attempts + 1,
              lastError: () => error.toString(),
            ),
          );
        }
      }
      state = items;
    } finally {
      _processing = false;
    }
  }

  Future<Uint8List?> _readBytes(MediaOutboxItem item) async {
    final storedId = item.storedId;
    if (storedId != null) {
      return MediaStorage.instance.loadBytes(storedId);
    }
    final localPath = item.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      return MediaFiles.instance.read(localPath);
    }
    return null;
  }
}
