import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/notifications/domain/notification_prefs.dart';
import 'package:ourtree_app/features/notifications/domain/upcoming_reminders.dart';
import 'package:ourtree_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Уведомления: разрешение, токен устройства и что именно присылать.
class NotificationsPanel extends ConsumerStatefulWidget {
  const NotificationsPanel({super.key});

  @override
  ConsumerState<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends ConsumerState<NotificationsPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(notificationsControllerProvider);
    final family = ref.watch(activeFamilyControllerProvider).value;
    final familyData = ref.watch(familyDataProvider).value;
    final notifier = ref.read(notificationsControllerProvider.notifier);

    final upcoming = familyData == null
        ? const <UpcomingReminder>[]
        : upcomingReminders(
            family: familyData,
            from: DateTime.now(),
            days: 7,
            birthdayTitle: (member) => l10n.calendarBirthdayTitle(member.name),
          );
    final dateFormat = DateFormat.MMMd(l10n.localeName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(l10n.notificationsHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 14),
        _StatusCard(
          state: state,
          hasFamily: family != null,
          onEnable: notifier.enable,
          onDisable: notifier.disable,
          onRetry: notifier.retry,
        ),
        const SizedBox(height: 12),
        _PrefsCard(
          prefs: state.prefs,
          onChanged: notifier.updatePrefs,
        ),
        const SizedBox(height: 12),
        _UpcomingCard(upcoming: upcoming, dateFormat: dateFormat),
      ],
    );
  }
}

/// Карточка состояния: включено/нет, кнопки и разбор ошибок.
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.state,
    required this.hasFamily,
    required this.onEnable,
    required this.onDisable,
    required this.onRetry,
  });

  final NotificationsState state;
  final bool hasFamily;
  final Future<void> Function() onEnable;
  final Future<void> Function() onDisable;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationsStatusTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(_statusText(l10n), style: theme.textTheme.bodyMedium),
          if (state.error != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorText(l10n, state.error!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.terracotta,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (state.registered) ...[
                OutlinedButton.icon(
                  onPressed: state.busy
                      ? null
                      : () {
                          onDisable();
                        },
                  icon: const Icon(Icons.notifications_off_outlined),
                  label: Text(l10n.notificationsDisable),
                ),
                OutlinedButton.icon(
                  onPressed: state.busy
                      ? null
                      : () {
                          onRetry();
                        },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.notificationsRefresh),
                ),
              ] else
                FilledButton.icon(
                  onPressed: state.busy || !hasFamily
                      ? null
                      : () {
                          onEnable();
                        },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(l10n.notificationsEnable),
                ),
            ],
          ),
          if (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
            const SizedBox(height: 10),
            Text(
              l10n.notificationsIosHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Текст состояния: что мешает или что уже работает.
  String _statusText(AppLocalizations l10n) {
    if (state.registered) return l10n.notificationsEnabled;
    if (!hasFamily) return l10n.notificationsNoFamily;
    if (state.permission == NotificationPermissionState.denied) {
      return l10n.notificationsDenied;
    }
    return l10n.notificationsDisabled;
  }

  /// Расшифровка ошибки по коду из провайдера.
  String _errorText(AppLocalizations l10n, String code) => switch (code) {
        'notificationsFailedNoKey' => l10n.notificationsFailedNoKey,
        'notificationsFailedPermission' => l10n.notificationsFailedPermission,
        'notificationsFailedToken' => l10n.notificationsFailedToken,
        'notificationsFailedNoFamily' => l10n.notificationsNoFamily,
        _ => l10n.notificationsFailed,
      };
}

/// Тумблеры: какие уведомления присылать.
class _PrefsCard extends StatelessWidget {
  const _PrefsCard({required this.prefs, required this.onChanged});

  final NotificationPrefs prefs;
  final Future<void> Function(NotificationPrefs prefs) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PaperCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.notificationsPrefsTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          SwitchListTile.adaptive(
            value: prefs.birthdays,
            onChanged: (value) => onChanged(prefs.copyWith(birthdays: value)),
            title: Text(l10n.notificationsBirthdays),
            subtitle: Text(l10n.notificationsBirthdaysHint),
          ),
          SwitchListTile.adaptive(
            value: prefs.calendar,
            onChanged: (value) => onChanged(prefs.copyWith(calendar: value)),
            title: Text(l10n.notificationsCalendar),
            subtitle: Text(l10n.notificationsCalendarHint),
          ),
          SwitchListTile.adaptive(
            value: prefs.familyUpdates,
            onChanged: (value) =>
                onChanged(prefs.copyWith(familyUpdates: value)),
            title: Text(l10n.notificationsFamilyUpdates),
            subtitle: Text(l10n.notificationsFamilyUpdatesHint),
          ),
        ],
      ),
    );
  }
}

/// Ближайшие напоминания на 7 дней — то, что придёт пушем.
class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.upcoming, required this.dateFormat});

  final List<UpcomingReminder> upcoming;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.notificationsUpcoming, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (upcoming.isEmpty)
            Text(
              l10n.notificationsUpcomingEmpty,
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final item in upcoming.take(7))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.isBirthday
                          ? Icons.cake_outlined
                          : Icons.event_outlined,
                      size: 16,
                      color: AppColors.moss,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(item.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
