// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Текущий выбранный раздел главного экрана.

@ProviderFor(HomeTabController)
final homeTabControllerProvider = HomeTabControllerProvider._();

/// Текущий выбранный раздел главного экрана.
final class HomeTabControllerProvider
    extends $NotifierProvider<HomeTabController, HomeTab> {
  /// Текущий выбранный раздел главного экрана.
  HomeTabControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeTabControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeTabControllerHash();

  @$internal
  @override
  HomeTabController create() => HomeTabController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeTab>(value),
    );
  }
}

String _$homeTabControllerHash() => r'ed8387a2f24e71173655fd9b8101b3af05de300d';

/// Текущий выбранный раздел главного экрана.

abstract class _$HomeTabController extends $Notifier<HomeTab> {
  HomeTab build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeTab, HomeTab>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<HomeTab, HomeTab>, HomeTab, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Репозиторий, из которого читаются данные семьи.

@ProviderFor(familyRepository)
final familyRepositoryProvider = FamilyRepositoryProvider._();

/// Репозиторий, из которого читаются данные семьи.

final class FamilyRepositoryProvider extends $FunctionalProvider<
    FamilyRepository,
    FamilyRepository,
    FamilyRepository> with $Provider<FamilyRepository> {
  /// Репозиторий, из которого читаются данные семьи.
  FamilyRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'familyRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$familyRepositoryHash();

  @$internal
  @override
  $ProviderElement<FamilyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FamilyRepository create(Ref ref) {
    return familyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FamilyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FamilyRepository>(value),
    );
  }
}

String _$familyRepositoryHash() => r'300e9458eb346961eb6a5f2723d876b6782b08d2';

/// Изменяемое состояние семейного древа.

@ProviderFor(FamilyDataNotifier)
final familyDataProvider = FamilyDataNotifierProvider._();

/// Изменяемое состояние семейного древа.
final class FamilyDataNotifierProvider
    extends $AsyncNotifierProvider<FamilyDataNotifier, FamilyData> {
  /// Изменяемое состояние семейного древа.
  FamilyDataNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'familyDataProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$familyDataNotifierHash();

  @$internal
  @override
  FamilyDataNotifier create() => FamilyDataNotifier();
}

String _$familyDataNotifierHash() =>
    r'7b566fed03c82d929879c2963a9db75536a52220';

/// Изменяемое состояние семейного древа.

abstract class _$FamilyDataNotifier extends $AsyncNotifier<FamilyData> {
  FutureOr<FamilyData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FamilyData>, FamilyData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<FamilyData>, FamilyData>,
        AsyncValue<FamilyData>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
