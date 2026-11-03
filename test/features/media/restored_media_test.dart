import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/restored_media.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RestoredMedia.restoredId', () {
    test('возвращает идентификатор восстановленного файла', () {
      expect(
        RestoredMedia.restoredId('hive://restored-0123456789abcdef01234567'),
        'restored-0123456789abcdef01234567',
      );
    });

    test('обычные локальные файлы не трогает', () {
      expect(RestoredMedia.restoredId('hive://media-123'), isNull);
      expect(RestoredMedia.restoredId('/photos/a.jpg'), isNull);
      expect(RestoredMedia.restoredId('https://example.com/a.jpg'), isNull);
      expect(RestoredMedia.restoredId(null), isNull);
      expect(RestoredMedia.restoredId('   '), isNull);
    });
  });

  test('находит встроенный файл по хешу исходного пути', () async {
    const source = '/photos/0b377b59-c45a-4e28-aac8-b52bdcf517c6.jpg';
    final digest = sha256.convert(utf8.encode(source)).toString();
    final id = 'restored-${digest.substring(0, 24)}';

    final key = await RestoredMedia.instance.assetKeyFor(id);

    expect(key, 'assets/photos/0b377b59-c45a-4e28-aac8-b52bdcf517c6.jpg');
    final bytes = await RestoredMedia.instance.bytesFor(id);
    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(1000));
  });
}
