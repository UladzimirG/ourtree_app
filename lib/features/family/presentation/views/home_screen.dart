import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/access_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/widgets/account_button.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_sync_provider.dart';
import 'package:ourtree_app/features/family/presentation/views/calendar_section.dart';
import 'package:ourtree_app/features/family/presentation/views/family_section.dart';
import 'package:ourtree_app/features/family/presentation/views/timeline_section.dart';
import 'package:ourtree_app/features/family/presentation/widgets/card_sheet.dart';
import 'package:ourtree_app/features/family/presentation/widgets/edit_mode_banner.dart';
import 'package:ourtree_app/features/family/presentation/widgets/edit_mode_button.dart';
import 'package:ourtree_app/features/family/presentation/widgets/event_media_grid.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_bottom_nav.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_cloud_panel.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_header.dart';
import 'package:ourtree_app/features/family/presentation/widgets/sync_status_badge.dart';
import 'package:ourtree_app/features/family/presentation/widgets/kraft_background.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:ourtree_app/features/settings/domain/models/sync_status.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/profile/presentation/views/profile_screen.dart';
import 'package:ourtree_app/features/settings/presentation/providers/demo_edit_notice_provider.dart';
import 'package:ourtree_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:ourtree_app/features/settings/presentation/views/settings_screen.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Главный экран в стиле оригинального React-приложения.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tab = ref.watch(homeTabControllerProvider);
    final familyAsync = ref.watch(familyDataProvider);
    final settingsAsync = ref.watch(familySettingsProvider);
    final activeFamily = ref.watch(activeFamilyControllerProvider).value;
    final sync = ref.watch(familySyncControllerProvider);
    final syncing = activeFamily != null && sync == SyncStatus.loading;
    final demoNotice = ref.watch(demoEditNoticeProvider);
    final account = ref.watch(currentAccountProvider);
    // Вход выполнен, но семья не подключена — показываем демо-архив.
    final signedInWithoutFamily =
        activeFamily == null && account != null && account.serverBacked;

    // Первая правка демо-архива: честно сообщаем, что в облако она не попадёт.
    ref.listen(demoEditNoticeProvider, (previous, next) {
      if (!next.shouldPrompt || previous?.shouldPrompt == true) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        unawaited(_showDemoEditNotice(context, ref));
      });
    });

    // Пуш пришёл при открытом приложении — показываем его как snackbar.
    ref.listen(
      notificationsControllerProvider.select((state) => state.lastMessage),
      (previous, next) {
        if (next == null || previous?.serial == next.serial) return;
        final text = next.title.isEmpty
            ? next.body
            : (next.body.isEmpty ? next.title : '${next.title}\n${next.body}');
        if (text.isEmpty) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(text)),
          );
        });
      },
    );

    return KraftBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: familyAsync.when(
            data: (family) {
              final settings = settingsAsync.value ?? family.settings;
              final visible = ref.watch(visibleFamilyProvider) ?? family;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: FamilyHeader(
                      familyName: settings.familyName,
                      familyPhoto: settings.showFamilyPhotoInHeader
                          ? settings.familyPhoto
                          : null,
                      familyPhotoPosition: settings.familyPhotoPosition,
                      familyPhotoZoom: settings.familyPhotoZoom,
                      settingsTooltip: l10n.settingsTitle,
                      onSettingsTap: () => _openSettings(context),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SyncStatusBadge(showLabel: false),
                          AccountButton(showLabel: true),
                          const EditModeButton(),
                        ],
                      ),
                    ),
                  ),
                  if (activeFamily == null && demoNotice.hasLocalEdits)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _DemoLocalOnlyNotice(
                        onSettingsTap: () => showFamilyCloudPage(context),
                      ),
                    ),
                  if (signedInWithoutFamily)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _DemoAfterLoginNotice(
                        onOpenCloud: () => showFamilyCloudPage(context),
                      ),
                    ),
                  const EditModeBanner(),
                  Expanded(
                    child: syncing
                        ? _HomeStatus(label: l10n.homeLoading)
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: switch (tab) {
                              HomeTab.timeline => TimelineSection(
                                  key: const ValueKey<String>('timeline'),
                                  family: visible,
                                  showMedia: settings.showEventPhotos,
                                  onEventTap: (event) => _showEventDetails(
                                    context,
                                    visible,
                                    event,
                                    l10n,
                                  ),
                                ),
                              HomeTab.calendar => CalendarSection(
                                  key: const ValueKey<String>('calendar'),
                                  family: visible,
                                ),
                              HomeTab.family => FamilySection(
                                  key: const ValueKey<String>('family'),
                                  family: visible,
                                  onMemberTap: (member) =>
                                      _openProfile(context, member),
                                ),
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => _HomeStatus(label: l10n.homeLoading),
            error: (error, stackTrace) => _HomeStatus(
              label: l10n.homeLoadError,
              retryLabel: l10n.homeRetry,
              onRetry: () => ref.invalidate(familyDataProvider),
            ),
          ),
        ),
        bottomNavigationBar: familyAsync.hasValue
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: FamilyBottomNav(
                    selected: tab,
                    timelineLabel: l10n.navTimeline,
                    calendarLabel: l10n.navCalendar,
                    familyLabel: l10n.navFamily,
                    onSelected: (value) => ref
                        .read(homeTabControllerProvider.notifier)
                        .select(value),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

void _openSettings(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
  );
}

