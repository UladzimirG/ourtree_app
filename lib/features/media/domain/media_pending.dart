import 'package:ourtree_app/features/media/domain/models/media_asset.dart';

/// Нужен ли файлу аплоад в облако.
///
/// Считаем «ждущими» только локальные файлы: свои загрузки из Hive (`hive://`)
/// и файлы на диске (`localPath`). Демо-ассеты (`/photos/...`) и уже
/// загруженные облачные файлы (есть `storagePath`) не трогаем.
bool needsCloudUpload(MediaAsset asset) {
  final storagePath = asset.storagePath;
  if (storagePath != null && storagePath.isNotEmpty) return false;
  if (asset.uploadState == MediaUploadState.ready) return false;
  return asset.isStored || asset.isLocalFile;
}

/// Список файлов, которые ещё не в облаке.
List<MediaAsset> pendingCloudUploads(Iterable<MediaAsset> assets) =>
    assets.where(needsCloudUpload).toList(growable: false);
