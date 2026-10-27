import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_library_panel.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  FamilyMember member(String id, {List<GalleryShot> gallery = const []}) {
    return FamilyMember(
      id: id,
      role: 'Роль',
      name: id,
      nickname: '',
      birthday: '2000-01-01',
      gallery: gallery,
    );
  }

  test('a file without links is unused', () {
    final family = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [member('papa')],
    );
    const asset = MediaAsset(id: 'asset-1', source: 'hive://1');

    expect(mediaUsageLabels(family, asset, l10n), isEmpty);
  });

  test('tagging a person makes the file used', () {
    final family = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [member('papa')],
    );
    const asset = MediaAsset(
      id: 'asset-1',
      source: 'hive://1',
      people: [GalleryPerson(id: 'papa')],
    );

    expect(mediaUsageLabels(family, asset, l10n), isNotEmpty);
  });

  test('gallery or event links make the file used', () {
    const linked = FamilyMedia(
      id: 'media-1',
      source: 'hive://1',
      mediaId: 'asset-1',
    );
    final family = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [
        member('papa', gallery: [const GalleryShot(media: [linked])]),
      ],
      timelineEvents: const [
        TimelineEvent(id: 'e1', date: '2020-01-01', title: 'Event'),
      ],
    );
    const asset = MediaAsset(id: 'asset-1', source: 'hive://1');

    expect(mediaUsageLabels(family, asset, l10n), isNotEmpty);
  });
}
