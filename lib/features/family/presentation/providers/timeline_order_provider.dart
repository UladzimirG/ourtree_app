import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timeline_order_provider.g.dart';

/// Порядок событий на таймлайне.
enum TimelineOrder {
  oldestFirst,
  newestFirst;

  static TimelineOrder fromStorage(String? value) {
    for (final order in values) {
      if (order.name == value) return order;
    }
    return TimelineOrder.oldestFirst;
  }
}

/// Ключ выбранного порядка в локальном хранилище.
const String timelineOrderStorageKey = 'timeline_order';

/// Порядок событий таймлайна, который переживает перезапуск приложения.
@Riverpod(keepAlive: true)
class TimelineOrderController extends _$TimelineOrderController {
  @override
  TimelineOrder build() => TimelineOrder.fromStorage(
        MediaStorage.instance.getString(timelineOrderStorageKey),
      );

  Future<void> select(TimelineOrder order) async {
    if (state == order) return;
    state = order;
    await MediaStorage.instance.putString(timelineOrderStorageKey, order.name);
  }
}
