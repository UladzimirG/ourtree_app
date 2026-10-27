import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/access_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';

class _FakeFamilyDataNotifier extends FamilyDataNotifier {
  @override
  Future<FamilyData> build() async => FamilyData.empty;
}

void main() {
  late ProviderContainer container;

  setUp(() async {
    await MediaStorage.instance.clearForTests();
    container = ProviderContainer(
      overrides: [
        familyDataProvider.overrideWith(_FakeFamilyDataNotifier.new),
      ],
    );
    await container.read(familyDataProvider.future);
  });

  tearDown(() {
    container.dispose();
  });

  FamilyMember member(String id) => FamilyMember(
        id: id,
        role: 'Роль',
        name: id,
        nickname: '',
        birthday: '2000-01-01',
      );

  Future<void> seed() async {
    container.read(familyDataProvider.notifier).replaceData(
          FamilyData(
            settings: const FamilySettings(familyName: 'Family'),
            members: [member('a'), member('b')],
            timelineEvents: const [
              TimelineEvent(
                id: 'e1',
                date: '2020-01-01',
                title: 'A',
                memberId: 'a',
              ),
              TimelineEvent(
                id: 'e2',
                date: '2020-01-02',
                title: 'B',
                memberId: 'b',
              ),
              TimelineEvent(
                id: 'e3',
                date: '2020-01-03',
                title: 'Hidden',
              ),
            ],
          ),
        );
  }

  test('viewer sees only allowed members and events', () async {
    await seed();
    await container.read(accountsNotifierProvider.future);
    container.read(accountsNotifierProvider.notifier).replaceAll([
      const Account(
        id: 'viewer',
        login: 'viewer',
        name: 'Viewer',
        role: UserRole.viewer,
        allMembersVisible: false,
        visibleMemberIds: ['a'],
      ),
      const Account(
        id: 'other',
        login: 'other',
        name: 'Other',
        role: UserRole.editor,
      ),
    ]);
    await container.read(familyDataProvider.future);
    final events = container.read(familyDataProvider).value!.timelineEvents;
    container.read(familyDataProvider.notifier).updateTimelineEvent(
          'e3',
          (event) => event.copyWith(hiddenFrom: ['viewer']),
        );
    expect(events, isNotEmpty);

    container.read(currentAccountIdProvider.notifier).setAccount('viewer');

    final visible = container.read(visibleFamilyProvider)!;
    expect(visible.members.map((item) => item.id), ['a']);
    expect(visible.timelineEvents.map((item) => item.id), ['e1']);
  });

  test('admin and local owner see everything', () async {
    await seed();
    final visible = container.read(visibleFamilyProvider)!;
    expect(visible.members, hasLength(2));
    expect(visible.timelineEvents, hasLength(3));
  });

  test('new member is granted to a restricted editor', () async {
    await container.read(accountsNotifierProvider.future);
    container.read(accountsNotifierProvider.notifier).replaceAll([
      const Account(
        id: 'editor',
        login: 'editor',
        name: 'Editor',
        role: UserRole.editor,
        allMembersVisible: false,
      ),
    ]);

    container
        .read(accountsNotifierProvider.notifier)
        .grantMemberVisibility('editor', 'new-member');

    final account =
        container.read(accountsNotifierProvider).value!.single;
    expect(account.visibleMemberIds, contains('new-member'));
  });
}
