import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';
import 'package:ourtree_app/features/profile/domain/models/gallery_person.dart';

/// Файл в общей медиатеке семьи.
///
/// Сам файл хранится в [MediaStorage] (источник `hive://<id>`) либо является
/// внешней ссылкой/путём к ассету. Описание и кадрирование задаются отдельно
/// на каждой связи с участником или событием — это делает [FamilyMedia].
class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.source,
    this.type = MediaType.image,
    this.name,
    this.createdAt = 0,
    this.size,
    this.people = const <GalleryPerson>[],
  });

  final String id;
  final String source;
  final MediaType type;
  final String? name;
  final int createdAt;
  final int? size;

  /// Кто изображён на файле. Общее свойство самого снимка.
  final List<GalleryPerson> people;

  bool get isVideo => type == MediaType.video;

  bool get isStored => source.startsWith('hive://');

  String? get storedId =>
      isStored ? source.substring('hive://'.length) : null;

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
        id: readString(json['id']),
        source: readString(json['source']),
        type: MediaType.fromWire(json['type']),
        name: readNullableString(json['name']),
        createdAt: readInt(json['createdAt']) ?? 0,
        size: readInt(json['size']),
        people: readMapList(json['people'])
            .map(GalleryPerson.fromJson)
            .toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'type': type.wireName,
        if (name != null) 'name': name,
        if (createdAt > 0) 'createdAt': createdAt,
        if (size != null) 'size': size,
        if (people.isNotEmpty)
          'people': people.map((person) => person.toJson()).toList(),
      };

  MediaAsset copyWith({
    String? id,
    String? source,
    MediaType? type,
    String? Function()? name,
    int? createdAt,
    int? Function()? size,
    List<GalleryPerson>? people,
  }) =>
      MediaAsset(
        id: id ?? this.id,
        source: source ?? this.source,
        type: type ?? this.type,
        name: name == null ? this.name : name(),
        createdAt: createdAt ?? this.createdAt,
        size: size == null ? this.size : size(),
        people: people ?? this.people,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaAsset &&
          id == other.id &&
          source == other.source &&
          type == other.type &&
          name == other.name &&
          createdAt == other.createdAt &&
          size == other.size &&
          listsEqual(people, other.people);

  @override
  int get hashCode => Object.hash(
        id,
        source,
        type,
        name,
        createdAt,
        size,
        listsHash(people),
      );
}
