import 'package:file_picker/file_picker.dart';

import 'picker_web_options_stub.dart'
    if (dart.library.js_interop) 'picker_web_options_web.dart';

/// Настройки веб-пикера для импорта резервной копии.
///
/// На iOS (Safari и Chrome используют WebKit) при возврате из диалога выбора
/// файла приходит `focus` раньше `change`, и пикер по умолчанию считает выбор
/// отменённым через 500 мс. Поэтому авт-отмену по потере фокуса отключаем.
WebOptions importPickerWebOptions() => platformImportPickerWebOptions();
