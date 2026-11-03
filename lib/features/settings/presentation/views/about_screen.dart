import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/config/app_info.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/providers/cloud_family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/kraft_background.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Страница «О приложении».
///
/// Показывает версию сборки, разработчика, документы и лицензии — то, что
/// обычно ищут в таких разделах, плюс ID семьи для обращения в поддержку.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final family = ref.watch(activeFamilyControllerProvider).value;

    return KraftBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        l10n.aboutTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                  children: [
                    const _AppSummary(),
                    const SizedBox(height: 14),
                    PaperCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.aboutDescription,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: l10n.aboutVersion,
                            value: appVersionLabel,
                          ),
                          _InfoRow(
                            label: l10n.aboutPlatform,
                            value: _platformLabel(),
                          ),
                          if (appDeveloper.isNotEmpty)
                            _InfoRow(
                              label: l10n.aboutDeveloper,
                              value: appDeveloper,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _WhatsNewCard(),
                    const SizedBox(height: 12),
                    _LinksCard(l10n: l10n),
                    const SizedBox(height: 12),
                    _SupportCard(l10n: l10n, familyId: family?.id),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        l10n.aboutCopyright(DateTime.now().year),
                        style: theme.textTheme.bodySmall,
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

  /// Название платформы для строки «Платформа».
  String _platformLabel() {
    if (kIsWeb) return 'Web / PWA';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }
}

/// Логотип, название и версия — шапка страницы.
class _AppSummary extends StatelessWidget {
  const _AppSummary();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PaperCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/branding/app_icon.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                width: 64,
                height: 64,
                child: Icon(Icons.park_outlined, color: AppColors.moss),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 2),
                Text(
                  l10n.aboutVersionLabel(appVersionLabel),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка «подпись — значение».
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkSoft,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// «Что нового» в текущей версии.
class _WhatsNewCard extends StatelessWidget {
  const _WhatsNewCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = <String>[
      l10n.aboutChangelog1,
      l10n.aboutChangelog2,
      l10n.aboutChangelog3,
      l10n.aboutChangelog4,
      l10n.aboutChangelog5,
    ];

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.aboutChangelogTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Документы, лицензии и связь с разработчиком.
class _LinksCard extends StatelessWidget {
  const _LinksCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          if (appPrivacyUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.aboutPrivacy),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _launch(context, appPrivacyUrl),
            ),
          if (appTermsUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.aboutTerms),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _launch(context, appTermsUrl),
            ),
          if (appSupportEmail.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(l10n.aboutContact),
              subtitle: Text(appSupportEmail),
              onTap: () => _launch(context, 'mailto:$appSupportEmail'),
            ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: Text(l10n.aboutLicenses),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: appVersionLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// ID семьи: по нему поддержке проще найти данные.
class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.l10n, required this.familyId});

  final AppLocalizations l10n;
  final String? familyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final id = familyId;

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.aboutSupport, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          if (id == null || id.isEmpty)
            Text(l10n.aboutNoFamily, style: theme.textTheme.bodyMedium)
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.aboutFamilyId}: $id',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.aboutCopyFamilyId,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: id));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.aboutFamilyIdCopied)),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Открывает внешнюю ссылку во внешнем приложении или браузере.
Future<void> _launch(BuildContext context, String url) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);

  try {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (opened) return;
  } catch (error) {
    debugPrint('О приложении: ссылка не открылась: $error');
  }

  messenger.showSnackBar(SnackBar(content: Text(l10n.aboutLinkFailed)));
}
