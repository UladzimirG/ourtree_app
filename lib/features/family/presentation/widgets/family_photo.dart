import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/utils/asset_path.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

/// Переводит проценты из `PhotoPosition` в [Alignment].
Alignment photoAlignment(PhotoPosition? position) {
  final x = position?.x ?? 50;
  final y = position?.y ?? 50;
  return Alignment((x / 50) - 1, (y / 50) - 1);
}

/// Фотография семьи из ассетов с безопасным fallback для отсутствующих файлов.
class FamilyPhoto extends StatelessWidget {
  const FamilyPhoto({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.zoom = 1,
    this.fallback,
  });

  final String? source;
  final BoxFit fit;
  final Alignment alignment;
  final double zoom;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final value = source?.trim();
    final asset = familyPhotoAssetPath(value);
    Widget? image;

    if (asset != null) {
      image = Image.asset(
        asset,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        errorBuilder: _errorBuilder,
      );
    } else if (value != null && value.startsWith('data:image/')) {
      final bytes = _decodeDataUri(value);
      if (bytes != null) {
        image = Image.memory(
          bytes,
          fit: fit,
          alignment: alignment,
          filterQuality: FilterQuality.medium,
          errorBuilder: _errorBuilder,
        );
      }
    } else if (value != null && value.startsWith('hive://')) {
      image = _StoredMediaImage(
        id: value.substring('hive://'.length),
        fit: fit,
        alignment: alignment,
        fallback: fallback,
      );
    } else if (value != null &&
        (value.startsWith('http://') || value.startsWith('https://'))) {
      image = Image.network(
        value,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        errorBuilder: _errorBuilder,
      );
    }

    if (image == null) return fallback ?? const SizedBox.shrink();
    if (zoom == 1) return image;

    return Transform.scale(
      scale: zoom,
      alignment: alignment,
      child: image,
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) =>
      fallback ?? const SizedBox.shrink();
}

class _StoredMediaImage extends StatefulWidget {
  const _StoredMediaImage({
    required this.id,
    required this.fit,
    required this.alignment,
    this.fallback,
  });

  final String id;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? fallback;

  @override
  State<_StoredMediaImage> createState() => _StoredMediaImageState();
}

class _StoredMediaImageState extends State<_StoredMediaImage> {
  late Future<Uint8List?> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = MediaStorage.instance.loadBytes(widget.id);
  }

  @override
  void didUpdateWidget(covariant _StoredMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _bytes = MediaStorage.instance.loadBytes(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _bytes,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return widget.fallback ?? const SizedBox.shrink();
        return Image.memory(
          bytes,
          fit: widget.fit,
          alignment: widget.alignment,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) =>
              widget.fallback ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

Uint8List? _decodeDataUri(String value) {
  final comma = value.indexOf(',');
  if (comma < 0 || !value.substring(0, comma).contains(';base64')) return null;
  try {
    return base64Decode(value.substring(comma + 1));
  } catch (_) {
    return null;
  }
}
