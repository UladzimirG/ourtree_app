import 'package:ourtree_app/features/media/data/repositories/cloud_media_store.dart';
import 'package:ourtree_app/features/media/data/repositories/media_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_provider.g.dart';

/// Хранилище медиа в Firebase Storage; подменяется в тестах.
@Riverpod(keepAlive: true)
CloudMediaStore cloudMediaStore(Ref ref) => FirebaseCloudMediaStore();

/// Загрузка файлов в облако (локальная копия + Storage).
@Riverpod(keepAlive: true)
MediaRepository mediaRepository(Ref ref) =>
    MediaRepository(cloud: ref.watch(cloudMediaStoreProvider));
