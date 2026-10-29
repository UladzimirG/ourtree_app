import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'access_provider.g.dart';

/// Видно ли событие аккаунту [account].
bool isEventVisibleTo(Account account, TimelineEvent event) {
  if (account.isAdmin) return true;
  if (event.hiddenFrom.contains(account.id)) return false;
  final memberId = event.memberId;
  return memberId == null || account.canSeeMember(memberId);
}

/// Архив, отфильтрованный по правам текущего пользователя.
///
/// Локальный владелец устройства (`account == null`) и администраторы видят
/// всё. Редакторы и наблюдатели получают только разрешённых участников и
/// события, не скрытые через `hiddenFrom`.
@Riverpod(keepAlive: true)
FamilyData? visibleFamily(Ref ref) {
  final family = ref.watch(familyDataProvider).value;
  final account = ref.watch(currentAccountProvider);
  if (family == null) return null;
  if (account == null || account.isAdmin) return family;

  return family.copyWith(
    members: [
      for (final member in family.members)
        if (account.canSeeMember(member.id)) member,
    ],
    timelineEvents: [
      for (final event in family.timelineEvents)
        if (isEventVisibleTo(account, event)) event,
    ],
  );
}
