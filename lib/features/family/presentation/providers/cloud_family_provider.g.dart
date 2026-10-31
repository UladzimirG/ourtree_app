// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloud_family_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Хранилище семей в облаке; подменяется в тестах.

@ProviderFor(cloudFamilyStore)
final cloudFamilyStoreProvider = CloudFamilyStoreProvider._();

/// Хранилище семей в облаке; подменяется в тестах.

final class CloudFamilyStoreProvider extends $FunctionalProvider<
    CloudFamilyStore,
    CloudFamilyStore,
    CloudFamilyStore> with $Provider<CloudFamilyStore> {
  /// Хранилище семей в облаке; подменяется в тестах.
  CloudFamilyStoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cloudFamilyStoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cloudFamilyStoreHash();

  @$internal
  @override
  $ProviderElement<CloudFamilyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CloudFamilyStore create(Ref ref) {
    return cloudFamilyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudFamilyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudFamilyStore>(value),
    );
  }
}

String _$cloudFamilyStoreHash() => r'57fd02e1f8999a2be4ead134ae5ba656b021c87e';

/// Удаление данных семьи из облака; подменяется в тестах.

@ProviderFor(familyCleanupService)
final familyCleanupServiceProvider = FamilyCleanupServiceProvider._();

/// Удаление данных семьи из облака; подменяется в тестах.

final class FamilyCleanupServiceProvider extends $FunctionalProvider<
    FamilyCleanupService,
    FamilyCleanupService,
    FamilyCleanupService> with $Provider<FamilyCleanupService> {
  /// Удаление данных семьи из облака; подменяется в тестах.
  FamilyCleanupServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'familyCleanupServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$familyCleanupServiceHash();

  @$internal
  @override
  $ProviderElement<FamilyCleanupService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FamilyCleanupService create(Ref ref) {
    return familyCleanupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyCleanupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyCleanupService>(value),
    );
  }
}

String _$familyCleanupServiceHash() =>
    r'5ea996d9ec976db9207002320a627dd63ba83355';

/// Хранилище кодов приглашений; подменяется в тестах.

@ProviderFor(inviteStore)
final inviteStoreProvider = InviteStoreProvider._();

/// Хранилище кодов приглашений; подменяется в тестах.

final class InviteStoreProvider
    extends $FunctionalProvider<InviteStore, InviteStore, InviteStore>
    with $Provider<InviteStore> {
  /// Хранилище кодов приглашений; подменяется в тестах.
  InviteStoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inviteStoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inviteStoreHash();

  @$internal
  @override
  $ProviderElement<InviteStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InviteStore create(Ref ref) {
    return inviteStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InviteStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InviteStore>(value),
    );
  }
}

String _$inviteStoreHash() => r'a07670af55b8ec14c8df3eaf599579a544db5114';

/// Семья, открытая на этом устройстве.
///
/// `null` — режим демо-архива (семья ещё не создана/не выбрана). Именно это
/// состояние отделяет локальный демо-контент от облачного.

@ProviderFor(ActiveFamilyController)
final activeFamilyControllerProvider = ActiveFamilyControllerProvider._();

/// Семья, открытая на этом устройстве.
///
/// `null` — режим демо-архива (семья ещё не создана/не выбрана). Именно это
/// состояние отделяет локальный демо-контент от облачного.
final class ActiveFamilyControllerProvider
    extends $AsyncNotifierProvider<ActiveFamilyController, FamilyModel?> {
  /// Семья, открытая на этом устройстве.
  ///
  /// `null` — режим демо-архива (семья ещё не создана/не выбрана). Именно это
  /// состояние отделяет локальный демо-контент от облачного.
  ActiveFamilyControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeFamilyControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeFamilyControllerHash();

  @$internal
  @override
  ActiveFamilyController create() => ActiveFamilyController();
}

String _$activeFamilyControllerHash() =>
    r'872aa7bfa8d0b9dbc8b8f181acf0a255a081d779';

/// Семья, открытая на этом устройстве.
///
/// `null` — режим демо-архива (семья ещё не создана/не выбрана). Именно это
/// состояние отделяет локальный демо-контент от облачного.

abstract class _$ActiveFamilyController extends $AsyncNotifier<FamilyModel?> {
  FutureOr<FamilyModel?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FamilyModel?>, FamilyModel?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<FamilyModel?>, FamilyModel?>,
        AsyncValue<FamilyModel?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
