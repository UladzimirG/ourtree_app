import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/identity_provider.dart';
import 'package:ourtree_app/features/accounts/presentation/widgets/account_button.dart';
import 'package:ourtree_app/features/accounts/presentation/widgets/accounts_panel.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_cloud_panel.dart';
import 'package:ourtree_app/features/family/presentation/widgets/kraft_background.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/media/presentation/providers/media_upload_service.dart';
import 'package:ourtree_app/features/notifications/presentation/widgets/notifications_panel.dart';
import 'package:ourtree_app/features/media/presentation/widgets/demo_storage_notice.dart';
import 'package:ourtree_app/features/media/domain/models/photo_crop.dart';
import 'package:ourtree_app/features/media/presentation/widgets/interactive_photo_crop.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_library_panel.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/backup_provider.dart';
import 'package:ourtree_app/features/settings/presentation/providers/locale_provider.dart';
import 'package:ourtree_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:ourtree_app/features/settings/presentation/views/about_screen.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/backup_panel.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Разделы страницы настроек.
///
/// «Общие настройки» объединяют то, что не относится к контенту семьи:
/// язык интерфейса, резервные копии и доступы. Внутри они открываются
/// отдельными подстраницами.
enum _SettingsSection { family, media, general }

/// Полноценная страница настроек семьи.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  bool _initialized = false;
  _SettingsSection _section = _SettingsSection.family;

  /// Язык, для которого сейчас заполнена форма.
  Locale? _locale;

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(familySettingsProvider.notifier);

    // Название семьи живёт в двух местах: «шапка» локального архива и документ
    // семьи в облаке. Облачную запись делает только владелец — остальным
    // правила Firestore менять её не разрешают.
    if (!await _renameFamilyIfNeeded(_nameController.text.trim(), l10n)) {
      return;
    }

    notifier.updateFamilySubtitle(_subtitleController.text);
    notifier.updateFamilyPhoto(_photoController.text);
    await notifier.save();
    // Автоматический снимок перед следующей правкой — как делал сервер
    // старого проекта, но не чаще backupThrottleMs.
    await ref.read(backupsProvider.notifier).create(automatic: true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsSaved)),
    );
  }

  /// Переименование семьи: облако (если подключено) + локальная «шапка».
  ///
  /// Возвращает false, если сохранять форму нельзя: облако отклонило
  /// переименование (нет прав или нет сети) — тогда пользователь видит ошибку,
  /// а локальные данные остаются прежними.
  Future<bool> _renameFamilyIfNeeded(
    String name,
    AppLocalizations l10n,
  ) async {
    final notifier = ref.read(familySettingsProvider.notifier);
    final family = ref.read(activeFamilyControllerProvider).value;
    if (family == null) {
      notifier.updateFamilyName(name);
      return true;
    }

    final identity = ref.read(identityControllerProvider).value;
    final isOwner = identity != null && family.ownerAuthUid == identity.authUid;
    if (!isOwner) {
      // Поле названия для не-владельца только для чтения: не трогаем его,
      // но остальные настройки сохранить можно.
      return true;
    }
    if (family.name == name) {
      notifier.updateFamilyName(name);
      return true;
    }

    try {
      await ref.read(activeFamilyControllerProvider.notifier).rename(name);
      return true;
    } catch (_) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.familyRenameFailed)),
      );
      return false;
    }
  }

  /// После отката к демо-данным форма должна перечитаться из архива.
  void _onArchiveReset() {
    if (!mounted) return;
    setState(() => _initialized = false);
  }

  Future<void> _pickFamilyPhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;
    final hash = sha256.convert(bytes).toString();
    final existing = ref.read(familyDataProvider).value?.findDuplicateMedia(
          hash: hash,
          name: file.name,
          size: bytes.length,
        );

    String source;
    if (existing != null) {
      source = existing.source;
    } else {
      final asset = await ref.read(mediaUploadServiceProvider.notifier).store(
            bytes: bytes,
            name: file.name,
            hash: hash,
          );
      ref.read(familyDataProvider.notifier).upsertMediaAsset(asset);
      source = asset.source;
      if (!ref.read(mediaUploadServiceProvider) && mounted) {
        showLocalOnlyNotice(context, l10n);
      }
    }
    if (!mounted) return;
    _photoController.text = source;
    ref.read(familySettingsProvider.notifier).updateFamilyPhoto(source);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final familyAsync = ref.watch(familyDataProvider);
    final settingsAsync = ref.watch(familySettingsProvider);

    // После смены языка архив другой, поэтому форму заполняем заново.
    final locale = ref.watch(appLocaleProvider);
    if (locale != _locale) {
      _locale = locale;
      _initialized = false;
    }
    final role = ref.watch(currentRoleProvider);
    final isAdmin = role == UserRole.admin;
    final canEdit = role != UserRole.viewer;
    final sections = <_SettingsSection>[
      // «Семья» показываем всем: название и оформление должны быть
      // обнаружимы, даже если менять их может только администратор.
      _SettingsSection.family,
      if (canEdit) _SettingsSection.media,
      // Общие настройки доступны всем: язык — это настройка устройства.
      _SettingsSection.general,
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
              final settings = settingsAsync.value ?? family.settings;
              final activeFamily =
                  ref.watch(activeFamilyControllerProvider).value;
              final identity = ref.watch(identityControllerProvider).value;
              // Название семьи меняет только владелец: остальным поля формы
              // доступны, а имя — только для чтения.
              final canRename = activeFamily == null ||
                  (identity != null &&
                      activeFamily.ownerAuthUid == identity.authUid);
              if (!_initialized) {
                _nameController.text = settings.familyName;
                _subtitleController.text = settings.familySubtitle;
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
                                padding:
                                    const EdgeInsets.fromLTRB(16, 6, 16, 32),
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
                                    subtitleController: _subtitleController,
                                    photoController: _photoController,
                                    l10n: l10n,
                                    onNameChanged: (value) => ref
                                        .read(familySettingsProvider.notifier)
                                        .updateFamilyName(value),
                                    onSubtitleChanged: (value) => ref
                                        .read(familySettingsProvider.notifier)
                                        .updateFamilySubtitle(value),
                                    onPhotoChanged: (value) => ref
                                        .read(familySettingsProvider.notifier)
                                        .updateFamilyPhoto(value),
                                    onUploadPhoto: _pickFamilyPhoto,
                                    onClearPhoto: () {
                                      _photoController.clear();
                                      ref
                                          .read(
                                            familySettingsProvider.notifier,
                                          )
                                          .updateFamilyPhoto('');
                                    },
                                    onShowFamilyPhotoChanged: (value) => ref
                                        .read(familySettingsProvider.notifier)
                                        .updateShowFamilyPhotoInHeader(value),
                                    onShowEventPhotosChanged: (value) => ref
                                        .read(familySettingsProvider.notifier)
                                        .updateShowEventPhotos(value),
                                    canRename: canRename,
                                    canEdit: isAdmin,
                                    onPhotoPositionChanged: (position) => ref
                                        .read(familySettingsProvider.notifier)
                                        .updateFamilyPhotoPosition(position),
                                    onPhotoZoomChanged: (zoom) => ref
                                        .read(familySettingsProvider.notifier)
                                        .updateFamilyPhotoZoom(zoom),
                                    onSave: _save,
                                  ),
                                ],
                              ),
                            _SettingsSection.media => const MediaLibraryPanel(),
                            _SettingsSection.general => _GeneralSection(
                                onArchiveReset: _onArchiveReset,
                              ),
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
                ref.invalidate(familySettingsProvider);
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
    // Wrap вместо горизонтальной прокрутки: на узком экране чипы
    // переносятся на следующую строку и не обрезаются по бокам.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final section in sections)
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
        ],
      ),
    );
  }
}

