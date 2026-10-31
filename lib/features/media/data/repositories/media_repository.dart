import 'dart:typed_data';

import 'package:ourtree_app/core/media/media_files.dart';
import 'package:ourtree_app/core/utils/ids.dart';
import 'package:ourtree_app/features/media/data/repositories/cloud_media_store.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';

/// Оркестрация загрузки медиа: локальная копия → Firebase Storage.
///
/// Репозиторий не знает про Riverpod и Firestore-документы: он возвращает
/// обновлённый [MediaAsset], а запись в архив делает вызывающая сторона.
class MediaRepository {
  MediaRepository({CloudMediaStore? cloud, MediaFiles? files})
      : _cloud = cloud ?? FirebaseCloudMediaStore(),
        _files = files ?? MediaFiles.instance;

  final CloudMediaStore _cloud;
  final MediaFiles _files;

  /// Сохраняет локальную копию и выгружает файл в Storage.
  ///
  /// Возвращает ассет с `localPath`, `storagePath`, `downloadUrl` и
  /// `uploadState = ready`. `source` заменяется на download URL, чтобы
  /// существующий рендер сразу показывал файл из облака.
  Future<MediaAsset> uploadAsset({
    required MediaAsset asset,
    required Uint8List bytes,
    required String familyId,
    required String userId,
    String extension = 'jpg',
    String? contentType,
    void Function(double progress)? onProgress,
  }) async {
    final assetId = asset.id.isEmpty ? newMediaAssetId() : asset.id;
    final fileName = 'original.$extension';

    final localPath = await _files.save(assetId, bytes, extension: extension);

    final result = await _cloud.upload(
      familyId: familyId,
      assetId: assetId,
      bytes: bytes,
      fileName: fileName,
      contentType: contentType ?? (asset.isVideo ? 'video/mp4' : 'image/jpeg'),
      onProgress: onProgress,
    );

    return asset.copyWith(
      id: assetId,
      source: result.downloadUrl,
      localPath: () => localPath,
      storagePath: () => result.storagePath,
      downloadUrl: () => result.downloadUrl,
      uploadState: MediaUploadState.ready,
      uploadedBy: () => userId,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Удаляет объект из Storage и локальную копию файла.
  Future<void> deleteAsset(MediaAsset asset) async {
    final storagePath = asset.storagePath;
    if (storagePath != null && storagePath.isNotEmpty) {
      await _cloud.delete(storagePath);
    }
    await _files.delete(asset.localPath);
  }
}
