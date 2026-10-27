import 'package:ourtree_app/core/utils/json_reader.dart';

/// Настройки семьи, которые лежат в корне `family.json`.
///
/// Это «шапка» хранилища: название и общее фото. Остальные данные
/// (`members`, `timelineEvents`) живут в агрегате `FamilyData`.
class FamilySettings {
  const FamilySettings({
    required this.familyName,
    this.familyPhoto,
    this.showFamilyPhotoInHeader = true,
    this.showEventPhotos = true,
    this.revision,
  });

  /// Название семьи по умолчанию, если в файле его нет.
  static const String fallbackName = 'Our Tree';

  final String familyName;

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
        familyPhoto: readNullableString(json['familyPhoto']),
        showFamilyPhotoInHeader:
            readBool(json['showFamilyPhotoInHeader']) ?? true,
        showEventPhotos: readBool(json['showEventPhotos']) ?? true,
        revision: readInt(json['revision']),
      );

  Map<String, dynamic> toJson() => {
        'familyName': familyName,
        if (familyPhoto != null && familyPhoto!.isNotEmpty)
          'familyPhoto': familyPhoto,
        'showFamilyPhotoInHeader': showFamilyPhotoInHeader,
        'showEventPhotos': showEventPhotos,
        if (revision != null) 'revision': revision,
      };

  /// Копия с изменёнными полями.
  ///
  /// Nullable-поля принимают колбэк, чтобы их можно было очистить:
  /// `copyWith(familyPhoto: () => null)`.
  FamilySettings copyWith({
    String? familyName,
    String? Function()? familyPhoto,
    bool? showFamilyPhotoInHeader,
    bool? showEventPhotos,
    int? Function()? revision,
  }) =>
      FamilySettings(
        familyName: familyName ?? this.familyName,
        familyPhoto: familyPhoto == null ? this.familyPhoto : familyPhoto(),
        showFamilyPhotoInHeader:
            showFamilyPhotoInHeader ?? this.showFamilyPhotoInHeader,
        showEventPhotos: showEventPhotos ?? this.showEventPhotos,
        revision: revision == null ? this.revision : revision(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilySettings &&
          familyName == other.familyName &&
          familyPhoto == other.familyPhoto &&
          showFamilyPhotoInHeader == other.showFamilyPhotoInHeader &&
          showEventPhotos == other.showEventPhotos &&
          revision == other.revision;

  @override
  int get hashCode => Object.hash(
        familyName,
        familyPhoto,
        showFamilyPhotoInHeader,
        showEventPhotos,
        revision,
      );
}
