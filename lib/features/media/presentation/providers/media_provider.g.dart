// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Хранилище медиа в Firebase Storage; подменяется в тестах.

@ProviderFor(cloudMediaStore)
final cloudMediaStoreProvider = CloudMediaStoreProvider._();

/// Хранилище медиа в Firebase Storage; подменяется в тестах.

final class CloudMediaStoreProvider extends $FunctionalProvider<CloudMediaStore,
    CloudMediaStore, CloudMediaStore> with $Provider<CloudMediaStore> {
  /// Хранилище медиа в Firebase Storage; подменяется в тестах.
  CloudMediaStoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cloudMediaStoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cloudMediaStoreHash();

  @$internal
  @override
  $ProviderElement<CloudMediaStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudMediaStore create(Ref ref) {
    return cloudMediaStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudMediaStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudMediaStore>(value),
    );
  }
}

String _$cloudMediaStoreHash() => r'2b1dc1f2a6fe5f1471237306c3d5c642de08208f';

/// Загрузка файлов в облако (локальная копия + Storage).

@ProviderFor(mediaRepository)
final mediaRepositoryProvider = MediaRepositoryProvider._();

/// Загрузка файлов в облако (локальная копия + Storage).

final class MediaRepositoryProvider extends $FunctionalProvider<MediaRepository,
    MediaRepository, MediaRepository> with $Provider<MediaRepository> {
  /// Загрузка файлов в облако (локальная копия + Storage).
  MediaRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mediaRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaRepositoryHash();

  @$internal
  @override
  $ProviderElement<MediaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaRepository create(Ref ref) {
    return mediaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaRepository>(value),
    );
  }
}

String _$mediaRepositoryHash() => r'ec38ebaa4ef31448dfcd586f23289e8d919d1ad3';
