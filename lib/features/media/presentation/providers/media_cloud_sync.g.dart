// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_cloud_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Догружает локальные файлы в облако, как только семья подключена.
///
/// Раньше для этого нужно было вручную нажать «Загрузить всё локальное»: фото,
/// добавленные до создания или подключения семьи, оставались только на этом
/// устройстве и не появлялись в общем архиве.

@ProviderFor(MediaCloudSync)
final mediaCloudSyncProvider = MediaCloudSyncProvider._();

/// Догружает локальные файлы в облако, как только семья подключена.
///
/// Раньше для этого нужно было вручную нажать «Загрузить всё локальное»: фото,
/// добавленные до создания или подключения семьи, оставались только на этом
/// устройстве и не появлялись в общем архиве.
final class MediaCloudSyncProvider
    extends $NotifierProvider<MediaCloudSync, bool> {
  /// Догружает локальные файлы в облако, как только семья подключена.
  ///
  /// Раньше для этого нужно было вручную нажать «Загрузить всё локальное»: фото,
  /// добавленные до создания или подключения семьи, оставались только на этом
  /// устройстве и не появлялись в общем архиве.
  MediaCloudSyncProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mediaCloudSyncProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaCloudSyncHash();

  @$internal
  @override
  MediaCloudSync create() => MediaCloudSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mediaCloudSyncHash() => r'b3e66bcbf32f1ea1cb4ea639550ee11b6a4dc05b';

/// Догружает локальные файлы в облако, как только семья подключена.
///
/// Раньше для этого нужно было вручную нажать «Загрузить всё локальное»: фото,
/// добавленные до создания или подключения семьи, оставались только на этом
/// устройстве и не появлялись в общем архиве.

abstract class _$MediaCloudSync extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
