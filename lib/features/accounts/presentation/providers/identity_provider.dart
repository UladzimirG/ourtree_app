import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/utils/ids.dart';
import 'package:ourtree_app/features/accounts/data/gateways/identity_gateway.dart';
import 'package:ourtree_app/features/accounts/data/repositories/user_store.dart';
import 'package:ourtree_app/features/accounts/domain/models/identity_state.dart';
import 'package:ourtree_app/features/accounts/domain/models/user_model.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'identity_provider.g.dart';

/// Ключ локальной личности устройства в боксе `app_state`.
const String localUserIdStorageKey = 'local_user_id';

/// Шлюз анонимного входа; подменяется в тестах.
@Riverpod(keepAlive: true)
IdentityGateway identityGateway(Ref ref) => FirebaseIdentityGateway();

/// Хранилище профиля пользователя; подменяется в тестах.
@Riverpod(keepAlive: true)
UserStore userStore(Ref ref) => FirestoreUserStore();

/// UUID пользователя на этом устройстве.
///
/// Если на устройстве выбран локальный аккаунт — берём его id (после миграции
/// это UUID v4), иначе создаём «личность устройства». Именно этот id уходит
/// в Firestore (`users/{userId}`) и в `families/*/members/{userId}`.
@Riverpod(keepAlive: true)
String localUserId(Ref ref) {
  final accountId = ref.watch(currentAccountIdProvider);
  final storage = MediaStorage.instance;

  if (accountId != null && accountId.isNotEmpty) {
    unawaited(storage.putString(localUserIdStorageKey, accountId));
    return accountId;
  }

  final stored = storage.getString(localUserIdStorageKey);
  if (stored != null && stored.isNotEmpty) return stored;

  final created = newUserId();
  unawaited(storage.putString(localUserIdStorageKey, created));
  return created;
}

/// Личность пользователя: локальный id + анонимный `auth.uid` + профиль в облаке.
///
/// Вход полностью бесшовный: пользователь не видит ни формы, ни пароля — при
/// первом запуске выполняется `signInAnonymously()`.
@Riverpod(keepAlive: true)
class IdentityController extends _$IdentityController {
  @override
  Future<IdentityState> build() async {
    final userId = ref.watch(localUserIdProvider);
    final gateway = ref.watch(identityGatewayProvider);
    final store = ref.watch(userStoreProvider);

    final authUid = gateway.currentAuthUid ?? await gateway.signInAnonymously();
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await store.find(authUid);
    final user = (existing ?? UserModel(id: userId, createdAt: now)).copyWith(
      authUid: authUid,
      lastSeenAt: now,
    );

    await store.upsert(user);

    // Диагностика: видно в консоли `flutter run`. Проверяем, что документ
    // реально дошёл до сервера, а не остался в локальной очереди.
    try {
      final confirmed = await store.find(authUid, fromServer: true);
      debugPrint(
        'CloudIdentity: authUid=$authUid localUserId=$userId '
        'persisted=${confirmed != null}',
      );
    } catch (error) {
      debugPrint('CloudIdentity: Firestore недоступен с устройства: $error');
    }

    return IdentityState(user: user, authUid: authUid);
  }

  /// Запоминает активную семью — локально (сразу) и в облаке (best effort).
  Future<void> setActiveFamily(String? familyId) async {
    final current = state.value;
    if (current == null) return;

    final user = current.user.copyWith(activeFamilyId: () => familyId);
    state = AsyncData(IdentityState(user: user, authUid: current.authUid));

    try {
      await ref
          .read(userStoreProvider)
          .setActiveFamily(current.authUid, familyId);
    } catch (_) {
      // Офлайн не должен мешать локальной работе: значение уже сохранено
      // в состоянии и уйдёт в облако при следующем успешном входе.
    }
  }

  /// Сбрасывает анонимную сессию (например, при полном выходе из приложения).
  Future<void> signOut() async {
    await ref.read(identityGatewayProvider).signOut();
    ref.invalidateSelf();
  }

  /// Повторная попытка после сетевой ошибки.
  void retry() => ref.invalidateSelf();
}
