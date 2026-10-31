// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Прогресс выгрузки конкретного файла: `assetId -> 0..1`.
///
/// Живёт только в памяти: после завершения записи удаляется.

@ProviderFor(MediaUploadProgress)
final mediaUploadProgressProvider = MediaUploadProgressProvider._();

/// Прогресс выгрузки конкретного файла: `assetId -> 0..1`.
///
/// Живёт только в памяти: после завершения записи удаляется.
final class MediaUploadProgressProvider
    extends $NotifierProvider<MediaUploadProgress, Map<String, double>> {
  /// Прогресс выгрузки конкретного файла: `assetId -> 0..1`.
  ///
  /// Живёт только в памяти: после завершения записи удаляется.
  MediaUploadProgressProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mediaUploadProgressProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaUploadProgressHash();

  @$internal
  @override
  MediaUploadProgress create() => MediaUploadProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$mediaUploadProgressHash() =>
    r'b10aa0a7a17629b6f17c4e6e1768190b2c7f9a34';

/// Прогресс выгрузки конкретного файла: `assetId -> 0..1`.
///
/// Живёт только в памяти: после завершения записи удаляется.

abstract class _$MediaUploadProgress extends $Notifier<Map<String, double>> {
  Map<String, double> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, double>, Map<String, double>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, double>, Map<String, double>>,
        Map<String, double>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
