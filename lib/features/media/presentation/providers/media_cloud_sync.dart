import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/media/domain/media_pending.dart';
import 'package:ourtree_app/features/media/presentation/providers/bulk_upload_provider.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_outbox_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_cloud_sync.g.dart';

/// Догружает локальные файлы в облако, как только семья подключена.
///
/// Раньше для этого нужно было вручную нажать «Загрузить всё локальное»: фото,
/// добавленные до создания или подключения семьи, оставались только на этом
/// устройстве и не появлялись в общем архиве.
@Riverpod(keepAlive: true)
class MediaCloudSync extends _$MediaCloudSync {
  bool _running = false;

  @override
  bool build() {
    ref.listen(activeFamilyControllerProvider, (previous, next) {
      final family = next.value;
      if (family == null) return;
      if (previous?.value?.id == family.id) return;
      // Семья подключилась: отправляем всё, что накопилось локально.
      unawaited(_drain());
    });

    // Вход в аккаунт мог завершиться позже загрузки семьи.
    ref.listen(identityControllerProvider, (previous, next) {
      if (next.value?.isSignedIn != true) return;
      unawaited(_drain());
    });

    ref.listen(familyDataProvider, (previous, next) {
      final data = next.value;
      if (data == null || previous?.value == data) return;
      if (pendingCloudUploads(data.mediaLibrary).isEmpty) return;
      unawaited(_drain());
    });

    return true;
  }

  /// Отправляет очередь и локальные файлы.
  ///
  /// Ошибки не всплывают в UI: статус виден на карточках медиатеки и в бейдже
  /// синхронизации, а неотправленное остаётся в очереди до следующей попытки.
  Future<void> _drain() async {
    if (_running) return;

    final family = ref.read(activeFamilyControllerProvider).value;
    final identity = ref.read(identityControllerProvider).value;
    if (family == null || identity == null || !identity.isSignedIn) return;

    _running = true;
    try {
      await ref.read(bulkUploadControllerProvider.notifier).uploadPending();
      await ref.read(mediaOutboxControllerProvider.notifier).processQueue();
    } catch (error) {
      debugPrint('Медиатека: автозагрузка не удалась: $error');
    } finally {
      _running = false;
    }
  }
}
