import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/profile/domain/models/event_kind.dart';
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';
import 'package:ourtree_app/features/profile/domain/models/photo_position.dart';

/// Событие семейного таймлайна (`TimelineEvent` из `src/data/family.ts`).
class TimelineEvent {
  const TimelineEvent({
    required this.id,
    required this.date,
    required this.title,
    this.text = '',
    this.kind = EventKind.milestone,
    this.place,
    this.photo,
    this.photoPosition,
    this.photoZoom,
    this.media = const <FamilyMedia>[],
    this.memberId,
    this.showElapsed,
    this.showInCalendar,
    this.hiddenFrom = const <String>[],
  });

  final String id;

  /// Дата в формате `YYYY-MM-DD`; формат сохраняется как есть для сортировки
  /// и совместимости с сервером.
  final String date;

  final String title;
  final String text;
  final EventKind kind;
  final String? place;

  /// Путь к обложке события.
  final String? photo;
  final PhotoPosition? photoPosition;
  final double? photoZoom;

  final List<FamilyMedia> media;

  /// Профиль, к которому относится событие (для дней рождения).
  final String? memberId;

  /// Показывать ли «сколько прошло с этого дня».
  final bool? showElapsed;

  /// Отмечать ли дату события в семейном календаре.
  ///
  /// `null` и `true` — отмечать, `false` — скрыть.
  final bool? showInCalendar;

  /// Идентификаторы аккаунтов и гостевых ссылок, которым событие не видно.
  ///
  /// Поле проверяет сервер (`hiddenFrom` в `validateFamily`), хотя в
  /// TypeScript-типе оно не описано.
  final List<String> hiddenFrom;

  bool get hasMedia => media.isNotEmpty;

  /// Дата события как [DateTime]; `null`, если строка некорректна.
  DateTime? get eventDate => DateTime.tryParse(date);

  /// Скрыто ли событие от пользователя [uid].
  bool isHiddenFrom(String? uid) => uid != null && hiddenFrom.contains(uid);

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    final position = readMap(json['photoPosition']);
    return TimelineEvent(
      id: readString(json['id']),
      date: readString(json['date']),
      title: readString(json['title']),
      text: readString(json['text']),
      kind: EventKind.fromWire(json['kind']),
      place: readNullableString(json['place']),
      photo: readNullableString(json['photo']),
      photoPosition: position == null ? null : PhotoPosition.fromJson(position),
      photoZoom: readDouble(json['photoZoom']),
      media: readMapList(json['media'])
          .map(FamilyMedia.fromJson)
          .toList(growable: false),
      memberId: readNullableString(json['memberId']),
      showElapsed: readBool(json['showElapsed']),
      showInCalendar: readBool(json['showInCalendar']),
      hiddenFrom: readStringList(json['hiddenFrom']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'title': title,
        'text': text,
        'kind': kind.wireName,
        if (place != null) 'place': place,
        if (photo != null) 'photo': photo,
        if (photoPosition != null) 'photoPosition': photoPosition!.toJson(),
        if (photoZoom != null) 'photoZoom': photoZoom,
        'media': media.map((item) => item.toJson()).toList(growable: false),
        if (memberId != null) 'memberId': memberId,
        if (showElapsed != null) 'showElapsed': showElapsed,
        if (showInCalendar != null) 'showInCalendar': showInCalendar,
        if (hiddenFrom.isNotEmpty) 'hiddenFrom': hiddenFrom,
      };

  /// Копия с изменёнными полями.
  ///
  /// Nullable-поля принимают колбэк, чтобы их можно было очистить:
  /// `copyWith(memberId: () => null)`.
  TimelineEvent copyWith({
    String? id,
    String? date,
    String? title,
    String? text,
    EventKind? kind,
    String? Function()? place,
    String? Function()? photo,
    PhotoPosition? Function()? photoPosition,
    double? Function()? photoZoom,
    List<FamilyMedia>? media,
    String? Function()? memberId,
    bool? Function()? showElapsed,
    bool? showInCalendar,
    List<String>? hiddenFrom,
  }) =>
      TimelineEvent(
        id: id ?? this.id,
        date: date ?? this.date,
        title: title ?? this.title,
        text: text ?? this.text,
        kind: kind ?? this.kind,
        place: place == null ? this.place : place(),
        photo: photo == null ? this.photo : photo(),
        photoPosition:
            photoPosition == null ? this.photoPosition : photoPosition(),
        photoZoom: photoZoom == null ? this.photoZoom : photoZoom(),
        media: media ?? this.media,
        memberId: memberId == null ? this.memberId : memberId(),
        showElapsed: showElapsed == null ? this.showElapsed : showElapsed(),
        showInCalendar: showInCalendar ?? this.showInCalendar,
        hiddenFrom: hiddenFrom ?? this.hiddenFrom,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineEvent &&
          id == other.id &&
          date == other.date &&
          title == other.title &&
          text == other.text &&
          kind == other.kind &&
          place == other.place &&
          photo == other.photo &&
          photoPosition == other.photoPosition &&
          photoZoom == other.photoZoom &&
          listsEqual(media, other.media) &&
          memberId == other.memberId &&
          showElapsed == other.showElapsed &&
          showInCalendar == other.showInCalendar &&
          listsEqual(hiddenFrom, other.hiddenFrom);

  @override
  int get hashCode => Object.hashAll([
        id,
        date,
        title,
        text,
        kind,
        place,
        photo,
        photoPosition,
        photoZoom,
        listsHash(media),
        memberId,
        showElapsed,
        showInCalendar,
        listsHash(hiddenFrom),
      ]);
}
