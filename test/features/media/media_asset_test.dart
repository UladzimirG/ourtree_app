import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';

void main() {
  group('MediaAsset', () {
    test('parses a legacy local asset without cloud fields', () {
      final asset = MediaAsset.fromJson({
        'id': 'media-1',
        'source': 'hive://media-1',
        'type': 'image',
        'name': 'old.jpg',
      });

      expect(asset.isStored, isTrue);
      expect(asset.storedId, 'media-1');
      expect(asset.isRemote, isFalse);
      expect(asset.uploadState, MediaUploadState.local);
      expect(asset.displaySource, 'hive://media-1');
      expect(asset.cacheKey, 'media-1');
    });

    test('uses the content hash as the cache key for cloud assets', () {
      final asset = MediaAsset.fromJson({
        'id': 'asset-1',
        'source': 'hive://asset-1',
        'type': 'video',
        'hash': 'abc123',
        'storagePath': 'families/f1/media/asset-1/original.mp4',
        'downloadUrl': 'https://storage.example/asset-1.mp4',
        'posterUrl': 'https://storage.example/asset-1.jpg',
        'durationMs': 42000,
        'uploadState': 'ready',
      });

      expect(asset.type, MediaType.video);
      expect(asset.isRemote, isTrue);
      expect(asset.isReady, isTrue);
      expect(asset.cacheKey, 'abc123');
      expect(asset.displaySource, 'https://storage.example/asset-1.mp4');
      expect(asset.durationMs, 42000);
    });

    test('prefers a local file over the network url', () {
      final asset = MediaAsset(
        id: 'asset-1',
        source: 'hive://asset-1',
        downloadUrl: 'https://storage.example/asset-1.jpg',
        localPath: '/tmp/ourtree/asset-1.jpg',
        uploadState: MediaUploadState.ready,
      );

      expect(asset.isLocalFile, isTrue);
      expect(asset.displaySource, '/tmp/ourtree/asset-1.jpg');
    });

    test('round-trips every cloud field', () {
      final asset = MediaAsset(
        id: 'asset-2',
        source: 'hive://asset-2',
        type: MediaType.video,
        name: 'beach.mp4',
        createdAt: 1700000000000,
        size: 123456,
        hash: 'deadbeef',
        storagePath: 'families/f1/media/asset-2/original.mp4',
        downloadUrl: 'https://storage.example/asset-2.mp4',
        thumbUrl: 'https://storage.example/asset-2-thumb.jpg',
        posterUrl: 'https://storage.example/asset-2-poster.jpg',
        localPath: '/tmp/ourtree/asset-2.mp4',
        width: 1920,
        height: 1080,
        durationMs: 15000,
        uploadState: MediaUploadState.uploading,
        uploadedBy: 'user-1',
        updatedAt: 1700000001000,
      );

      final restored = MediaAsset.fromJson(
        jsonDecode(jsonEncode(asset.toJson())).cast<String, dynamic>(),
      );

      expect(restored, asset);
      expect(restored.uploadState, MediaUploadState.uploading);
    });

    test('copyWith can clear nullable fields', () {
      final asset = MediaAsset(
        id: 'asset-3',
        source: 'hive://asset-3',
        localPath: '/tmp/ourtree/asset-3.jpg',
      );

      final cleared = asset.copyWith(localPath: () => null);

      expect(cleared.localPath, isNull);
      expect(cleared.isLocalFile, isFalse);
      expect(cleared.displaySource, 'hive://asset-3');
      expect(cleared, isNot(asset));
    });
  });
}
