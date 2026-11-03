import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/widgets/header_action_button.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/media/domain/models/photo_crop.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

/// Верхняя панель приложения: круглый «дом», название семьи и настройки.
class FamilyHeader extends StatelessWidget {
  const FamilyHeader({
    super.key,
    required this.familyName,
    required this.familyPhoto,
    this.familyPhotoPosition,
    this.familyPhotoZoom,
    required this.settingsTooltip,
    required this.onSettingsTap,
    this.trailing,
  });

  final String familyName;
  final String? familyPhoto;

  /// Точка фокуса общего фото (та же, что в настройках).
  final PhotoPosition? familyPhotoPosition;

  /// Масштаб общего фото.
  final double? familyPhotoZoom;

  final String settingsTooltip;
  final VoidCallback onSettingsTap;

  /// Необязательный виджет слева от кнопки настроек (например, статус синка).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // На телефоне в одну строку не помещаются название и все кнопки: подпись
    // сжимается до «О…». Поэтому действия уезжают во вторую строку.
    final compact = MediaQuery.sizeOf(context).width < 480;
    final avatarSize = compact ? 52.0 : 66.0;
    final headline = compact
        ? theme.textTheme.headlineSmall?.copyWith(fontSize: 20)
        : theme.textTheme.headlineSmall;

    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: const BoxDecoration(
        color: AppColors.paper,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: FamilyPhoto(
          source: familyPhoto,
          fit: BoxFit.cover,
          alignment: photoAlignment(familyPhotoPosition),
          zoom: photoZoomOrDefault(familyPhotoZoom),
          fallback: Image.asset(
            'assets/branding/app_icon.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.park_outlined,
              size: 30,
              color: AppColors.moss,
            ),
          ),
        ),
      ),
    );

    final title = Text(
      familyName,
      maxLines: compact ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: headline,
    );

    final settingsButton = HeaderActionButton(
      icon: Icons.settings_outlined,
      tooltip: settingsTooltip,
      onTap: onSettingsTap,
    );

    if (!compact) {
      return Row(
        children: [
          avatar,
          const SizedBox(width: 10),
          Expanded(child: title),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 6),
          ],
          settingsButton,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            avatar,
            const SizedBox(width: 10),
            Expanded(child: title),
            const SizedBox(width: 4),
            settingsButton,
          ],
        ),
        if (trailing != null)
          Align(
            alignment: Alignment.centerRight,
            child: trailing!,
          ),
      ],
    );
  }
}
