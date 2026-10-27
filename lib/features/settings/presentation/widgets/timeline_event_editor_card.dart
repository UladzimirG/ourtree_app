import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/media_editor.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/settings_fields.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Форма редактирования одного события таймлайна.
class TimelineEventEditorCard extends StatelessWidget {
  const TimelineEventEditorCard({
    super.key,
    required this.event,
    required this.members,
    required this.l10n,
    required this.onChanged,
    required this.onRemove,
    this.canDelete = true,
    this.otherEvents = const <TimelineEvent>[],
  });

  final TimelineEvent event;
  final List<FamilyMember> members;
  final List<TimelineEvent> otherEvents;
  final AppLocalizations l10n;
  final ValueChanged<TimelineEvent> onChanged;
  final VoidCallback onRemove;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberId = members.any((member) => member.id == event.memberId)
        ? event.memberId
        : null;

    return PaperCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const Icon(Icons.event_outlined, color: AppColors.terracotta),
        title: Text(
          event.title.trim().isEmpty ? '—' : event.title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          formatDisplayDateFromIso(event.date),
          style: theme.textTheme.bodySmall,
        ),
        children: [
          SettingsTextField(
            label: l10n.eventTitleField,
            initialValue: event.title,
            onChanged: (value) => onChanged(event.copyWith(title: value)),
          ),
          SettingsDateField(
            label: l10n.eventDateField,
            value: event.date,
            hint: l10n.dateFormatHint,
            invalidLabel: l10n.invalidDate,
            onChanged: (value) => onChanged(event.copyWith(date: value)),
          ),
          _SectionLabel(label: l10n.eventKindField),
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0x99FFFDF6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x386F4B2A)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<EventKind>(
                isExpanded: true,
                value: event.kind,
                items: [
                  for (final kind in EventKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(_eventKindLabel(kind, l10n)),
                    ),
                ],
                onChanged: (kind) {
                  if (kind != null) onChanged(event.copyWith(kind: kind));
                },
              ),
            ),
          ),
          SettingsTextField(
            label: l10n.eventPlaceField,
            initialValue: event.place ?? '',
            onChanged: (value) => onChanged(
              event.copyWith(
                place: () => value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          SettingsTextField(
            label: l10n.eventTextField,
            initialValue: stripRichText(event.text),
            maxLines: 4,
            onChanged: (value) => onChanged(
              event.copyWith(text: stripRichText(value)),
            ),
          ),
          if (event.photo != null)
            SettingsPhotoField(
              label: l10n.mediaTitle,
              source: event.photo,
              hint: l10n.photoPathHint,
              clearLabel: l10n.settingsClearPhoto,
              previewLabel: l10n.settingsPhotoPreview,
              uploadLabel: l10n.mediaUpload,
              l10n: l10n,
              position: event.photoPosition,
              zoom: event.photoZoom,
              onPositionChange: (position) => onChanged(
                event.copyWith(photoPosition: () => position),
              ),
              onZoomChange: (zoom) => onChanged(
                event.copyWith(photoZoom: () => zoom),
              ),
              onChanged: (value) => onChanged(
                event.copyWith(
                  photo: () => value.trim().isEmpty ? null : value.trim(),
                ),
              ),
            ),
          MediaListEditor(
            value: event.media,
            l10n: l10n,
            members: members,
            events: otherEvents,
            title: l10n.mediaTitle,
            onChanged: (media) => onChanged(event.copyWith(media: media)),
          ),
          const Divider(color: Color(0x336F4B2A), height: 24),
          _SectionLabel(label: l10n.eventMemberField),
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0x99FFFDF6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x386F4B2A)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: memberId ?? '',
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(l10n.eventMemberNone),
                  ),
                  for (final member in members)
                    DropdownMenuItem(
                      value: member.id,
                      child: Text(
                        member.name.trim().isEmpty ? '—' : member.name,
                      ),
                    ),
                ],
                onChanged: (value) => onChanged(
                  event.copyWith(
                    memberId: () =>
                        value == null || value.isEmpty ? null : value,
                  ),
                ),
              ),
            ),
          ),
          SettingsSwitchField(
            label: l10n.eventShowElapsed,
            value: event.showElapsed ?? false,
            onChanged: (value) => onChanged(
              event.copyWith(showElapsed: () => value),
            ),
          ),
          SettingsSwitchField(
            label: l10n.eventShowInCalendar,
            value: event.showInCalendar ?? true,
            onChanged: (value) => onChanged(
              event.copyWith(showInCalendar: value),
            ),
          ),
          if (canDelete)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.terracotta,
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.eventDelete),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: settingsCaptionStyle(Theme.of(context)),
      ),
    );
  }
}

String _eventKindLabel(EventKind kind, AppLocalizations l10n) {
  return switch (kind) {
    EventKind.meeting => l10n.eventKindMeeting,
    EventKind.date => l10n.eventKindDate,
    EventKind.wedding => l10n.eventKindWedding,
    EventKind.church => l10n.eventKindChurch,
    EventKind.birth => l10n.eventKindBirth,
    EventKind.trip => l10n.eventKindTrip,
    EventKind.milestone => l10n.eventKindMilestone,
  };
}
