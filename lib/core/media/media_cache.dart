import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Кэш сетевых медиа: «скачали один раз, дальше открываем с диска».
///
/// Ключ кэша — SHA-256 содержимого (`MediaAsset.cacheKey`), поэтому файл
/// никогда не меняется под тем же ключом и инвалидация не нужна.
/// На web файлового кэша нет — там работает браузерный HTTP-кэш.
class MediaCache {
  MediaCache._();

  static const String key = 'ourtree_media';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 800,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
