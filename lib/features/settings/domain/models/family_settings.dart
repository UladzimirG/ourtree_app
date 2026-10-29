import 'package:ourtree_app/core/utils/json_reader.dart';

/// Настройки семьи, которые лежат в корне `family.json`.
///
/// Это «шапка» хранилища: название и общее фото. Остальные данные
/// (`members`, `timelineEvents`) живут в агрегате `FamilyData`.
class FamilySettings {
  const FamilySettings({
    required this.familyName,
    this.familySubtitle = '',
    this.familyPhoto,
    this.showFamilyPhotoInHeader = true,
    this.showEventPhotos = true,
    this.revision,
    this.nameIsCustom = false,
    this.subtitleIsCustom = false,
  });

  /// Название семьи по умолчанию, если в файле его нет.
  static const String fallbackName = 'Our Tree';

  final String familyName;

  /// Необязательный подзаголовок на главной странице.
  ///
  /// Пользователь задаёт его в настройках; пустая строка означает «не
  /// показывать подзаголовок вовсе».
  final String familySubtitle;

  /// Название изменено пользователем.
  ///
  /// Пока флаг снят, при загрузке подставляется локализованное название
  /// демо-архива текущего языка — так сохранённая копия не «залипает» на
  /// названии другого языка.
  final bool nameIsCustom;

  /// Подзаголовок изменён пользователем (логика та же, что у [nameIsCustom]).
  final bool subtitleIsCustom;

  /// Путь к общему фото семьи.
  final String? familyPhoto;

  /// Показывать ли общее фото семьи в шапке приложения.
  final bool showFamilyPhotoInHeader;

  /// Показывать ли фотографии в карточках таймлайна.
  final bool showEventPhotos;

  /// Метка сервера, защищающая от одновременной перезаписи с двух устройств.
  final int? revision;

  factory FamilySettings.fromJson(Map<String, dynamic> json) => FamilySettings(
        familyName: readString(json['familyName'], fallback: fallbackName),
        familySubtitle: readString(json['familySubtitle']),
        familyPhoto: readNullableString(json['familyPhoto']),
        showFamilyPhotoInHeader:
            readBool(json['showFamilyPhotoInHeader']) ?? true,
        showEventPhotos: readBool(json['showEventPhotos']) ?? true,
        revision: readInt(json['revision']),
        nameIsCustom: readBool(json['nameIsCustom']) ?? false,
        subtitleIsCustom: readBool(json['subtitleIsCustom']) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'familyName': familyName,
        if (familySubtitle.trim().isNotEmpty) 'familySubtitle': familySubtitle,
        if (familyPhoto != null && familyPhoto!.isNotEmpty)
          'familyPhoto': familyPhoto,
        'showFamilyPhotoInHeader': showFamilyPhotoInHeader,
        'showEventPhotos': showEventPhotos,
        if (revision != null) 'revision': revision,
        if (nameIsCustom) 'nameIsCustom': true,
        if (subtitleIsCustom) 'subtitleIsCustom': true,
      };

  /// Копия с изменёнными полями.
  ///
  /// Nullable-поля принимают колбэк, чтобы их можно было очистить:
  /// `copyWith(familyPhoto: () => null)`.
  FamilySettings copyWith({
    String? familyName,
    String? familySubtitle,
    String? Function()? familyPhoto,
    bool? showFamilyPhotoInHeader,
    bool? showEventPhotos,
    int? Function()? revision,
    bool? nameIsCustom,
    bool? subtitleIsCustom,
  }) =>
      FamilySettings(
        familyName: familyName ?? this.familyName,
        familySubtitle: familySubtitle ?? this.familySubtitle,
        familyPhoto: familyPhoto == null ? this.familyPhoto : familyPhoto(),
        showFamilyPhotoInHeader:
            showFamilyPhotoInHeader ?? this.showFamilyPhotoInHeader,
        showEventPhotos: showEventPhotos ?? this.showEventPhotos,
        revision: revision == null ? this.revision : revision(),
        nameIsCustom: nameIsCustom ?? this.nameIsCustom,
        subtitleIsCustom: subtitleIsCustom ?? this.subtitleIsCustom,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilySettings &&
          familyName == other.familyName &&
          familySubtitle == other.familySubtitle &&
          familyPhoto == other.familyPhoto &&
          showFamilyPhotoInHeader == other.showFamilyPhotoInHeader &&
          showEventPhotos == other.showEventPhotos &&
          revision == other.revision &&
          nameIsCustom == other.nameIsCustom &&
          subtitleIsCustom == other.subtitleIsCustom;

  @override
  int get hashCode => Object.hash(
        familyName,
        familySubtitle,
        familyPhoto,
        showFamilyPhotoInHeader,
        showEventPhotos,
        revision,
        nameIsCustom,
        subtitleIsCustom,
      );
}
