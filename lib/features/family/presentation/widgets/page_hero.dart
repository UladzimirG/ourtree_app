import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';

/// Заголовок страницы: рукописная подпись, серифный заголовок и описание.
///
/// [eyebrow] необязателен: если он пустой, подпись не занимает место вовсе.
class PageHero extends StatelessWidget {
  const PageHero({
    super.key,
    this.eyebrow,
    required this.title,
    this.lede,
  });

  final String? eyebrow;
  final String title;
  final String? lede;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eyebrowText = eyebrow?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrowText.isNotEmpty) ...[
            Text(
              eyebrowText,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'Georgia',
                fontStyle: FontStyle.italic,
                fontSize: 18,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(title, style: theme.textTheme.headlineMedium),
          if (lede != null) ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                lede!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkSoft,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
