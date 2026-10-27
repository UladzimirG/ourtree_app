/// Преобразует путь из семейного JSON в путь Flutter-ассета.
///
/// В архиве пути обычно выглядят как `/photos/file.jpg`. В приложении они
/// лежат в `assets/photos/file.jpg`. Внешние URL и data-URI не являются
/// ассетами, поэтому для них возвращается `null`.
String? familyPhotoAssetPath(String? source) {
  final value = source?.trim();
  if (value == null || value.isEmpty) return null;

  final normalized = value.replaceAll('\\', '/');
  if (normalized.startsWith('http://') ||
      normalized.startsWith('https://') ||
      normalized.startsWith('data:') ||
      normalized.startsWith('blob:')) {
    return null;
  }

  final relative = normalized.replaceFirst(RegExp(r'^/+'), '');
  if (relative.startsWith('assets/')) return relative;
  if (relative.startsWith('photos/')) return 'assets/$relative';
  if (relative.isEmpty) return null;

  return 'assets/photos/${relative.split('/').last}';
}
