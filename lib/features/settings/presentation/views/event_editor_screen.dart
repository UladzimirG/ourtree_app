import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/kraft_background.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/editor_top_bar.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/timeline_event_editor_card.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Полноэкранный редактор события, открываемый из таймлайна и календаря.
class EventEditorScreen extends ConsumerWidget {
  const EventEditorScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final family = ref.watch(familyDataProvider).value;
    final event = family == null ? null : _eventById(family, eventId);

    return KraftBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: family == null || event == null
              ? _EditorStatus(
                  onBack: () => Navigator.of(context).maybePop(),
                  label: l10n.profileNotFound,
                )
              : Column(
                  children: [
                    EditorTopBar(
                      title: l10n.eventEditorTitle,
                      doneLabel: l10n.editModeDone,
                      onDone: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                        children: [
                          TimelineEventEditorCard(
                            event: event,
                            members: family.members,
                            l10n: l10n,
                            initiallyExpanded: true,
                            canDelete: ref.watch(currentRoleProvider) ==
                                UserRole.admin,
                            otherEvents: [
                              for (final item in family.timelineEvents)
                                if (item.id != event.id) item,
                            ],
                            onChanged: (updated) => ref
                                .read(familyDataProvider.notifier)
                                .updateTimelineEvent(event.id, (_) => updated),
                            onRemove: () => _confirmRemove(
                              context,
                              ref,
                              l10n,
                              event,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TimelineEvent event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.eventDeleteConfirmTitle),
        content: Text(l10n.eventDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.eventDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ref.read(familyDataProvider.notifier).removeTimelineEvent(event.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  TimelineEvent? _eventById(FamilyData family, String id) {
    for (final event in family.timelineEvents) {
      if (event.id == id) return event;
    }
    return null;
  }
}

class _EditorStatus extends StatelessWidget {
  const _EditorStatus({required this.label, required this.onBack});

  final String label;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: onBack, child: const Icon(Icons.arrow_back)),
        ],
      ),
    );
  }
}
