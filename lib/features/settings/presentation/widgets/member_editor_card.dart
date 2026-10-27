import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/rich_text.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/profile/presentation/widgets/member_avatar.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/media_editor.dart';
import 'package:ourtree_app/features/settings/presentation/widgets/settings_fields.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Форма редактирования одного члена семьи.
class MemberEditorCard extends StatelessWidget {
  const MemberEditorCard({
    super.key,
    required this.member,
    required this.l10n,
    required this.onChanged,
    required this.onRemove,
    this.canDelete = true,
    this.members = const <FamilyMember>[],
    this.events = const <TimelineEvent>[],
  });

  final FamilyMember member;
  final AppLocalizations l10n;
  final ValueChanged<FamilyMember> onChanged;
  final VoidCallback onRemove;
  final bool canDelete;
  final List<FamilyMember> members;
  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = member.name.trim().isEmpty ? '—' : member.name;

    return PaperCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: MemberAvatar(member: member, size: 44),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(member.role, style: theme.textTheme.bodySmall),
        children: [
          SettingsTextField(
            label: l10n.memberNameField,
            initialValue: member.name,
            onChanged: (value) => onChanged(member.copyWith(name: value)),
          ),
          SettingsTextField(
            label: l10n.memberRoleField,
            initialValue: member.role,
            onChanged: (value) => onChanged(member.copyWith(role: value)),
          ),
          SettingsTextField(
            label: l10n.memberNicknameField,
            initialValue: member.nickname,
            onChanged: (value) => onChanged(member.copyWith(nickname: value)),
          ),
          SettingsDateField(
            label: l10n.memberBirthdayField,
            value: member.birthday,
            hint: l10n.dateFormatHint,
            invalidLabel: l10n.invalidDate,
            onChanged: (value) => onChanged(member.copyWith(birthday: value)),
          ),
          SettingsSwitchField(
            label: l10n.memberShowBirthday,
            value: member.showBirthdayOnTimeline ?? true,
            onChanged: (value) => onChanged(
              member.copyWith(showBirthdayOnTimeline: value),
            ),
          ),
          SettingsSwitchField(
            label: l10n.memberShowInCalendar,
            value: member.showInCalendar ?? true,
            onChanged: (value) => onChanged(
              member.copyWith(showInCalendar: value),
            ),
          ),
          const SizedBox(height: 8),
          MediaListEditor(
            value: member.birthdayMedia,
            l10n: l10n,
            members: members,
            events: events,
            ownerId: member.id,
            title: l10n.memberBirthdayMedia,
            showEvents: false,
            onChanged: (media) => onChanged(member.copyWith(birthdayMedia: media)),
          ),
          const Divider(color: Color(0x336F4B2A), height: 28),
          SettingsPhotoField(
            label: l10n.memberMainPhoto,
            source: member.photo,
            hint: l10n.photoPathHint,
            clearLabel: l10n.settingsClearPhoto,
            previewLabel: l10n.settingsPhotoPreview,
            uploadLabel: l10n.mediaUpload,
            l10n: l10n,
            position: member.photoPosition,
            zoom: member.photoZoom,
            onPositionChange: (position) => onChanged(
              member.copyWith(photoPosition: () => position),
            ),
            onZoomChange: (zoom) => onChanged(
              member.copyWith(photoZoom: () => zoom),
            ),
            onChanged: (value) => onChanged(
              member.copyWith(
                photo: () => value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          SettingsTextField(
            label: l10n.profileAbout,
            initialValue: stripRichText(member.about),
            maxLines: 4,
            onChanged: (value) => onChanged(
              member.copyWith(about: stripRichText(value)),
            ),
          ),
          SettingsTextField(
            label: l10n.memberHabitsField,
            initialValue: member.habits.map(stripRichText).join('\n'),
            maxLines: 4,
            onChanged: (value) => onChanged(
              member.copyWith(
                habits: _lines(value).map(stripRichText).toList(),
              ),
            ),
          ),
          SettingsTextField(
            label: l10n.memberQuotesField,
            initialValue: member.quotes.map(stripRichText).join('\n'),
            maxLines: 4,
            onChanged: (value) => onChanged(
              member.copyWith(
                quotes: _lines(value).map(stripRichText).toList(),
              ),
            ),
          ),
          SettingsTextField(
            label: l10n.memberAccentField,
            initialValue: member.accent,
            hint: '#6b7352',
            onChanged: (value) => onChanged(member.copyWith(accent: value)),
          ),
          SettingsTextField(
            label: l10n.memberWishlistUrlField,
            initialValue: member.wishlistUrl ?? '',
            keyboardType: TextInputType.url,
            onChanged: (value) => onChanged(
              member.copyWith(
                wishlistUrl: () => value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.memberWishlistTitle.toUpperCase(),
                  style: settingsCaptionStyle(theme),
                ),
              ),
              TextButton.icon(
                onPressed: () => onChanged(
                  member.copyWith(
                    wishlist: [
                      ...member.wishlist,
                      const WishlistItem(title: ''),
                    ],
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.memberWishlistAdd),
              ),
            ],
          ),
          if (member.wishlist.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.memberWishlistEmpty,
                style: theme.textTheme.bodySmall,
              ),
            )
          else
            for (var index = 0; index < member.wishlist.length; index++)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                decoration: BoxDecoration(
                  color: AppColors.kraftWash,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SettingsTextField(
                      label: l10n.wishlistItemTitleField,
                      initialValue: member.wishlist[index].title,
                      onChanged: (value) => onChanged(
                        member.copyWith(
                          wishlist: _replaceWish(
                            member.wishlist,
                            index,
                            member.wishlist[index].copyWith(title: value),
                          ),
                        ),
                      ),
                    ),
                    SettingsTextField(
                      label: l10n.wishlistItemUrlField,
                      initialValue: member.wishlist[index].url ?? '',
                      keyboardType: TextInputType.url,
                      onChanged: (value) => onChanged(
                        member.copyWith(
                          wishlist: _replaceWish(
                            member.wishlist,
                            index,
                            member.wishlist[index].copyWith(
                              url: () => value.trim().isEmpty
                                  ? null
                                  : value.trim(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SettingsTextField(
                      label: l10n.wishlistNoteField,
                      initialValue: member.wishlist[index].note ?? '',
                      maxLines: 2,
                      onChanged: (value) => onChanged(
                        member.copyWith(
                          wishlist: _replaceWish(
                            member.wishlist,
                            index,
                            member.wishlist[index].copyWith(
                              note: () => value.trim().isEmpty
                                  ? null
                                  : value.trim(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => onChanged(
                          member.copyWith(
                            wishlist: [
                              for (var i = 0; i < member.wishlist.length; i++)
                                if (i != index) member.wishlist[i],
                            ],
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.terracotta,
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.wishlistRemove),
                      ),
                    ),
                  ],
                ),
              ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.memberGalleryTitle.toUpperCase(),
                  style: settingsCaptionStyle(theme),
                ),
              ),
              TextButton.icon(
                onPressed: () => onChanged(
                  member.copyWith(
                    gallery: [
                      ...member.gallery,
                      const GalleryShot(),
                    ],
                  ),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(l10n.memberGalleryAddShot),
              ),
            ],
          ),
          for (var index = 0; index < member.gallery.length; index++)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              decoration: BoxDecoration(
                color: const Color(0x66FFFDF6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x336F4B2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsTextField(
                    label: l10n.memberGalleryCaption,
                    initialValue: member.gallery[index].caption,
                    onChanged: (value) => onChanged(
                      member.copyWith(
                        gallery: _replaceShot(
                          member.gallery,
                          index,
                          member.gallery[index].copyWith(caption: value),
                        ),
                      ),
                    ),
                  ),
                  if (member.gallery[index].photo != null)
                    SettingsPhotoField(
                      label: l10n.memberMainPhoto,
                      source: member.gallery[index].photo,
                      hint: l10n.photoPathHint,
                      clearLabel: l10n.settingsClearPhoto,
                      previewLabel: l10n.settingsPhotoPreview,
                      onChanged: (value) => onChanged(
                        member.copyWith(
                          gallery: _replaceShot(
                            member.gallery,
                            index,
                            member.gallery[index].copyWith(
                              photo: () =>
                                  value.trim().isEmpty ? null : value.trim(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  MediaListEditor(
                    value: member.gallery[index].media,
                    l10n: l10n,
                    members: members,
                    events: events,
                    ownerId: member.id,
                    showEvents: false,
                    onChanged: (media) => onChanged(
                      member.copyWith(
                        gallery: _replaceShot(
                          member.gallery,
                          index,
                          member.gallery[index].copyWith(media: media),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => onChanged(
                        member.copyWith(
                          gallery: [
                            for (var i = 0; i < member.gallery.length; i++)
                              if (i != index) member.gallery[i],
                          ],
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.terracotta,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.memberGalleryRemoveShot),
                    ),
                  ),
                ],
              ),
            ),
          SettingsJsonField(
            label: l10n.settingsAdvancedJson,
            value: const JsonEncoder.withIndent('  ').convert(member.toJson()),
            applyLabel: l10n.settingsApplyJson,
            invalidLabel: l10n.settingsInvalidJson,
            onApply: (json) => onChanged(
              FamilyMember.fromJson(json).copyWith(id: member.id),
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
                label: Text(l10n.memberDelete),
              ),
            ),
        ],
      ),
    );
  }
}

List<String> _lines(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}

List<WishlistItem> _replaceWish(
  List<WishlistItem> items,
  int index,
  WishlistItem value,
) {
  return [
    for (var i = 0; i < items.length; i++)
      if (i == index) value else items[i],
  ];
}

List<GalleryShot> _replaceShot(
  List<GalleryShot> shots,
  int index,
  GalleryShot value,
) {
  return [
    for (var i = 0; i < shots.length; i++)
      if (i == index) value else shots[i],
  ];
}
