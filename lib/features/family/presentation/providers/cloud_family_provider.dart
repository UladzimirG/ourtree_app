import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/data/repositories/cloud_family_store.dart';
import 'package:ourtree_app/features/family/data/repositories/family_cleanup_service.dart';
import 'package:ourtree_app/features/family/data/repositories/invite_store.dart';
import 'package:ourtree_app/features/family/domain/models/family_join_exception.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_sync_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cloud_family_provider.g.dart';

/// Хранилище семей в облаке; подменяется в тестах.
@Riverpod(keepAlive: true)
CloudFamilyStore cloudFamilyStore(Ref ref) => FirestoreCloudFamilyStore();

/// Удаление данных семьи из облака; подменяется в тестах.
@Riverpod(keepAlive: true)
FamilyCleanupService familyCleanupService(Ref ref) =>
    FirebaseFamilyCleanupService();

/// Хранилище кодов приглашений; подменяется в тестах.
@Riverpod(keepAlive: true)
InviteStore inviteStore(Ref ref) => FirestoreInviteStore();

/// Семья, открытая на этом устройстве.
///
/// `null` — режим демо-архива (семья ещё не создана/не выбрана). Именно это
/// состояние отделяет локальный демо-контент от облачного.
@Riverpod(keepAlive: true)
class ActiveFamilyController extends _$ActiveFamilyController {
  /// Срок жизни кода приглашения.
  static const Duration inviteTtl = Duration(days: 14);

  @override
  Future<FamilyModel?> build() async {
    final identity = await ref.watch(identityControllerProvider.future);
    final familyId = identity.activeFamilyId;
    if (familyId == null || familyId.isEmpty) return null;

    final family = await ref.watch(cloudFamilyStoreProvider).find(familyId);
    if (family == null) {
      // Документа семьи больше нет: владелец удалил данные из облака.
      // Отключаемся локально, чтобы приложение не «висело» на мёртвой ссылке.
      await ref.read(identityControllerProvider.notifier).setActiveFamily(null);
    }
    return family;
  }

  /// Создаёт семью и делает её активной на устройстве.
  Future<FamilyModel> create(String name) async {
    final identity = await ref.read(identityControllerProvider.future);
    final family = await ref.read(cloudFamilyStoreProvider).create(
          userId: identity.userId,
          authUid: identity.authUid,
          name: name,
        );

    await ref
        .read(identityControllerProvider.notifier)
        .setActiveFamily(family.id);

    state = AsyncData(family);
    return family;
  }

  /// Присоединяется к семье по коду приглашения.
  ///
  /// Бросает [FamilyJoinException], если код неверного формата, не найден,
  /// отозван или истёк.
  Future<FamilyModel> join(String rawCode) async {
    final code = InviteCode.normalize(rawCode);
    if (!InviteCode.isValid(code)) {
      throw const InvalidInviteCodeException();
    }

    final invite = await ref.read(inviteStoreProvider).find(code);
    final now = DateTime.now();
    if (invite == null || invite.familyId.isEmpty || !invite.isValidAt(now)) {
      throw const InviteNotFoundException();
    }

    final identity = await ref.read(identityControllerProvider.future);
    final family = await ref.read(cloudFamilyStoreProvider).joinWithInvite(
          familyId: invite.familyId,
          userId: identity.userId,
          authUid: identity.authUid,
          inviteCode: code,
        );

    await ref
        .read(identityControllerProvider.notifier)
        .setActiveFamily(family.id);

    state = AsyncData(family);
    return family;
  }

  /// Выпускает новый код приглашения для текущей семьи.
  Future<String> createInvite() async {
    final current = state.value;
    if (current == null) {
      throw StateError('Сначала создайте или выберите семью');
    }

    final identity = await ref.read(identityControllerProvider.future);
    return ref.read(inviteStoreProvider).create(
          familyId: current.id,
          createdByAuthUid: identity.authUid,
          ttl: inviteTtl,
        );
  }

  /// Переключается на уже существующую семью.
  Future<void> select(String familyId) async {
    await ref
        .read(identityControllerProvider.notifier)
        .setActiveFamily(familyId);
    ref.invalidateSelf();
  }

  /// Повторная загрузка после сетевой ошибки.
  void retry() => ref.invalidateSelf();

  /// Отключает это устройство от семьи.
  ///
  /// Обычный участник при выходе удаляет свой документ членства, остальные
  /// данные остаются для семьи. Владелец, у которого в семье есть другие
  /// активные участники, отключиться не может: иначе семья осталась бы без
  /// владельца и её никто не смог бы удалить. Владелец-одиночка при отключении
  /// выполняет полное удаление данных из облака — так не остаётся «мусора».
  ///
  /// Возвращает `false`, если отключение запрещено (владелец не один).
  Future<bool> disconnect() async {
    final current = state.value;
    if (current == null) return true;

    final identity = await ref.read(identityControllerProvider.future);
    final service = ref.read(familyCleanupServiceProvider);

    if (current.ownerAuthUid != identity.authUid) {
      await service.leaveFamily(
        familyId: current.id,
        authUid: identity.authUid,
      );
      await _detachLocally(current.id);
      return true;
    }

    final others = await service.countOtherActiveMembers(
      familyId: current.id,
      authUid: identity.authUid,
    );
    if (others > 0) return false;

    // Владелец один: уходя, уносим данные с собой — ничего не остаётся в облаке.
    await service.deleteFamilyData(
      familyId: current.id,
      authUid: identity.authUid,
    );
    await _detachLocally(current.id);
    return true;
  }

  /// Полностью удаляет данные семьи из облака (только владелец).
  ///
  /// Удаляются файлы в Storage, документы Firestore и коды приглашений.
  /// Локальный архив на устройстве остаётся: пользователь продолжает видеть
  /// свои фото и может создать новую семью.
  Future<void> deleteFamilyData() async {
    final current = state.value;
    if (current == null) {
      throw StateError('Семья не подключена');
    }

    final identity = await ref.read(identityControllerProvider.future);
    if (current.ownerAuthUid != identity.authUid) {
      throw StateError('Удалить данные семьи может только владелец');
    }

    await ref.read(familyCleanupServiceProvider).deleteFamilyData(
          familyId: current.id,
          authUid: identity.authUid,
        );
    await _detachLocally(current.id);
  }

  /// Локальное отключение: стираем отметки синхронизации и активную семью.
  Future<void> _detachLocally(String familyId) async {
    await ref.read(familySyncControllerProvider.notifier).forgetFamily(familyId);
    await ref
        .read(identityControllerProvider.notifier)
        .setActiveFamily(null);
    state = const AsyncData(null);
  }
}
