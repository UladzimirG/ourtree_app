import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/settings_provider.dart';

/// Сколько снимков хранится одновременно.
const int backupKeptLimit = 30;

/// Минимальный интервал между автоматическими снимками.
const int backupThrottleMs = 5 * 60 * 1000;

/// Локальные резервные копии семейного архива.
///
/// Снимок — это JSON архива плюс копии всех файлов медиатеки. Поэтому после
/// восстановления фотографии доступны даже если оригиналы были удалены.
final backupsNotifierProvider =
    AsyncNotifierProvider<BackupsNotifier, BackupList>(
  BackupsNotifier.new,
);

class BackupsNotifier extends AsyncNotifier<BackupList> {
  MediaStorage get _storage => MediaStorage.instance;

  @override
  Future<BackupList> build() async {
    final entries = <BackupEntry>[];
    for (final name in _storage.backupNames()) {
      final entry = _entryOf(_storage.getBackup(name));
      if (entry != null) entries.add(entry);
    }
    entries.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return _list(entries);
  }

  FamilyData? get _family => ref.read(familyDataProvider).valueOrNull;

  /// Делает снимок текущего состояния вместе с файлами медиатеки.
  Future<BackupEntry?> create({bool automatic = false}) async {
    final family = _family;
    if (family == null) return null;

    final current = state.valueOrNull ?? const BackupList();
    if (automatic && current.backups.isNotEmpty) {
      final elapsed = DateTime.now().millisecondsSinceEpoch -
          current.backups.first.savedAt;
      if (elapsed < backupThrottleMs) return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final revision = family.revision ?? current.backups.length + 1;
    final name = 'family-$now-$revision.json';
    final entry = BackupEntry(
      name: name,
      savedAt: now,
      revision: revision,
      size: utf8.encode(jsonEncode(family.toJson())).length,
    );

    final media = <String, String>{};
    for (final asset in family.mediaLibrary) {
      final storedId = asset.storedId;
      if (storedId == null) continue;
      final bytes = await _storage.loadBytes(storedId);
      if (bytes != null) media[storedId] = base64Encode(bytes);
    }

    await _storage.putBackup(name, {
      'entry': entry.toJson(),
      'data': jsonEncode(family.toJson()),
      'media': media,
    });

    _set([entry, ...current.backups]);
    return entry;
  }

  /// Восстанавливает архив и все файлы из снимка.
  Future<bool> restore(String name) async {
    final bundle = _storage.getBackup(name);
    if (bundle == null) return false;

    await create();
    final media = bundle['media'];
    if (media is Map) {
      for (final entry in media.entries) {
        final id = entry.key;
        final encoded = entry.value;
        if (id is String && encoded is String) {
          await _storage.putBytes(id, base64Decode(encoded));
        }
      }
    }

    final raw = bundle['data'];
    if (raw is! String) return false;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return false;
    final data = FamilyData.fromJson(decoded.cast<String, dynamic>());
    ref.read(familyDataProvider.notifier).replaceData(data);
    ref.invalidate(familySettingsNotifierProvider);
    return true;
  }

  Future<void> delete(String name) async {
    await _storage.deleteBackup(name);
    final current = state.valueOrNull ?? const BackupList();
    _set(
      current.backups
          .where((entry) => entry.name != name)
          .toList(growable: false),
    );
  }

  BackupEntry? _entryOf(Map<String, dynamic>? bundle) {
    final raw = bundle?['entry'];
    if (raw is Map) {
      return BackupEntry.fromJson(raw.cast<String, dynamic>());
    }
    return null;
  }

  void _set(List<BackupEntry> entries) {
    final kept = entries.take(backupKeptLimit).toList(growable: false);
    for (final entry in entries.skip(backupKeptLimit)) {
      unawaited(_storage.deleteBackup(entry.name));
    }
    state = AsyncData(_list(kept));
  }

  BackupList _list(List<BackupEntry> entries) => BackupList(
        backups: List<BackupEntry>.unmodifiable(entries),
        kept: backupKeptLimit,
        throttleMs: backupThrottleMs,
        totalSize: entries.fold<int>(0, (sum, entry) => sum + entry.size),
        dirExists: true,
      );
}
