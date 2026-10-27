import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

import 'media_video_player.dart';

/// Превью видео для карточек с трансформацией/наклоном.
///
/// Платформенный HTML-video на вебе плохо работает внутри `Transform.rotate`,
/// поэтому здесь показывается кнопка, а плеер открывается в обычном диалоге.
class VideoPreviewButton extends StatelessWidget {
  const VideoPreviewButton({
    super.key,
    required this.source,
    this.name,
    this.title,
  });

  final String source;
  final String? name;
  final String? title;

  Future<void> _open(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF14110E),
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title?.trim().isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      title!.trim(),
                      style: const TextStyle(
                        color: AppColors.paper,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                MediaVideoPlayer(source: source, name: name),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      AppLocalizations.of(dialogContext)!.close,
                      style: const TextStyle(color: AppColors.paper),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: const Color(0xFF1C1712),
      child: InkWell(
        onTap: () => _open(context),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0x88000000),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.videoPlay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
