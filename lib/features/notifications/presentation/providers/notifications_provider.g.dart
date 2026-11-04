// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Хранилище токенов устройств; подменяется в тестах.

@ProviderFor(deviceTokenStore)
final deviceTokenStoreProvider = DeviceTokenStoreProvider._();

/// Хранилище токенов устройств; подменяется в тестах.

final class DeviceTokenStoreProvider extends $FunctionalProvider<
    DeviceTokenStore,
    DeviceTokenStore,
    DeviceTokenStore> with $Provider<DeviceTokenStore> {
  /// Хранилище токенов устройств; подменяется в тестах.
  DeviceTokenStoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deviceTokenStoreProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deviceTokenStoreHash();

  @$internal
  @override
  $ProviderElement<DeviceTokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceTokenStore create(Ref ref) {
    return deviceTokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceTokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceTokenStore>(value),
    );
  }
}

String _$deviceTokenStoreHash() => r'3ac622073b299bee98c6cbfa4cf66d435c5ba552';

/// Включение уведомлений, токен устройства и настройки.

@ProviderFor(NotificationsController)
final notificationsControllerProvider = NotificationsControllerProvider._();

/// Включение уведомлений, токен устройства и настройки.
final class NotificationsControllerProvider
    extends $NotifierProvider<NotificationsController, NotificationsState> {
  /// Включение уведомлений, токен устройства и настройки.
  NotificationsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationsControllerHash();

  @$internal
  @override
  NotificationsController create() => NotificationsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsState>(value),
    );
  }
}

String _$notificationsControllerHash() =>
    r'f78800157dd810a0e820ed2734c8cdb4031d2ab8';

/// Включение уведомлений, токен устройства и настройки.

abstract class _$NotificationsController extends $Notifier<NotificationsState> {
  NotificationsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationsState, NotificationsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<NotificationsState, NotificationsState>,
        NotificationsState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
