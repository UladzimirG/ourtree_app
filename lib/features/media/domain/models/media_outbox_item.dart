import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

/// Операция выгрузки файла, ждущая сети.
///
/// Хранится в Hive (JSON), поэтому переживает перезапуск приложения: файл уже
/// лежит локально (в Hive или на диске), а в облако уедет при первой
/// возможности.
class MediaOutboxItem {
  const MediaOutboxItem({
    required this.assetId,
    required this.familyId,
    required this.userId,
    required this.name,
    this.type = MediaType.image,
    this.extension = 'jpg',
    this.hash,
    this.size,
    this.storedId,
    this.localPath,
    this.attempts = 0,
    this.lastError,
    this.createdAt = 0,
  });

  final String assetId;
  final String familyId;
  final String userId;
  final String name;
  final MediaType type;
  final String extension;
  final String? hash;
  final int? size;

  /// Идентификатор байтов в Hive (`hive://<id>`).
  final String? storedId;

  /// Путь к локальному файлу (если байты на диске).
  final String? localPath;

  final int attempts;
  final String? lastError;
  final int createdAt;

  factory MediaOutboxItem.fromJson(Map<String, dynamic> json) =>
      MediaOutboxItem(
        assetId: readString(json['assetId']),
        familyId: readString(json['familyId']),
        userId: readString(json['userId']),
        name: readString(json['name']),
        type: MediaType.fromWire(json['type']),
        extension: readString(json['extension'], fallback: 'jpg'),
        hash: readNullableString(json['hash']),
        size: readInt(json['size']),
        storedId: readNullableString(json['storedId']),
        localPath: readNullableString(json['localPath']),
        attempts: readInt(json['attempts']) ?? 0,
        lastError: readNullableString(json['lastError']),
        createdAt: readInt(json['createdAt']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'assetId': assetId,
        'familyId': familyId,
        'userId': userId,
        'name': name,
        'type': type.wireName,
        'extension': extension,
        if (hash != null) 'hash': hash,
        if (size != null) 'size': size,
        if (storedId != null) 'storedId': storedId,
        if (localPath != null) 'localPath': localPath,
        'attempts': attempts,
        if (lastError != null) 'lastError': lastError,
        if (createdAt > 0) 'createdAt': createdAt,
      };

  MediaOutboxItem copyWith({
    int? attempts,
    String? Function()? lastError,
  }) =>
      MediaOutboxItem(
        assetId: assetId,
        familyId: familyId,
        userId: userId,
        name: name,
        type: type,
        extension: extension,
        hash: hash,
        size: size,
        storedId: storedId,
        localPath: localPath,
        attempts: attempts ?? this.attempts,
        lastError: lastError == null ? this.lastError : lastError(),
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaOutboxItem &&
          assetId == other.assetId &&
          familyId == other.familyId &&
          userId == other.userId &&
          name == other.name &&
          type == other.type &&
          extension == other.extension &&
          hash == other.hash &&
          size == other.size &&
          storedId == other.storedId &&
          localPath == other.localPath &&
          attempts == other.attempts &&
          lastError == other.lastError &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        assetId,
        familyId,
        userId,
        name,
        type,
        extension,
        hash,
        size,
        storedId,
        localPath,
        attempts,
        lastError,
        createdAt,
      );
}
