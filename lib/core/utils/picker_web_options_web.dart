import 'package:file_picker/file_picker.dart';
import 'package:file_picker_web/file_picker_web.dart';

/// Web: не отменяем выбор файла при возврате фокуса в окно.
///
/// Иначе iOS (WebKit под любым браузером) успевает прислать `focus` раньше
/// `change`, и импорт резервной копии «отменяется» без участия пользователя.
WebOptions platformImportPickerWebOptions() => const FilePickerWebOptions(
      cancelUploadOnWindowBlur: false,
    );
