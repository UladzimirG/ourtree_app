import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  Future<AccountsNotifier> accounts() async {
    await container.read(accountsNotifierProvider.future);
    return container.read(accountsNotifierProvider.notifier);
  }

  group('AccountsNotifier', () {
    test('rejects a login that breaks the allowed pattern', () async {
      final notifier = await accounts();

      final error = notifier.create(
        const AccountInput(
          login: 'a',
          name: 'A',
          password: 'secret',
          role: UserRole.viewer,
        ),
      );

      expect(error, AccountsError.badLogin);
      expect(container.read(accountsNotifierProvider).value, isEmpty);
    });

    test('rejects a password shorter than the server minimum', () async {
      final notifier = await accounts();

      final error = notifier.create(
        const AccountInput(
          login: 'grandma',
          name: 'Grandma',
          password: '123',
          role: UserRole.viewer,
        ),
      );

      expect(error, AccountsError.weakPassword);
      expect(container.read(accountsNotifierProvider).value, isEmpty);
    });

    test('creates an account and normalises its login', () async {
      final notifier = await accounts();

      final error = notifier.create(
        const AccountInput(
          login: '  Grandma ',
          name: '  Бабушка  ',
          password: 'secret',
          role: UserRole.editor,
        ),
      );

      expect(error, isNull);
      final list = container.read(accountsNotifierProvider).value!;
      expect(list, hasLength(1));
      expect(list.single.login, 'grandma');
      expect(list.single.name, 'Бабушка');
      expect(list.single.role, UserRole.editor);
      expect(list.single.createdAt, greaterThan(0));
    });

    test('rejects a duplicate login ignoring case', () async {
      final notifier = await accounts();
      notifier.create(
        const AccountInput(
          login: 'grandma',
          name: 'Grandma',
          password: 'secret',
          role: UserRole.viewer,
        ),
      );

      final error = notifier.create(
        const AccountInput(
          login: 'GRANDMA',
          name: 'Second',
          password: 'secret',
          role: UserRole.viewer,
        ),
      );

      expect(error, AccountsError.loginTaken);
      expect(container.read(accountsNotifierProvider).value, hasLength(1));
    });

    test('updates name and role but keeps the login', () async {
      final notifier = await accounts();
      notifier.create(
        const AccountInput(
          login: 'grandma',
          name: 'Grandma',
          password: 'secret',
          role: UserRole.viewer,
        ),
      );
      final id = container.read(accountsNotifierProvider).value!.single.id;

      final error = notifier.updateAccount(
        id,
        const AccountPatch(name: 'Бабушка', role: UserRole.admin),
      );

      expect(error, isNull);
      final account = container.read(accountsNotifierProvider).value!.single;
      expect(account.login, 'grandma');
      expect(account.name, 'Бабушка');
      expect(account.role, UserRole.admin);
    });

    test('rejects an update to a missing account', () async {
      final notifier = await accounts();

      final error = notifier.updateAccount(
        'missing',
        const AccountPatch(name: 'Nobody'),
      );

      expect(error, AccountsError.notFound);
    });

    test('removes an account', () async {
      final notifier = await accounts();
      notifier.create(
        const AccountInput(
          login: 'grandma',
          name: 'Grandma',
          password: 'secret',
          role: UserRole.viewer,
        ),
      );
      final id = container.read(accountsNotifierProvider).value!.single.id;

      notifier.remove(id);

      expect(container.read(accountsNotifierProvider).value, isEmpty);
    });
  });

  group('GuestLinksNotifier', () {
    Future<GuestLinksNotifier> links() async {
      await container.read(guestLinksNotifierProvider.future);
      return container.read(guestLinksNotifierProvider.notifier);
    }

    test('creates an active link with a token and expiry', () async {
      final notifier = await links();
      final created = notifier.create(
        const GuestLinkInput(label: '  Друг  ', days: 7),
      );

      expect(created.token, isNotEmpty);
      expect(created.link.label, 'Друг');
      expect(created.link.revoked, isFalse);
      expect(created.link.isActiveAt(DateTime.now()), isTrue);
      final list = container.read(guestLinksNotifierProvider).value!;
      expect(list, hasLength(1));
    });

    test('falls back to the default ttl for non-positive days', () async {
      final notifier = await links();
      final created = notifier.create(
        const GuestLinkInput(label: '', days: 0),
      );
      final expectedMs = guestLinkDefaultTtlDays * 24 * 60 * 60 * 1000;

      expect(
        created.link.expiresAt - created.link.createdAt,
        closeTo(expectedMs, 1000),
      );
    });

    test('revokes a link and reports it as inactive', () async {
      final notifier = await links();
      final created = notifier.create(
        const GuestLinkInput(label: 'Друг', days: 7),
      );

      notifier.revoke(created.link.id);

      final link = container.read(guestLinksNotifierProvider).value!.single;
      expect(link.revoked, isTrue);
      expect(link.isActiveAt(DateTime.now()), isFalse);
    });

    test('removes a link', () async {
      final notifier = await links();
      final created = notifier.create(
        const GuestLinkInput(label: 'Друг', days: 7),
      );

      notifier.remove(created.link.id);

      expect(container.read(guestLinksNotifierProvider).value, isEmpty);
    });
  });
}
