import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/access_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/widgets/accounts_panel.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/family/presentation/widgets/kraft_background.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_library_panel.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/backup_provider.dart';
import 'package:ourtree_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/backup_panel.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/member_editor_card.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/timeline_event_editor_card.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Разделы страницы настроек.
enum _SettingsSection { family, members, events, media, accounts, backups }


/// Полноценная страница настроек семьи.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  bool _initialized = false;
  _SettingsSection _section = _SettingsSection.family;

  @override
  void dispose() {
    _nameController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(familySettingsNotifierProvider.notifier);
    notifier.updateFamilyName(_nameController.text.trim());
    notifier.updateFamilyPhoto(_photoController.text);
    await notifier.save();
    // Автоматический снимок перед следующей правкой — как делал сервер
    // старого проекта, но не чаще backupThrottleMs.
    await ref.read(backupsNotifierProvider.notifier).create(automatic: true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsSaved)),
    );
  }

  Future<void> _pickFamilyPhoto() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;
    final hash = sha256.convert(bytes).toString();
    final existing = ref
        .read(familyDataProvider)
        .valueOrNull
        ?.findDuplicateMedia(
          hash: hash,
          name: file.name,
          size: bytes.length,
        );

    String source;
    if (existing != null) {
      source = existing.source;
    } else {
      final storedId = await MediaStorage.instance.saveBytes(
        bytes,
        name: file.name,
      );
      ref.read(familyDataProvider.notifier).upsertMediaAsset(
            MediaAsset(
              id: 'asset-$storedId',
              source: 'hive://$storedId',
              name: file.name,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              size: bytes.length,
              hash: hash,
            ),
          );
      source = 'hive://$storedId';
    }
    if (!mounted) return;
    _photoController.text = source;
    ref
        .read(familySettingsNotifierProvider.notifier)
        .updateFamilyPhoto(source);
    setState(() {});
  }

  void _addMember() {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now().toIso8601String().split('T').first;
    final memberId = 'member-${DateTime.now().millisecondsSinceEpoch}';
    ref.read(familyDataProvider.notifier).addMember(
          FamilyMember(
            id: memberId,
            role: l10n.memberDefaultRole,
            name: l10n.memberDefaultName,
            nickname: '',
            birthday: today,
            showBirthdayOnTimeline: true,
            about: '',
            accent: '#6b7352',
          ),
        );
    final account = ref.read(currentAccountProvider);
    if (account != null) {
      ref
          .read(accountsNotifierProvider.notifier)
          .grantMemberVisibility(account.id, memberId);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.memberAdded)),
    );
  }

  void _addEvent() {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now().toIso8601String().split('T').first;
    ref.read(familyDataProvider.notifier).addTimelineEvent(
          TimelineEvent(
            id: 'event-${DateTime.now().millisecondsSinceEpoch}',
            date: today,
            title: l10n.eventDefaultTitle,
            kind: EventKind.milestone,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.eventAdded)),
    );
  }

  Future<void> _confirmRemoveMember(FamilyMember member, AppLocalizations l10n) async {
    final confirmed = await _confirm(
      title: l10n.memberDeleteConfirmTitle,
      body: l10n.memberDeleteConfirmBody,
      action: l10n.memberDelete,
      l10n: l10n,
    );
    if (confirmed != true || !mounted) return;
    ref.read(familyDataProvider.notifier).removeMember(member.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.memberDeleted)),
    );
  }

  Future<void> _confirmRemoveEvent(
    TimelineEvent event,
    AppLocalizations l10n,
  ) async {
    final confirmed = await _confirm(
      title: l10n.eventDeleteConfirmTitle,
      body: l10n.eventDeleteConfirmBody,
      action: l10n.eventDelete,
      l10n: l10n,
    );
    if (confirmed != true || !mounted) return;
    ref.read(familyDataProvider.notifier).removeTimelineEvent(event.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.eventDeleted)),
    );
  }

  Future<bool?> _confirm({
    required String title,
    required String body,
    required String action,
    required AppLocalizations l10n,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final familyAsync = ref.watch(familyDataProvider);
    final settingsAsync = ref.watch(familySettingsNotifierProvider);
    final role = ref.watch(currentRoleProvider);
    final isAdmin = role == UserRole.admin;
    final canEdit = role != UserRole.viewer;
    final sections = <_SettingsSection>[
      if (isAdmin) _SettingsSection.family,
      if (canEdit) ...const [
        _SettingsSection.members,
        _SettingsSection.events,
        _SettingsSection.media,
      ],
      if (isAdmin) ...const [
        _SettingsSection.accounts,
        _SettingsSection.backups,
      ],
    ];
    final section = sections.contains(_section)
        ? _section
        : (sections.isEmpty ? null : sections.first);

    return KraftBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: familyAsync.when(
            data: (family) {
              final settings = settingsAsync.valueOrNull ?? family.settings;
              final visible = ref.watch(visibleFamilyProvider) ?? family;
              if (!_initialized) {
                _nameController.text = settings.familyName;
                _photoController.text = settings.familyPhoto ?? '';
                _initialized = true;
              }

              return Column(
                children: [
                  _SettingsTopBar(title: l10n.settingsTitle),
                  _SettingsTabs(
                    sections: sections,
                    selected: section,
                    l10n: l10n,
                    onSelected: (next) => setState(() => _section = next),
                  ),
                  const AccountSessionBar(),
                  Expanded(
                    child: section == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.settingsNoAccess,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : switch (section) {
                      _SettingsSection.family => ListView(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                          children: [
                            _SettingsSummary(
                              family: family,
                              familyName: settings.familyName,
                              l10n: l10n,
                            ),
                            const SizedBox(height: 14),
                            _SettingsForm(
                              formKey: _formKey,
                              settings: settings,
                              nameController: _nameController,
                              photoController: _photoController,
                              l10n: l10n,
                              onNameChanged: (value) => ref
                                  .read(familySettingsNotifierProvider.notifier)
                                  .updateFamilyName(value),
                              onPhotoChanged: (value) => ref
                                  .read(familySettingsNotifierProvider.notifier)
                                  .updateFamilyPhoto(value),
                              onUploadPhoto: _pickFamilyPhoto,
                              onClearPhoto: () {
                                _photoController.clear();
                                ref
                                    .read(
                                      familySettingsNotifierProvider.notifier,
                                    )
                                    .updateFamilyPhoto('');
                              },
                              onShowFamilyPhotoChanged: (value) => ref
                                  .read(familySettingsNotifierProvider.notifier)
                                  .updateShowFamilyPhotoInHeader(value),
                              onShowEventPhotosChanged: (value) => ref
                                  .read(familySettingsNotifierProvider.notifier)
                                  .updateShowEventPhotos(value),
                              onSave: _save,
                            ),
                          ],
                        ),
                      _SettingsSection.members => _MembersSection(
                          members: visible.members,
                          events: visible.timelineEvents,
                          canManage: isAdmin,
                          l10n: l10n,
                          onAdd: _addMember,
                          onChanged: (member) => ref
                              .read(familyDataProvider.notifier)
                              .updateMember(member.id, (_) => member),
                          onRemove: (member) =>
                              _confirmRemoveMember(member, l10n),
                        ),
                      _SettingsSection.events => _EventsSection(
                          events: [...visible.timelineEvents]
                            ..sort((a, b) => a.date.compareTo(b.date)),
                          members: visible.members,
                          canManage: isAdmin,
                          l10n: l10n,
                          onAdd: _addEvent,
                          onChanged: (event) => ref
                              .read(familyDataProvider.notifier)
                              .updateTimelineEvent(event.id, (_) => event),
                          onRemove: (event) =>
                              _confirmRemoveEvent(event, l10n),
                        ),
                      _SettingsSection.media => const MediaLibraryPanel(),
                      _SettingsSection.accounts => const AccountsPanel(),
                      _SettingsSection.backups => const BackupPanel(),
                    },
                  ),
                ],
              );
            },
            loading: () => _SettingsStatus(label: l10n.homeLoading),
            error: (error, stackTrace) => _SettingsStatus(
              label: l10n.homeLoadError,
              retryLabel: l10n.homeRetry,
              onRetry: () {
                ref.invalidate(familyDataProvider);
                ref.invalidate(familySettingsNotifierProvider);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTabs extends StatelessWidget {
  const _SettingsTabs({
    required this.sections,
    required this.selected,
    required this.l10n,
    required this.onSelected,
  });

  final List<_SettingsSection> sections;
  final _SettingsSection? selected;
  final AppLocalizations l10n;
  final ValueChanged<_SettingsSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          for (final section in sections) ...[
            ChoiceChip(
              selected: section == selected,
              label: Text(_settingsSectionLabel(section, l10n)),
              onSelected: (_) => onSelected(section),
              selectedColor: AppColors.moss,
              labelStyle: TextStyle(
                color: section == selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.kraftWash,
              side: BorderSide.none,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.members,
    required this.events,
    required this.canManage,
    required this.l10n,
    required this.onAdd,
    required this.onChanged,
    required this.onRemove,
  });

  final List<FamilyMember> members;
  final List<TimelineEvent> events;
  final bool canManage;
  final AppLocalizations l10n;
  final VoidCallback onAdd;
  final ValueChanged<FamilyMember> onChanged;
  final ValueChanged<FamilyMember> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(l10n.settingsMembersHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(l10n.memberAdd),
          ),
        ),
        const SizedBox(height: 16),
        if (members.isEmpty)
          PaperCard(
            tilt: 0.3,
            child: Text(
              l10n.familyEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          )
        else
          for (final member in members) ...[
            MemberEditorCard(
              member: member,
              l10n: l10n,
              members: members,
              events: events,
              canDelete: canManage,
              onChanged: onChanged,
              onRemove: () => onRemove(member),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _EventsSection extends StatelessWidget {
  const _EventsSection({
    required this.events,
    required this.members,
    required this.canManage,
    required this.l10n,
    required this.onAdd,
    required this.onChanged,
    required this.onRemove,
  });

  final List<TimelineEvent> events;
  final List<FamilyMember> members;
  final bool canManage;
  final AppLocalizations l10n;
  final VoidCallback onAdd;
  final ValueChanged<TimelineEvent> onChanged;
  final ValueChanged<TimelineEvent> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(l10n.settingsEventsHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.event_available),
            label: Text(l10n.eventAdd),
          ),
        ),
        const SizedBox(height: 16),
        if (events.isEmpty)
          PaperCard(
            tilt: -0.3,
            child: Text(
              l10n.timelineEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          )
        else
          for (final event in events) ...[
            TimelineEventEditorCard(
              event: event,
              members: members,
              canDelete: canManage,
              otherEvents: [
                for (final other in events)
                  if (other.id != event.id) other,
              ],
              l10n: l10n,
              onChanged: onChanged,
              onRemove: () => onRemove(event),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

String _settingsSectionLabel(_SettingsSection section, AppLocalizations l10n) {
  return switch (section) {
    _SettingsSection.family => l10n.settingsTabFamily,
    _SettingsSection.members => l10n.settingsTabMembers,
    _SettingsSection.events => l10n.settingsTabEvents,
    _SettingsSection.media => l10n.settingsTabMedia,
    _SettingsSection.accounts => l10n.settingsTabAccounts,
    _SettingsSection.backups => l10n.settingsTabBackups,
  };
}


class _SettingsSummary extends StatelessWidget {
  const _SettingsSummary({
    required this.family,
    required this.familyName,
    required this.l10n,
  });

  final FamilyData family;
  final String familyName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaperCard(
      tilt: -0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(familyName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CountChip(
                label: l10n.homeMembersCount(family.members.length),
              ),
              _CountChip(
                label: l10n.homeEventsCount(family.timelineEvents.length),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Caption(label: l10n.settingsDataSource),
          const SizedBox(height: 4),
          Text(l10n.settingsArchiveSource, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _SettingsForm extends StatelessWidget {
  const _SettingsForm({
    required this.formKey,
    required this.settings,
    required this.nameController,
    required this.photoController,
    required this.l10n,
    required this.onNameChanged,
    required this.onPhotoChanged,
    required this.onUploadPhoto,
    required this.onClearPhoto,
    required this.onShowFamilyPhotoChanged,
    required this.onShowEventPhotosChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final FamilySettings settings;
  final TextEditingController nameController;
  final TextEditingController photoController;
  final AppLocalizations l10n;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhotoChanged;
  final VoidCallback onUploadPhoto;
  final VoidCallback onClearPhoto;
  final ValueChanged<bool> onShowFamilyPhotoChanged;
  final ValueChanged<bool> onShowEventPhotosChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaperCard(
      tilt: 0.4,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Caption(label: l10n.settingsFamilyName),
            const SizedBox(height: 6),
            TextFormField(
              controller: nameController,
              onChanged: onNameChanged,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.settingsNameRequired;
                }
                return null;
              },
              decoration: _inputDecoration(hint: l10n.settingsFamilyName),
            ),
            const SizedBox(height: 16),
            _Caption(label: l10n.settingsFamilyPhoto),
            const SizedBox(height: 6),
            TextFormField(
              controller: photoController,
              onChanged: onPhotoChanged,
              decoration: _inputDecoration(hint: l10n.settingsFamilyPhotoHint),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FamilyPhoto(
                  source: photoController.text,
                  fit: BoxFit.cover,
                  fallback: Container(
                    color: AppColors.kraftWash,
                    child: Center(
                      child: Text(
                        l10n.settingsPhotoPreview,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Georgia',
                          fontStyle: FontStyle.italic,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onUploadPhoto,
                  icon: const Icon(Icons.upload_file),
                  label: Text(l10n.mediaUpload),
                ),
                if (photoController.text.trim().isNotEmpty)
                  TextButton.icon(
                    onPressed: onClearPhoto,
                    icon: const Icon(Icons.close),
                    label: Text(l10n.settingsClearPhoto),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _Caption(label: l10n.settingsAppearance),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.moss,
              value: settings.showFamilyPhotoInHeader,
              onChanged: onShowFamilyPhotoChanged,
              title: Text(
                l10n.settingsShowFamilyPhoto,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.moss,
              value: settings.showEventPhotos,
              onChanged: onShowEventPhotosChanged,
              title: Text(
                l10n.settingsShowEventPhotos,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.settingsSave),
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.settingsLocalOnly, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({required String hint}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0x99FFFDF6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x386F4B2A)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x386F4B2A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.moss, width: 2),
    ),
  );
}

class _SettingsTopBar extends StatelessWidget {
  const _SettingsTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.inkSoft,
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kraftWash,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsStatus extends StatelessWidget {
  const _SettingsStatus({
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
    );
  }
}
