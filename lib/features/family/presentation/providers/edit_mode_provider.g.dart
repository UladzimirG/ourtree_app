// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Может ли текущий пользователь редактировать содержимое семьи.
///
/// Локальный владелец устройства и администраторы — да, редакторы — да,
/// наблюдатели — нет.

@ProviderFor(canEditContent)
final canEditContentProvider = CanEditContentProvider._();

/// Может ли текущий пользователь редактировать содержимое семьи.
///
/// Локальный владелец устройства и администраторы — да, редакторы — да,
/// наблюдатели — нет.

final class CanEditContentProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Может ли текущий пользователь редактировать содержимое семьи.
  ///
  /// Локальный владелец устройства и администраторы — да, редакторы — да,
  /// наблюдатели — нет.
  CanEditContentProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'canEditContentProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canEditContentHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canEditContent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canEditContentHash() => r'73a303b033683ae8a93ba0aeec723af63cded6c9';

/// Ручной переключатель режима редактирования.

@ProviderFor(EditModeController)
final editModeControllerProvider = EditModeControllerProvider._();

/// Ручной переключатель режима редактирования.
final class EditModeControllerProvider
    extends $NotifierProvider<EditModeController, bool> {
  /// Ручной переключатель режима редактирования.
  EditModeControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'editModeControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$editModeControllerHash();

  @$internal
  @override
  EditModeController create() => EditModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$editModeControllerHash() =>
    r'eed628c4c846e0ad3c5d948f3ee4ee442944b1ed';

/// Ручной переключатель режима редактирования.

abstract class _$EditModeController extends $Notifier<bool> {
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

/// Итоговый режим редактирования: включён пользователем и разрешён ролью.
///
/// Если во время работы войти аккаунтом наблюдателя, режим автоматически
/// выключается, даже если флаг остался включённым.

@ProviderFor(editMode)
final editModeProvider = EditModeProvider._();

/// Итоговый режим редактирования: включён пользователем и разрешён ролью.
///
/// Если во время работы войти аккаунтом наблюдателя, режим автоматически
/// выключается, даже если флаг остался включённым.

final class EditModeProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Итоговый режим редактирования: включён пользователем и разрешён ролью.
  ///
  /// Если во время работы войти аккаунтом наблюдателя, режим автоматически
  /// выключается, даже если флаг остался включённым.
  EditModeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'editModeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$editModeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return editMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$editModeHash() => r'2a4b5a001596a153e6ed6589cd20609013bf1064';
