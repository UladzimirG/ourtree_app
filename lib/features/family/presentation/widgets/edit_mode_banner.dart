import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/providers/edit_mode_provider.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Плашка «Режим редактирования» под шапкой главного экрана.
class EditModeBanner extends ConsumerWidget {
  const EditModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(editModeProvider)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.mossWash,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.moss.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 18, color: AppColors.moss),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.editModeBanner,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(editModeControllerProvider.notifier).exit(),
            child: Text(l10n.editModeDone),
          ),
        ],
      ),
    );
  }
}
