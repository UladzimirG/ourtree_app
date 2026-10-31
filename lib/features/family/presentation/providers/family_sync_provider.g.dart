// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Хранилище текстового состояния семьи; подменяется в тестах.

@ProviderFor(cloudFamilyStateStore)
final cloudFamilyStateStoreProvider = CloudFamilyStateStoreProvider._();

/// Хранилище текстового состояния семьи; подменяется в тестах.

final class CloudFamilyStateStoreProvider extends $FunctionalProvider<
    CloudFamilyStateStore,
    CloudFamilyStateStore,
    CloudFamilyStateStore> with $Provider<CloudFamilyStateStore> {
  /// Хранилище текстового состояния семьи; подменяется в тестах.
  CloudFamilyStateStoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cloudFamilyStateStoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cloudFamilyStateStoreHash();

  @$internal
  @override
  $ProviderElement<CloudFamilyStateStore> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudFamilyStateStore create(Ref ref) {
    return cloudFamilyStateStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudFamilyStateStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudFamilyStateStore>(value),
    );
  }
}

String _$cloudFamilyStateStoreHash() =>
    r'dcc9a17228aadb48650b16063a39da889c71eb8f';

/// Синхронизация архива с Firestore по сущностям.
///
/// При подключении семьи забираем серверную копию и **сливаем** её с локальной:
/// для каждого человека, события и медиафайла побеждает более свежая отметка
/// времени. Удаления передаются через tombstones (`entityDeletedAt`), поэтому
/// удалённое на телефоне не «воскресает» на планшете.

@ProviderFor(FamilySyncController)
final familySyncControllerProvider = FamilySyncControllerProvider._();

/// Синхронизация архива с Firestore по сущностям.
///
/// При подключении семьи забираем серверную копию и **сливаем** её с локальной:
/// для каждого человека, события и медиафайла побеждает более свежая отметка
/// времени. Удаления передаются через tombstones (`entityDeletedAt`), поэтому
/// удалённое на телефоне не «воскресает» на планшете.
final class FamilySyncControllerProvider
    extends $NotifierProvider<FamilySyncController, SyncStatus> {
  /// Синхронизация архива с Firestore по сущностям.
  ///
  /// При подключении семьи забираем серверную копию и **сливаем** её с локальной:
  /// для каждого человека, события и медиафайла побеждает более свежая отметка
  /// времени. Удаления передаются через tombstones (`entityDeletedAt`), поэтому
  /// удалённое на телефоне не «воскресает» на планшете.
  FamilySyncControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'familySyncControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$familySyncControllerHash();

  @$internal
  @override
  FamilySyncController create() => FamilySyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$familySyncControllerHash() =>
    r'00ecc081cdab31bed4b3f3197bd27f4a867b21e6';

/// Синхронизация архива с Firestore по сущностям.
///
/// При подключении семьи забираем серверную копию и **сливаем** её с локальной:
/// для каждого человека, события и медиафайла побеждает более свежая отметка
/// времени. Удаления передаются через tombstones (`entityDeletedAt`), поэтому
/// удалённое на телефоне не «воскресает» на планшете.

abstract class _$FamilySyncController extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncStatus, SyncStatus>, SyncStatus, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
