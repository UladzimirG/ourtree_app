import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_mode_provider.g.dart';

/// Может ли текущий пользователь редактировать содержимое семьи.
///
/// Локальный владелец устройства и администраторы — да, редакторы — да,
/// наблюдатели — нет.
@Riverpod(keepAlive: true)
bool canEditContent(Ref ref) =>
    ref.watch(currentRoleProvider) != UserRole.viewer;

/// Ручной переключатель режима редактирования.
@Riverpod(keepAlive: true)
class EditModeController extends _$EditModeController {
  @override
  bool build() => false;

  void toggle() {
    if (!ref.read(canEditContentProvider)) return;
    state = !state;
  }

  void exit() => state = false;
}

/// Итоговый режим редактирования: включён пользователем и разрешён ролью.
///
/// Если во время работы войти аккаунтом наблюдателя, режим автоматически
/// выключается, даже если флаг остался включённым.
@Riverpod(keepAlive: true)
bool editMode(Ref ref) =>
    ref.watch(canEditContentProvider) && ref.watch(editModeControllerProvider);
