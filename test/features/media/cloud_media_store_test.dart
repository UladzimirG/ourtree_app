import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/media/data/repositories/cloud_media_store.dart';

void main() {
  group('mediaStoragePath', () {
    test('строит путь внутри семьи и ассета', () {
      expect(
        mediaStoragePath(
          familyId: 'family-1',
          assetId: 'asset-1',
          fileName: 'original.jpg',
        ),
        'families/family-1/media/asset-1/original.jpg',
      );
    });

    test('поддерживает вложенные имена для постера видео', () {
      expect(
        mediaStoragePath(
          familyId: 'f',
          assetId: 'a',
          fileName: 'poster.jpg',
        ),
        'families/f/media/a/poster.jpg',
      );
    });
  });

  group('CloudUploadResult', () {
    test('хранит путь и ссылку', () {
      const result = CloudUploadResult(
        storagePath: 'families/f/media/a/original.jpg',
        downloadUrl: 'https://example.com/a.jpg',
      );

      expect(result.storagePath, contains('/media/a/'));
      expect(result.downloadUrl, startsWith('https://'));
    });
  });
}
