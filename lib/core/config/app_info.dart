/// Сведения о приложении для страницы «О приложении».
///
/// Версия должна совпадать с `version:` в `pubspec.yaml` — за этим следит
/// тест `test/core/app_info_test.dart`, чтобы страница не показывала старое
/// значение после релиза.
const String appVersion = '0.6.0';
const int appBuildNumber = 6;

/// Версия в виде `0.5.0+5` — как в `pubspec.yaml`.
const String appVersionLabel = '$appVersion+$appBuildNumber';

/// Название разработчика (показывается, если не пусто).
const String appDeveloper = 'OurTree';

/// Контакты поддержки. Пустая строка — строка не показывается.
// TODO(ourtree): указать реальный адрес поддержки.
const String appSupportEmail = 'uladdze@gmail.com';

/// Ссылки на документы. Пустая строка — строка не показывается.
// TODO(ourtree): указать реальные адреса документов.
const String appPrivacyUrl = '';
const String appTermsUrl = '';