/// Общие настройки семьи: точки входа в подстраницы.
///
/// Здесь только то, что не относится к контенту семьи. Панели копий и
/// аккаунтов — самостоятельные страницы с собственной прокруткой, поэтому
/// открываем их отдельными маршрутами, а не аккордеоном внутри списка.
class _GeneralSection extends ConsumerWidget {
  const _GeneralSection({required this.onArchiveReset});

  /// Сообщает странице настроек, что архив сброшен и форму надо перечитать.
  final VoidCallback onArchiveReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAdmin = ref.watch(currentRoleProvider) == UserRole.admin;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        Text(l10n.settingsGeneralHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 14),
        _SettingsLink(
          icon: Icons.cloud_outlined,
          title: l10n.familyCloudTitle,
          subtitle: l10n.familyCloudHint,
          page: (_) => const FamilyCloudPanel(),
        ),
        const SizedBox(height: 10),
        _SettingsLink(
          icon: Icons.translate,
          title: l10n.settingsTabLanguage,
          subtitle: l10n.settingsLanguageHint,
          page: (_) => const _LanguageSection(),
        ),
        const SizedBox(height: 10),
        _SettingsLink(
          icon: Icons.notifications_outlined,
          title: l10n.notificationsTitle,
          subtitle: l10n.notificationsHint,
          page: (_) => const NotificationsPanel(),
        ),
        const SizedBox(height: 10),
        _SettingsLink(
          icon: Icons.info_outline,
          title: l10n.aboutTitle,
          subtitle: l10n.aboutHint,
          page: (_) => const AboutScreen(),
        ),
        if (isAdmin) ...[
          const SizedBox(height: 10),
          _SettingsLink(
            icon: Icons.history,
            title: l10n.settingsTabBackups,
            subtitle: l10n.settingsBackupsHint,
            page: (_) => const BackupPanel(),
          ),
          const SizedBox(height: 10),
          _SettingsLink(
            icon: Icons.people_outline,
            title: l10n.settingsTabAccounts,
            subtitle: l10n.settingsAccountsHint,
            page: (_) => const AccountsPanel(),
          ),
          const SizedBox(height: 10),
          _SettingsLink(
            icon: Icons.restore,
            title: l10n.settingsResetDemo,
            subtitle: l10n.settingsResetDemoHint,
            onTap: () => _resetToDemo(context, ref),
          ),
        ] else ...[
          const SizedBox(height: 10),
          PaperCard(
            tilt: 0.3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline, color: AppColors.inkSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.adminOnlySettingsHint,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Сбрасывает локальные правки и возвращает демо-архив.
  ///
  /// Действие необратимо: сначала предупреждаем и предлагаем сделать
  /// резервную копию. Облачные данные при этом не удаляются.
  Future<void> _resetToDemo(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final hasCloud = ref.read(activeFamilyControllerProvider).value != null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsResetDemoConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsResetDemoConfirmBody),
            if (hasCloud) ...[
              const SizedBox(height: 10),
              Text(
                l10n.settingsResetDemoCloudWarning(l10n.familyCloudDeleteCloud),
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => _backupBeforeReset(dialogContext, ref),
            child: Text(l10n.settingsResetDemoBackup),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.settingsResetDemoAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(familyDataProvider.notifier).resetToDemo();
    onArchiveReset();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsResetDemoDone)),
    );
  }

