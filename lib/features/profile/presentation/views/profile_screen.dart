import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/accounts/presentation/providers/access_provider.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/family/presentation/widgets/kraft_background.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/media/presentation/widgets/media_viewer.dart';
import 'package:ourtree_app/features/profile/presentation/widgets/member_avatar.dart';
import 'package:ourtree_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Домашний альбом одного человека.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    required this.memberId,
  });

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final familyAsync = ref.watch(familyDataProvider);
    final settingsAsync = ref.watch(familySettingsProvider);

    return KraftBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: familyAsync.when(
            data: (family) {
              final visible = ref.watch(visibleFamilyProvider) ?? family;
              final member = visible.memberById(memberId);

              return Column(
                children: [
                  _ProfileTopBar(
                    title: settingsAsync.value?.familyName ??
                        family.familyName,
                    backTooltip: l10n.profileBack,
                  ),
                  Expanded(
                    child: member == null
                        ? _ProfileNotFound(l10n: l10n)
                        : _ProfileBody(
                            member: member,
                            family: visible,
                            l10n: l10n,
                          ),
                  ),
                ],
              );
            },
            loading: () => _StatusView(label: l10n.homeLoading),
            error: (error, stackTrace) => _StatusView(
              label: l10n.homeLoadError,
              retryLabel: l10n.homeRetry,
              onRetry: () => ref.invalidate(familyDataProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({
    required this.title,
    required this.backTooltip,
  });

  final String title;
  final String backTooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: backTooltip,
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

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.member,
    required this.family,
    required this.l10n,
  });

  final FamilyMember member;
  final FamilyData family;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final birthday = member.birthdayDate;
    final birthdayLabel = birthday == null
        ? formatDisplayDateFromIso(member.birthday, localeName: l10n.localeName)
        : formatDisplayDate(birthday, localeName: l10n.localeName);
    final age = _age(member);
    final meta = age == null
        ? birthdayLabel
        : '${l10n.memberAgeYears(age)} · $birthdayLabel';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
      children: [
        PaperCard(
          tilt: -0.6,
          child: Column(
            children: [
              MemberAvatar(member: member, size: 108),
              const SizedBox(height: 12),
              Text(
                member.role.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkSoft,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                member.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              if (member.nickname.trim().isNotEmpty)
                Text(
                  member.nickname,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                    color: AppColors.terracotta,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                meta,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PaperCard(
          tilt: 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.profileAbout, style: theme.textTheme.headlineSmall),
              if (stripRichText(member.about).trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  stripRichText(member.about),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
              if (member.habits.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final habit in member.habits)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.kraftWash,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stripRichText(habit),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ],
              for (final quote in member.quotes)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    stripRichText(quote),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontSize: 22,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _WishlistCard(member: member, l10n: l10n),
        const SizedBox(height: 14),
        _GalleryCard(member: member, family: family, l10n: l10n),
      ],
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.member,
    required this.l10n,
  });

  final FamilyMember member;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = member.wishlistUrl?.trim();
    final hasLink = url != null && url.isNotEmpty;

    return PaperCard(
      tilt: -0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileWishlist, style: theme.textTheme.headlineSmall),
          if (member.wishlist.isEmpty && !hasLink)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.profileWishlistEmpty,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          for (final item in member.wishlist)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.kraftWash,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.note?.trim().isNotEmpty == true)
                      Text(
                        item.note!.trim(),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (item.url?.trim().isNotEmpty == true)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => _openUrl(
                            context,
                            item.url!.trim(),
                            l10n,
                          ),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(item.url!.trim()),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (hasLink) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _openUrl(context, url, l10n),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.mediaOpenLink),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.profileLinkCopied)),
                    );
                  },
                  icon: const Icon(Icons.link),
                  label: Text(l10n.profileCopyWishlistLink),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({
    required this.member,
    required this.family,
    required this.l10n,
  });

  final FamilyMember member;
  final FamilyData family;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _galleryEntries(family.mediaForMember(member.id));
    final viewerItems = [
      for (final item in items)
        if (item.source != null && item.source!.trim().isNotEmpty)
          MediaViewerItem(
            source: item.source!,
            type: item.type,
            name: item.name,
            caption: item.caption,
            position: item.position,
            zoom: item.zoom,
          ),
    ];

    int viewerIndexFor(int index) => items
        .take(index)
        .where((item) => item.source?.trim().isNotEmpty == true)
        .length;

    return PaperCard(
      tilt: 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.profileGallery, style: theme.textTheme.headlineSmall),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.profileGalleryEmpty,
                style: theme.textTheme.bodyLarge,
              ),
            )
          else ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 10) / 2;
                return Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    for (var index = 0; index < items.length; index++)
                      SizedBox(
                        width: itemWidth,
                        child: _Polaroid(
                          entry: items[index],
                          onTap: () => showMediaViewer(
                            context,
                            items: viewerItems,
                            initialIndex: viewerIndexFor(index),
                            eyebrow: formatDisplayDateFromIso(
                              member.birthday,
                              localeName: l10n.localeName,
                            ),
                            title: member.name,
                            subtitle: l10n.profileGallery,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _Polaroid extends StatelessWidget {
  const _Polaroid({required this.entry, required this.onTap});

  final _GalleryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallback = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x2E8A5A2E), Color(0x1F6F4B2A)],
        ),
      ),
      child: Icon(
        entry.type == MediaType.video
            ? Icons.play_circle_outline
            : Icons.photo_outlined,
        color: AppColors.inkSoft,
        size: 28,
      ),
    );
    final content = entry.type == MediaType.video
        ? const ColoredBox(
            color: Color(0xFF1C1712),
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: AppColors.paper,
                size: 30,
              ),
            ),
          )
        : entry.source == null
            ? fallback
            : FamilyPhoto(
                source: entry.source,
                fit: BoxFit.cover,
                alignment: photoAlignment(entry.position),
                zoom: entry.zoom ?? 1.4,
                fallback: fallback,
              );
    final caption = entry.caption?.trim();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF6),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: content,
              ),
            ),
          ),
          if (caption != null && caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  color: AppColors.inkSoft,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryEntry {
  const _GalleryEntry({
    required this.source,
    this.name,
    required this.type,
    this.caption,
    this.position,
    this.zoom,
  });

  final String? source;
  final String? name;
  final MediaType type;
  final String? caption;
  final PhotoPosition? position;
  final double? zoom;
}

List<_GalleryEntry> _galleryEntries(List<FamilyMedia> media) {
  return [
    for (final entry in media)
      _GalleryEntry(
        source: entry.source.trim().isEmpty ? null : entry.source.trim(),
        name: entry.name,
        type: entry.type,
        caption: entry.caption,
        position: entry.position,
        zoom: entry.zoom,
      ),
  ];
}

Future<void> _openUrl(
  BuildContext context,
  String url,
  AppLocalizations l10n,
) async {
  final uri = Uri.tryParse(url.trim());
  if (uri != null) {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened) return;
    } catch (_) {
      // Ниже ссылка просто копируется в буфер.
    }
  }
  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.profileLinkCopied)),
  );
}

class _StatusView extends StatelessWidget {
  const _StatusView({
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

class _ProfileNotFound extends StatelessWidget {
  const _ProfileNotFound({required this.l10n});

  final AppLocalizations l10n;

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
              Text(l10n.profileNotFound, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(l10n.profileBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int? _age(FamilyMember member) {
  final birthday = member.birthdayDate;
  if (birthday == null) return null;

  final now = DateTime.now();
  var years = now.year - birthday.year;
  if (now.isBefore(DateTime(now.year, birthday.month, birthday.day))) {
    years -= 1;
  }
  return years < 0 ? null : years;
}
