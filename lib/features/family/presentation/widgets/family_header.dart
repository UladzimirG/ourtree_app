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
        _HeaderSettingsButton(
          tooltip: settingsTooltip,
          onTap: onSettingsTap,
        ),
      ],
    );
  }
}

class _HeaderSettingsButton extends StatefulWidget {
  const _HeaderSettingsButton({
    required this.tooltip,
    required this.onTap,
  });

  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_HeaderSettingsButton> createState() => _HeaderSettingsButtonState();
}

class _HeaderSettingsButtonState extends State<_HeaderSettingsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          // Тот же тон, что у плашки нижнего меню.
          color: _hovered ? AppColors.paper : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: _hovered
              ? const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.softShadow,
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: IconButton(
          onPressed: widget.onTap,
          tooltip: widget.tooltip,
          iconSize: 26,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}
