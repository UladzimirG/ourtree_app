import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/core/utils/dates.dart';
import 'package:ourtree_app/features/family/presentation/providers/family_provider.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/media/presentation/widgets/interactive_photo_crop.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

TextStyle? settingsCaptionStyle(ThemeData theme) {
  return theme.textTheme.bodySmall?.copyWith(
    color: AppColors.inkSoft,
    fontSize: 11,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w700,
  );
}

InputDecoration settingsInputDecoration({
  required String hint,
  String? helper,
  bool dense = false,
}) {
  return InputDecoration(
    hintText: hint,
    helperText: helper,
    filled: true,
    fillColor: const Color(0x99FFFDF6),
    isDense: dense,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 12,
      vertical: dense ? 9 : 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x386F4B2A)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x386F4B2A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.moss, width: 2),
    ),
  );
}

class SettingsTextField extends StatelessWidget {
  const SettingsTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: settingsCaptionStyle(theme)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: initialValue,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: settingsInputDecoration(hint: hint ?? label),
          ),
        ],
      ),
    );
  }
}

class SettingsSwitchField extends StatelessWidget {
  const SettingsSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppColors.moss,
      value: value,
      onChanged: onChanged,
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class SettingsPhotoField extends ConsumerWidget {
  const SettingsPhotoField({
    super.key,
    required this.label,
    required this.source,
    required this.onChanged,
    required this.hint,
    required this.clearLabel,
    required this.previewLabel,
    this.uploadLabel,
    this.position,
    this.onPositionChange,
    this.zoom,
    this.onZoomChange,
    this.l10n,
  });

  final String label;
  final String? source;
  final ValueChanged<String> onChanged;
  final String hint;
  final String clearLabel;
  final String previewLabel;
  final String? uploadLabel;
  final PhotoPosition? position;
  final ValueChanged<PhotoPosition>? onPositionChange;
  final double? zoom;
  final ValueChanged<double>? onZoomChange;
  final AppLocalizations? l10n;

  Future<void> _pickImage(WidgetRef ref) async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;

    final hash = sha256.convert(bytes).toString();
    final existing = ref
        .read(familyDataProvider)
        .valueOrNull
        ?.findDuplicateMedia(
          hash: hash,
          name: file.name,
          size: bytes.length,
        );
    if (existing != null) {
      onChanged(existing.source);
      return;
    }

    final storedId = await MediaStorage.instance.saveBytes(
      bytes,
      name: file.name,
    );
    ref.read(familyDataProvider.notifier).upsertMediaAsset(
          MediaAsset(
            id: 'asset-$storedId',
            source: 'hive://$storedId',
            name: file.name,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            size: bytes.length,
            hash: hash,
          ),
        );
    onChanged('hive://$storedId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final value = source ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTextField(
          label: label,
          initialValue: value,
          onChanged: onChanged,
          hint: hint,
        ),
        if (value.trim().isNotEmpty && onPositionChange != null && l10n != null)
          InteractivePhotoCrop(
            source: value,
            position: position ?? PhotoPosition.center,
            zoom: zoom ?? 1.4,
            onChanged: (nextPosition, nextZoom) {
              onPositionChange!(nextPosition);
              onZoomChange?.call(nextZoom);
            },
          )
        else
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FamilyPhoto(
                source: value,
                fit: BoxFit.cover,
                alignment: photoAlignment(position),
                zoom: zoom ?? 1,
                fallback: Container(
                  color: AppColors.kraftWash,
                  child: Center(
                    child: Text(
                      previewLabel,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (uploadLabel != null)
              TextButton.icon(
                onPressed: () => _pickImage(ref),
                icon: const Icon(Icons.upload_file),
                label: Text(uploadLabel!),
              ),
            if (value.trim().isNotEmpty)
              TextButton.icon(
                onPressed: () => onChanged(''),
                icon: const Icon(Icons.close),
                label: Text(clearLabel),
              ),
          ],
        ),
      ],
    );
  }
}

/// Редактор вложенных данных записи: галерей, медиа, вишлиста и т.п.
class SettingsJsonField extends StatefulWidget {
  const SettingsJsonField({
    super.key,
    required this.label,
    required this.value,
    required this.applyLabel,
    required this.invalidLabel,
    required this.onApply,
  });

  final String label;
  final String value;
  final String applyLabel;
  final String invalidLabel;
  final ValueChanged<Map<String, dynamic>> onApply;

  @override
  State<SettingsJsonField> createState() => _SettingsJsonFieldState();
}

class _SettingsJsonFieldState extends State<SettingsJsonField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant SettingsJsonField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _apply() {
    try {
      final decoded = jsonDecode(_controller.text);
      if (decoded is! Map) {
        setState(() => _error = widget.invalidLabel);
        return;
      }
      widget.onApply(decoded.cast<String, dynamic>());
      setState(() => _error = null);
    } catch (_) {
      setState(() => _error = widget.invalidLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: settingsCaptionStyle(theme),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 10,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: settingsInputDecoration(hint: widget.label),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.terracotta,
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.data_object),
              label: Text(widget.applyLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Поле даты в формате `ДД.ММ.ГГГГ`; наружу отдаёт ISO `YYYY-MM-DD`.
class SettingsDateField extends StatefulWidget {
  const SettingsDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.hint,
    required this.invalidLabel,
  });

  final String label;

  /// Значение в ISO-формате, как оно хранится в архиве.
  final String value;
  final ValueChanged<String> onChanged;
  final String hint;
  final String invalidLabel;

  @override
  State<SettingsDateField> createState() => _SettingsDateFieldState();
}

class _SettingsDateFieldState extends State<SettingsDateField> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: formatDisplayDateFromIso(widget.value),
    );
  }

  @override
  void didUpdateWidget(covariant SettingsDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && oldWidget.value != widget.value) {
      _controller.text = formatDisplayDateFromIso(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _handleChanged(String raw) {
    final masked = maskDisplayDate(raw);
    if (_controller.text != masked) {
      _controller.value = TextEditingValue(
        text: masked,
        selection: TextSelection.collapsed(offset: masked.length),
      );
    }

    if (masked.isEmpty) {
      setState(() => _invalid = false);
      widget.onChanged('');
      return;
    }

    final iso = isoFromDisplayDate(masked);
    final complete = masked.length == 10;
    setState(() => _invalid = complete && iso.isEmpty);
    if (!complete) return;
    if (iso.isNotEmpty) widget.onChanged(iso);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: settingsCaptionStyle(Theme.of(context)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            focusNode: _focus,
            keyboardType: TextInputType.datetime,
            decoration: settingsInputDecoration(hint: widget.hint).copyWith(
              errorText: _invalid ? widget.invalidLabel : null,
            ),
            onChanged: _handleChanged,
            onTapOutside: (_) => _focus.unfocus(),
          ),
        ],
      ),
    );
  }
}

