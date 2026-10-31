import 'dart:typed_data';

import 'package:ourtree_app/core/media/media_files.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/media/domain/media_pending.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_progress_provider.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bulk_upload_provider.g.dart';

/// Прогресс массовой выгрузки локальных файлов в облако.
class BulkUploadState {
  const BulkUploadState({
    this.total = 0,
    this.done = 0,
    this.failed = 0,
    this.running = false,
  });

  final int total;
  final int done;
  final int failed;
  final bool running;

  int get processed => done + failed;

  bool get isComplete => !running && total > 0 && processed >= total;

  BulkUploadState copyWith({
    int? total,
    int? done,
    int? failed,
    bool? running,
  }) =>
      BulkUploadState(
        total: total ?? this.total,
        done: done ?? this.done,
        failed: failed ?? this.failed,
        running: running ?? this.running,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulkUploadState &&
          total == other.total &&
          done == other.done &&
          failed == other.failed &&
          running == other.running;

  @override
  int get hashCode => Object.hash(total, done, failed, running);
}

/// Разовая выгрузка всех локальных файлов семьи в Firebase Storage.
@Riverpod(keepAlive: true)
class BulkUploadController extends _$BulkUploadController {
  @override
  BulkUploadState build() => const BulkUploadState();

  /// Сколько файлов ждёт выгрузки прямо сейчас.
  int pendingCount() {
    final family = ref.read(familyDataProvider).value;
    if (family == null) return 0;
    return pendingCloudUploads(family.mediaLibrary).length;
  }

  /// Загружает все локальные файлы по очереди.
  ///
  /// Последовательно, чтобы не держать в памяти десятки мегабайт: видео
  /// читается и отправляется по одному файлу.
  Future<BulkUploadState> uploadPending() async {
    if (state.running) return state;

    final family = ref.read(activeFamilyControllerProvider).value;
    final identity = ref.read(identityControllerProvider).value;
    final data = ref.read(familyDataProvider).value;
    if (family == null || identity == null || data == null) {
      return state;
    }

    final pending = pendingCloudUploads(data.mediaLibrary);
    if (pending.isEmpty) {
      state = const BulkUploadState();
      return state;
    }

    state = BulkUploadState(total: pending.length, running: true);

    var done = 0;
    var failed = 0;
    for (final asset in pending) {
      try {
        final bytes = await _readBytes(asset);
        if (bytes == null || bytes.isEmpty) {
          failed++;
        } else {
          final updated = await ref.read(mediaRepositoryProvider).uploadAsset(
                asset: asset,
                bytes: bytes,
                familyId: family.id,
                userId: identity.userId,
                extension: asset.isVideo ? 'mp4' : 'jpg',
                onProgress: (value) => ref
                    .read(mediaUploadProgressProvider.notifier)
                    .setProgress(asset.id, value),
              );
          ref
              .read(mediaUploadProgressProvider.notifier)
              .clear(asset.id);
          ref.read(familyDataProvider.notifier).upsertMediaAsset(updated);
          done++;
        }
      } catch (_) {
        ref.read(mediaUploadProgressProvider.notifier).clear(asset.id);
        failed++;
      }
      state = BulkUploadState(
        total: pending.length,
        done: done,
        failed: failed,
        running: true,
      );
    }

    state = BulkUploadState(
      total: pending.length,
      done: done,
      failed: failed,
    );
    return state;
  }

  Future<Uint8List?> _readBytes(MediaAsset asset) async {
    final storedId = asset.storedId;
    if (storedId != null) {
      return MediaStorage.instance.loadBytes(storedId);
    }
    final localPath = asset.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      return MediaFiles.instance.read(localPath);
    }
    return null;
  }
}
