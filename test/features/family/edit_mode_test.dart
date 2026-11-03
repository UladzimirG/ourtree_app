import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/features/accounts/domain/models/accounts_models.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/presentation/providers/edit_mode_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    await MediaStorage.instance.clearForTests();
    container = ProviderContainer();
    await container.read(accountsProvider.future);
  });

  tearDown(() {
    container.dispose();
  });

  test('редактор может включить и выключить режим', () {
    container.read(accountsProvider.notifier).replaceAll(const [
      Account(
        id: 'editor',
        login: 'editor',
        name: 'Editor',
        role: UserRole.editor,
      ),
    ]);
    container.read(currentAccountIdProvider.notifier).setAccount('editor');

    expect(container.read(canEditContentProvider), isTrue);
    container.read(editModeControllerProvider.notifier).toggle();
    expect(container.read(editModeProvider), isTrue);

    container.read(editModeControllerProvider.notifier).exit();
    expect(container.read(editModeProvider), isFalse);
  });

  test('наблюдатель не может включить режим', () {
    container.read(accountsProvider.notifier).replaceAll(const [
      Account(
        id: 'viewer',
        login: 'viewer',
        name: 'Viewer',
        role: UserRole.viewer,
      ),
    ]);
    container.read(currentAccountIdProvider.notifier).setAccount('viewer');

    expect(container.read(canEditContentProvider), isFalse);
    container.read(editModeControllerProvider.notifier).toggle();
    expect(container.read(editModeControllerProvider), isFalse);
    expect(container.read(editModeProvider), isFalse);
  });
}
