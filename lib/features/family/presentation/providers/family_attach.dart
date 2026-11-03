import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_sync_provider.dart';

/// После входа в аккаунт дожидается подключения семьи и подтягивает архив.
///
/// `true` — семья найдена и архив синхронизирован; `false` — аккаунт не связан
/// с семьёй; `null` — проверить не удалось (нет сети или таймаут), и говорить
/// пользователю «семьи нет» нельзя.
Future<bool?> attachFamilyAfterSignIn(WidgetRef ref) async {
  FamilyModel? family;
  try {
    // Личность только что сменилась — пересобираем активную семью, иначе
    // прочитаем закэшированное `null` от анонимной сессии.
    ref.invalidate(activeFamilyControllerProvider);
    family = await ref
        .read(activeFamilyControllerProvider.future)
        .timeout(const Duration(seconds: 10));
  } catch (error) {
    debugPrint('Вход: не удалось прочитать семью: $error');
    return null;
  }
  if (family == null) return false;

  try {
    await ref
        .read(familySyncControllerProvider.notifier)
        .pull(family.id)
        .timeout(const Duration(seconds: 25));
  } catch (error) {
    debugPrint('Вход: архив не синхронизирован: $error');
    return null;
  }
  return true;
}
