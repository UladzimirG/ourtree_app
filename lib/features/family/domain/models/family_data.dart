import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/profile/domain/models/event_kind.dart';
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';
import 'package:ourtree_app/features/profile/domain/models/family_member.dart';
import 'package:ourtree_app/features/profile/domain/models/gallery_person.dart';
import 'package:ourtree_app/features/profile/domain/models/timeline_event.dart';
import 'package:ourtree_app/features/settings/domain/models/family_settings.dart';

/// Всё содержимое семейного альбома (`FamilyData` из `FamilyDataContext.tsx`).
///
/// JSON плоский, как `family_ru.json` / `family_en.json`: настройки лежат в корне рядом с
/// массивами [members] и [timelineEvents].
class FamilyData {
  const FamilyData({
    required this.settings,
    this.members = const <FamilyMember>[],
    this.timelineEvents = const <TimelineEvent>[],
    this.mediaLibrary = const <MediaAsset>[],
  });

  final FamilySettings settings;
  final List<FamilyMember> members;
  final List<TimelineEvent> timelineEvents;

  /// Общая медиатека семьи. Связи хранятся в профилях и событиях.
  final List<MediaAsset> mediaLibrary;

  String get familyName => settings.familyName;

  String? get familyPhoto => settings.familyPhoto;

  int? get revision => settings.revision;

  static const FamilyData empty = FamilyData(
    settings: FamilySettings(familyName: FamilySettings.fallbackName),
  );

  factory FamilyData.fromJson(Map<String, dynamic> json) => FamilyData(
        settings: FamilySettings.fromJson(json),
        members: readMapList(json['members'])
            .map(FamilyMember.fromJson)
            .toList(growable: false),
        timelineEvents: readMapList(json['timelineEvents'])
            .map(TimelineEvent.fromJson)
            .toList(growable: false),
        mediaLibrary: readMapList(json['mediaLibrary'])
            .map(MediaAsset.fromJson)
            .toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        ...settings.toJson(),
        'members': members
            .map((member) => member.toJson())
            .toList(growable: false),
        'timelineEvents': timelineEvents
            .map((event) => event.toJson())
            .toList(growable: false),
        if (mediaLibrary.isNotEmpty)
          'mediaLibrary':
              mediaLibrary.map((asset) => asset.toJson()).toList(growable: false),
      };

  /// Профиль по идентификатору; `null`, если такого члена семьи нет.
  FamilyMember? memberById(String id) {
    for (final member in members) {
      if (member.id == id) return member;
    }
    return null;
  }

  /// События по возрастанию даты.
  ///
  /// Даты хранятся как `YYYY-MM-DD`, поэтому обычное сравнение строк даёт
  /// правильный хронологический порядок.
  List<TimelineEvent> get sortedTimelineEvents {
    final sorted = [...timelineEvents]..sort((a, b) => a.date.compareTo(b.date));
    return List<TimelineEvent>.unmodifiable(sorted);
  }

  /// Ищет уже загруженную копию файла.
  ///
  /// Сначала сравнивает SHA-256, затем — имя и размер (для старых записей,
  /// у которых хеша ещё нет).
  MediaAsset? findDuplicateMedia({
    String? hash,
    String? name,
    int? size,
  }) {
    final normalizedName = name?.trim();
    for (final asset in mediaLibrary) {
      if (hash != null && asset.hash == hash) return asset;
      if (hash != null &&
          asset.hash == null &&
          normalizedName != null &&
          asset.name == normalizedName &&
          size != null &&
          asset.size == size) {
        return asset;
      }
    }
    return null;
  }

  /// Все файлы, которые должны появиться в профиле [memberId].
  ///
  /// Кроме собственной галереи сюда входят файлы из событий и чужих галерей,
  /// где участник отмечен через `FamilyMedia.people`.
  List<FamilyMedia> mediaForMember(String memberId) {
    final result = <FamilyMedia>[];

    for (final member in members) {
      for (final shot in member.gallery) {
        final legacy = shot.photo?.trim();
        if (legacy != null && legacy.isNotEmpty) {
          result.add(
            FamilyMedia(
              id: 'legacy-${member.id}-${shot.caption.hashCode}',
              source: legacy,
              caption: shot.caption,
            ),
          );
        }
        for (final media in shot.media) {
          if (member.id == memberId) {
            result.add(media);
          } else if (media.isPersonTagged(memberId)) {
            result.add(_withPersonCaption(media, memberId));
          }
        }
      }
    }

    final own = memberById(memberId);
    if (own != null) {
      result.addAll(own.birthdayMedia);
    }

    for (final event in timelineEvents) {
      final legacy = event.photo?.trim();
      if (legacy != null && legacy.isNotEmpty) {
        if (event.memberId == memberId) {
          result.add(
            FamilyMedia(
              id: 'legacy-event-${event.id}',
              source: legacy,
              caption: event.title,
            ),
          );
        }
      }
      for (final media in event.media) {
        if (event.memberId == memberId) {
          result.add(media);
        } else if (media.isPersonTagged(memberId)) {
          result.add(_withPersonCaption(media, memberId));
        }
      }
    }

    // Файлы из медиатеки, отмеченные этим человеком, но ещё не привязанные
    // к конкретной галерее/событию, тоже должны быть в его галерее.
    for (final asset in mediaLibrary) {
      GalleryPerson? person;
      for (final tagged in asset.people) {
        if (tagged.id == memberId) {
          person = tagged;
          break;
        }
      }
      if (person == null) continue;
      final caption = person.caption?.trim();
      result.add(
        FamilyMedia(
          id: 'library-${asset.id}',
          mediaId: asset.id,
          source: asset.source,
          type: asset.type,
          name: asset.name,
          people: asset.people,
          caption: caption == null || caption.isEmpty ? null : caption,
        ),
      );
    }

    return _uniqueMedia(result);
  }

