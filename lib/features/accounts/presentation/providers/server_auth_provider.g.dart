// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Клиент серверного API аккаунтов (подменяется в тестах).

@ProviderFor(accountsApi)
final accountsApiProvider = AccountsApiProvider._();

/// Клиент серверного API аккаунтов (подменяется в тестах).

final class AccountsApiProvider
    extends $FunctionalProvider<AccountsApi, AccountsApi, AccountsApi>
    with $Provider<AccountsApi> {
  /// Клиент серверного API аккаунтов (подменяется в тестах).
  AccountsApiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'accountsApiProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$accountsApiHash();

  @$internal
  @override
  $ProviderElement<AccountsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountsApi create(Ref ref) {
    return accountsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountsApi>(value),
    );
  }
}

String _$accountsApiHash() => r'3c1c8175e09943f57734bc68e55f527d0dad75a8';

/// Серверная авторизация по логину и паролю.
///
/// Жизненный цикл входа: Cloud Function проверяет пароль → возвращает
/// custom token → Firebase Auth делает `uid` равным id аккаунта →
/// членство в семьях переносится на этот uid на сервере.

@ProviderFor(ServerAuth)
final serverAuthProvider = ServerAuthProvider._();

/// Серверная авторизация по логину и паролю.
///
/// Жизненный цикл входа: Cloud Function проверяет пароль → возвращает
/// custom token → Firebase Auth делает `uid` равным id аккаунта →
/// членство в семьях переносится на этот uid на сервере.
final class ServerAuthProvider extends $NotifierProvider<ServerAuth, void> {
  /// Серверная авторизация по логину и паролю.
  ///
  /// Жизненный цикл входа: Cloud Function проверяет пароль → возвращает
  /// custom token → Firebase Auth делает `uid` равным id аккаунта →
  /// членство в семьях переносится на этот uid на сервере.
  ServerAuthProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serverAuthProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serverAuthHash();

  @$internal
  @override
  ServerAuth create() => ServerAuth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$serverAuthHash() => r'54ad4eb82086093039fa0bddd9c85416cdbb4a9a';

/// Серверная авторизация по логину и паролю.
///
/// Жизненный цикл входа: Cloud Function проверяет пароль → возвращает
/// custom token → Firebase Auth делает `uid` равным id аккаунта →
/// членство в семьях переносится на этот uid на сервере.

abstract class _$ServerAuth extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
