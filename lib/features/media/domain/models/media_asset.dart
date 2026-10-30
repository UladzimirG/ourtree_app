import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';
import 'package:ourtree_app/features/profile/domain/models/family_media.dart';
import 'package:ourtree_app/features/profile/domain/models/gallery_person.dart';

/// Состояние выгрузки файла в Firebase Storage.
enum MediaUploadState {
  local('local'),
  queued('queued'),
  uploading('uploading'),
  ready('ready'),
  failed('failed');

  const MediaUploadState(this.wireName);

  final String wireName;

  static MediaUploadState fromWire(Object? value) {
    for (final state in values) {
      if (state.wireName == value) return state;
    }
    return MediaUploadState.local;
  }
}

/// Файл в общей медиатеке семьи.
///
/// Сам файл хранится в [MediaStorage] (источник `hive://<id>`), в файловой
/// системе устройства ([localPath]) либо в Firebase Storage (`downloadUrl`).
/// Описание и кадрирование задаются отдельно на каждой связи с участником или
/// событием — это делает [FamilyMedia].
class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.source,
    this.type = MediaType.image,
    this.name,
    this.createdAt = 0,
    this.size,
    this.hash,
    this.people = const <GalleryPerson>[],
    this.storagePath,
    this.downloadUrl,
    this.thumbUrl,
    this.posterUrl,
    this.localPath,
    this.width,
    this.height,
    this.durationMs,
    this.uploadState = MediaUploadState.local,
    this.uploadedBy,
    this.updatedAt = 0,
    this.deletedAt,
  });

  final String id;
  final String source;
  final MediaType type;
  final String? name;
  final int createdAt;
  final int? size;

  /// SHA-256 содержимого — для поиска дублей при загрузке.
  final String? hash;

  /// Кто изображён на файле. Общее свойство самого снимка.
  final List<GalleryPerson> people;

  bool get isVideo => type == MediaType.video;

  bool get isStored => source.startsWith('hive://');

  String? get storedId =>
      isStored ? source.substring('hive://'.length) : null;

  // --- v2: облако ---

  /// Путь в Storage: `families/{fid}/media/{assetId}/original.jpg`.
  final String? storagePath;

  final String? downloadUrl;
  final String? thumbUrl;

  /// Кадр-постер для видео.
  final String? posterUrl;

  /// Файл на устройстве (вытеснил `hive://`-байты).
  final String? localPath;

  final int? width;
  final int? height;
  final int? durationMs;

  final MediaUploadState uploadState;
  final String? uploadedBy;

  /// Время последнего изменения документа в миллисекундах эпохи.
  final int updatedAt;
  final int? deletedAt;

  bool get isRemote => (downloadUrl ?? '').isNotEmpty;

  bool get isLocalFile => (localPath ?? '').isNotEmpty;

  bool get isReady => uploadState == MediaUploadState.ready && isRemote;

  /// Ключ кэша: содержимое неизменяемо, поэтому SHA-256 — идеальный ключ,
  /// инвалидация после перезаписи файла не нужна.
  String get cacheKey => (hash?.isNotEmpty ?? false) ? hash! : id;

  /// Источник для отображения: локальный файл → облако → прежний `source`.
  String get displaySource {
    if (isLocalFile) return localPath!;
    if (isRemote) return downloadUrl!;
    return source;
  }

  factory MediaAsset.fromJson(Map<String, dynamic> json) => MediaAsset(
        id: readString(json['id']),
        source: readString(json['source']),
        type: MediaType.fromWire(json['type']),
        name: readNullableString(json['name']),
        createdAt: readInt(json['createdAt']) ?? 0,
        size: readInt(json['size']),
        hash: readNullableString(json['hash']),
        people: readMapList(json['people'])
            .map(GalleryPerson.fromJson)
            .toList(growable: false),
        storagePath: readNullableString(json['storagePath']),
        downloadUrl: readNullableString(json['downloadUrl']),
        thumbUrl: readNullableString(json['thumbUrl']),
        posterUrl: readNullableString(json['posterUrl']),
        localPath: readNullableString(json['localPath']),
        width: readInt(json['width']),
        height: readInt(json['height']),
        durationMs: readInt(json['durationMs']),
        uploadState: MediaUploadState.fromWire(json['uploadState']),
        uploadedBy: readNullableString(json['uploadedBy']),
        updatedAt: readInt(json['updatedAt']) ?? 0,
        deletedAt: readInt(json['deletedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'type': type.wireName,
        if (name != null) 'name': name,
        if (createdAt > 0) 'createdAt': createdAt,
        if (size != null) 'size': size,
        if (hash != null) 'hash': hash,
        if (people.isNotEmpty)
          'people': people.map((person) => person.toJson()).toList(),
        if (storagePath != null) 'storagePath': storagePath,
        if (downloadUrl != null) 'downloadUrl': downloadUrl,
        if (thumbUrl != null) 'thumbUrl': thumbUrl,
        if (posterUrl != null) 'posterUrl': posterUrl,
        if (localPath != null) 'localPath': localPath,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (durationMs != null) 'durationMs': durationMs,
        if (uploadState != MediaUploadState.local)
          'uploadState': uploadState.wireName,
        if (uploadedBy != null) 'uploadedBy': uploadedBy,
        if (updatedAt > 0) 'updatedAt': updatedAt,
        if (deletedAt != null) 'deletedAt': deletedAt,
      };

  MediaAsset copyWith({
    String? id,
    String? source,
    MediaType? type,
    String? Function()? name,
    int? createdAt,
    int? Function()? size,
    String? Function()? hash,
    List<GalleryPerson>? people,
    String? Function()? storagePath,
    String? Function()? downloadUrl,
    String? Function()? thumbUrl,
    String? Function()? posterUrl,
    String? Function()? localPath,
    int? Function()? width,
    int? Function()? height,
    int? Function()? durationMs,
    MediaUploadState? uploadState,
    String? Function()? uploadedBy,
    int? updatedAt,
    int? Function()? deletedAt,
  }) =>
      MediaAsset(
        id: id ?? this.id,
        source: source ?? this.source,
        type: type ?? this.type,
        name: name == null ? this.name : name(),
        createdAt: createdAt ?? this.createdAt,
        size: size == null ? this.size : size(),
        hash: hash == null ? this.hash : hash(),
        people: people ?? this.people,
        storagePath: storagePath == null ? this.storagePath : storagePath(),
        downloadUrl: downloadUrl == null ? this.downloadUrl : downloadUrl(),
        thumbUrl: thumbUrl == null ? this.thumbUrl : thumbUrl(),
        posterUrl: posterUrl == null ? this.posterUrl : posterUrl(),
        localPath: localPath == null ? this.localPath : localPath(),
        width: width == null ? this.width : width(),
        height: height == null ? this.height : height(),
        durationMs: durationMs == null ? this.durationMs : durationMs(),
        uploadState: uploadState ?? this.uploadState,
        uploadedBy: uploadedBy == null ? this.uploadedBy : uploadedBy(),
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt == null ? this.deletedAt : deletedAt(),
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
          hash == other.hash &&
          listsEqual(people, other.people) &&
          storagePath == other.storagePath &&
          downloadUrl == other.downloadUrl &&
          thumbUrl == other.thumbUrl &&
          posterUrl == other.posterUrl &&
          localPath == other.localPath &&
          width == other.width &&
          height == other.height &&
          durationMs == other.durationMs &&
          uploadState == other.uploadState &&
          uploadedBy == other.uploadedBy &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hashAll(<Object?>[
        id,
        source,
        type,
        name,
        createdAt,
        size,
        hash,
        listsHash(people),
        storagePath,
        downloadUrl,
        thumbUrl,
        posterUrl,
        localPath,
        width,
        height,
        durationMs,
        uploadState,
        uploadedBy,
        updatedAt,
        deletedAt,
      ]);
}