void _openProfile(BuildContext context, FamilyMember member) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProfileScreen(memberId: member.id),
    ),
  );
}

/// Объясняет, что правки демо-архива не попадут в облако.
Future<void> _showDemoEditNotice(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;

  final openSettings = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.demoEditNoticeTitle),
      content: Text(l10n.demoEditNoticeBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.demoEditNoticeLater),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.demoEditNoticeAction),
        ),
      ],
    ),
  );

  // Диалог показываем один раз: повторно он только мешает.
  await ref.read(demoEditNoticeProvider.notifier).markShown();
  if (openSettings == true && context.mounted) _openSettings(context);
}

/// Компактная метка «только на этом устройстве» в шапке архива.
class _DemoLocalOnlyNotice extends StatelessWidget {
  const _DemoLocalOnlyNotice({required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PaperCard(
      tilt: 0.2,
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: AppColors.terracotta,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.demoLocalOnlyNotice,
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: onSettingsTap,
            child: Text(l10n.demoEditNoticeAction),
          ),
        ],
      ),
    );
  }
}

Future<void> _showEventDetails(
  BuildContext context,
  FamilyData family,
  TimelineEvent event,
  AppLocalizations l10n,
) {
  return showCardSheet(context, (sheetContext) {
    final theme = Theme.of(sheetContext);
    final date = event.eventDate;
    final dateLabel = date == null
        ? formatDisplayDateFromIso(event.date, localeName: l10n.localeName)
        : formatDisplayDate(date, localeName: l10n.localeName);
    final place = event.place?.trim();
    final text = stripRichText(event.text);
    final media = family.mediaForEvent(event);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dateLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 4),
        Text(event.title, style: theme.textTheme.headlineSmall),
        if (place != null && place.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            place,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
              fontSize: 20,
              color: AppColors.terracotta,
            ),
          ),
        ],
        if (text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(text, style: theme.textTheme.bodyLarge),
        ],
        if (media.isNotEmpty) ...[
          const SizedBox(height: 14),
          EventMediaGrid(
            media: media,
            placeholderLabel: l10n.mediaPlaceholder,
            eyebrow: l10n.timelineEyebrow,
            title: event.title,
            subtitle: dateLabel,
            openViewer: true,
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: Text(l10n.close),
          ),
        ),
      ],
    );
  });
}

class _HomeStatus extends StatelessWidget {
  const _HomeStatus({
    required this.label,
    this.retryLabel,
    this.onRetry,
  });

  final String label;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: PaperCard(
            tilt: 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/branding/app_icon.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 12),
                if (onRetry == null)
                  const CircularProgressIndicator()
                else
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 40,
                    color: AppColors.terracotta,
                  ),
                const SizedBox(height: 12),
                Text(label, textAlign: TextAlign.center),
                if (onRetry != null && retryLabel != null) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onRetry,
                    child: Text(retryLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Подсказка после входа: семья есть, но в приложении всё ещё демо-архив.
class _DemoAfterLoginNotice extends StatelessWidget {
  const _DemoAfterLoginNotice({required this.onOpenCloud});

  final VoidCallback onOpenCloud;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PaperCard(
      tilt: 0.15,
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.cloud_download_outlined,
            size: 18,
            color: AppColors.terracotta,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.demoAfterLoginNotice,
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: onOpenCloud,
            child: Text(l10n.demoAfterLoginAction),
          ),
        ],
      ),
    );
  }
}

