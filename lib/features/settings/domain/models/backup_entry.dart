import 'package:ourtree_app/core/utils/collection_equality.dart';
import 'package:ourtree_app/core/utils/json_reader.dart';

/// Одна резервная копия `family.json` (`BackupEntry`).
class BackupEntry {
  const BackupEntry({
    required this.name,
    required this.savedAt,
    required this.revision,
    required this.size,
  });

  /// Имя файла вида `family-<время в ms>-<revision>.json`.
  final String name;

  /// Момент создания снимка в миллисекундах с начала эпохи.
  final int savedAt;

  /// Ревизия данных на момент снимка.
  final int revision;

  /// Размер файла в байтах.
  final int size;

  DateTime get savedAtDate => DateTime.fromMillisecondsSinceEpoch(savedAt);

  factory BackupEntry.fromJson(Map<String, dynamic> json) => BackupEntry(
        name: readString(json['name']),
        savedAt: readInt(json['savedAt']) ?? 0,
        revision: readInt(json['revision']) ?? 0,
        size: readInt(json['size']) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'savedAt': savedAt,
        'revision': revision,
        'size': size,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupEntry &&
          name == other.name &&
          savedAt == other.savedAt &&
          revision == other.revision &&
          size == other.size;

  @override
  int get hashCode => Object.hash(name, savedAt, revision, size);
}

/// Состояние хранилища резервных копий (`BackupList`).
class BackupList {
  const BackupList({
    this.backups = const <BackupEntry>[],
    this.kept = 0,
    this.throttleMs = 0,
    this.totalSize = 0,
    this.dirExists = false,
  });

  /// Снимки, новые сверху.
  final List<BackupEntry> backups;

  /// Сколько снимков сервер хранит до удаления старых.
  final int kept;

  /// Минимальный интервал между автоматическими снимками, мс.
  final int throttleMs;

  /// Суммарный размер папки с копиями, байты.
  final int totalSize;

  /// Существует ли папка с копиями на диске.
  final bool dirExists;

  factory BackupList.fromJson(Map<String, dynamic> json) => BackupList(
        backups: readMapList(json['backups'])
            .map(BackupEntry.fromJson)
            .toList(growable: false),
        kept: readInt(json['kept']) ?? 0,
        throttleMs: readInt(json['throttleMs']) ?? 0,
        totalSize: readInt(json['totalSize']) ?? 0,
        dirExists: readBool(json['dirExists']) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'backups': backups
            .map((backup) => backup.toJson())
            .toList(growable: false),
        'kept': kept,
        'throttleMs': throttleMs,
        'totalSize': totalSize,
        'dirExists': dirExists,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupList &&
          listsEqual(backups, other.backups) &&
          kept == other.kept &&
          throttleMs == other.throttleMs &&
          totalSize == other.totalSize &&
          dirExists == other.dirExists;

  @override
  int get hashCode => Object.hash(
        listsHash(backups),
        kept,
        throttleMs,
        totalSize,
        dirExists,
      );
}
