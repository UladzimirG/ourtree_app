import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/family/data/repositories/cloud_family_store.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cloud_family_provider.g.dart';

/// Хранилище семей в облаке; подменяется в тестах.
@Riverpod(keepAlive: true)
CloudFamilyStore cloudFamilyStore(Ref ref) => FirestoreCloudFamilyStore();

/// Семья, открытая на этом устройстве.
///
/// `null` — режим демо-архива (семья ещё не создана/не выбрана). Именно это
/// состояние отделяет локальный демо-контент от облачного.
@Riverpod(keepAlive: true)
class ActiveFamilyController extends _$ActiveFamilyController {
  @override
  Future<FamilyModel?> build() async {
    final identity = await ref.watch(identityControllerProvider.future);
    final familyId = identity.activeFamilyId;
    if (familyId == null || familyId.isEmpty) return null;
    return ref.watch(cloudFamilyStoreProvider).find(familyId);
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

  /// Переключается на уже существующую семью.
  Future<void> select(String familyId) async {
    await ref
        .read(identityControllerProvider.notifier)
        .setActiveFamily(familyId);
    ref.invalidateSelf();
  }

  /// Повторная загрузка после сетевой ошибки.
  void retry() => ref.invalidateSelf();
}
