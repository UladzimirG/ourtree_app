import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/backup_provider.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Список резервных копий архива и действия над ними.
class BackupPanel extends ConsumerWidget {
  const BackupPanel({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final entry = await ref.read(backupsNotifierProvider.notifier).create();
    if (!context.mounted) return;
    final message = entry == null ? l10n.backupCreateFailed : l10n.backupCreated;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    BackupEntry entry,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupRestoreConfirmTitle),
        content: Text(l10n.backupRestoreConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.backupRestore),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final restored =
        await ref.read(backupsNotifierProvider.notifier).restore(entry.name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          restored ? l10n.backupRestored : l10n.backupRestoreFailed,
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    BackupEntry entry,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupDeleteConfirmTitle),
        content: Text(l10n.backupDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.backupDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(backupsNotifierProvider.notifier).delete(entry.name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.backupDeleted)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final info = ref.watch(backupsNotifierProvider).valueOrNull ??
        const BackupList(kept: backupKeptLimit, throttleMs: backupThrottleMs);
    final dateTime = DateFormat.yMMMd(l10n.localeName).add_Hm();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(l10n.settingsBackupsHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        PaperCard(
          tilt: -0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _create(context, ref),
                  icon: const Icon(Icons.save_alt),
                  label: Text(l10n.backupCreate),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.backupSummary(
                  info.backups.length,
                  info.kept,
                  formatBackupSize(info.totalSize, l10n),
                ),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (info.backups.isEmpty)
          PaperCard(
            tilt: 0.3,
            child: Text(
              l10n.backupEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          )
        else
          for (final entry in info.backups) ...[
            _BackupRow(
              entry: entry,
              dateLabel: dateTime.format(entry.savedAtDate),
              l10n: l10n,
              onRestore: () => _restore(context, ref, entry, l10n),
              onDelete: () => _delete(context, ref, entry, l10n),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 8),
        Text(l10n.backupLocalOnly, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _BackupRow extends StatelessWidget {
  const _BackupRow({
    required this.entry,
    required this.dateLabel,
    required this.l10n,
    required this.onRestore,
    required this.onDelete,
  });

  final BackupEntry entry;
  final String dateLabel;
  final AppLocalizations l10n;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaperCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            '${l10n.backupRevision(entry.revision)} · '
            '${formatBackupSize(entry.size, l10n)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onRestore,
                icon: const Icon(Icons.restore),
                label: Text(l10n.backupRestore),
              ),
              TextButton.icon(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.terracotta,
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.backupDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String formatBackupSize(int bytes, AppLocalizations l10n) {
  if (bytes < 1024) return l10n.backupSizeBytes(bytes);
  if (bytes < 1024 * 1024) {
    return l10n.backupSizeKb((bytes / 1024).toStringAsFixed(1));
  }
  return l10n.backupSizeMb((bytes / (1024 * 1024)).toStringAsFixed(1));
}
