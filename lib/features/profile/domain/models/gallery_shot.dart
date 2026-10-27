import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';

/// Один кадр галереи профиля (`GalleryShot`).
class GalleryShot {
  const GalleryShot({
    this.caption = '',
    this.photo,
    this.media = const <FamilyMedia>[],
  });

  /// Подпись кадра; у старых записей может быть пустой.
  final String caption;

  /// Одиночное фото кадра (устаревшее поле рядом с [media]).
  final String? photo;

  /// Фотографии и видео этого кадра.
  final List<FamilyMedia> media;

  factory GalleryShot.fromJson(Map<String, dynamic> json) => GalleryShot(
        caption: readString(json['caption']),
        photo: readNullableString(json['photo']),
        media: readMapList(json['media'])
            .map(FamilyMedia.fromJson)
            .toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'caption': caption,
        if (photo != null) 'photo': photo,
        if (media.isNotEmpty)
          'media': media.map((item) => item.toJson()).toList(growable: false),
      };

  GalleryShot copyWith({
    String? caption,
    String? Function()? photo,
    List<FamilyMedia>? media,
  }) =>
      GalleryShot(
        caption: caption ?? this.caption,
        photo: photo == null ? this.photo : photo(),
        media: media ?? this.media,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryShot &&
          caption == other.caption &&
          photo == other.photo &&
          listsEqual(media, other.media);

  @override
  int get hashCode => Object.hash(caption, photo, listsHash(media));
}
