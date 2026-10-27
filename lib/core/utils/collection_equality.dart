/// Сравнение списков по значению — без зависимости от Flutter.
///
/// Нужно моделям с вложенными списками: `==` должен реагировать на изменение
/// содержимого, иначе Riverpod не заметит обновление состояния.
bool listsEqual<T>(List<T>? first, List<T>? second) {
  if (identical(first, second)) return true;
  final left = first ?? <T>[];
  final right = second ?? <T>[];
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

int listsHash<T>(List<T>? list) => Object.hashAll(list ?? <T>[]);
