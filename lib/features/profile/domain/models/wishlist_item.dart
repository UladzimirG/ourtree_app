import 'package:ourtree_app/core/utils/json_reader.dart';

/// Пункт вишлиста профиля (`FamilyMember.wishlist`).
class WishlistItem {
  const WishlistItem({
    required this.title,
    this.url,
    this.note,
  });

  final String title;

  /// Ссылка на товар.
  final String? url;

  /// Пояснение или пожелание к подарку.
  final String? note;

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        title: readString(json['title']),
        url: readNullableString(json['url']),
        note: readNullableString(json['note']),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        if (url != null) 'url': url,
        if (note != null) 'note': note,
      };

  WishlistItem copyWith({
    String? title,
    String? Function()? url,
    String? Function()? note,
  }) =>
      WishlistItem(
        title: title ?? this.title,
        url: url == null ? this.url : url(),
        note: note == null ? this.note : note(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItem &&
          title == other.title &&
          url == other.url &&
          note == other.note;

  @override
  int get hashCode => Object.hash(title, url, note);
}
