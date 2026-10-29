import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/access_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/views/calendar_section.dart';
import 'package:ourtree_app/features/family/presentation/views/family_section.dart';
import 'package:ourtree_app/features/family/presentation/views/timeline_section.dart';
import 'package:ourtree_app/features/family/presentation/widgets/card_sheet.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_bottom_nav.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_header.dart';
import 'package:ourtree_app/features/family/presentation/widgets/kraft_background.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/profile/presentation/views/profile_screen.dart';
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
                      settingsTooltip: l10n.settingsTitle,
                      onSettingsTap: () => _openSettings(context),
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: switch (tab) {
                        HomeTab.timeline => TimelineSection(
                            key: const ValueKey<String>('timeline'),
                            family: visible,
                            showMedia: settings.showEventPhotos,
                            onEventTap: (event) =>
                                _showEventDetails(context, event, l10n),
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
                    onSelected: (value) =>
                        ref.read(homeTabControllerProvider.notifier).select(value),
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

Future<void> _showEventDetails(
  BuildContext context,
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