  /// Все файлы, которые должны появиться в карточке [event].
  ///
  /// Включает медиа самого события, медиа его дня рождения и файлы из галерей
  /// участников, связанные с событием через `FamilyMedia.eventIds`.
  List<FamilyMedia> mediaForEvent(TimelineEvent event) {
    final result = <FamilyMedia>[...event.media];

    final legacy = event.photo?.trim();
    if (legacy != null && legacy.isNotEmpty) {
      result.add(
        FamilyMedia(
          id: 'legacy-event-${event.id}',
          source: legacy,
          caption: event.title,
        ),
      );
    }

    if (event.kind == EventKind.birth && event.memberId != null) {
      final member = memberById(event.memberId!);
      if (member != null) result.addAll(member.birthdayMedia);
    }

    for (final member in members) {
      for (final shot in member.gallery) {
        for (final media in shot.media) {
          if (media.isLinkedToEvent(event.id)) result.add(media);
        }
      }
    }

    return _uniqueMedia(result);
  }

  /// Обновляет общие свойства файла во всех связях.
  ///
  /// Подпись и кадрирование каждой связи сохраняются: меняются только
  /// свойства самого файла — источник, тип, имя и отмеченные люди.
  FamilyData withUpdatedMediaAsset(MediaAsset asset) {
    FamilyMedia sync(FamilyMedia media) {
      if (media.mediaId != asset.id && media.source != asset.source) {
        return media;
      }
      return media.copyWith(
        mediaId: asset.id,
        source: asset.source,
        type: asset.type,
        name: () => asset.name,
        people: asset.people,
      );
    }

    return copyWith(
      mediaLibrary: [
        for (final item in mediaLibrary)
          if (item.id == asset.id) asset else item,
        if (assetById(asset.id) == null) asset,
      ],
      members: [
        for (final member in members)
          member.copyWith(
            birthdayMedia:
                member.birthdayMedia.map(sync).toList(growable: false),
            gallery: [
              for (final shot in member.gallery)
                shot.copyWith(
                  media: shot.media.map(sync).toList(growable: false),
                ),
            ],
          ),
      ],
      timelineEvents: [
        for (final event in timelineEvents)
          event.copyWith(
            media: event.media.map(sync).toList(growable: false),
          ),
      ],
    );
  }

  /// Удаляет файл из медиатеки вместе со всеми связями и обложками.
  FamilyData withoutMediaAsset(String assetId) {
    final asset = assetById(assetId);
    if (asset == null) return this;
    final source = asset.source;

    bool keep(FamilyMedia media) =>
        media.mediaId != assetId && media.source != source;

    return copyWith(
      settings: settings.copyWith(
        familyPhoto: () =>
            settings.familyPhoto == source ? null : settings.familyPhoto,
      ),
      members: [
        for (final member in members)
          member.copyWith(
            photo: () => member.photo == source ? null : member.photo,
            birthdayMedia:
                member.birthdayMedia.where(keep).toList(growable: false),
            gallery: [
              for (final shot in member.gallery)
                shot.copyWith(
                  photo: () => shot.photo == source ? null : shot.photo,
                  media: shot.media.where(keep).toList(growable: false),
                ),
            ],
          ),
      ],
      timelineEvents: [
        for (final event in timelineEvents)
          event.copyWith(
            photo: () => event.photo == source ? null : event.photo,
            media: event.media.where(keep).toList(growable: false),
          ),
      ],
      mediaLibrary: [
        for (final item in mediaLibrary)
          if (item.id != assetId) item,
      ],
    );
  }

