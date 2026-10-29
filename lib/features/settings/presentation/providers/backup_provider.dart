import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/utils/asset_path.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_provider.g.dart';

/// Сколько снимков хранится одновременно.
const int backupKeptLimit = 30;

/// Минимальный интервал между автоматическими снимками.
const int backupThrottleMs = 5 * 60 * 1000;

/// Готовый к сохранению на устройство бэкап.
class BackupExport {
  const BackupExport({required this.entry, required this.bytes});

  final BackupEntry entry;
  final Uint8List bytes;
}

/// Локальные резервные копии семейного архива.
///
/// Снимок — это полный JSON архива плюс копии всех локальных файлов медиатеки
/// (Hive и ассетов). Поэтому после восстановления фотографии доступны, даже
/// если оригиналы были удалены.
@Riverpod(keepAlive: true)
class BackupsNotifier extends _$BackupsNotifier {
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

  FamilyData? get _family => ref.read(familyDataProvider).value;

  /// Делает снимок текущего состояния вместе с медиа.
  Future<BackupEntry?> create({
    bool automatic = false,
    bool includeMedia = true,
  }) async {
    final bundle = await _createBundle(
      automatic: automatic,
      includeMedia: includeMedia,
    );
    return bundle?.entry;
  }

  /// Делает снимок и возвращает файл для сохранения на устройство.
  Future<BackupExport?> createExport({required bool includeMedia}) async {
    final bundle = await _createBundle(
      automatic: false,
      includeMedia: includeMedia,
    );
    if (bundle == null) return null;

    final exported = <String, dynamic>{
      'format': 'ourtree-backup',
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'includeMedia': includeMedia,
      'entry': bundle.entry.toJson(),
      ...bundle.data,
    };
    return BackupExport(
      entry: bundle.entry,
      bytes: Uint8List.fromList(utf8.encode(jsonEncode(exported))),
    );
  }

  Future<_BuiltBackup?> _createBundle({
    required bool automatic,
    required bool includeMedia,
  }) async {
    final family = _family;
    if (family == null) return null;

    final current = state.value ?? const BackupList();
    if (automatic && current.backups.isNotEmpty) {
      final elapsed = DateTime.now().millisecondsSinceEpoch -
          current.backups.first.savedAt;
      if (elapsed < backupThrottleMs) return null;
    }

    final data = await _bundle(family, includeMedia: includeMedia);
    final now = DateTime.now().millisecondsSinceEpoch;
    final revision = family.revision ?? current.backups.length + 1;
    final name = 'family-$now-$revision.json';
    final size = utf8.encode(jsonEncode(data)).length;
    final entry = BackupEntry(
      name: name,
      savedAt: now,
      revision: revision,
      size: size,
    );

    final stored = <String, dynamic>{
      'entry': entry.toJson(),
      ...data,
    };
    await _storage.putBackup(name, stored);
    _set([entry, ...current.backups]);
    return _BuiltBackup(entry: entry, data: data);
  }

  /// Собирает полный архив: настройки, все поля, медиатеку и байты файлов.
  Future<Map<String, dynamic>> _bundle(
    FamilyData family, {
    required bool includeMedia,
  }) async {
    final media = <String, String>{};
    final assets = <String, String>{};

    if (includeMedia) {
      for (final asset in family.mediaLibrary) {
        final storedId = asset.storedId;
        if (storedId != null) {
          final bytes = await _storage.loadBytes(storedId);
          if (bytes != null) media[storedId] = base64Encode(bytes);
          continue;
        }

        final assetPath = familyPhotoAssetPath(asset.source);
        if (assetPath == null) continue;
        try {
          final data = await rootBundle.load(assetPath);
          assets[asset.source] = base64Encode(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          );
        } catch (_) {
          // Внешний/отсутствующий файл останется в данных как ссылка.
        }
      }
    }

    final accounts =
        ref.read(accountsProvider).value ?? const <Account>[];
    final guestLinks = ref.read(guestLinksProvider).value ??
        const <GuestLink>[];

    return <String, dynamic>{
      'data': family.toJson(),
      'media': media,
      'assets': assets,
      'accounts': accounts.map((account) => account.toJson()).toList(),
      'guestLinks': guestLinks.map((link) => link.toJson()).toList(),
    };
  }

