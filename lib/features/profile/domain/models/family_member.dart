import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';
import 'package:ourtree_app/features/profile/domain/models/gallery_shot.dart';
import 'package:ourtree_app/features/profile/domain/models/photo_position.dart';
import 'package:ourtree_app/features/profile/domain/models/wishlist_item.dart';

/// Профиль члена семьи (`FamilyMember` из `src/data/family.ts`).
class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.role,
    required this.name,
    required this.nickname,
    required this.birthday,
    this.showBirthdayOnTimeline,
    this.showInCalendar,
    this.birthdayMedia = const <FamilyMedia>[],
    this.photo,
    this.photoPosition,
    this.photoZoom,
    this.about = '',
    this.habits = const <String>[],
    this.quotes = const <String>[],
    this.wishlistUrl,
    this.wishlist = const <WishlistItem>[],
    this.gallery = const <GalleryShot>[],
    this.accent = '',
  });

  /// Идентификатор члена семьи; используется в ссылках и отметках на фото.
  final String id;

  /// Свободная подпись роли в семье («Папа», «Мама»), не путать с `UserRole`.
  final String role;

  final String name;

  /// Домашнее прозвище.
  final String nickname;

  /// Дата рождения в формате `YYYY-MM-DD`.
  final String birthday;

  /// Показывать ли день рождения в таймлайне.
  ///
  /// `null` и `true` — показывать, `false` — скрыть. В исходных данных поле
  /// необязательное, поэтому `null` сохранён как отдельное состояние.
  final bool? showBirthdayOnTimeline;

  /// Отмечать ли день рождения в семейном календаре.
  ///
  /// `null` и `true` — отмечать, `false` — скрыть.
  final bool? showInCalendar;

  /// Медиа, прикреплённые к пункту «День рождения» в таймлайне.
  final List<FamilyMedia> birthdayMedia;

  /// Путь к аватару.
  final String? photo;

  /// Точка фокуса аватара.
  final PhotoPosition? photoPosition;

  /// Масштаб аватара при кадрировании.
  final double? photoZoom;

  /// Описание профиля; может содержать простую HTML-разметку (`<em>`).
  final String about;

  final List<String> habits;
  final List<String> quotes;

  /// Устаревшая общая ссылка на вишлист рядом со списком [wishlist].
  final String? wishlistUrl;

  final List<WishlistItem> wishlist;
  final List<GalleryShot> gallery;

  /// Цвет акцента профиля в формате `#rrggbb`.
  final String accent;

  /// Дата рождения как [DateTime]; `null`, если строка некорректна.
  DateTime? get birthdayDate => DateTime.tryParse(birthday);

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final position = readMap(json['photoPosition']);
    return FamilyMember(
      id: readString(json['id']),
      role: readString(json['role']),
      name: readString(json['name']),
      nickname: readString(json['nickname']),
      birthday: readString(json['birthday']),
      showBirthdayOnTimeline: readBool(json['showBirthdayOnTimeline']),
      showInCalendar: readBool(json['showInCalendar']),
      birthdayMedia: readMapList(json['birthdayMedia'])
          .map(FamilyMedia.fromJson)
          .toList(growable: false),
      photo: readNullableString(json['photo']),
      photoPosition: position == null ? null : PhotoPosition.fromJson(position),
      photoZoom: readDouble(json['photoZoom']),
      about: readString(json['about']),
      habits: readStringList(json['habits']),
      quotes: readStringList(json['quotes']),
      wishlistUrl: readNullableString(json['wishlistUrl']),
      wishlist: readMapList(json['wishlist'])
          .map(WishlistItem.fromJson)
          .toList(growable: false),
      gallery: readMapList(json['gallery'])
          .map(GalleryShot.fromJson)
          .toList(growable: false),
      accent: readString(json['accent']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'name': name,
        'nickname': nickname,
        'birthday': birthday,
        if (showBirthdayOnTimeline != null)
          'showBirthdayOnTimeline': showBirthdayOnTimeline,
        if (showInCalendar != null) 'showInCalendar': showInCalendar,
        'birthdayMedia': birthdayMedia
            .map((media) => media.toJson())
            .toList(growable: false),
        if (photo != null) 'photo': photo,
        if (photoPosition != null) 'photoPosition': photoPosition!.toJson(),
        if (photoZoom != null) 'photoZoom': photoZoom,
        'about': about,
        'habits': habits,
        'quotes': quotes,
        if (wishlistUrl != null) 'wishlistUrl': wishlistUrl,
        'wishlist': wishlist
            .map((item) => item.toJson())
            .toList(growable: false),
        'gallery': gallery
            .map((shot) => shot.toJson())
            .toList(growable: false),
        'accent': accent,
      };

  /// Копия с изменёнными полями.
  ///
  /// Nullable-поля принимают колбэк, чтобы их можно было очистить:
  /// `copyWith(photo: () => null)`.
  FamilyMember copyWith({
    String? id,
    String? role,
    String? name,
    String? nickname,
    String? birthday,
    bool? showBirthdayOnTimeline,
    bool? showInCalendar,
    List<FamilyMedia>? birthdayMedia,
    String? Function()? photo,
    PhotoPosition? Function()? photoPosition,
    double? Function()? photoZoom,
    String? about,
    List<String>? habits,
    List<String>? quotes,
    String? Function()? wishlistUrl,
    List<WishlistItem>? wishlist,
    List<GalleryShot>? gallery,
    String? accent,
  }) =>
      FamilyMember(
        id: id ?? this.id,
        role: role ?? this.role,
        name: name ?? this.name,
        nickname: nickname ?? this.nickname,
        birthday: birthday ?? this.birthday,
        showBirthdayOnTimeline:
            showBirthdayOnTimeline ?? this.showBirthdayOnTimeline,
        showInCalendar: showInCalendar ?? this.showInCalendar,
        birthdayMedia: birthdayMedia ?? this.birthdayMedia,
        photo: photo == null ? this.photo : photo(),
        photoPosition:
            photoPosition == null ? this.photoPosition : photoPosition(),
        photoZoom: photoZoom == null ? this.photoZoom : photoZoom(),
        about: about ?? this.about,
        habits: habits ?? this.habits,
        quotes: quotes ?? this.quotes,
        wishlistUrl: wishlistUrl == null ? this.wishlistUrl : wishlistUrl(),
        wishlist: wishlist ?? this.wishlist,
        gallery: gallery ?? this.gallery,
        accent: accent ?? this.accent,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMember &&
          id == other.id &&
          role == other.role &&
          name == other.name &&
          nickname == other.nickname &&
          birthday == other.birthday &&
          showBirthdayOnTimeline == other.showBirthdayOnTimeline &&
          showInCalendar == other.showInCalendar &&
          listsEqual(birthdayMedia, other.birthdayMedia) &&
          photo == other.photo &&
          photoPosition == other.photoPosition &&
          photoZoom == other.photoZoom &&
          about == other.about &&
          listsEqual(habits, other.habits) &&
          listsEqual(quotes, other.quotes) &&
          wishlistUrl == other.wishlistUrl &&
          listsEqual(wishlist, other.wishlist) &&
          listsEqual(gallery, other.gallery) &&
          accent == other.accent;

  @override
  int get hashCode => Object.hashAll([
        id,
        role,
        name,
        nickname,
        birthday,
        showBirthdayOnTimeline,
        showInCalendar,
        listsHash(birthdayMedia),
        photo,
        photoPosition,
        photoZoom,
        about,
        listsHash(habits),
        listsHash(quotes),
        wishlistUrl,
        listsHash(wishlist),
        listsHash(gallery),
        accent,
      ]);
}
