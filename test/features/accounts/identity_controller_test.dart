import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/data/gateways/identity_gateway.dart';
import 'package:ourtree_app/features/accounts/data/repositories/user_store.dart';
import 'package:ourtree_app/features/accounts/domain/models/user_model.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';

/// Фейковый Firebase Auth: вход выдаёт предсказуемые uid.
class _FakeGateway implements IdentityGateway {
  _FakeGateway();

  String? sessionUid;
  int signInCalls = 0;

  @override
  String? get currentAuthUid => sessionUid;

  @override
  Stream<String?> get authUidChanges => const Stream<String?>.empty();

  @override
  Future<String> signInAnonymously() async {
    signInCalls++;
    sessionUid = 'auth-$signInCalls';
    return sessionUid!;
  }

  @override
  Future<void> signOut() async => sessionUid = null;
}

/// In-memory замена Firestore.
class _MemoryUserStore implements UserStore {
  final Map<String, UserModel> users = <String, UserModel>{};
  final List<String?> activeFamilyUpdates = <String?>[];

  @override
  Future<UserModel?> find(String userId) async => users[userId];

  @override
  Future<void> upsert(UserModel user) async => users[user.id] = user;

  @override
  Future<void> setActiveFamily(String userId, String? familyId) async {
    activeFamilyUpdates.add(familyId);
    // Firestore делает merge — фейк ведёт себя так же.
    final existing = users[userId];
    if (existing != null) {
      users[userId] = existing.copyWith(activeFamilyId: () => familyId);
    }
  }
}

final RegExp _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  late _FakeGateway gateway;
  late _MemoryUserStore store;
  late ProviderContainer container;

  setUp(() async {
    await MediaStorage.instance.clearForTests();
    gateway = _FakeGateway();
    store = _MemoryUserStore();
    container = ProviderContainer(
      overrides: [
        identityGatewayProvider.overrideWith((ref) => gateway),
        userStoreProvider.overrideWith((ref) => store),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('IdentityController', () {
    test('signs in anonymously and creates the user document', () async {
      final identity = await container.read(identityControllerProvider.future);

      expect(identity.isSignedIn, isTrue);
      expect(identity.authUid, 'auth-1');
      expect(identity.user.id, matches(_uuidV4));
      expect(gateway.signInCalls, 1);

      final saved = store.users[identity.user.id];
      expect(saved, isNotNull);
      expect(saved!.authUid, 'auth-1');
      expect(saved.createdAt, greaterThan(0));
    });

    test('reuses an existing session without a second sign-in', () async {
      gateway.sessionUid = 'auth-existing';

      final identity = await container.read(identityControllerProvider.future);

      expect(identity.authUid, 'auth-existing');
      expect(gateway.signInCalls, 0);
    });

    test('keeps the same local id across rebuilds', () async {
      final first = await container.read(identityControllerProvider.future);

      container.invalidate(identityControllerProvider);
      final second = await container.read(identityControllerProvider.future);

      expect(second.user.id, first.user.id);
    });

    test('keeps createdAt and active family from the stored profile', () async {
      final first = await container.read(identityControllerProvider.future);
      await container
          .read(identityControllerProvider.notifier)
          .setActiveFamily('family-1');

      final updated = container.read(identityControllerProvider).value!;
      expect(updated.activeFamilyId, 'family-1');
      expect(store.activeFamilyUpdates, ['family-1']);

      container.invalidate(identityControllerProvider);
      final reloaded =
          await container.read(identityControllerProvider.future);

      expect(reloaded.activeFamilyId, 'family-1');
      expect(reloaded.user.createdAt, first.user.createdAt);
    });

    test('surfaces a gateway failure as an error state', () async {
      final failing = _FailingGateway();
      final failingContainer = ProviderContainer(
        overrides: [
          identityGatewayProvider.overrideWith((ref) => failing),
          userStoreProvider.overrideWith((ref) => store),
        ],
      );
      addTearDown(failingContainer.dispose);

      await expectLater(
        failingContainer.read(identityControllerProvider.future),
        throwsA(isA<StateError>()),
      );
      expect(
        failingContainer.read(identityControllerProvider),
        isA<AsyncError<Object?>>(),
      );
    });

    test('signOut clears the session and starts a new one', () async {
      await container.read(identityControllerProvider.future);

      await container.read(identityControllerProvider.notifier).signOut();
      final next = await container.read(identityControllerProvider.future);

      expect(gateway.signInCalls, 2);
      expect(next.authUid, 'auth-2');
    });
  });
}

class _FailingGateway implements IdentityGateway {
  @override
  String? get currentAuthUid => null;

  @override
  Stream<String?> get authUidChanges => const Stream<String?>.empty();

  @override
  Future<String> signInAnonymously() async =>
      throw StateError('Анонимный вход недоступен');

  @override
  Future<void> signOut() async {}
}
