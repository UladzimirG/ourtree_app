// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Разовая выгрузка всех локальных файлов семьи в Firebase Storage.

@ProviderFor(BulkUploadController)
final bulkUploadControllerProvider = BulkUploadControllerProvider._();

/// Разовая выгрузка всех локальных файлов семьи в Firebase Storage.
final class BulkUploadControllerProvider
    extends $NotifierProvider<BulkUploadController, BulkUploadState> {
  /// Разовая выгрузка всех локальных файлов семьи в Firebase Storage.
  BulkUploadControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bulkUploadControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bulkUploadControllerHash();

  @$internal
  @override
  BulkUploadController create() => BulkUploadController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BulkUploadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BulkUploadState>(value),
    );
  }
}

String _$bulkUploadControllerHash() =>
    r'923f2df6299cc68a46a763bbfce2dc3caa74a708';

/// Разовая выгрузка всех локальных файлов семьи в Firebase Storage.

abstract class _$BulkUploadController extends $Notifier<BulkUploadState> {
  BulkUploadState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BulkUploadState, BulkUploadState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BulkUploadState, BulkUploadState>,
        BulkUploadState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
