import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/profile/domain/models/gallery_person.dart';
import 'package:ourtree_app/features/profile/domain/models/photo_position.dart';

/// Тип медиафайла в альбоме.
enum MediaType {
  image('image'),
  video('video');

  const MediaType(this.wireName);

  /// Значение, которое приходит в JSON.
  final String wireName;

  bool get isVideo => this == MediaType.video;

  /// Неизвестный тип считаем изображением — так безопаснее для старых данных.
  static MediaType fromWire(Object? value) =>
      value == MediaType.video.wireName ? MediaType.video : MediaType.image;
}

/// Фотография или видео внутри профиля либо события (`FamilyMedia`).
class FamilyMedia {
  const FamilyMedia({
    required this.id,
    required this.source,
    this.mediaId,
    this.type = MediaType.image,
    this.name,
    this.caption,
    this.position,
    this.zoom,
    this.people = const <GalleryPerson>[],
    this.eventIds = const <String>[],
  });

  /// Идентификатор записи; должен быть уникальным внутри альбома.
  final String id;

  /// Путь к файлу относительно сайта (`/photos/...`) или `hive://<id>`.
  final String source;

  /// Ссылка на файл в общей медиатеке.
  final String? mediaId;

  final MediaType type;

  /// Исходное имя загруженного файла.
  final String? name;

  /// Описание именно этой фотографии.
  final String? caption;

  /// Точка фокуса при кадрировании.
  final PhotoPosition? position;

  /// Масштаб при кадрировании.
  final double? zoom;

  /// Кто изображён на этой фотографии, кроме её владельца.
  final List<GalleryPerson> people;

  /// События, к которым привязан файл.
  final List<String> eventIds;

  bool get isImage => type == MediaType.image;

  /// Отмечен ли на файле участник [memberId].
  bool isPersonTagged(String memberId) =>
      people.any((person) => person.id == memberId);

  /// Привязан ли файл к событию [eventId].
  bool isLinkedToEvent(String eventId) => eventIds.contains(eventId);

  factory FamilyMedia.fromJson(Map<String, dynamic> json) {
    final position = readMap(json['position']);
    return FamilyMedia(
      id: readString(json['id']),
      source: readString(json['source']),
      mediaId: readNullableString(json['mediaId']),
      type: MediaType.fromWire(json['type']),
      name: readNullableString(json['name']),
      caption: readNullableString(json['caption']),
      position: position == null ? null : PhotoPosition.fromJson(position),
      zoom: readDouble(json['zoom']),
      people: readMapList(json['people'])
          .map(GalleryPerson.fromJson)
          .toList(growable: false),
      eventIds: readStringList(json['eventIds']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        if (mediaId != null) 'mediaId': mediaId,
        'type': type.wireName,
        if (name != null) 'name': name,
        if (caption != null) 'caption': caption,
        if (position != null) 'position': position!.toJson(),
        if (zoom != null) 'zoom': zoom,
        if (people.isNotEmpty)
          'people':
              people.map((person) => person.toJson()).toList(growable: false),
        if (eventIds.isNotEmpty) 'eventIds': eventIds,
      };

  /// Копия с изменёнными полями.
  ///
  /// Nullable-поля принимают колбэк, чтобы их можно было очистить:
  /// `copyWith(caption: () => null)`.
  FamilyMedia copyWith({
    String? id,
    String? source,
    String? mediaId,
    MediaType? type,
    String? Function()? name,
    String? Function()? caption,
    PhotoPosition? Function()? position,
    double? Function()? zoom,
    List<GalleryPerson>? people,
    List<String>? eventIds,
  }) =>
      FamilyMedia(
        id: id ?? this.id,
        source: source ?? this.source,
        mediaId: mediaId ?? this.mediaId,
        type: type ?? this.type,
        name: name == null ? this.name : name(),
        caption: caption == null ? this.caption : caption(),
        position: position == null ? this.position : position(),
        zoom: zoom == null ? this.zoom : zoom(),
        people: people ?? this.people,
        eventIds: eventIds ?? this.eventIds,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMedia &&
          id == other.id &&
          source == other.source &&
          mediaId == other.mediaId &&
          type == other.type &&
          name == other.name &&
          caption == other.caption &&
          position == other.position &&
          zoom == other.zoom &&
          listsEqual(people, other.people) &&
          listsEqual(eventIds, other.eventIds);

  @override
  int get hashCode => Object.hash(
        id,
        source,
        mediaId,
        type,
        name,
        caption,
        position,
        zoom,
        listsHash(people),
        listsHash(eventIds),
      );
}
