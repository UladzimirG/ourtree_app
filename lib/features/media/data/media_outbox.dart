import 'dart:convert';

import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/media/domain/models/media_outbox_item.dart';

/// Постоянная очередь выгрузки медиа (Hive, ключ `media_outbox`).
class MediaOutbox {
  MediaOutbox({MediaStorage? storage})
      : _storage = storage ?? MediaStorage.instance;

  static const String storageKey = 'media_outbox';

  final MediaStorage _storage;

  List<MediaOutboxItem> load() {
    final raw = _storage.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return const <MediaOutboxItem>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <MediaOutboxItem>[];
      return [
        for (final item in decoded)
          if (item is Map)
            MediaOutboxItem.fromJson(item.cast<String, dynamic>()),
      ];
    } catch (_) {
      return const <MediaOutboxItem>[];
    }
  }

  Future<List<MediaOutboxItem>> saveAll(List<MediaOutboxItem> items) async {
    final next = List<MediaOutboxItem>.unmodifiable(items);
    await _storage.putString(
      storageKey,
      jsonEncode(next.map((item) => item.toJson()).toList(growable: false)),
    );
    return next;
  }

  /// Добавляет операцию; повторная постановка того же ассета заменяет запись.
  Future<List<MediaOutboxItem>> add(MediaOutboxItem item) async {
    final items = load();
    final next = [
      for (final existing in items)
        if (existing.assetId != item.assetId) existing,
      item,
    ];
    return saveAll(next);
  }

  Future<List<MediaOutboxItem>> remove(String assetId) async {
    final items = load();
    return saveAll([
      for (final item in items)
        if (item.assetId != assetId) item,
    ]);
  }

  Future<List<MediaOutboxItem>> replace(MediaOutboxItem item) async {
    final items = load();
    return saveAll([
      for (final existing in items)
        if (existing.assetId == item.assetId) item else existing,
    ]);
  }
}
