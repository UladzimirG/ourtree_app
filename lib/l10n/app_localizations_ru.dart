// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'OurTree App';

  @override
  String get homeFamilyLabel => 'Семья';

  @override
  String get homeSubtitle => 'Место для семейных историй, фотографий и дат.';

  @override
  String get homeOverviewTitle => 'Обзор';

  @override
  String homeMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
      zero: 'Пока нет участников',
    );
    return '$_temp0';
  }

  @override
  String homeEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count события',
      many: '$count событий',
      few: '$count события',
      one: '$count событие',
      zero: 'Пока нет событий',
    );
    return '$_temp0';
  }

  @override
  String get homeLoading => 'Загружаем данные семьи…';

  @override
  String get homeLoadError => 'Не удалось загрузить данные семьи.';

  @override
  String get homeRetry => 'Повторить';

  @override
  String get settingsTitle => 'Настройки семьи';

  @override
  String get navTimeline => 'Таймлайн';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navFamily => 'Семья';

  @override
  String get timelineEyebrow => 'Семейный альбом';

  @override
  String get timelineTitle => 'Таймлайн жизни';

  @override
  String get timelineLede =>
      'Нить событий, на которую нанизаны наши встречи, праздники и поездки.';

  @override
  String get timelineEmpty => 'Таймлайн пока пуст.';

  @override
  String timelineTogetherYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вместе уже $count года',
      many: 'Вместе уже $count лет',
      few: 'Вместе уже $count года',
      one: 'Вместе уже $count год',
      zero: 'Вместе с этого дня',
    );
    return '$_temp0';
  }

  @override
  String get mediaPlaceholder => 'Фото или видео';

  @override
  String get familyTitle => 'Семья и профили';

  @override
  String get familyLede =>
      'Нажмите на карточку, чтобы открыть домашний альбом человека.';

  @override
  String get familyEmpty => 'В семье пока нет участников.';

  @override
  String memberAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
      zero: 'Меньше года',
    );
    return '$_temp0';
  }

  @override
  String get calendarEyebrow => 'Не забыть главное';

  @override
  String get calendarTitle => 'Семейный календарь';

  @override
  String get calendarLede =>
      'Дни с семейными событиями выделены. Нажмите на день, чтобы увидеть события.';

  @override
  String get calendarPreviousMonth => 'Предыдущий месяц';

  @override
  String get calendarNextMonth => 'Следующий месяц';

  @override
  String get calendarNoEvents => 'В этот день событий нет.';

  @override
  String get profileBack => 'Все свои';

  @override
  String get profileAbout => 'Обо мне';

  @override
  String get profileWishlist => 'Вишлист';

  @override
  String get profileWishlistEmpty => 'Список желаний пока пуст.';

  @override
  String get profileGallery => 'Мини-галерея';

  @override
  String get profileGalleryEmpty => 'Фотографий пока нет.';

  @override
  String get profileNotFound =>
      'Этот профиль ещё не записан в семейный альбом.';

  @override
  String get profileCopyWishlistLink => 'Скопировать ссылку на вишлист';

  @override
  String get profileLinkCopied => 'Ссылка на вишлист скопирована.';

  @override
  String get settingsFamilyName => 'Название семьи';

  @override
  String get settingsFamilySubtitle => 'Подзаголовок семьи';

  @override
  String get settingsFamilySubtitleHint =>
      'Показывается под названием семьи на главной странице';

  @override
  String get settingsDataSource => 'Источник данных';

  @override
  String get settingsArchiveSource =>
      'Семейный архив из демонстрационных файлов приложения';

  @override
  String get settingsReload => 'Обновить данные';

  @override
  String get settingsReloadStarted => 'Данные семьи обновлены.';

  @override
  String get settingsEditingSoon =>
      'Редактирование появится на следующем шаге.';

  @override
  String get settingsFamilyPhoto => 'Фото семьи';

  @override
  String get settingsFamilyPhotoHint =>
      '/photos/семья.jpg или assets/photos/семья.jpg';

  @override
  String get settingsPhotoPreview => 'Предпросмотр фото';

  @override
  String get settingsClearPhoto => 'Убрать фото';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsShowFamilyPhoto => 'Показывать фото семьи в шапке';

  @override
  String get settingsShowEventPhotos => 'Показывать фотографии в таймлайне';

  @override
  String get settingsSave => 'Сохранить';

  @override
  String get settingsSaved => 'Настройки сохранены.';

  @override
  String get settingsNameRequired => 'Название семьи не может быть пустым.';

  @override
  String get settingsLocalOnly =>
      'Изменения сохраняются локально на этом устройстве.';

  @override
  String get settingsTabFamily => 'Семья';

  @override
  String get settingsTabMembers => 'Участники';

  @override
  String get settingsTabEvents => 'События';

  @override
  String get settingsTabAccounts => 'Аккаунты';

  @override
  String get settingsTabBackups => 'Копии';

  @override
  String get settingsTabMedia => 'Медиатека';

  @override
  String get settingsTabGeneral => 'Общие настройки';

  @override
  String get settingsGeneralHint =>
      'Резервные копии, язык интерфейса и доступы к альбому.';

  @override
  String get settingsMediaHint =>
      'Все фотографии и видео в одном месте. Видео автоматически приводятся к поддерживаемому формату. Описание и кадрирование задаются отдельно для каждого участника и события.';

  @override
  String get mediaLibraryTitle => 'Медиатека семьи';

  @override
  String get mediaLibraryUpload => 'Загрузить файлы';

  @override
  String get mediaLibraryAddLink => 'Добавить по ссылке';

  @override
  String get mediaAssetName => 'Имя файла';

  @override
  String get mediaAssetType => 'Тип';

  @override
  String get mediaUsageTitle => 'Где используется';

  @override
  String get mediaUsageNone => 'Пока ни с кем не связано.';

  @override
  String mediaUsageAvatar(String name) {
    return '$name — аватар';
  }

  @override
  String mediaUsageBirthday(String name) {
    return '$name — день рождения';
  }

  @override
  String mediaUsageGallery(String name) {
    return '$name — галерея';
  }

  @override
  String mediaUsageEvent(String name) {
    return 'Событие «$name»';
  }

  @override
  String get mediaUsageFamilyPhoto => 'Фото семьи в шапке';

  @override
  String get mediaStoredLocally => 'Хранится локально';

  @override
  String get mediaDeleteTitle => 'Удалить файл из медиатеки?';

  @override
  String get mediaDeleteBody =>
      'Файл и все его связи с участниками и событиями будут удалены. Действие нельзя отменить.';

  @override
  String get mediaDelete => 'Удалить';

  @override
  String get mediaDeleted => 'Файл удалён из медиатеки.';

  @override
  String get mediaDuplicateFound => 'Этот файл уже есть в медиатеке.';

  @override
  String get mediaDuplicateAttached =>
      'Этот файл уже был в медиатеке — привязана существующая копия.';

  @override
  String get mediaViewerOpen => 'Открыть в просмотрщике';

  @override
  String mediaLibrarySize(int count, String size) {
    return '$count файлов · $size';
  }

  @override
  String get settingsMembersHint =>
      'Правьте профили, фотографии и видимость дней рождения. Новые участники сохраняются в сессии приложения.';

  @override
  String get settingsEventsHint =>
      'Правьте события таймлайна, даты и места. Дни рождения формируются из профилей участников.';

  @override
  String get settingsAccountsHint =>
      'Создавайте семейные аккаунты, назначайте роли и выпускайте гостевые ссылки.';

  @override
  String get settingsAccountsLocalOnly =>
      'Аккаунты, права доступа и гостевые ссылки хранятся локально, переживают перезапуск и входят в бэкап.';

  @override
  String get settingsBackupsHint =>
      'Снимки семейного архива. Восстановление откатывает данные на выбранный момент.';

  @override
  String get memberAdd => 'Добавить участника';

  @override
  String get memberAdded => 'Участник добавлен.';

  @override
  String get memberDeleted => 'Участник удалён.';

  @override
  String get memberDefaultName => 'Новый участник';

  @override
  String get memberDefaultRole => 'Член семьи';

  @override
  String get memberDeleteConfirmTitle => 'Удалить этого участника?';

  @override
  String get memberDeleteConfirmBody =>
      'Профиль, личные фотографии и события, привязанные к участнику, исчезнут из альбома.';

  @override
  String get memberNameField => 'Имя';

  @override
  String get memberRoleField => 'Роль в семье';

  @override
  String get memberNicknameField => 'Домашнее прозвище';

  @override
  String get memberBirthdayField => 'День рождения';

  @override
  String get memberBirthdayHint => 'ГГГГ-ММ-ДД';

  @override
  String get memberShowBirthday => 'Показывать день рождения в таймлайне';

  @override
  String get memberMainPhoto => 'Главное фото';

  @override
  String get memberHabitsField => 'Привычки, по одной в строке';

  @override
  String get memberQuotesField => 'Цитаты, по одной в строке';

  @override
  String get memberAccentField => 'Цвет акцента';

  @override
  String get memberWishlistUrlField => 'Ссылка на вишлист';

  @override
  String get memberDelete => 'Удалить участника';

  @override
  String get eventAdd => 'Добавить событие';

  @override
  String get eventAdded => 'Событие добавлено.';

  @override
  String get eventDeleted => 'Событие удалено.';

  @override
  String get eventDefaultTitle => 'Новое событие';

  @override
  String get eventDelete => 'Удалить событие';

  @override
  String get eventDeleteConfirmTitle => 'Удалить это событие?';

  @override
  String get eventDeleteConfirmBody =>
      'Событие и ссылки на его медиа исчезнут из таймлайна.';

  @override
  String get eventTitleField => 'Название события';

  @override
  String get eventDateField => 'Дата';

  @override
  String get eventKindField => 'Тип события';

  @override
  String get eventPlaceField => 'Место';

  @override
  String get eventTextField => 'Описание';

  @override
  String get eventMemberField => 'Связанный участник';

  @override
  String get eventMemberNone => 'Без участника';

  @override
  String get eventShowElapsed => 'Показывать, сколько прошло';

  @override
  String get eventKindMeeting => 'Знакомство';

  @override
  String get eventKindDate => 'Свидание';

  @override
  String get eventKindWedding => 'Свадьба';

  @override
  String get eventKindChurch => 'Венчание';

  @override
  String get eventKindBirth => 'Рождение';

  @override
  String get eventKindTrip => 'Поездка';

  @override
  String get eventKindMilestone => 'Веха';

  @override
  String get photoPathHint => '/photos/фото.jpg или assets/photos/фото.jpg';

  @override
  String get settingsAdvancedJson => 'Дополнительный JSON';

  @override
  String get settingsApplyJson => 'Применить JSON';

  @override
  String get settingsInvalidJson => 'Некорректный JSON-объект.';

  @override
  String get accountAdd => 'Новый аккаунт';

  @override
  String get accountCreate => 'Создать аккаунт';

  @override
  String get accountCreated => 'Аккаунт создан.';

  @override
  String get accountSaved => 'Аккаунт обновлён.';

  @override
  String get accountDeleted => 'Аккаунт удалён.';

  @override
  String get accountDelete => 'Удалить';

  @override
  String get accountDeleteConfirmTitle => 'Удалить этот аккаунт?';

  @override
  String get accountDeleteConfirmBody =>
      'Доступ к семейному альбому будет закрыт сразу.';

  @override
  String get accountLoginField => 'Логин';

  @override
  String get accountNameField => 'Имя';

  @override
  String get accountPasswordField => 'Пароль';

  @override
  String get accountPasswordKeepHint =>
      'Оставьте пустым, чтобы не менять пароль';

  @override
  String get accountRoleField => 'Роль';

  @override
  String get accountRoleViewer => 'Наблюдатель';

  @override
  String get accountRoleEditor => 'Редактор';

  @override
  String get accountRoleAdmin => 'Администратор';

  @override
  String get accountLoginInvalid =>
      'Логин — 2–32 символа: латинские буквы, цифры, точка, дефис или подчёркивание.';

  @override
  String get accountLoginRequirements =>
      '2–32 символа: латинские буквы, цифры, точка, дефис или подчёркивание.';

  @override
  String get accountPasswordRequirements => 'Не менее 4 символов.';

  @override
  String get accountRoleInvalid => 'Неизвестная роль.';

  @override
  String get accountPasswordTooShort =>
      'Пароль слишком короткий: нужно минимум 4 символа.';

  @override
  String get accountLoginTaken => 'Этот логин уже занят.';

  @override
  String get accountCannotDeleteSelf => 'Нельзя удалить собственный аккаунт.';

  @override
  String get accountCannotChangeOwnRole => 'Нельзя изменить собственную роль.';

  @override
  String get accountNotFound => 'Аккаунт не найден.';

  @override
  String get accountForbidden => 'Недостаточно прав.';

  @override
  String get accountUnauthenticated => 'Войдите в аккаунт заново.';

  @override
  String get accountOffline => 'Нет связи с сервером.';

  @override
  String get accountUnknownError => 'Что-то пошло не так.';

  @override
  String get accountsEmpty => 'Аккаунтов пока нет. Создайте первый выше.';

  @override
  String get guestLinksTitle => 'Гостевые ссылки';

  @override
  String get guestLinksHint =>
      'Гостевая ссылка открывает альбом без аккаунта и истекает автоматически.';

  @override
  String get guestLinkLabelField => 'Для кого ссылка';

  @override
  String get guestLinkDaysField => 'Срок действия, дней';

  @override
  String get guestLinkCreate => 'Создать гостевую ссылку';

  @override
  String get guestLinkCopy => 'Скопировать токен';

  @override
  String get guestLinkCopied => 'Гостевой токен скопирован.';

  @override
  String get guestLinkRevoke => 'Отозвать';

  @override
  String get guestLinksEmpty => 'Гостевых ссылок пока нет.';

  @override
  String get guestLinkStatusActive => 'Действует';

  @override
  String get guestLinkStatusExpired => 'Истекла';

  @override
  String get guestLinkStatusRevoked => 'Отозвана';

  @override
  String get backupCreate => 'Создать копию сейчас';

  @override
  String get backupCreated => 'Снимок сохранён.';

  @override
  String get backupCreateFailed => 'Не удалось создать снимок.';

  @override
  String get backupEmpty => 'Копий пока нет — создайте первую выше.';

  @override
  String get backupRestore => 'Восстановить';

  @override
  String get backupRestoreConfirmTitle => 'Восстановить этот снимок?';

  @override
  String get backupRestoreConfirmBody =>
      'Изменения после этого момента исчезнут. Текущее состояние сначала сохранится в копию, поэтому откат можно вернуть обратно.';

  @override
  String get backupRestored => 'Данные восстановлены из снимка.';

  @override
  String get backupRestoreFailed => 'Не удалось восстановить снимок.';

  @override
  String get backupDelete => 'Удалить';

  @override
  String get backupDeleteConfirmTitle => 'Удалить этот снимок?';

  @override
  String get backupDeleteConfirmBody =>
      'Удалится только резервная копия, данные семьи останутся прежними.';

  @override
  String get backupDeleted => 'Снимок удалён.';

  @override
  String get backupExport => 'Сохранить бэкап';

  @override
  String get backupExportTitle => 'Создание бэкапа';

  @override
  String get backupExportHint =>
      'Будет создана полная копия настроек, профилей, событий, аккаунтов, прав доступа и медиатеки. Внешние ссылки сохраняются без файлов; пароли — только в виде соли и хеша.';

  @override
  String get backupIncludeMedia => 'Сохранять фотографии и видео';

  @override
  String get backupIncludeMediaHint =>
      'В бэкап попадут копии всех локальных медиафайлов, поэтому файл может быть большим.';

  @override
  String get backupSaveDialogTitle => 'Куда сохранить бэкап семьи';

  @override
  String backupSavedTo(String path) {
    return 'Бэкап сохранён: $path';
  }

  @override
  String get backupExportCanceled => 'Сохранение бэкапа отменено.';

  @override
  String get backupImport => 'Импортировать бэкап';

  @override
  String get backupImportSuccess => 'Бэкап импортирован.';

  @override
  String get backupImportFailed => 'Не удалось импортировать этот файл бэкапа.';

  @override
  String backupSummary(int count, int kept, String size) {
    return '$count из $kept · $size';
  }

  @override
  String backupRevision(int revision) {
    return 'ревизия $revision';
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
      'Снимки хранятся локально и включают копии файлов медиатеки.';

  @override
  String get dateFormatHint => 'ДД.ММ.ГГГГ';

  @override
  String get invalidDate => 'Введите существующую дату: ДД.ММ.ГГГГ';

  @override
  String get memberShowInCalendar =>
      'Отмечать день рождения в семейном календаре';

  @override
  String get memberBirthdayMedia => 'Фото и видео дня рождения';

  @override
  String get memberGalleryTitle => 'Фотографии и видео';

  @override
  String get memberGalleryAddShot => 'Добавить фото';

  @override
  String get memberGalleryRemoveShot => 'Удалить снимок';

  @override
  String get memberGalleryCaption => 'Подпись снимка';

  @override
  String get memberWishlistTitle => 'Вишлист';

  @override
  String get memberWishlistAdd => 'Добавить желание';

  @override
  String get memberWishlistEmpty => 'Желаний пока нет.';

  @override
  String get wishlistItemTitleField => 'Желание';

  @override
  String get wishlistItemUrlField => 'Ссылка на товар';

  @override
  String get wishlistNoteField => 'Заметка';

  @override
  String get wishlistRemove => 'Удалить желание';

  @override
  String get eventShowInCalendar => 'Отмечать дату в семейном календаре';

  @override
  String calendarBirthdayTitle(String name) {
    return 'День рождения: $name';
  }

  @override
  String get mediaTitle => 'Фотографии и видео';

  @override
  String get mediaAdd => 'Добавить медиа';

  @override
  String get mediaAddByLink => 'Добавить по ссылке';

  @override
  String get mediaEmpty => 'Фотографий и видео пока нет.';

  @override
  String get mediaSourceField => 'Путь к файлу или ссылка';

  @override
  String get mediaCaptionField => 'Подпись';

  @override
  String get mediaTypeField => 'Тип';

  @override
  String get mediaTypeImage => 'Фото';

  @override
  String get mediaTypeVideo => 'Видео';

  @override
  String get mediaPeopleField => 'Кто на фото';

  @override
  String get mediaEventsField => 'Связанные события';

  @override
  String get mediaPeopleHint =>
      'Отмеченное фото появится в профиле каждого выбранного человека.';

  @override
  String mediaPersonCaption(String name) {
    return 'Подпись для $name';
  }

  @override
  String get mediaEventsHint => 'Связанное фото появится в выбранных событиях.';

  @override
  String get mediaFromLibrary => 'Из медиатеки';

  @override
  String get mediaLibraryEmpty =>
      'Медиатека пуста. Загрузите файлы в «Настройки → Медиатека».';

  @override
  String get mediaCropField => 'Видимая часть для этой связи';

  @override
  String get videoPlay => 'Играть';

  @override
  String get videoPause => 'Пауза';

  @override
  String get videoMute => 'Выключить звук';

  @override
  String get videoUnmute => 'Включить звук';

  @override
  String get videoError => 'Не удалось воспроизвести видео.';

  @override
  String get mediaViewerPrevious => 'Предыдущее медиа';

  @override
  String get mediaViewerNext => 'Следующее медиа';

  @override
  String get videoConvert => 'Поддерживаемый формат';

  @override
  String get videoConverting => 'Подготовка видео…';

  @override
  String get videoConverted => 'Видео сохранено в поддерживаемом формате.';

  @override
  String get videoConvertFailed =>
      'Не удалось подготовить видео в поддерживаемом формате.';

  @override
  String get videoConvertHint =>
      'Видео автоматически приводится к поддерживаемому формату.';

  @override
  String get mediaCropX => 'По горизонтали';

  @override
  String get mediaCropY => 'По вертикали';

  @override
  String get mediaZoom => 'Масштаб';

  @override
  String get mediaCropHint =>
      'Перетащите фото и используйте жест масштабирования';

  @override
  String get mediaCropReset => 'Сбросить кадр';

  @override
  String get mediaZoomIn => 'Приблизить';

  @override
  String get mediaZoomOut => 'Отдалить';

  @override
  String get mediaRemove => 'Удалить медиа';

  @override
  String get mediaUpload => 'Загрузить с устройства';

  @override
  String get mediaUploading => 'Загрузка…';

  @override
  String get mediaUploadHint =>
      'Фото и видео до 20 МБ. Видео автоматически приводятся к поддерживаемому формату. Файлы хранятся локально на этом устройстве.';

  @override
  String mediaUploadTooLarge(String name) {
    return 'Файл больше 20 МБ: $name';
  }

  @override
  String get mediaUploadFailed => 'Не удалось загрузить файл.';

  @override
  String get mediaUploadEmpty => 'Выбранный файл пуст.';

  @override
  String get mediaOpenLink => 'Открыть ссылку';

  @override
  String get mediaLinkCopied => 'Ссылка скопирована.';

  @override
  String timelineElapsedYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
      zero: '$count лет',
    );
    return '$_temp0';
  }

  @override
  String timelineElapsedMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца',
      many: '$count месяцев',
      few: '$count месяца',
      one: '$count месяц',
      zero: '$count месяцев',
    );
    return '$_temp0';
  }

  @override
  String timelineElapsedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
      zero: '$count дней',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get settingsNoAccess => 'У вас нет доступа к этому разделу.';

  @override
  String get accountLocalAdmin => 'Локальный администратор';

  @override
  String get accountSignIn => 'Войти';

  @override
  String get accountSignOut => 'Выйти';

  @override
  String get accountSignInAction => 'Войти';

  @override
  String accountSignedIn(String name) {
    return 'Вы вошли как $name.';
  }

  @override
  String get accountSignedOut =>
      'Вы вышли. Активен режим локального администратора.';

  @override
  String get accountLoginFailed => 'Неверный логин или пароль.';

  @override
  String get accountAccessTitle => 'Доступ';

  @override
  String get accountAccessHint =>
      'Выберите профили и события, которые видит этот аккаунт.';

  @override
  String get accountAllMembers => 'Все члены семьи';

  @override
  String get accountVisibleEvents => 'Видимые события';

  @override
  String mediaUsagePersonTag(String name) {
    return '$name — отмечен на фото';
  }

  @override
  String get mediaUnused => 'Не используется';

  @override
  String mediaOnlyUnused(int count) {
    return 'Только неиспользуемые ($count)';
  }

  @override
  String get mediaUseInProfile => 'Использовать в профиле';

  @override
  String get mediaUseTitle => 'Показать файл в профилях';

  @override
  String get mediaUseNoMembers =>
      'Нет членов семьи, к которым можно привязать файл.';

  @override
  String get mediaUseApply => 'Применить';

  @override
  String get mediaUsed => 'Файл теперь показывается в выбранных профилях.';

  @override
  String get settingsTabLanguage => 'Язык';

  @override
  String get settingsLanguage => 'Язык интерфейса';

  @override
  String get settingsLanguageHint => 'Выбор сохраняется на этом устройстве.';

  @override
  String get settingsLanguageSystem => 'Как в системе';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageBelarusian => 'Беларуская';

  @override
  String get settingsLanguageUkrainian => 'Українська';
}
