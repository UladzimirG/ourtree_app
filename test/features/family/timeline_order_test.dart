import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/family/presentation/providers/timeline_order_provider.dart';

void main() {
  setUp(() async {
    await MediaStorage.instance.clearForTests();
  });

  test('по умолчанию сначала старые', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(timelineOrderControllerProvider),
      TimelineOrder.oldestFirst,
    );
  });

  test('выбор порядка сохраняется между запусками', () async {
    final first = ProviderContainer();
    await first
        .read(timelineOrderControllerProvider.notifier)
        .select(TimelineOrder.newestFirst);
    first.dispose();

    final second = ProviderContainer();
    addTearDown(second.dispose);

    expect(
      second.read(timelineOrderControllerProvider),
      TimelineOrder.newestFirst,
    );
  });
}
