import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Локальные файлы медиатеки.
///
/// Байты больше не держим в Hive (на web это IndexedDB с квотами): свои файлы
/// лежат в каталоге приложения, а Hive остаётся для метаданных и бэкапов.
/// На web файловой системы нет — там используем прежнее поведение (`hive://`).
class MediaFiles {
  MediaFiles._();

  static final MediaFiles instance = MediaFiles._();

  Directory? _directory;

  bool get isSupported => !kIsWeb;

  Future<Directory?> _dir() async {
    if (!isSupported) return null;
    final cached = _directory;
    if (cached != null && cached.existsSync()) return cached;

    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'media'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    _directory = dir;
    return dir;
  }

  /// Путь, по которому будет лежать файл [id].
  Future<String?> pathFor(String id, {String extension = 'jpg'}) async {
    final dir = await _dir();
    if (dir == null) return null;
    return p.join(dir.path, '$id.$extension');
  }

  /// Сохраняет байты и возвращает путь к файлу (или `null` на web).
  Future<String?> save(String id, Uint8List bytes, {String extension = 'jpg'}) async {
    final path = await pathFor(id, extension: extension);
    if (path == null) return null;
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<Uint8List?> read(String? path) async {
    if (path == null || path.isEmpty || !isSupported) return null;
    final file = File(path);
    if (!file.existsSync()) return null;
    return file.readAsBytes();
  }

  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty || !isSupported) return;
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }

  /// Удаляет локальные копии, на которые больше никто не ссылается.
  Future<void> deleteFolder() async {
    final dir = await _dir();
    if (dir == null || !dir.existsSync()) return;
    await dir.delete(recursive: true);
    _directory = null;
  }
}
