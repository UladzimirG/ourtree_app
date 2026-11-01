// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Редактируемые настройки семьи.

@ProviderFor(FamilySettingsNotifier)
final familySettingsProvider = FamilySettingsNotifierProvider._();

/// Редактируемые настройки семьи.
final class FamilySettingsNotifierProvider
    extends $AsyncNotifierProvider<FamilySettingsNotifier, FamilySettings> {
  /// Редактируемые настройки семьи.
  FamilySettingsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'familySettingsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$familySettingsNotifierHash();

  @$internal
  @override
  FamilySettingsNotifier create() => FamilySettingsNotifier();
}

String _$familySettingsNotifierHash() =>
    r'747cf76a50656968c760751d075ce4859ba01c21';

/// Редактируемые настройки семьи.

abstract class _$FamilySettingsNotifier extends $AsyncNotifier<FamilySettings> {
  FutureOr<FamilySettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FamilySettings>, FamilySettings>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<FamilySettings>, FamilySettings>,
        AsyncValue<FamilySettings>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
