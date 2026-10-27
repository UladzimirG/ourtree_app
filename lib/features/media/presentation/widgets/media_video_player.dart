import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

import 'video_controller_model.dart';
import 'video_controller_stub.dart'
    if (dart.library.io) 'video_controller_io.dart'
    if (dart.library.html) 'video_controller_web.dart';

/// Видеоплеер для локальных (`hive://`), data-URI и сетевых источников.
class MediaVideoPlayer extends StatefulWidget {
  const MediaVideoPlayer({
    super.key,
    required this.source,
    this.name,
    this.fit = BoxFit.contain,
    this.showControls = true,
  });

  final String source;
  final String? name;
  final BoxFit fit;
  final bool showControls;

  @override
  State<MediaVideoPlayer> createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  VideoPlayerController? _controller;
  Future<void> Function()? _cleanup;
  bool _loading = true;
  bool _error = false;
  String? _errorDetail;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MediaVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _load();
  }

  @override
  void dispose() {
    final cleanup = _cleanup;
    _controller?.removeListener(_onValue);
    _controller?.dispose();
    if (cleanup != null) cleanup();
    super.dispose();
  }

  Future<void> _load() async {
    final old = _controller;
    final oldCleanup = _cleanup;
    old?.removeListener(_onValue);
    await old?.dispose();
    if (oldCleanup != null) await oldCleanup();

    if (mounted) {
      setState(() {
        _controller = null;
        _cleanup = null;
        _loading = true;
        _error = false;
        _errorDetail = null;
      });
    }

    final source = widget.source.trim();
    Uint8List? bytes;
    if (source.startsWith('hive://')) {
      bytes = await MediaStorage.instance.loadBytes(
        source.substring('hive://'.length),
      );
    } else if (source.startsWith('data:video/')) {
      final comma = source.indexOf(',');
      if (comma >= 0) {
        try {
          bytes = base64Decode(source.substring(comma + 1));
        } catch (_) {
          bytes = null;
        }
      }
    }

    PreparedVideo prepared;
    try {
      prepared = await prepareVideo(source, bytes, widget.name);
      final controller = prepared.controller;
      if (controller == null) {
        throw StateError(prepared.error ?? 'Unsupported source');
      }
      await controller.initialize();
      controller.addListener(_onValue);
      if (!mounted) {
        await controller.dispose();
        await prepared.cleanup?.call();
        return;
      }
      setState(() {
        _controller = controller;
        _cleanup = prepared.cleanup;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
        _errorDetail = error.toString();
      });
    }
  }

  void _onValue() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    _muted = !_muted;
    await controller.setVolume(_muted ? 0 : 1);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildBody(
          context,
          AppLocalizations.of(context)!,
          Theme.of(context),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error || _controller == null) {
      return ColoredBox(
        color: const Color(0xFF1C1712),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam_off_outlined,
                color: AppColors.paper,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.videoError,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.paper,
                ),
              ),
              if (_errorDetail != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(
                    _errorDetail!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.paper.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final controller = _controller!;
    final value = controller.value;
    final playing = value.isPlaying;

    return ColoredBox(
      color: const Color(0xFF1C1712),
      child: GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: value.aspectRatio > 0
                    ? value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(controller),
              ),
            ),
            if (!playing)
              Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0x88000000),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            if (widget.showControls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 2),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xCC000000)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip:
                                playing ? l10n.videoPause : l10n.videoPlay,
                            onPressed: _togglePlay,
                            icon: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Text(
                            '${_format(value.position)} / '
                            '${_format(value.duration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip:
                                _muted ? l10n.videoUnmute : l10n.videoMute,
                            onPressed: _toggleMute,
                            icon: Icon(
                              _muted ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
