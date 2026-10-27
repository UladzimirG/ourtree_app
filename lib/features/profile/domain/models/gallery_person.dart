import 'package:ourtree_app/core/utils/json_reader.dart';

/// Ещё один человек на снимке с необязательной собственной подписью
/// (`GalleryPerson`).
class GalleryPerson {
  const GalleryPerson({
    required this.id,
    this.caption,
  });

  /// Идентификатор члена семьи (`FamilyMember.id`).
  final String id;

  /// Подпись именно для этого человека; пусто — показывается общая подпись.
  final String? caption;

  factory GalleryPerson.fromJson(Map<String, dynamic> json) => GalleryPerson(
        id: readString(json['id']),
        caption: readNullableString(json['caption']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (caption != null) 'caption': caption,
      };

  GalleryPerson copyWith({
    String? id,
    String? Function()? caption,
  }) =>
      GalleryPerson(
        id: id ?? this.id,
        caption: caption == null ? this.caption : caption(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryPerson && id == other.id && caption == other.caption;

  @override
  int get hashCode => Object.hash(id, caption);
}
