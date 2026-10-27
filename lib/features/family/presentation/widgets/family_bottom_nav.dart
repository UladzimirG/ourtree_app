import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';

/// Нижняя навигация из трёх разделов, как `BottomNav` в React-проекте.
class FamilyBottomNav extends StatelessWidget {
  const FamilyBottomNav({
    super.key,
    required this.selected,
    required this.timelineLabel,
    required this.calendarLabel,
    required this.familyLabel,
    required this.onSelected,
  });

  final HomeTab selected;
  final String timelineLabel;
  final String calendarLabel;
  final String familyLabel;
  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.timeline,
            label: timelineLabel,
            selected: selected == HomeTab.timeline,
            onTap: () => onSelected(HomeTab.timeline),
          ),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            label: calendarLabel,
            selected: selected == HomeTab.calendar,
            onTap: () => onSelected(HomeTab.calendar),
          ),
          _NavItem(
            icon: Icons.people_outline,
            label: familyLabel,
            selected: selected == HomeTab.family,
            onTap: () => onSelected(HomeTab.family),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.inkSoft;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.activeWash : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
