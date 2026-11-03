import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/picker_web_options.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/backup_provider.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Предел размера файла резервной копии для импорта.
///
/// Снимок с медиа — это base64 внутри JSON: на iPhone такой файл целиком
/// разбирается в памяти, поэтому слишком большие файлы предупреждаем заранее.
const int backupImportSizeLimit = 64 * 1024 * 1024;

/// Список резервных копий архива и действия над ними.
class BackupPanel extends ConsumerWidget {
  const BackupPanel({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    var includeMedia = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.backupExportTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.backupExportHint),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: includeMedia,
                onChanged: (value) =>
                    setDialogState(() => includeMedia = value),
                title: Text(l10n.backupIncludeMedia),
                subtitle: Text(l10n.backupIncludeMediaHint),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.backupExport),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final export = await ref
        .read(backupsProvider.notifier)
        .createExport(includeMedia: includeMedia);
    if (!context.mounted) return;
    if (export == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupCreateFailed)),
      );
      return;
    }

    final stamp = DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
    final uri = await FilePicker.saveFile(
      fileName: 'ourtree-backup-$stamp.json',
      bytes: export.bytes,
      mimeType: 'application/json',
      dialogTitle: l10n.backupSaveDialogTitle,
    );
    if (!context.mounted) return;

    // На вебе файл скачивается браузером, и путь не возвращается (null) —
    // это успех, а не отмена.
    if (kIsWeb && uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupDownloadStarted)),
      );
      return;
    }
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupExportCanceled)),
      );
      return;
    }

    final path = uri.path.isNotEmpty ? uri.path : uri.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.backupSavedTo(path))),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    // На вебе (в том числе в PWA на iPhone) любой браузер работает через
    // WebKit: фильтр по расширениям там ненадёжен, а авт-отмена выбора по
    // возврату фокуса вообще ломает импорт. Поэтому берём любой файл и
    // проверяем расширение сами.
    final file = await FilePicker.pickFile(
      type: kIsWeb ? FileType.any : FileType.custom,
      allowedExtensions: kIsWeb ? null : const ['json', 'ourtree'],
      dialogTitle: l10n.backupImport,
      webOptions: importPickerWebOptions(),
    );
    if (file == null || !context.mounted) return;

    if (kIsWeb && !_looksLikeBackup(file.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupImportWrongFile)),
      );
      return;
    }

    final size = file.lengthSync() ?? await file.length() ?? 0;
    if (size > backupImportSizeLimit) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.backupImportTooLarge(backupImportSizeLimit ~/ (1024 * 1024)),
          ),
        ),
      );
      return;
    }

    Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (error) {
      debugPrint('Бэкап: файл не прочитан: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupImportUnreadable)),
      );
      return;
    }

    final notifier = ref.read(backupsProvider.notifier);
    final imported = await notifier.importBytes(bytes);
    if (!context.mounted) return;

    final skipped = notifier.lastSkippedMedia;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !imported
              ? l10n.backupImportFailed
              : skipped > 0
                  ? '${l10n.backupImportSuccess} ${l10n.backupImportPartial(skipped)}'
                  : l10n.backupImportSuccess,
        ),
      ),
    );
  }

  /// Похоже ли имя файла на резервную копию OurTree.
  bool _looksLikeBackup(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.json') || lower.endsWith('.ourtree');
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
        await ref.read(backupsProvider.notifier).restore(entry.name);
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

    await ref.read(backupsProvider.notifier).delete(entry.name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.backupDeleted)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final info = ref.watch(backupsProvider).value ??
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _export(context, ref),
                    icon: const Icon(Icons.save_alt),
                    label: Text(l10n.backupExport),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _import(context, ref),
                    icon: const Icon(Icons.restore_page_outlined),
                    label: Text(l10n.backupImport),
                  ),
                ],
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
