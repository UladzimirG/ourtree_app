import 'dart:async';

import 'package:ourtree_app/core/media/media_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'demo_edit_notice_provider.g.dart';

/// Ключ «подсказку о демо-режиме уже показывали».
const String demoEditNoticeShownKey = 'demo_edit_notice_shown';

/// Ключ «в демо-режиме есть локальные правки».
const String demoLocalEditsKey = 'demo_local_edits';

/// Состояние подсказки «изменения не сохранятся в облаке».
class DemoEditNoticeState {
  const DemoEditNoticeState({
    this.shouldPrompt = false,
    this.hasLocalEdits = false,
  });

  /// Нужно показать диалог прямо сейчас.
  final bool shouldPrompt;

  /// В демо-режиме уже есть правки — показываем постоянную метку в шапке.
  final bool hasLocalEdits;

  DemoEditNoticeState copyWith({bool? shouldPrompt, bool? hasLocalEdits}) =>
      DemoEditNoticeState(
        shouldPrompt: shouldPrompt ?? this.shouldPrompt,
        hasLocalEdits: hasLocalEdits ?? this.hasLocalEdits,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DemoEditNoticeState &&
          shouldPrompt == other.shouldPrompt &&
          hasLocalEdits == other.hasLocalEdits;

  @override
  int get hashCode => Object.hash(shouldPrompt, hasLocalEdits);
}

/// Подсказывает, что демо-архив хранится только на устройстве.
///
/// Пока семья не создана и аккаунт не заведён, правки никуда не уезжают:
/// приложение об этом честно сообщает — один раз диалогом и постоянной меткой
/// в шапке, пока архив не окажется в облаке.
@Riverpod(keepAlive: true)
class DemoEditNoticeNotifier extends _$DemoEditNoticeNotifier {
  @override
  DemoEditNoticeState build() => DemoEditNoticeState(
        hasLocalEdits:
            MediaStorage.instance.getString(demoLocalEditsKey) != null,
      );

  /// Вызывается после каждой локальной правки архива в демо-режиме.
  void noteLocalEdit() {
    final shown =
        MediaStorage.instance.getString(demoEditNoticeShownKey) != null;
    if (!state.hasLocalEdits) {
      unawaited(MediaStorage.instance.putString(demoLocalEditsKey, '1'));
    }
    state = DemoEditNoticeState(
      shouldPrompt: !shown,
      hasLocalEdits: true,
    );
  }

  /// Запоминает, что диалог уже показан: второй раз не мешаем.
  Future<void> markShown() async {
    await MediaStorage.instance.putString(demoEditNoticeShownKey, '1');
    if (!state.shouldPrompt) return;
    state = state.copyWith(shouldPrompt: false);
  }

  /// Семья подключена — архив уехал в облако, метка больше не нужна.
  Future<void> familyConnected() async {
    await MediaStorage.instance.removeString(demoLocalEditsKey);
    if (!state.hasLocalEdits && !state.shouldPrompt) return;
    state = const DemoEditNoticeState();
  }
}