  /// Собирает все фото и видео в общую медиатеку.
  ///
  /// Старый архив хранил файлы внутри профилей и событий. Метод создаёт
  /// [MediaAsset] для каждого уникального источника, проставляет ссылки
  /// `mediaId` и синхронизирует общие свойства (тип, имя, люди). Описание и
  /// кадрирование остаются индивидуальными у каждой связи.
  FamilyData normalizeMediaLibrary() {
    final assets = <String, MediaAsset>{
      for (final asset in mediaLibrary) asset.id: asset,
    };
    final bySource = <String, String>{
      for (final asset in mediaLibrary)
        if (asset.source.trim().isNotEmpty) asset.source: asset.id,
    };
    MediaAsset ensure(FamilyMedia media) {
      final source = media.source.trim();
      var asset = media.mediaId == null ? null : assets[media.mediaId!];
      asset ??= source.isEmpty ? null : assets[bySource[source]];
      if (asset == null) {
        final id = media.mediaId ??
            (source.isEmpty
                ? 'asset-${media.id}'
                : 'asset-${_sourceHash(source)}');
        asset = assets[id] ??
            MediaAsset(
              id: id,
              source: source,
              type: media.type,
              name: media.name,
              people: media.people,
            );
        assets[id] = asset;
        if (source.isNotEmpty) bySource[source] = id;
      } else {
        final people = _mergePeople(asset.people, media.people);
        if (people.length != asset.people.length) {
          assets[asset.id] = asset = asset.copyWith(people: people);
        }
      }
      return assets[asset.id]!;
    }

    void ensureCover(String? source) {
      final value = source?.trim();
      if (value == null || value.isEmpty) return;
      if (bySource.containsKey(value)) return;
      final id = 'cover-${_sourceHash(value)}';
      final asset = MediaAsset(
        id: id,
        source: value,
        name: value.split('/').last,
      );
      assets[id] = asset;
      bySource[value] = id;
    }

    FamilyMedia link(FamilyMedia media) {
      final asset = ensure(media);
      return media.copyWith(
        mediaId: asset.id,
        source: asset.source,
        type: asset.type,
        name: () => asset.name,
        people: asset.people,
      );
    }

    ensureCover(settings.familyPhoto);

    final nextMembers = <FamilyMember>[];
    for (final member in members) {
      ensureCover(member.photo);
      nextMembers.add(
        member.copyWith(
          birthdayMedia: member.birthdayMedia.map(link).toList(growable: false),
          gallery: [
            for (final shot in member.gallery)
              shot.copyWith(
                media: shot.media.map(link).toList(growable: false),
              ),
          ],
        ),
      );
    }

    final nextEvents = <TimelineEvent>[];
    for (final event in timelineEvents) {
      ensureCover(event.photo);
      nextEvents.add(
        event.copyWith(
          media: event.media.map(link).toList(growable: false),
        ),
      );
    }

    return copyWith(
      members: nextMembers,
      timelineEvents: nextEvents,
      mediaLibrary: assets.values.toList(growable: false),
    );
  }

  MediaAsset? assetById(String? id) {
    if (id == null) return null;
    for (final asset in mediaLibrary) {
      if (asset.id == id) return asset;
    }
    return null;
  }

  MediaAsset? assetBySource(String source) {
    final value = source.trim();
    if (value.isEmpty) return null;
    for (final asset in mediaLibrary) {
      if (asset.source == value) return asset;
    }
    return null;
  }

  FamilyData copyWith({
    FamilySettings? settings,
    List<FamilyMember>? members,
    List<TimelineEvent>? timelineEvents,
    List<MediaAsset>? mediaLibrary,
  }) =>
      FamilyData(
        settings: settings ?? this.settings,
        members: members ?? this.members,
        timelineEvents: timelineEvents ?? this.timelineEvents,
        mediaLibrary: mediaLibrary ?? this.mediaLibrary,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyData &&
          settings == other.settings &&
          listsEqual(members, other.members) &&
          listsEqual(timelineEvents, other.timelineEvents) &&
          listsEqual(mediaLibrary, other.mediaLibrary);

  @override
  int get hashCode => Object.hash(
        settings,
        listsHash(members),
        listsHash(timelineEvents),
        listsHash(mediaLibrary),
      );
}

/// Убирает повторы одного и того же файла, пришедшего из разных мест.
/// Подставляет личную подпись отмеченного человека, если она задана.
FamilyMedia _withPersonCaption(FamilyMedia media, String memberId) {
  for (final person in media.people) {
    if (person.id == memberId && person.caption?.trim().isNotEmpty == true) {
      return media.copyWith(caption: () => person.caption);
    }
  }
  return media;
}

List<GalleryPerson> _mergePeople(
  List<GalleryPerson> current,
  List<GalleryPerson> incoming,
) {
  final result = <String, GalleryPerson>{
    for (final person in current) person.id: person,
  };
  for (final person in incoming) {
    result.putIfAbsent(person.id, () => person);
  }
  return result.values.toList(growable: false);
}

/// Стабильный ключ источника (FNV-1a), чтобы id переживал перезапуск.
String _sourceHash(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return '${hash.toRadixString(16)}-${value.length}';
}

List<FamilyMedia> _uniqueMedia(Iterable<FamilyMedia> items) {
  final seen = <String>{};
  final result = <FamilyMedia>[];
  for (final media in items) {
    final key = media.source.trim().isNotEmpty ? media.source : media.id;
    if (!seen.add(key)) continue;
    result.add(media);
  }
  return List<FamilyMedia>.unmodifiable(result);
}
