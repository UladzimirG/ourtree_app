import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/media/data/media_outbox.dart';
import 'package:ourtree_app/features/media/domain/models/media_outbox_item.dart';
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';

void main() {
  setUp(() async {
    await MediaStorage.instance.clearForTests();
  });

  MediaOutboxItem item(String id, {int attempts = 0}) => MediaOutboxItem(
        assetId: id,
        familyId: 'family-1',
        userId: 'user-1',
        name: '$id.jpg',
        hash: 'hash-$id',
        size: 1024,
        storedId: 'media-$id',
        attempts: attempts,
        createdAt: 1700000000000,
      );

  group('MediaOutbox', () {
    test('сохраняет операцию и читает её после перезагрузки', () async {
      final outbox = MediaOutbox();

      await outbox.add(item('a'));

      final reloaded = MediaOutbox().load();
      expect(reloaded, hasLength(1));
      expect(reloaded.first.assetId, 'a');
      expect(reloaded.first.storedId, 'media-a');
      expect(reloaded.first.type, MediaType.image);
    });

    test('повторная постановка не создаёт дубль', () async {
      final outbox = MediaOutbox();

      await outbox.add(item('a'));
      final items = await outbox.add(item('a'));

      expect(items, hasLength(1));
    });

    test('remove убирает только нужную операцию', () async {
      final outbox = MediaOutbox();
      await outbox.add(item('a'));
      await outbox.add(item('b'));

      final items = await outbox.remove('a');

      expect(items.map((entry) => entry.assetId), ['b']);
    });

    test('replace обновляет попытки и текст ошибки', () async {
      final outbox = MediaOutbox();
      await outbox.add(item('a'));

      final items = await outbox.replace(
        item('a', attempts: 2).copyWith(lastError: () => 'unavailable'),
      );

      expect(items.single.attempts, 2);
      expect(items.single.lastError, 'unavailable');
    });

    test('битый JSON в хранилище не роняет загрузку', () async {
      await MediaStorage.instance.putString(MediaOutbox.storageKey, 'not json');

      expect(MediaOutbox().load(), isEmpty);
    });
  });

  group('MediaOutboxItem', () {
    test('переживает JSON round-trip', () {
      final original = item('x', attempts: 3);
      final restored = MediaOutboxItem.fromJson(original.toJson());

      expect(restored, original);
    });
  });
}
