import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/widgets/header_action_button.dart';
import 'package:ourtree_app/features/family/presentation/providers/edit_mode_provider.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Кнопка входа в режим редактирования и выхода из него.
///
/// Видна только администратору и редактору. Наблюдатель не должен видеть
/// кнопку, которая всё равно ничего не делает.
class EditModeButton extends ConsumerWidget {
  const EditModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canEditContentProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final active = ref.watch(editModeProvider);

    return HeaderActionButton(
      icon: active ? Icons.check_circle_outline : Icons.edit_outlined,
      tooltip: active ? l10n.editModeExit : l10n.editModeEnter,
      active: active,
      onTap: () => ref.read(editModeControllerProvider.notifier).toggle(),
    );
  }
}