  /// Восстанавливает архив и все файлы из снимка.
  Future<bool> restore(String name) async {
    final bundle = _storage.getBackup(name);
    if (bundle == null) return false;

    await create();
    return _applyBundle(bundle);
  }

  /// Импортирует бэкап из файла, сохранённого на устройстве.
  Future<bool> importBytes(Uint8List bytes) async {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) return false;
      final bundle = decoded.cast<String, dynamic>();
      if (bundle['format'] != 'ourtree-backup' && bundle['data'] == null) {
        return false;
      }
      return await _applyBundle(bundle);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _applyBundle(Map<String, dynamic> bundle) async {
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

    // Встроенные файлы из APK восстанавливаем в Hive и переписываем ссылки:
    // после переустановки/обновления приложения они больше не зависят от
    // наличия исходного файла в сборке.
    final replacedSources = <String, String>{};
    final assets = bundle['assets'];
    if (assets is Map) {
      for (final entry in assets.entries) {
        final source = entry.key;
        final encoded = entry.value;
        if (source is! String || encoded is! String) continue;
        final digest = sha256.convert(utf8.encode(source)).toString();
        final id = 'restored-${digest.substring(0, 24)}';
        await _storage.putBytes(id, base64Decode(encoded));
        for (final alias in _sourceAliases(source)) {
          replacedSources[alias] = 'hive://$id';
        }
      }
    }

    final raw = bundle['data'];
    Map<String, dynamic>? data;
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) data = decoded.cast<String, dynamic>();
    } else if (raw is Map) {
      data = raw.cast<String, dynamic>();
    }
    if (data == null) return false;
    if (replacedSources.isNotEmpty) {
      final replaced = _replaceSources(data, replacedSources);
      if (replaced is Map) data = replaced.cast<String, dynamic>();
    }

    final family = FamilyData.fromJson(data);
    ref.read(familyDataProvider.notifier).replaceData(family);
    ref.invalidate(familySettingsProvider);

    final accounts = bundle['accounts'];
    if (accounts is List) {
      ref.read(accountsProvider.notifier).replaceAll([
        for (final item in accounts)
          if (item is Map) Account.fromJson(item.cast<String, dynamic>()),
      ]);
    }
    final links = bundle['guestLinks'];
    if (links is List) {
      ref.read(guestLinksProvider.notifier).replaceAll([
        for (final item in links)
          if (item is Map) GuestLink.fromJson(item.cast<String, dynamic>()),
      ]);
    }
    return true;
  }

  Future<void> delete(String name) async {
    await _storage.deleteBackup(name);
    final current = state.value ?? const BackupList();
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

Set<String> _sourceAliases(String source) {
  final normalized = source.trim().replaceAll('\\', '/');
  final aliases = <String>{normalized};
  final relative = normalized.replaceFirst(RegExp(r'^/+'), '');
  if (relative.isNotEmpty) aliases.add(relative);
  final asset = familyPhotoAssetPath(normalized);
  if (asset != null) aliases.add(asset);
  return aliases;
}

/// Рекурсивно заменяет строки-источники медиа на `hive://...`.
Object? _replaceSources(
  Object? value,
  Map<String, String> replacements,
) {
  if (value is String) return replacements[value] ?? value;
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key.toString(): _replaceSources(entry.value, replacements),
    };
  }
  if (value is List) {
    return [
      for (final item in value) _replaceSources(item, replacements),
    ];
  }
  return value;
}

class _BuiltBackup {
  const _BuiltBackup({required this.entry, required this.data});

  final BackupEntry entry;
  final Map<String, dynamic> data;
}