  /// Делает снимок текущего состояния прямо из диалога отката.
  Future<void> _backupBeforeReset(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(backupsProvider.notifier).create();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsResetDemoBackupDone)),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsResetDemoBackupFailed)),
      );
    }
  }
}

/// Строка-переход на подстраницу общих настроек.
class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.page,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Куда ведёт строка. Если не задано, используется [onTap].
  final WidgetBuilder? page;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaperCard(
      onTap: () {
        if (onTap != null) {
          onTap!();
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (pageContext) => _SettingsSubpage(
              title: title,
              child: page!(pageContext),
            ),
          ),
        );
      },
      child: Row(
        children: [
          Icon(icon, color: AppColors.terracotta),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.inkSoft),
        ],
      ),
    );
  }
}

/// Подстраница общих настроек: та же «бумажная» рамка и кнопка «назад».
class _SettingsSubpage extends StatelessWidget {
  const _SettingsSubpage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KraftBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _SettingsTopBar(title: title),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Выбор языка интерфейса.
///
/// Это настройка конкретного устройства, поэтому она не зависит от роли
/// аккаунта: выбор доступен и наблюдателю, и администратору.
class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedCode =
        ref.watch(localeControllerProvider)?.languageCode ?? systemLocaleCode;

    void select(String code) {
      ref.read(localeControllerProvider.notifier).select(
            code == systemLocaleCode ? null : Locale(code),
          );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        PaperCard(
          tilt: -0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Caption(label: l10n.settingsLanguage),
              const SizedBox(height: 8),
              Text(l10n.settingsLanguageHint,
                  style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              _LanguageOption(
                label: l10n.settingsLanguageSystem,
                selected: selectedCode == systemLocaleCode,
                onTap: () => select(systemLocaleCode),
              ),
              // Языки — по алфавиту: English, Беларуская, Русский, Українська.
              _LanguageOption(
                label: l10n.settingsLanguageEnglish,
                selected: selectedCode == 'en',
                onTap: () => select('en'),
              ),
              _LanguageOption(
                label: l10n.settingsLanguageBelarusian,
                selected: selectedCode == 'be',
                onTap: () => select('be'),
              ),
              _LanguageOption(
                label: l10n.settingsLanguageRussian,
                selected: selectedCode == 'ru',
                onTap: () => select('ru'),
              ),
              _LanguageOption(
                label: l10n.settingsLanguageUkrainian,
                selected: selectedCode == 'uk',
                onTap: () => select('uk'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Строка выбора языка.
///
/// Вместо `RadioListTile` используем иконки-«радио»: они не зависят от
/// устаревшего API группы и одинаково ведут себя на любой ширине экрана.
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.moss : AppColors.inkSoft,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? AppColors.ink : AppColors.inkSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _settingsSectionLabel(_SettingsSection section, AppLocalizations l10n) {
  return switch (section) {
    _SettingsSection.family => l10n.settingsTabFamily,
    _SettingsSection.media => l10n.settingsTabMedia,
    _SettingsSection.general => l10n.settingsTabGeneral,
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
    required this.subtitleController,
    required this.photoController,
    required this.l10n,
    required this.onNameChanged,
    required this.onSubtitleChanged,
    required this.onPhotoChanged,
    required this.onUploadPhoto,
    required this.onClearPhoto,
    required this.onShowFamilyPhotoChanged,
    required this.onShowEventPhotosChanged,
    required this.canRename,
    required this.canEdit,
    required this.onPhotoPositionChanged,
    required this.onPhotoZoomChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final FamilySettings settings;
  final TextEditingController nameController;
  final TextEditingController subtitleController;
  final TextEditingController photoController;
  final AppLocalizations l10n;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onSubtitleChanged;
  final ValueChanged<String> onPhotoChanged;
  final VoidCallback onUploadPhoto;
  final VoidCallback onClearPhoto;
  final ValueChanged<bool> onShowFamilyPhotoChanged;
  final ValueChanged<bool> onShowEventPhotosChanged;

  /// Может ли текущий пользователь менять название семьи.
  final bool canRename;

  /// Может ли текущий пользователь редактировать настройки семьи.
  /// Наблюдатели и редакторы видят раздел, но только для чтения.
  final bool canEdit;

  final ValueChanged<PhotoPosition> onPhotoPositionChanged;
  final ValueChanged<double> onPhotoZoomChanged;
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
              readOnly: !canEdit || !canRename,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.settingsNameRequired;
                }
                return null;
              },
              decoration:
                  _inputDecoration(hint: l10n.settingsFamilyName).copyWith(
                suffixIcon: canEdit && canRename
                    ? null
                    : const Icon(Icons.lock_outline, size: 18),
              ),
            ),
            if (!canRename)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.familyRenameOwnerOnly,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.terracotta,
                  ),
                ),
              ),
            if (!canEdit)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  l10n.settingsFamilyReadOnly,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.terracotta,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _Caption(label: l10n.settingsFamilySubtitle),
            const SizedBox(height: 6),
            TextFormField(
              controller: subtitleController,
              onChanged: onSubtitleChanged,
              readOnly: !canEdit,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hint: l10n.settingsFamilySubtitleHint,
              ),
            ),
            const SizedBox(height: 16),
            _Caption(label: l10n.settingsFamilyPhoto),
            const SizedBox(height: 6),
            TextFormField(
              controller: photoController,
              onChanged: onPhotoChanged,
              readOnly: !canEdit,
              decoration: _inputDecoration(hint: l10n.settingsFamilyPhotoHint),
            ),
            const SizedBox(height: 10),
            if (photoController.text.trim().isEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
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
              )
            else
              InteractivePhotoCrop(
                source: photoController.text.trim(),
                position: settings.familyPhotoPosition ?? PhotoPosition.center,
                zoom: photoZoomOrDefault(settings.familyPhotoZoom),
                onChanged: (position, zoom) {
                  onPhotoPositionChanged(position);
                  onPhotoZoomChanged(zoom);
                },
                showExpand: true,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: canEdit ? onUploadPhoto : null,
                  icon: const Icon(Icons.upload_file),
                  label: Text(l10n.mediaUpload),
                ),
                if (photoController.text.trim().isNotEmpty)
                  TextButton.icon(
                    onPressed: canEdit ? onClearPhoto : null,
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
              onChanged: canEdit ? onShowFamilyPhotoChanged : null,
              title: Text(
                l10n.settingsShowFamilyPhoto,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.moss,
              value: settings.showEventPhotos,
              onChanged: canEdit ? onShowEventPhotosChanged : null,
              title: Text(
                l10n.settingsShowEventPhotos,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canEdit ? onSave : null,
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
          const AccountButton(),
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
