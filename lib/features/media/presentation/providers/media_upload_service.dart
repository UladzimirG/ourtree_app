import 'dart:typed_data';

import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/utils/ids.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/domain/models/media_outbox_item.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_outbox_provider.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_progress_provider.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_provider.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_upload_service.g.dart';

/// Единая точка сохранения выбранного пользователем файла.
///
/// Если семья подключена — файл уходит в Firebase Storage и в архив пишется
/// облачный ассет. В демо-режиме (или без входа) файл остаётся в Hive и
/// доступен только на этом устройстве — об этом обязательно сообщаем в UI.
@Riverpod(keepAlive: true)
class MediaUploadService extends _$MediaUploadService {
  @override
  bool build() {
    // Значение = «облако доступно»; пересчитывается при смене семьи/входа.
    final family = ref.watch(activeFamilyControllerProvider).value;
    final identity = ref.watch(identityControllerProvider).value;
    return family != null && identity != null && identity.isSignedIn;
  }

  /// `true`, если новые файлы будут синхронизированы (семья подключена).
  bool get isCloudEnabled => state;

  /// Сохраняет байты и возвращает готовый ассет.
  Future<MediaAsset> store({
    required Uint8List bytes,
    required String name,
    required String hash,
    MediaType type = MediaType.image,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final family = ref.read(activeFamilyControllerProvider).value;
    final identity = ref.read(identityControllerProvider).value;

    if (family != null && identity != null && identity.isSignedIn) {
      final assetId = newMediaAssetId();
      final progress = ref.read(mediaUploadProgressProvider.notifier);
      try {
        return await ref.read(mediaRepositoryProvider).uploadAsset(
              asset: MediaAsset(
                id: assetId,
                source: '',
                type: type,
                name: name,
                createdAt: now,
                size: bytes.length,
                hash: hash,
                uploadState: MediaUploadState.uploading,
              ),
              bytes: bytes,
              familyId: family.id,
              userId: identity.userId,
              extension: type.isVideo ? 'mp4' : 'jpg',
              onProgress: (value) => progress.setProgress(assetId, value),
            );
      } catch (_) {
        // Нет сети или облако недоступно: файл остаётся локально,
        // а операция попадает в очередь и отправится сама при связи.
        final storedId = await MediaStorage.instance.saveBytes(
          bytes,
          name: name,
        );
        final asset = MediaAsset(
          id: 'asset-$storedId',
          source: 'hive://$storedId',
          type: type,
          name: name,
          createdAt: now,
          size: bytes.length,
          hash: hash,
          uploadState: MediaUploadState.queued,
        );

        await ref.read(mediaOutboxControllerProvider.notifier).enqueue(
              MediaOutboxItem(
                assetId: asset.id,
                familyId: family.id,
                userId: identity.userId,
                name: name,
                type: type,
                extension: type.isVideo ? 'mp4' : 'jpg',
                hash: hash,
                size: bytes.length,
                storedId: storedId,
                createdAt: now,
              ),
            );

        return asset;
      } finally {
        progress.clear(assetId);
      }
    }

    final storedId = await MediaStorage.instance.saveBytes(bytes, name: name);
    return MediaAsset(
      id: 'asset-$storedId',
      source: 'hive://$storedId',
      type: type,
      name: name,
      createdAt: now,
      size: bytes.length,
      hash: hash,
    );
  }
}
