import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_sync_provider.dart';
import 'package:ourtree_app/features/settings/domain/models/sync_status.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Индикатор синхронизации архива с облаком.
///
/// Показывается только когда семья подключена: в демо-режиме синхронизации нет,
/// и лишняя иконка только путала бы.
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(activeFamilyControllerProvider).value;
    if (family == null) return const SizedBox.shrink();

    final status = ref.watch(familySyncControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final (IconData icon, String label, Color color) = switch (status) {
      SyncStatus.loading => (
          Icons.cloud_download_outlined,
          l10n.syncStatusLoading,
          AppColors.inkSoft,
        ),
      SyncStatus.saving => (
          Icons.cloud_upload_outlined,
          l10n.syncStatusSaving,
          AppColors.terracotta,
        ),
      SyncStatus.error => (
          Icons.cloud_off_outlined,
          l10n.syncStatusError,
          AppColors.terracotta,
        ),
      SyncStatus.saved => (
          Icons.cloud_done_outlined,
          l10n.syncStatusSaved,
          AppColors.moss,
        ),
    };

    return Tooltip(
      message: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
