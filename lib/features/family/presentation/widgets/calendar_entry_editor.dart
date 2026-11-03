import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/card_sheet.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/settings_fields.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Лёгкая форма даты, которая существует только в календаре.
Future<void> showCalendarEntryEditor(
  BuildContext context, {
  required AppLocalizations l10n,
  required DateTime day,
  TimelineEvent? event,
}) {
  return showCardSheet(
    context,
    (sheetContext) => CalendarEntryEditor(
      l10n: l10n,
      day: day,
      event: event,
    ),
  );
}

class CalendarEntryEditor extends ConsumerStatefulWidget {
  const CalendarEntryEditor({
    super.key,
    required this.l10n,
    required this.day,
    this.event,
  });

  final AppLocalizations l10n;
  final DateTime day;
  final TimelineEvent? event;

  @override
  ConsumerState<CalendarEntryEditor> createState() =>
      _CalendarEntryEditorState();
}

class _CalendarEntryEditorState extends ConsumerState<CalendarEntryEditor> {
  late final TextEditingController _title;
  late final TextEditingController _note;
  late String _date;
  late bool _recurring;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _title = TextEditingController(
      text: event?.title ?? widget.l10n.calendarEntryDefaultTitle,
    );
    _note = TextEditingController(text: event?.text ?? '');
    _date = event?.date ?? _iso(widget.day);
    _recurring = event?.recurringYearly ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = widget.l10n;
    final title = _title.text.trim().isEmpty
        ? l10n.calendarEntryDefaultTitle
        : _title.text.trim();
    final existing = widget.event;
    if (existing == null) {
      ref.read(familyDataProvider.notifier).addTimelineEvent(
            TimelineEvent(
              id: 'calendar-${DateTime.now().microsecondsSinceEpoch}',
              date: _date,
              title: title,
              text: _note.text,
              kind: EventKind.milestone,
              showInTimeline: false,
              showInCalendar: true,
              recurringYearly: _recurring ? true : null,
            ),
          );
    } else {
      ref.read(familyDataProvider.notifier).updateTimelineEvent(
            existing.id,
            (event) => event.copyWith(
              date: _date,
              title: title,
              text: _note.text,
              showInTimeline: false,
              showInCalendar: true,
              recurringYearly: _recurring,
            ),
          );
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.calendarEntrySaved)),
    );
  }

  Future<void> _delete() async {
    final l10n = widget.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.calendarEntryDeleteConfirmTitle),
        content: Text(l10n.calendarEntryDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.calendarEntryDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final event = widget.event;
    if (event != null) {
      ref.read(familyDataProvider.notifier).removeTimelineEvent(event.id);
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.calendarEntryDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = Theme.of(context);
    final isEditing = widget.event != null;
    final canDelete = ref.watch(currentRoleProvider) == UserRole.admin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.calendarEntryTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(l10n.calendarEntryHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        SettingsTextField(
          label: l10n.calendarEntryTitleField,
          initialValue: _title.text,
          onChanged: (value) => _title.text = value,
        ),
        SettingsDateField(
          label: l10n.calendarEntryDateField,
          value: _date,
          hint: l10n.dateFormatHint,
          invalidLabel: l10n.invalidDate,
          onChanged: (value) => _date = value,
        ),
        SettingsTextField(
          label: l10n.calendarEntryNoteField,
          initialValue: _note.text,
          maxLines: 4,
          onChanged: (value) => _note.text = value,
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.moss,
          value: _recurring,
          title: Text(
            l10n.calendarEntryRecurring,
            style: theme.textTheme.bodyLarge,
          ),
          onChanged: (value) => setState(() => _recurring = value),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(l10n.settingsSave),
          ),
        ),
        if (isEditing) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: canDelete
                  ? _delete
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.adminOnlyDeleteHint)),
                      ),
              style: TextButton.styleFrom(
                foregroundColor: canDelete
                    ? AppColors.terracotta
                    : AppColors.inkSoft.withValues(alpha: 0.6),
              ),
              icon: Icon(
                canDelete ? Icons.delete_outline : Icons.lock_outline,
              ),
              label: Text(
                canDelete
                    ? l10n.calendarEntryDelete
                    : '${l10n.calendarEntryDelete} · ${l10n.adminOnlyAction}',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _iso(DateTime day) => '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';
