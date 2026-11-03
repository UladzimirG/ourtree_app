// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Единая точка сохранения выбранного пользователем файла.
///
/// Если семья подключена — файл уходит в Firebase Storage и в архив пишется
/// облачный ассет. В демо-режиме (или без входа) файл остаётся в Hive и
/// доступен только на этом устройстве — об этом обязательно сообщаем в UI.

@ProviderFor(MediaUploadService)
final mediaUploadServiceProvider = MediaUploadServiceProvider._();

/// Единая точка сохранения выбранного пользователем файла.
///
/// Если семья подключена — файл уходит в Firebase Storage и в архив пишется
/// облачный ассет. В демо-режиме (или без входа) файл остаётся в Hive и
/// доступен только на этом устройстве — об этом обязательно сообщаем в UI.
final class MediaUploadServiceProvider
    extends $NotifierProvider<MediaUploadService, bool> {
  /// Единая точка сохранения выбранного пользователем файла.
  ///
  /// Если семья подключена — файл уходит в Firebase Storage и в архив пишется
  /// облачный ассет. В демо-режиме (или без входа) файл остаётся в Hive и
  /// доступен только на этом устройстве — об этом обязательно сообщаем в UI.
  MediaUploadServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mediaUploadServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaUploadServiceHash();

  @$internal
  @override
  MediaUploadService create() => MediaUploadService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mediaUploadServiceHash() =>
    r'550d3e8df6dca2519d270ccd99194446d2637b11';

/// Единая точка сохранения выбранного пользователем файла.
///
/// Если семья подключена — файл уходит в Firebase Storage и в архив пишется
/// облачный ассет. В демо-режиме (или без входа) файл остаётся в Hive и
/// доступен только на этом устройстве — об этом обязательно сообщаем в UI.

abstract class _$MediaUploadService extends $Notifier<bool> {
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
