import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/utils/asset_path.dart';

void main() {
  group('familyPhotoAssetPath', () {
    test('maps archive video paths to Flutter assets', () {
      expect(
        familyPhotoAssetPath('/photos/fc705fd2.mp4'),
        'assets/photos/fc705fd2.mp4',
      );
      expect(
        familyPhotoAssetPath('assets/photos/video.mp4'),
        'assets/photos/video.mp4',
      );
      expect(
        familyPhotoAssetPath('photos/video.mp4'),
        'assets/photos/video.mp4',
      );
    });

    test('does not map external and empty sources', () {
      expect(familyPhotoAssetPath('https://example.com/a.mp4'), isNull);
      expect(familyPhotoAssetPath('data:video/mp4;base64,AAAA'), isNull);
      expect(familyPhotoAssetPath(''), isNull);
      expect(familyPhotoAssetPath(null), isNull);
    });
  });
}
