import 'package:flutter/material.dart';
import 'package:ourtree_app/l10n/app_localizations.dart';

/// Предупреждение: файл сохранён только локально (демо-режим).
///
/// Показываем после каждой загрузки, чтобы пользователь понимал, что без
/// подключённой семьи фото не появится на других устройствах.
void showLocalOnlyNotice(BuildContext context, AppLocalizations l10n) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.mediaLocalOnlyNotice),
      duration: const Duration(seconds: 6),
    ),
  );
}
