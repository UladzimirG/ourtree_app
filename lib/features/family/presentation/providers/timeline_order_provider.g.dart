// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Порядок событий таймлайна, который переживает перезапуск приложения.

@ProviderFor(TimelineOrderController)
final timelineOrderControllerProvider = TimelineOrderControllerProvider._();

/// Порядок событий таймлайна, который переживает перезапуск приложения.
final class TimelineOrderControllerProvider
    extends $NotifierProvider<TimelineOrderController, TimelineOrder> {
  /// Порядок событий таймлайна, который переживает перезапуск приложения.
  TimelineOrderControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'timelineOrderControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$timelineOrderControllerHash();

  @$internal
  @override
  TimelineOrderController create() => TimelineOrderController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimelineOrder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimelineOrder>(value),
    );
  }
}

String _$timelineOrderControllerHash() =>
    r'0201133c4ed4c790ce4c3eab42bcd6bc0896a37a';

/// Порядок событий таймлайна, который переживает перезапуск приложения.

abstract class _$TimelineOrderController extends $Notifier<TimelineOrder> {
  TimelineOrder build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TimelineOrder, TimelineOrder>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TimelineOrder, TimelineOrder>,
        TimelineOrder,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
