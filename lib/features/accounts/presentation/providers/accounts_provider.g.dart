// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Изменяемый список учётных записей семейного альбома.
///
/// Аккаунты и права хранятся в Hive и переживают перезапуск приложения.

@ProviderFor(AccountsNotifier)
final accountsProvider = AccountsNotifierProvider._();

/// Изменяемый список учётных записей семейного альбома.
///
/// Аккаунты и права хранятся в Hive и переживают перезапуск приложения.
final class AccountsNotifierProvider
    extends $AsyncNotifierProvider<AccountsNotifier, List<Account>> {
  /// Изменяемый список учётных записей семейного альбома.
  ///
  /// Аккаунты и права хранятся в Hive и переживают перезапуск приложения.
  AccountsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountsNotifierHash();

  @$internal
  @override
  AccountsNotifier create() => AccountsNotifier();
}

String _$accountsNotifierHash() => r'2fd773bfe0ac1fe5612243f4316ec4eed6104c21';

/// Изменяемый список учётных записей семейного альбома.
///
/// Аккаунты и права хранятся в Hive и переживают перезапуск приложения.

abstract class _$AccountsNotifier extends $AsyncNotifier<List<Account>> {
  FutureOr<List<Account>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Account>>, List<Account>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Account>>, List<Account>>,
        AsyncValue<List<Account>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Текущий пользователь; `null` — локальный администратор устройства.

@ProviderFor(CurrentAccountId)
final currentAccountIdProvider = CurrentAccountIdProvider._();

/// Текущий пользователь; `null` — локальный администратор устройства.
final class CurrentAccountIdProvider
    extends $NotifierProvider<CurrentAccountId, String?> {
  /// Текущий пользователь; `null` — локальный администратор устройства.
  CurrentAccountIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentAccountIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentAccountIdHash();

  @$internal
  @override
  CurrentAccountId create() => CurrentAccountId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentAccountIdHash() => r'0cd3ced1507e887a60b41c7d4e3d6f49d72bae57';

/// Текущий пользователь; `null` — локальный администратор устройства.

abstract class _$CurrentAccountId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Аккаунт, от имени которого сейчас работает интерфейс.

@ProviderFor(currentAccount)
final currentAccountProvider = CurrentAccountProvider._();

/// Аккаунт, от имени которого сейчас работает интерфейс.

final class CurrentAccountProvider
    extends $FunctionalProvider<Account?, Account?, Account?>
    with $Provider<Account?> {
  /// Аккаунт, от имени которого сейчас работает интерфейс.
  CurrentAccountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentAccountProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentAccountHash();

  @$internal
  @override
  $ProviderElement<Account?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Account? create(Ref ref) {
    return currentAccount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Account? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Account?>(value),
    );
  }
}

String _$currentAccountHash() => r'c19ba90076460e591a10624ed47aaf945f16f680';

/// Роль текущего пользователя. Локальный владелец устройства — админ.

@ProviderFor(currentRole)
final currentRoleProvider = CurrentRoleProvider._();

/// Роль текущего пользователя. Локальный владелец устройства — админ.

final class CurrentRoleProvider
    extends $FunctionalProvider<UserRole, UserRole, UserRole>
    with $Provider<UserRole> {
  /// Роль текущего пользователя. Локальный владелец устройства — админ.
  CurrentRoleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentRoleProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentRoleHash();

  @$internal
  @override
  $ProviderElement<UserRole> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRole create(Ref ref) {
    return currentRole(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRole value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRole>(value),
    );
  }
}

String _$currentRoleHash() => r'093b7a1ebe518d3ab28e9298829e6d39b95861ac';

/// Может ли текущий пользователь управлять аккаунтами.

@ProviderFor(canManageAccounts)
final canManageAccountsProvider = CanManageAccountsProvider._();

/// Может ли текущий пользователь управлять аккаунтами.

final class CanManageAccountsProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Может ли текущий пользователь управлять аккаунтами.
  CanManageAccountsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'canManageAccountsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$canManageAccountsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canManageAccounts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canManageAccountsHash() => r'71c0c98963bf566f206f35bb4e3ba4b76ba2d2c8';

/// Гостевые ссылки, выпущенные для просмотра альбома без аккаунта.

@ProviderFor(GuestLinksNotifier)
final guestLinksProvider = GuestLinksNotifierProvider._();

/// Гостевые ссылки, выпущенные для просмотра альбома без аккаунта.
final class GuestLinksNotifierProvider
    extends $AsyncNotifierProvider<GuestLinksNotifier, List<GuestLink>> {
  /// Гостевые ссылки, выпущенные для просмотра альбома без аккаунта.
  GuestLinksNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'guestLinksProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$guestLinksNotifierHash();

  @$internal
  @override
  GuestLinksNotifier create() => GuestLinksNotifier();
}

String _$guestLinksNotifierHash() =>
    r'1be1725c03aa0fcae671367d7b174243b799584d';

/// Гостевые ссылки, выпущенные для просмотра альбома без аккаунта.

abstract class _$GuestLinksNotifier extends $AsyncNotifier<List<GuestLink>> {
  FutureOr<List<GuestLink>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<GuestLink>>, List<GuestLink>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<GuestLink>>, List<GuestLink>>,
        AsyncValue<List<GuestLink>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
