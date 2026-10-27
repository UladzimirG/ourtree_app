import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';

/// Верхняя панель приложения: круглый «дом», название семьи и настройки.
class FamilyHeader extends StatelessWidget {
  const FamilyHeader({
    super.key,
    required this.familyName,
    required this.familyPhoto,
    required this.settingsTooltip,
    required this.onSettingsTap,
  });

  final String familyName;
  final String? familyPhoto;
  final String settingsTooltip;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 66,
          height: 66,
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
              fallback: const Icon(
                Icons.home_outlined,
                size: 30,
                color: AppColors.moss,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            familyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        IconButton(
          onPressed: onSettingsTap,
          tooltip: settingsTooltip,
          iconSize: 26,
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.inkSoft,
          ),
        ),
      ],
    );
  }
}
