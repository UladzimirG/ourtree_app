import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';

/// Круглая кнопка в шапке приложения с мягким hover-эффектом.
///
/// Используется для настроек, режима редактирования и входа в аккаунт, чтобы
/// все действия в шапке выглядели одинаково.
class HeaderActionButton extends StatefulWidget {
  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  /// Включённое состояние (например, режим редактирования).
  final bool active;

  @override
  State<HeaderActionButton> createState() => _HeaderActionButtonState();
}

class _HeaderActionButtonState extends State<HeaderActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final color = widget.active
        ? AppColors.terracotta
        : (enabled
            ? AppColors.inkSoft
            : AppColors.inkSoft.withValues(alpha: 0.4));

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
          color: _hovered && enabled ? AppColors.paper : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: _hovered && enabled
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
          icon: Icon(widget.icon, color: color),
        ),
      ),
    );
  }
}
