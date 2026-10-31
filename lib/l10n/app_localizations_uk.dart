// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'OurTree App';

  @override
  String get homeFamilyLabel => 'Родина';

  @override
  String get homeSubtitle => 'Місце для сімейних історій, фотографій і дат.';

  @override
  String get homeOverviewTitle => 'Огляд';

  @override
  String homeMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учасника',
      many: '$count учасників',
      few: '$count учасники',
      one: '$count учасник',
      zero: 'Поки немає учасників',
    );
    return '$_temp0';
  }

  @override
  String homeEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count події',
      many: '$count подій',
      few: '$count події',
      one: '$count подія',
      zero: 'Поки немає подій',
    );
    return '$_temp0';
  }

  @override
  String get homeLoading => 'Завантажуємо дані родини…';

  @override
  String get homeLoadError => 'Не вдалося завантажити дані родини.';

  @override
  String get homeRetry => 'Повторити';

  @override
  String get settingsTitle => 'Налаштування родини';

  @override
  String get navTimeline => 'Хронологія';

  @override
  String get navCalendar => 'Календар';

  @override
  String get navFamily => 'Родина';

  @override
  String get timelineEyebrow => 'Сімейний альбом';

  @override
  String get timelineTitle => 'Хронологія життя';

  @override
  String get timelineLede =>
      'Нитка подій, на яку нанизані наші зустрічі, свята й подорожі.';

  @override
  String get timelineEmpty => 'Хронологія поки порожня.';

  @override
  String timelineTogetherYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Разом уже $count року',
      many: 'Разом уже $count років',
      few: 'Разом уже $count роки',
      one: 'Разом уже $count рік',
      zero: 'Разом із цього дня',
    );
    return '$_temp0';
  }

  @override
  String get mediaPlaceholder => 'Фото або відео';

  @override
  String get familyTitle => 'Родина і профілі';

  @override
  String get familyLede =>
      'Натисніть на картку, щоб відкрити домашній альбом людини.';

  @override
  String get familyEmpty => 'У родині поки немає учасників.';

  @override
  String memberAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count року',
      many: '$count років',
      few: '$count роки',
      one: '$count рік',
      zero: 'Менше року',
    );
    return '$_temp0';
  }

  @override
  String get calendarEyebrow => 'Не забути головне';

  @override
  String get calendarTitle => 'Сімейний календар';

  @override
  String get calendarLede =>
      'Дні з сімейними подіями виділені. Натисніть на день, щоб побачити події.';

  @override
  String get calendarPreviousMonth => 'Попередній місяць';

  @override
  String get calendarNextMonth => 'Наступний місяць';

  @override
  String get calendarNoEvents => 'Цього дня подій немає.';

  @override
  String get profileBack => 'Усі свої';

  @override
  String get profileAbout => 'Про мене';

  @override
  String get profileWishlist => 'Список бажань';

  @override
  String get profileWishlistEmpty => 'Список бажань поки порожній.';

  @override
  String get profileGallery => 'Міні-галерея';

  @override
  String get profileGalleryEmpty => 'Фотографій поки немає.';

  @override
  String get profileNotFound =>
      'Цей профіль ще не записаний у сімейний альбом.';

  @override
  String get profileCopyWishlistLink => 'Скопіювати посилання на список бажань';

  @override
  String get profileLinkCopied => 'Посилання на список бажань скопійовано.';

  @override
  String get settingsFamilyName => 'Назва родини';

  @override
  String get settingsFamilySubtitle => 'Підзаголовок родини';

  @override
  String get settingsFamilySubtitleHint =>
      'Показується під назвою родини на головній сторінці';

  @override
  String get settingsDataSource => 'Джерело даних';

  @override
  String get settingsArchiveSource =>
      'Сімейний архів із демонстраційних файлів застосунку';

  @override
  String get settingsReload => 'Оновити дані';

  @override
  String get settingsReloadStarted => 'Дані родини оновлено.';

  @override
  String get settingsEditingSoon =>
      'Редагування з\'явиться на наступному кроці.';

  @override
  String get settingsFamilyPhoto => 'Фото родини';

  @override
  String get settingsFamilyPhotoHint =>
      '/photos/родина.jpg або assets/photos/родина.jpg';

  @override
  String get settingsPhotoPreview => 'Попередній перегляд фото';

  @override
  String get settingsClearPhoto => 'Прибрати фото';

  @override
  String get settingsAppearance => 'Зовнішній вигляд';

  @override
  String get settingsShowFamilyPhoto => 'Показувати фото родини у шапці';

  @override
  String get settingsShowEventPhotos => 'Показувати фотографії в хронології';

  @override
  String get settingsSave => 'Зберегти';

  @override
  String get settingsSaved => 'Налаштування збережено.';

  @override
  String get settingsNameRequired => 'Назва родини не може бути порожньою.';

  @override
  String get settingsLocalOnly =>
      'Зміни зберігаються локально на цьому пристрої.';

  @override
  String get settingsTabFamily => 'Родина';

  @override
  String get settingsTabMembers => 'Учасники';

  @override
  String get settingsTabEvents => 'Події';

  @override
  String get settingsTabAccounts => 'Акаунти';

  @override
  String get settingsTabBackups => 'Копії';

  @override
  String get settingsTabMedia => 'Медіатека';

  @override
  String get settingsTabGeneral => 'Загальні налаштування';

  @override
  String get settingsGeneralHint =>
      'Резервні копії, мова інтерфейсу та доступи до альбому.';

  @override
  String get settingsMediaHint =>
      'Усі фото й відео в одному місці. Відео автоматично приводяться до підтримуваного формату. Опис і кадрування задаються окремо для кожного учасника та події.';

  @override
  String get mediaLibraryTitle => 'Медіатека родини';

  @override
  String get mediaLibraryUpload => 'Завантажити файли';

  @override
  String get mediaLibraryAddLink => 'Додати за посиланням';

  @override
  String get mediaAssetName => 'Ім\'я файлу';

  @override
  String get mediaAssetType => 'Тип';

  @override
  String get mediaUsageTitle => 'Де використовується';

  @override
  String get mediaUsageNone => 'Поки ні з чим не пов\'язано.';

  @override
  String mediaUsageAvatar(String name) {
    return '$name — аватар';
  }

  @override
  String mediaUsageBirthday(String name) {
    return '$name — день народження';
  }

  @override
  String mediaUsageGallery(String name) {
    return '$name — галерея';
  }

  @override
  String mediaUsageEvent(String name) {
    return 'Подія \"$name\"';
  }

  @override
  String get mediaUsageFamilyPhoto => 'Фото родини в шапці';

  @override
  String get mediaStoredLocally => 'Зберігається локально';

  @override
  String get mediaDeleteTitle => 'Видалити цей файл із медіатеки?';

  @override
  String get mediaDeleteBody =>
      'Файл і всі його зв\'язки з учасниками та подіями зникнуть. Дію не можна скасувати.';

  @override
  String get mediaDelete => 'Видалити';

  @override
  String get mediaDeleted => 'Файл видалено з медіатеки.';

  @override
  String get mediaDuplicateFound => 'Цей файл уже є в медіатеці.';

  @override
  String get mediaDuplicateAttached =>
      'Файл уже був у медіатеці — приєднано наявний примірник.';

  @override
  String get mediaViewerOpen => 'Відкрити в перегляді';

  @override
  String mediaLibrarySize(int count, String size) {
    return '$count файлів · $size';
  }

  @override
  String get settingsMembersHint =>
      'Редагуйте профілі, фото та видимість днів народження. Нові учасники зберігаються в сесії застосунку.';

  @override
  String get settingsEventsHint =>
      'Редагуйте події хронології, дати й місця. Записи про дні народження формуються з профілів.';

  @override
  String get settingsAccountsHint =>
      'Створюйте акаунти родини, призначайте ролі та видавайте гостьові посилання.';

  @override
  String get settingsAccountsLocalOnly =>
      'Акаунти, права доступу й гостьові посилання зберігаються локально та переживають перезапуск і копії.';

  @override
  String get settingsBackupsHint =>
      'Знімки сімейного архіву. Відновлення повертає дані до обраного моменту.';

  @override
  String get memberAdd => 'Додати учасника';

  @override
  String get memberAdded => 'Учасника додано.';

  @override
  String get memberDeleted => 'Учасника видалено.';

  @override
  String get memberDefaultName => 'Новий учасник';

  @override
  String get memberDefaultRole => 'Член родини';

  @override
  String get memberDeleteConfirmTitle => 'Видалити цього учасника?';

  @override
  String get memberDeleteConfirmBody =>
      'Профіль, особисті фото та події цього учасника зникнуть з альбому.';

  @override
  String get memberNameField => 'Ім\'я';

  @override
  String get memberRoleField => 'Роль у родині';

  @override
  String get memberNicknameField => 'Прізвисько';

  @override
  String get memberBirthdayField => 'День народження';

  @override
  String get memberBirthdayHint => 'РРРР-ММ-ДД';

  @override
  String get memberShowBirthday => 'Показувати день народження в хронології';

  @override
  String get memberMainPhoto => 'Головне фото';

  @override
  String get memberHabitsField => 'Звички, по одній у рядку';

  @override
  String get memberQuotesField => 'Цитати, по одній у рядку';

  @override
  String get memberAccentField => 'Колір акценту';

  @override
  String get memberWishlistUrlField => 'Посилання на список бажань';

  @override
  String get memberDelete => 'Видалити учасника';

  @override
  String get eventAdd => 'Додати подію';

  @override
  String get eventAdded => 'Подію додано.';

  @override
  String get eventDeleted => 'Подію видалено.';

  @override
  String get eventDefaultTitle => 'Нова подія';

  @override
  String get eventDelete => 'Видалити подію';

  @override
  String get eventDeleteConfirmTitle => 'Видалити цю подію?';

  @override
  String get eventDeleteConfirmBody =>
      'Подія та її зв\'язки з медіа зникнуть з хронології.';

  @override
  String get eventTitleField => 'Назва події';

  @override
  String get eventDateField => 'Дата';

  @override
  String get eventKindField => 'Тип події';

  @override
  String get eventPlaceField => 'Місце';

  @override
  String get eventTextField => 'Опис';

  @override
  String get eventMemberField => 'Пов\'язаний учасник';

  @override
  String get eventMemberNone => 'Без учасника';

  @override
  String get eventShowElapsed => 'Показувати, скільки минуло';

  @override
  String get eventKindMeeting => 'Знайомство';

  @override
  String get eventKindDate => 'Побачення';

  @override
  String get eventKindWedding => 'Весілля';

  @override
  String get eventKindChurch => 'Вінчання';

  @override
  String get eventKindBirth => 'Народження';

  @override
  String get eventKindTrip => 'Подорож';

  @override
  String get eventKindMilestone => 'Важлива подія';

  @override
  String get photoPathHint => '/photos/фото.jpg або assets/photos/фото.jpg';

  @override
  String get settingsAdvancedJson => 'Розширений JSON';

  @override
  String get settingsApplyJson => 'Застосувати JSON';

  @override
  String get settingsInvalidJson => 'Неправильний JSON-об\'єкт.';

  @override
  String get accountAdd => 'Новий акаунт';

  @override
  String get accountCreate => 'Створити акаунт';

  @override
  String get accountCreated => 'Акаунт створено.';

  @override
  String get accountSaved => 'Акаунт оновлено.';

  @override
  String get accountDeleted => 'Акаунт видалено.';

  @override
  String get accountDelete => 'Видалити';

  @override
  String get accountDeleteConfirmTitle => 'Видалити цей акаунт?';

  @override
  String get accountDeleteConfirmBody =>
      'Людина одразу втратить доступ до сімейного альбому.';

  @override
  String get accountLoginField => 'Логін';

  @override
  String get accountNameField => 'Ім\'я';

  @override
  String get accountPasswordField => 'Пароль';

  @override
  String get accountPasswordKeepHint =>
      'Залиште порожнім, щоб зберегти поточний пароль';

  @override
  String get accountRoleField => 'Роль';

  @override
  String get accountRoleViewer => 'Спостерігач';

  @override
  String get accountRoleEditor => 'Редактор';

  @override
  String get accountRoleAdmin => 'Адміністратор';

  @override
  String get accountLoginInvalid =>
      'Логін має бути 2–32 символи: латинські літери, цифри, крапка, дефіс або підкреслення.';

  @override
  String get accountLoginRequirements =>
      '2–32 символи: латинські літери, цифри, крапка, дефіс або підкреслення.';

  @override
  String get accountPasswordRequirements => 'Щонайменше 4 символи.';

  @override
  String get accountRoleInvalid => 'Невідома роль.';

  @override
  String get accountPasswordTooShort => 'Пароль занадто короткий.';

  @override
  String get accountLoginTaken => 'Цей логін уже зайнятий.';

  @override
  String get accountCannotDeleteSelf => 'Не можна видалити власний акаунт.';

  @override
  String get accountCannotChangeOwnRole => 'Не можна змінити власну роль.';

  @override
  String get accountNotFound => 'Акаунт не знайдено.';

  @override
  String get accountForbidden => 'У вас недостатньо прав.';

  @override
  String get accountUnauthenticated => 'Увійдіть знову.';

  @override
  String get accountOffline => 'Немає зв\'язку з сервером.';

  @override
  String get accountUnknownError => 'Щось пішло не так.';

  @override
  String get accountsEmpty => 'Акаунтів поки немає. Створіть перший вище.';

  @override
  String get guestLinksTitle => 'Гостьові посилання';

  @override
  String get guestLinksHint =>
      'Гостьове посилання відкриває альбом без акаунта і автоматично завершується.';

  @override
  String get guestLinkLabelField => 'Для кого посилання';

  @override
  String get guestLinkDaysField => 'Діє, днів';

  @override
  String get guestLinkCreate => 'Створити гостьове посилання';

  @override
  String get guestLinkCopy => 'Скопіювати токен';

  @override
  String get guestLinkCopied => 'Гостьовий токен скопійовано.';

  @override
  String get guestLinkRevoke => 'Відкликати';

  @override
  String get guestLinksEmpty => 'Гостьових посилань поки немає.';

  @override
  String get guestLinkStatusActive => 'Діє';

  @override
  String get guestLinkStatusExpired => 'Завершилося';

  @override
  String get guestLinkStatusRevoked => 'Відкликане';

  @override
  String get backupCreate => 'Створити копію зараз';

  @override
  String get backupCreated => 'Знімок збережено.';

  @override
  String get backupCreateFailed => 'Не вдалося створити знімок.';

  @override
  String get backupEmpty => 'Копій поки немає — створіть першу вище.';

  @override
  String get backupRestore => 'Відновити';

  @override
  String get backupRestoreConfirmTitle => 'Відновити цей знімок?';

  @override
  String get backupRestoreConfirmBody =>
      'Зміни після цього моменту зникнуть. Поточний стан спершу збережеться в копію, тому відкат можна повернути.';

  @override
  String get backupRestored => 'Дані відновлено зі знімка.';

  @override
  String get backupRestoreFailed => 'Не вдалося відновити знімок.';

  @override
  String get backupDelete => 'Видалити';

  @override
  String get backupDeleteConfirmTitle => 'Видалити цей знімок?';

  @override
  String get backupDeleteConfirmBody =>
      'Видалиться лише резервна копія, дані родини залишаться попередніми.';

  @override
  String get backupDeleted => 'Знімок видалено.';

  @override
  String get backupExport => 'Зберегти бекап';

  @override
  String get backupExportTitle => 'Створення бекапу';

  @override
  String get backupExportHint =>
      'Буде створено повну копію налаштувань, профілів, подій, акаунтів, прав доступу й медіатеки. Зовнішні посилання зберігаються без файлів; паролі — лише у вигляді солі та хешу.';

  @override
  String get backupIncludeMedia => 'Зберігати фото й відео';

  @override
  String get backupIncludeMediaHint =>
      'До бекапу потраплять копії всіх локальних медіафайлів, тому файл може бути великим.';

  @override
  String get backupSaveDialogTitle => 'Куди зберегти бекап родини';

  @override
  String backupSavedTo(String path) {
    return 'Бекап збережено: $path';
  }

  @override
  String get backupExportCanceled => 'Збереження бекапу скасовано.';

  @override
  String get backupImport => 'Імпортувати бекап';

  @override
  String get backupImportSuccess => 'Бекап імпортовано.';

  @override
  String get backupImportFailed => 'Не вдалося імпортувати цей файл бекапу.';

  @override
  String backupSummary(int count, int kept, String size) {
    return '$count з $kept · $size';
  }

  @override
  String backupRevision(int revision) {
    return 'ревізія $revision';
  }

  @override
  String backupSizeBytes(int size) {
    return '$size Б';
  }

  @override
  String backupSizeKb(String size) {
    return '$size КБ';
  }

  @override
  String backupSizeMb(String size) {
    return '$size МБ';
  }

  @override
  String get backupLocalOnly =>
      'Знімки зберігаються локально й містять копії файлів медіатеки.';

  @override
  String get dateFormatHint => 'ДД.ММ.РРРР';

  @override
  String get invalidDate => 'Введіть існуючу дату: ДД.ММ.РРРР';

  @override
  String get memberShowInCalendar =>
      'Позначати день народження в сімейному календарі';

  @override
  String get memberBirthdayMedia => 'Фото й відео до дня народження';

  @override
  String get memberGalleryTitle => 'Фото й відео';

  @override
  String get memberGalleryAddShot => 'Додати фото';

  @override
  String get memberGalleryRemoveShot => 'Видалити кадр';

  @override
  String get memberGalleryCaption => 'Підпис кадру';

  @override
  String get memberWishlistTitle => 'Список бажань';

  @override
  String get memberWishlistAdd => 'Додати бажання';

  @override
  String get memberWishlistEmpty => 'Бажань поки немає.';

  @override
  String get wishlistItemTitleField => 'Бажання';

  @override
  String get wishlistItemUrlField => 'Посилання на товар';

  @override
  String get wishlistNoteField => 'Нотатка';

  @override
  String get wishlistRemove => 'Видалити бажання';

  @override
  String get eventShowInCalendar => 'Позначати дату в сімейному календарі';

  @override
  String calendarBirthdayTitle(String name) {
    return 'День народження: $name';
  }

  @override
  String get mediaTitle => 'Фото й відео';

  @override
  String get mediaAdd => 'Додати медіа';

  @override
  String get mediaAddByLink => 'Додати за посиланням';

  @override
  String get mediaEmpty => 'Фото й відео поки немає.';

  @override
  String get mediaSourceField => 'Шлях до файлу або посилання';

  @override
  String get mediaCaptionField => 'Підпис';

  @override
  String get mediaTypeField => 'Тип';

  @override
  String get mediaTypeImage => 'Фото';

  @override
  String get mediaTypeVideo => 'Відео';

  @override
  String get mediaPeopleField => 'Хто на фото';

  @override
  String get mediaEventsField => 'Пов\'язані події';

  @override
  String get mediaPeopleHint =>
      'Позначене фото з\'явиться в профілі кожної обраної людини.';

  @override
  String mediaPersonCaption(String name) {
    return 'Підпис для $name';
  }

  @override
  String get mediaEventsHint => 'Пов\'язане фото з\'явиться в обраних подіях.';

  @override
  String get mediaFromLibrary => 'З медіатеки';

  @override
  String get mediaLibraryEmpty =>
      'Медіатека порожня. Завантажте файли в «Налаштування → Медіатека».';

  @override
  String get mediaCropField => 'Видима частина для цього зв\'язку';

  @override
  String get videoPlay => 'Грати';

  @override
  String get videoPause => 'Пауза';

  @override
  String get videoMute => 'Вимкнути звук';

  @override
  String get videoUnmute => 'Увімкнути звук';

  @override
  String get videoError => 'Не вдалося відтворити відео.';

  @override
  String get mediaViewerPrevious => 'Попереднє медіа';

  @override
  String get mediaViewerNext => 'Наступне медіа';

  @override
  String get videoConvert => 'Підтримуваний формат';

  @override
  String get videoConverting => 'Готуємо відео…';

  @override
  String get videoConverted => 'Відео збережено в підтримуваному форматі.';

  @override
  String get videoConvertFailed =>
      'Не вдалося підготувати відео в підтримуваному форматі.';

  @override
  String get videoConvertHint =>
      'Відео автоматично приводиться до підтримуваного формату.';

  @override
  String get mediaCropX => 'По горизонталі';

  @override
  String get mediaCropY => 'По вертикалі';

  @override
  String get mediaZoom => 'Масштаб';

  @override
  String get mediaCropHint =>
      'Перетягніть фото й використайте жест масштабування';

  @override
  String get mediaCropReset => 'Скинути кадр';

  @override
  String get mediaZoomIn => 'Наблизити';

  @override
  String get mediaZoomOut => 'Віддалити';

  @override
  String get mediaRemove => 'Видалити медіа';

  @override
  String get mediaUpload => 'Завантажити з пристрою';

  @override
  String get mediaUploading => 'Завантаження…';

  @override
  String get mediaUploadHint =>
      'Фото й відео до 20 МБ. Відео автоматично приводяться до підтримуваного формату. Файли зберігаються локально на цьому пристрої.';

  @override
  String mediaUploadTooLarge(String name) {
    return 'Файл більший за 20 МБ: $name';
  }

  @override
  String get mediaUploadFailed => 'Не вдалося завантажити файл.';

  @override
  String get mediaUploadEmpty => 'Обраний файл порожній.';

  @override
  String get mediaOpenLink => 'Відкрити посилання';

  @override
  String get mediaLinkCopied => 'Посилання скопійовано.';

  @override
  String timelineElapsedYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count року',
      many: '$count років',
      few: '$count роки',
      one: '$count рік',
      zero: '$count років',
    );
    return '$_temp0';
  }

  @override
  String timelineElapsedMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count місяця',
      many: '$count місяців',
      few: '$count місяці',
      one: '$count місяць',
      zero: '$count місяців',
    );
    return '$_temp0';
  }

  @override
  String timelineElapsedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count днів',
      few: '$count дні',
      one: '$count день',
      zero: '$count днів',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Скасувати';

  @override
  String get close => 'Закрити';

  @override
  String get settingsNoAccess => 'У вас немає доступу до цього розділу.';

  @override
  String get accountLocalAdmin => 'Локальний адміністратор';

  @override
  String get accountSignIn => 'Увійти';

  @override
  String get accountSignOut => 'Вийти';

  @override
  String get accountSignInAction => 'Увійти';

  @override
  String accountSignedIn(String name) {
    return 'Ви увійшли як $name.';
  }

  @override
  String get accountSignedOut =>
      'Ви вийшли. Активний режим локального адміністратора.';

  @override
  String get accountLoginFailed => 'Неправильний логін або пароль.';

  @override
  String get accountAccessTitle => 'Доступ';

  @override
  String get accountAccessHint =>
      'Виберіть профілі та події, які бачить цей акаунт.';

  @override
  String get accountAllMembers => 'Усі члени родини';

  @override
  String get accountVisibleEvents => 'Видимі події';

  @override
  String mediaUsagePersonTag(String name) {
    return '$name — позначений на фото';
  }

  @override
  String get mediaUnused => 'Не використовується';

  @override
  String mediaOnlyUnused(int count) {
    return 'Лише невикористані ($count)';
  }

  @override
  String get mediaUseInProfile => 'Використати в профілі';

  @override
  String get mediaUseTitle => 'Показати файл у профілях';

  @override
  String get mediaUseNoMembers =>
      'Немає членів родини, до яких можна прив\'язати файл.';

  @override
  String get mediaUseApply => 'Застосувати';

  @override
  String get mediaUsed => 'Файл тепер показується у вибраних профілях.';

  @override
  String get settingsTabLanguage => 'Мова';

  @override
  String get settingsLanguage => 'Мова інтерфейсу';

  @override
  String get settingsLanguageHint => 'Вибір зберігається на цьому пристрої.';

  @override
  String get settingsLanguageSystem => 'Як у системі';

  @override
  String get settingsLanguageRussian => 'Російська';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageBelarusian => 'Беларуская';

  @override
  String get settingsLanguageUkrainian => 'Українська';

  @override
  String get familyCloudTitle => 'Сім\'я у хмарі';

  @override
  String get familyCloudHint =>
      'Створіть сім\'ю, щоб синхронізувати альбоми між пристроями, або приєднайтеся за кодом запрошення.';

  @override
  String get familyCloudCreateTitle => 'Створити сім\'ю';

  @override
  String get familyCloudNameLabel => 'Назва сім\'ї';

  @override
  String get familyCloudNameHint => 'Наприклад: Наша велика сім\'я';

  @override
  String get familyCloudCreateAction => 'Створити й підключити';

  @override
  String get familyCloudJoinTitle => 'Приєднатися за кодом';

  @override
  String get familyCloudCodeLabel => 'Код запрошення';

  @override
  String get familyCloudCodeHint => '8 символів, наприклад AB2CD3EF';

  @override
  String get familyCloudJoinAction => 'Приєднатися';

  @override
  String get familyCloudInvalidCode => 'Код має складатися з 8 літер або цифр.';

  @override
  String get familyCloudJoinNotFound =>
      'Код запрошення не знайдено або він прострочений.';

  @override
  String get familyCloudCreated => 'Сім\'ю створено.';

  @override
  String get familyCloudJoined => 'Ви приєдналися до сім\'ї.';

  @override
  String get familyCloudError =>
      'Не вдалося виконати запит. Перевірте з\'єднання та спробуйте ще раз.';

  @override
  String get familyCloudRetry => 'Спробувати ще раз';

  @override
  String get familyCloudOwnerBadge => 'Власник';

  @override
  String get familyCloudPremiumActive => 'Преміум активний';

  @override
  String get familyCloudPremiumFree => 'Безкоштовний план';

  @override
  String get familyCloudInviteTitle => 'Запрошення до сім\'ї';

  @override
  String get familyCloudInviteHint =>
      'Поділіться кодом: його можна використати один раз на людину.';

  @override
  String get familyCloudInviteCreate => 'Створити код запрошення';

  @override
  String get familyCloudInviteCopied => 'Код запрошення скопійовано.';

  @override
  String get familyCloudNameRequired => 'Назва сім\'ї не може бути порожньою.';

  @override
  String familyCloudId(String id) {
    return 'ID: $id';
  }

  @override
  String get familyCloudPrivacyTitle => 'Дані та приватність';

  @override
  String get familyCloudPrivacyHint =>
      'Ваші фото залишаються на пристрої. Видалення даних родини стирає файли й записи з хмари для всіх учасників.';

  @override
  String get familyCloudDisconnect => 'Відключити цей пристрій';

  @override
  String get familyCloudDisconnectConfirm =>
      'Відключити пристрій від родини? Локальний архів залишиться, дані в хмарі не видаляться.';

  @override
  String get familyCloudDisconnected => 'Пристрій відключено від родини.';

  @override
  String get familyCloudDisconnectOwnerBlocked =>
      'Ви власник, і в родині ще є інші учасники. Відключення недоступне — видаліть дані родини або залиште пристрій підключеним.';

  @override
  String get familyCloudDeleteCloud => 'Видалити дані родини з хмари';

  @override
  String get familyCloudDeleteCloudConfirm =>
      'Усі файли, події та учасники родини будуть безповоротно видалені з хмари. Скасувати це неможливо. Локальний архів залишиться на пристрої.';

  @override
  String get familyCloudDeleteCloudDone => 'Дані родини видалено з хмари.';

  @override
  String get commonDelete => 'Видалити';

  @override
  String get mediaLocalOnlyNotice =>
      'Збережено лише на цьому пристрої: хмарна сім\'я не підключена. Підключіть її в Налаштуваннях → «Сім\'я у хмарі», щоб фото синхронізувалися.';

  @override
  String mediaUploadAllLocal(int count) {
    return 'Завантажити все локальне ($count)';
  }

  @override
  String mediaUploadAllProgress(int done, int total) {
    return 'Завантаження $done з $total…';
  }

  @override
  String mediaUploadAllDone(int count) {
    return 'Завантажено в хмару: $count';
  }

  @override
  String mediaUploadAllFailed(int count) {
    return 'Не вдалося завантажити: $count';
  }

  @override
  String mediaOutboxRetry(int count) {
    return 'У черзі: $count — надіслати';
  }

  @override
  String get syncStatusLoading => 'Синхронізація…';

  @override
  String get syncStatusSaving => 'Збереження…';

  @override
  String get syncStatusSaved => 'Збережено';

  @override
  String get syncStatusError => 'Немає зв\'язку';
}
