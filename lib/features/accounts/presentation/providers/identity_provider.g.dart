// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Шлюз анонимного входа; подменяется в тестах.

@ProviderFor(identityGateway)
final identityGatewayProvider = IdentityGatewayProvider._();

/// Шлюз анонимного входа; подменяется в тестах.

final class IdentityGatewayProvider extends $FunctionalProvider<IdentityGateway,
    IdentityGateway, IdentityGateway> with $Provider<IdentityGateway> {
  /// Шлюз анонимного входа; подменяется в тестах.
  IdentityGatewayProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'identityGatewayProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$identityGatewayHash();

  @$internal
  @override
  $ProviderElement<IdentityGateway> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdentityGateway create(Ref ref) {
    return identityGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityGateway>(value),
    );
  }
}

String _$identityGatewayHash() => r'14a8ee2c84589ebabc36d7e108b1114000ac7c2f';

/// Хранилище профиля пользователя; подменяется в тестах.

@ProviderFor(userStore)
final userStoreProvider = UserStoreProvider._();

/// Хранилище профиля пользователя; подменяется в тестах.

final class UserStoreProvider
    extends $FunctionalProvider<UserStore, UserStore, UserStore>
    with $Provider<UserStore> {
  /// Хранилище профиля пользователя; подменяется в тестах.
  UserStoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userStoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userStoreHash();

  @$internal
  @override
  $ProviderElement<UserStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserStore create(Ref ref) {
    return userStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserStore>(value),
    );
  }
}

String _$userStoreHash() => r'6f92afc22fc7f3b828ff386fe19e8737a7c7c6bc';

/// UUID пользователя на этом устройстве.
///
/// Если на устройстве выбран локальный аккаунт — берём его id (после миграции
/// это UUID v4), иначе создаём «личность устройства». Именно этот id уходит
/// в Firestore (`users/{userId}`) и в `families/*/members/{userId}`.

@ProviderFor(localUserId)
final localUserIdProvider = LocalUserIdProvider._();

/// UUID пользователя на этом устройстве.
///
/// Если на устройстве выбран локальный аккаунт — берём его id (после миграции
/// это UUID v4), иначе создаём «личность устройства». Именно этот id уходит
/// в Firestore (`users/{userId}`) и в `families/*/members/{userId}`.

final class LocalUserIdProvider
    extends $FunctionalProvider<String, String, String> with $Provider<String> {
  /// UUID пользователя на этом устройстве.
  ///
  /// Если на устройстве выбран локальный аккаунт — берём его id (после миграции
  /// это UUID v4), иначе создаём «личность устройства». Именно этот id уходит
  /// в Firestore (`users/{userId}`) и в `families/*/members/{userId}`.
  LocalUserIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localUserIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localUserIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return localUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$localUserIdHash() => r'cc382205e68e119664e184c3136a113401c0a404';

/// Личность пользователя: локальный id + анонимный `auth.uid` + профиль в облаке.
///
/// Вход полностью бесшовный: пользователь не видит ни формы, ни пароля — при
/// первом запуске выполняется `signInAnonymously()`.

@ProviderFor(IdentityController)
final identityControllerProvider = IdentityControllerProvider._();

/// Личность пользователя: локальный id + анонимный `auth.uid` + профиль в облаке.
///
/// Вход полностью бесшовный: пользователь не видит ни формы, ни пароля — при
/// первом запуске выполняется `signInAnonymously()`.
final class IdentityControllerProvider
    extends $AsyncNotifierProvider<IdentityController, IdentityState> {
  /// Личность пользователя: локальный id + анонимный `auth.uid` + профиль в облаке.
  ///
  /// Вход полностью бесшовный: пользователь не видит ни формы, ни пароля — при
  /// первом запуске выполняется `signInAnonymously()`.
  IdentityControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'identityControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$identityControllerHash();

  @$internal
  @override
  IdentityController create() => IdentityController();
}

String _$identityControllerHash() =>
    r'43802b773cfc34e1359206da47ec08399eec9d04';

/// Личность пользователя: локальный id + анонимный `auth.uid` + профиль в облаке.
///
/// Вход полностью бесшовный: пользователь не видит ни формы, ни пароля — при
/// первом запуске выполняется `signInAnonymously()`.

abstract class _$IdentityController extends $AsyncNotifier<IdentityState> {
  FutureOr<IdentityState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<IdentityState>, IdentityState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<IdentityState>, IdentityState>,
        AsyncValue<IdentityState>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
