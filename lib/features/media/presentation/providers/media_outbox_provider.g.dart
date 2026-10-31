// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_outbox_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Поток изменений сети — для автоповтора очереди.

@ProviderFor(connectivityChanges)
final connectivityChangesProvider = ConnectivityChangesProvider._();

/// Поток изменений сети — для автоповтора очереди.

final class ConnectivityChangesProvider extends $FunctionalProvider<
        AsyncValue<List<ConnectivityResult>>,
        List<ConnectivityResult>,
        Stream<List<ConnectivityResult>>>
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  /// Поток изменений сети — для автоповтора очереди.
  ConnectivityChangesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityChangesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityChangesHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivityChanges(ref);
  }
}

String _$connectivityChangesHash() =>
    r'b9cdca0d9d2736e812c2ebf9ca37986ffe9b8d75';

/// Очередь выгрузки медиа: постановка, автоповтор, ручной retry.

@ProviderFor(MediaOutboxController)
final mediaOutboxControllerProvider = MediaOutboxControllerProvider._();

/// Очередь выгрузки медиа: постановка, автоповтор, ручной retry.
final class MediaOutboxControllerProvider
    extends $NotifierProvider<MediaOutboxController, List<MediaOutboxItem>> {
  /// Очередь выгрузки медиа: постановка, автоповтор, ручной retry.
  MediaOutboxControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mediaOutboxControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mediaOutboxControllerHash();

  @$internal
  @override
  MediaOutboxController create() => MediaOutboxController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MediaOutboxItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MediaOutboxItem>>(value),
    );
  }
}

String _$mediaOutboxControllerHash() =>
    r'afd7ab83fd186a2c7b4ef15473d05b44202a6d86';

/// Очередь выгрузки медиа: постановка, автоповтор, ручной retry.

abstract class _$MediaOutboxController
    extends $Notifier<List<MediaOutboxItem>> {
  List<MediaOutboxItem> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<MediaOutboxItem>, List<MediaOutboxItem>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<MediaOutboxItem>, List<MediaOutboxItem>>,
        List<MediaOutboxItem>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
