import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/media/domain/media_pending.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';

void main() {
  group('needsCloudUpload', () {
    test('файл из Hive ждёт загрузки', () {
      expect(
        needsCloudUpload(const MediaAsset(id: 'a', source: 'hive://m1')),
        isTrue,
      );
    });

    test('локальный файл на диске ждёт загрузки', () {
      expect(
        needsCloudUpload(
          const MediaAsset(id: 'a', source: '', localPath: '/tmp/a.jpg'),
        ),
        isTrue,
      );
    });

    test('демо-ассет из сборки не выгружаем', () {
      expect(
        needsCloudUpload(
          const MediaAsset(id: 'a', source: '/photos/media-023_portrait.jpg'),
        ),
        isFalse,
      );
    });

    test('облачный ассет повторно не выгружаем', () {
      expect(
        needsCloudUpload(
          const MediaAsset(
            id: 'a',
            source: 'https://example.com/a.jpg',
            storagePath: 'families/f/media/a/original.jpg',
            uploadState: MediaUploadState.ready,
          ),
        ),
        isFalse,
      );
    });

    test('ассет со ссылкой, но без storagePath — не наш случай', () {
      expect(
        needsCloudUpload(
          const MediaAsset(id: 'a', source: 'https://example.com/a.jpg'),
        ),
        isFalse,
      );
    });
  });

  test('pendingCloudUploads оставляет только локальные файлы', () {
    const assets = <MediaAsset>[
      MediaAsset(id: 'local', source: 'hive://m1'),
      MediaAsset(id: 'demo', source: '/photos/x.jpg'),
      MediaAsset(
        id: 'cloud',
        source: 'https://example.com/x.jpg',
        storagePath: 'families/f/media/cloud/original.jpg',
        uploadState: MediaUploadState.ready,
      ),
    ];

    final pending = pendingCloudUploads(assets);

    expect(pending.map((asset) => asset.id), ['local']);
  });
}
