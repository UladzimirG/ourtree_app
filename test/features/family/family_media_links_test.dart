import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';

void main() {
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

  test('FamilyMedia keeps event links through JSON', () {
    final media = FamilyMedia.fromJson(const {
      'id': 'm1',
      'source': '/photos/a.jpg',
      'type': 'image',
      'eventIds': ['e1', 'e2'],
      'people': [
        {'id': 'papa'},
      ],
    });

    expect(media.eventIds, ['e1', 'e2']);
    expect(media.isLinkedToEvent('e2'), isTrue);
    expect(media.isPersonTagged('papa'), isTrue);
    expect(media.toJson()['eventIds'], ['e1', 'e2']);
  });

  test('media linked to an event appears in that event', () {
    final tagged = const FamilyMedia(
      id: 'm1',
      source: '/photos/a.jpg',
      eventIds: ['e1'],
    );
    final family = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [
        member('papa', gallery: [GalleryShot(media: [tagged])]),
        member('mama'),
      ],
      timelineEvents: const [
        TimelineEvent(id: 'e1', date: '2020-01-01', title: 'Event'),
      ],
    );

    final media = family.mediaForEvent(family.timelineEvents.single);

    expect(media.map((item) => item.id), contains('m1'));
  });

  test('media tagged with a person appears in that profile', () {
    const tagged = FamilyMedia(
      id: 'm1',
      source: '/photos/a.jpg',
      people: [GalleryPerson(id: 'mama')],
    );
    final family = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [
        member('papa', gallery: [GalleryShot(media: [tagged])]),
        member('mama'),
      ],
    );

    final papa = family.mediaForMember('papa');
    final mama = family.mediaForMember('mama');

    expect(papa.map((item) => item.id), contains('m1'));
    expect(mama.map((item) => item.id), contains('m1'));
  });

  test('event media tagged with a person appears in the profile', () {
    const tagged = FamilyMedia(
      id: 'm2',
      source: '/photos/e.jpg',
      people: [GalleryPerson(id: 'mama')],
    );
    final family = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [member('papa'), member('mama')],
      timelineEvents: const [
        TimelineEvent(
          id: 'e1',
          date: '2020-01-01',
          title: 'Event',
          media: [tagged],
        ),
      ],
    );

    expect(
      family.mediaForMember('mama').map((item) => item.id),
      contains('m2'),
    );
  });

  test('normalisation builds one asset and keeps per-link metadata', () {
    const first = FamilyMedia(
      id: 'link-1',
      source: '/photos/shared.jpg',
      caption: 'Подпись папы',
      position: PhotoPosition(x: 20, y: 30),
      zoom: 1.5,
    );
    const second = FamilyMedia(
      id: 'link-2',
      source: '/photos/shared.jpg',
      caption: 'Подпись мамы',
      position: PhotoPosition(x: 70, y: 60),
      zoom: 2,
    );
    final family = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [
        member('papa', gallery: [GalleryShot(media: [first])]),
        member('mama', gallery: [GalleryShot(media: [second])]),
      ],
    ).normalizeMediaLibrary();

    expect(family.mediaLibrary, hasLength(1));
    final asset = family.mediaLibrary.single;
    expect(
      family.members[0].gallery.single.media.single.mediaId,
      asset.id,
    );
    expect(
      family.members[1].gallery.single.media.single.mediaId,
      asset.id,
    );
    expect(
      family.members[0].gallery.single.media.single.caption,
      'Подпись папы',
    );
    expect(
      family.members[1].gallery.single.media.single.caption,
      'Подпись мамы',
    );
    expect(family.members[0].gallery.single.media.single.zoom, 1.5);
    expect(family.members[1].gallery.single.media.single.position?.x, 70);
  });

  test('asset update syncs people but keeps link caption and crop', () {
    const link = FamilyMedia(
      id: 'link-1',
      source: '/photos/a.jpg',
      caption: 'Моя подпись',
      position: PhotoPosition(x: 10, y: 90),
      zoom: 1.8,
    );
    final normalized = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [member('papa', gallery: [GalleryShot(media: [link])])],
    ).normalizeMediaLibrary();
    final asset = normalized.mediaLibrary.single;

    final updated = normalized.withUpdatedMediaAsset(
      asset.copyWith(
        name: () => 'new.jpg',
        people: [const GalleryPerson(id: 'mama')],
      ),
    );
    final saved = updated.members.single.gallery.single.media.single;

    expect(saved.name, 'new.jpg');
    expect(saved.people.single.id, 'mama');
    expect(saved.caption, 'Моя подпись');
    expect(saved.position?.x, 10);
    expect(saved.zoom, 1.8);
  });

  test('deleting an asset removes every link', () {
    const link = FamilyMedia(id: 'link-1', source: '/photos/a.jpg');
    final normalized = FamilyData(
      settings: const FamilySettings(familyName: 'Family'),
      members: [
        member('papa', gallery: [GalleryShot(media: [link])]),
      ],
      timelineEvents: const [
        TimelineEvent(id: 'e1', date: '2020-01-01', title: 'E', media: [link]),
      ],
    ).normalizeMediaLibrary();

    final cleaned = normalized.withoutMediaAsset(
      normalized.mediaLibrary.single.id,
    );

    expect(cleaned.mediaLibrary, isEmpty);
    expect(cleaned.members.single.gallery.single.media, isEmpty);
    expect(cleaned.timelineEvents.single.media, isEmpty);
  });

  test('calendar flags survive JSON and default to visible', () {
    final event = TimelineEvent.fromJson(const {
      'id': 'e1',
      'date': '2020-01-01',
      'title': 'Event',
      'showInCalendar': false,
    });
    final hiddenMember = FamilyMember.fromJson(const {
      'id': 'papa',
      'role': 'Папа',
      'name': 'Папа',
      'nickname': '',
      'birthday': '1980-01-01',
      'showInCalendar': false,
    });
    final visibleMember = member('mama');

    expect(event.showInCalendar, isFalse);
    expect(hiddenMember.showInCalendar, isFalse);
    expect(visibleMember.showInCalendar, isNull);
    expect(event.toJson()['showInCalendar'], isFalse);
  });
}
