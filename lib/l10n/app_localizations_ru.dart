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
  String get settingsFamilyReadOnly =>
      'Менять настройки семьи может только администратор.';

  @override
  String get settingsFamilySubtitle => 'Подзаголовок семьи';

  @override
  String get settingsFamilySubtitleHint =>
      'Показывается под названием семьи на главной странице';

  @override
  String get settingsDataSource => 'Источник данных';

  @override
  String get settingsArchiveSource =>
      'Семейный архив из демонстрационных файлов приложения (локально)';

  @override
  String get settingsResetDemo => 'Откат к демонстрационным данным';

  @override
  String get settingsResetDemoHint =>
      'Вернуть локальный архив к демонстрационным файлам приложения';

  @override
  String get settingsResetDemoConfirmTitle =>
      'Откатить к демонстрационным данным?';

  @override
  String get settingsResetDemoConfirmBody =>
      'Все локальные изменения семьи — участники, события, медиатека, название и фото — будут потеряны. Отменить это действие нельзя.';

  @override
  String settingsResetDemoCloudWarning(String deleteAction) {
    return 'Данные в облаке не удаляются. Удалить их можно в разделе «Общие настройки → Облако» — кнопка «$deleteAction».';
  }

  @override
  String get settingsResetDemoAction => 'Откатить';

  @override
  String get settingsResetDemoBackup => 'Сделать бэкап';

  @override
  String get settingsResetDemoBackupDone => 'Резервная копия создана.';

  @override
  String get settingsResetDemoBackupFailed =>
      'Не удалось создать резервную копию.';

  @override
  String get settingsResetDemoDone =>
      'Архив возвращён к демонстрационным данным.';

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
  String get familyRenameOwnerOnly =>
      'Переименовать семью может только администратор семьи — тот, кто её создал.';

  @override
  String get familyRenamed => 'Название семьи изменено.';

  @override
  String get familyRenameFailed =>
      'Не удалось изменить название в облаке. Проверьте соединение.';

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
      'Создавайте семейные аккаунты с логином и паролем, назначайте роли и выпускайте гостевые ссылки. Аккаунты хранятся на сервере.';

  @override
  String get settingsAccountsLocalOnly =>
      'Аккаунты синхронизируются с сервером: входите с тем же логином и паролем на любом устройстве. Локальная копия позволяет войти без сети.';

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
  String get eventMemberField => 'Основной участник';

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
  String get accountServerUnavailable =>
      'Сервер аккаунтов недоступен. Проверьте соединение и повторите.';

  @override
  String get accountServerError =>
      'Сервер аккаунтов вернул ошибку. Попробуйте позже.';

  @override
  String get accountCreatedLocalOnly =>
      'Сервер недоступен: аккаунт сохранён только на этом устройстве.';

  @override
  String get accountServerBadge => 'Сервер';

  @override
  String get accountMigratedOnServer => 'Аккаунт перенесён на сервер.';

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
  String get mediaCropHint => 'Перетаскивайте фото и масштабируйте щипком';

  @override
  String get mediaCropExpand => 'Развернуть';

  @override
  String get mediaCropDone => 'Готово';

  @override
  String get mediaCropReset => 'Сбросить кадр';

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

  @override
  String get familyCloudTitle => 'Семья в облаке';

  @override
  String get familyCloudHint =>
      'Создайте семью, чтобы синхронизировать альбомы между устройствами, или присоединитесь по коду приглашения.';

  @override
  String get familyCloudCreateTitle => 'Создать семью';

  @override
  String get familyCloudNameLabel => 'Название семьи';

  @override
  String get familyCloudNameHint => 'Например: Наша большая семья';

  @override
  String get familyCloudCreateAction => 'Создать и подключить';

  @override
  String get familyCloudJoinTitle => 'Присоединиться по коду';

  @override
  String get familyCloudCodeLabel => 'Код приглашения';

  @override
  String get familyCloudCodeHint => '8 символов, например AB2CD3EF';

  @override
  String get familyCloudJoinAction => 'Присоединиться';

  @override
  String get familyCloudInvalidCode =>
      'Код должен состоять из 8 букв или цифр.';

  @override
  String get familyCloudJoinNotFound => 'Код приглашения не найден или истёк.';

  @override
  String get familyCloudCreated => 'Семья создана.';

  @override
  String get familyCloudJoined => 'Вы присоединились к семье.';

  @override
  String get familyCloudError =>
      'Не удалось выполнить запрос. Проверьте соединение и попробуйте снова.';

  @override
  String get familyCloudRetry => 'Попробовать снова';

  @override
  String get familyCloudOwnerBadge => 'Владелец';

  @override
  String get familyCloudPremiumActive => 'Премиум активен';

  @override
  String get familyCloudPremiumFree => 'Бесплатный план';

  @override
  String get familyCloudInviteTitle => 'Приглашение в семью';

  @override
  String get familyCloudInviteHint =>
      'Поделитесь кодом: его можно использовать один раз на человека.';

  @override
  String get familyCloudInviteCreate => 'Создать код приглашения';

  @override
  String get familyCloudInviteCopied => 'Код приглашения скопирован.';

  @override
  String get familyCloudNameRequired => 'Название семьи не может быть пустым.';

  @override
  String familyCloudId(String id) {
    return 'ID: $id';
  }

  @override
  String get familyCloudPrivacyTitle => 'Данные и приватность';

  @override
  String get familyCloudPrivacyHint =>
      'Ваши фото остаются на устройстве. Удаление данных семьи стирает файлы и записи из облака для всех участников.';

  @override
  String get familyCloudDisconnect => 'Отключить это устройство';

  @override
  String get familyCloudDisconnectConfirm =>
      'Отключить устройство от семьи? Локальный архив останется, данные в облаке не удалятся.';

  @override
  String get familyCloudDisconnected => 'Устройство отключено от семьи.';

  @override
  String get familyCloudDisconnectOwnerBlocked =>
      'Вы владелец, и в семье ещё есть другие участники. Отключение недоступно — удалите данные семьи или оставьте устройство подключённым.';

  @override
  String get familyCloudDeleteCloud => 'Удалить данные семьи из облака';

  @override
  String get familyCloudDeleteCloudConfirm =>
      'Все файлы, события и участники семьи будут безвозвратно удалены из облака. Отменить это нельзя. Локальный архив останется на устройстве.';

  @override
  String get familyCloudDeleteCloudDone => 'Данные семьи удалены из облака.';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get mediaLocalOnlyNotice =>
      'Сохранено только на этом устройстве: облачная семья не подключена. Подключите её в Настройках → «Семья в облаке», чтобы фото синхронизировались.';

  @override
  String mediaUploadAllLocal(int count) {
    return 'Загрузить всё локальное ($count)';
  }

  @override
  String mediaUploadAllProgress(int done, int total) {
    return 'Загрузка $done из $total…';
  }

  @override
  String mediaUploadAllDone(int count) {
    return 'Загружено в облако: $count';
  }

  @override
  String mediaUploadAllFailed(int count) {
    return 'Не удалось загрузить: $count';
  }

  @override
  String get mediaUploadUnavailableHint =>
      'Эти файлы хранились только на другом устройстве или потерялись при переустановке — добавьте их заново.';

  @override
  String mediaOutboxRetry(int count) {
    return 'В очереди: $count — отправить';
  }

  @override
  String get syncStatusLoading => 'Синхронизация…';

  @override
  String get syncStatusSaving => 'Сохранение…';

  @override
  String get syncStatusSaved => 'Сохранено';

  @override
  String get syncStatusError => 'Нет связи';

  @override
  String get editModeEnter => 'Режим редактирования';

  @override
  String get editModeExit => 'Выйти из режима редактирования';

  @override
  String get editModeBanner =>
      'Режим редактирования: нажмите на карандаш у карточки';

  @override
  String get editModeDone => 'Готово';

  @override
  String get adminOnlyAction => 'Только администратор';

  @override
  String get adminOnlyDeleteHint =>
      'Удалять события и участников может только администратор.';

  @override
  String get adminOnlySettingsHint =>
      'Резервные копии, аккаунты и откат к демо-данным доступны только администратору.';

  @override
  String get accountEntryTitle => 'Аккаунт';

  @override
  String get accountAuthTitle => 'Вход или создание аккаунта';

  @override
  String get accountSignInTab => 'Вход';

  @override
  String get accountSignUpTab => 'Регистрация';

  @override
  String get accountSignInSubtitle =>
      'Войдите, чтобы загрузить данные своей семьи.';

  @override
  String get accountSignUpHint =>
      'Новый аккаунт получит роль наблюдателя. Администратор сможет изменить её позже.';

  @override
  String get accountFirstAdminHint =>
      'Первый аккаунт семьи становится администратором.';

  @override
  String accountSessionTitle(String name) {
    return 'Вы вошли как $name';
  }

  @override
  String get accountManage => 'Управление аккаунтами';

  @override
  String get accountSwitch => 'Сменить аккаунт';

  @override
  String get calendarViewMonth => 'Месяц';

  @override
  String get calendarViewYear => 'Год';

  @override
  String get calendarToday => 'Сегодня';

  @override
  String get calendarAddEvent => 'Добавить событие';

  @override
  String get calendarAddDate => 'Добавить дату';

  @override
  String get calendarEntryTitle => 'Дата в календаре';

  @override
  String get calendarEntryTitleField => 'Название';

  @override
  String get calendarEntryNoteField => 'Заметка';

  @override
  String get calendarEntryDateField => 'Дата';

  @override
  String get calendarEntryRecurring => 'Повторять каждый год';

  @override
  String get calendarEntryHint =>
      'Дата появится только в календаре и не попадёт в таймлайн.';

  @override
  String get calendarEntrySaved => 'Дата добавлена в календарь.';

  @override
  String get calendarEntryDeleted => 'Дата удалена из календаря.';

  @override
  String get calendarEntryEdit => 'Изменить дату';

  @override
  String get calendarEntryDelete => 'Удалить дату';

  @override
  String get calendarEntryDeleteConfirmTitle => 'Удалить эту дату?';

  @override
  String get calendarEntryDeleteConfirmBody =>
      'Дата исчезнет из календаря. События таймлайна не затрагиваются.';

  @override
  String get calendarEntryDefaultTitle => 'Дата';

  @override
  String get calendarLegendEvent => 'События';

  @override
  String get calendarLegendBirthday => 'Дни рождения';

  @override
  String get eventShowInTimeline => 'Показывать в таймлайне';

  @override
  String get eventRecurringYearly => 'Повторять каждый год';

  @override
  String get eventCalendarOnlyBadge => 'Только календарь';

  @override
  String get eventMemberHint =>
      'Влияет на доступ и профиль. Несколько человек на фото отмечайте в «Кто на фото».';

  @override
  String get eventNewBadge => 'Новое';

  @override
  String get timelineOrderLabel => 'Порядок';

  @override
  String get timelineOrderOldest => 'Сначала старые';

  @override
  String get timelineOrderNewest => 'Сначала новые';

  @override
  String get profileStories => 'Интересное';

  @override
  String get profileStoriesEmpty => 'Пока нет историй.';

  @override
  String get profileStoriesAdd => 'Добавить историю';

  @override
  String get profileStoryDelete => 'Удалить историю';

  @override
  String get profileStoryTitleField => 'Заголовок';

  @override
  String get profileStoryTextField => 'Текст истории';

  @override
  String get readMore => 'Читать дальше';

  @override
  String get readLess => 'Свернуть';

  @override
  String get memberEditorTitle => 'Участник';

  @override
  String get eventEditorTitle => 'Событие';

  @override
  String get memberEdit => 'Редактировать участника';

  @override
  String get eventEdit => 'Редактировать событие';

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String get familyCloudInviteCopy => 'Копировать код';

  @override
  String get familyCloudInviteCopyHint =>
      'Браузер не разрешил скопировать автоматически: нажмите значок копирования рядом с кодом.';

  @override
  String get backupDownloadStarted => 'Файл резервной копии скачан браузером.';

  @override
  String get backupImportWrongFile =>
      'Выберите файл резервной копии OurTree (.json или .ourtree).';

  @override
  String backupImportTooLarge(int mb) {
    return 'Файл больше $mb МБ и может не поместиться в память браузера. Сохраните копию без медиа и попробуйте снова.';
  }

  @override
  String get backupImportUnreadable =>
      'Не удалось прочитать выбранный файл. Если он лежит в iCloud, сначала скачайте его на устройство.';

  @override
  String backupImportPartial(int count) {
    return 'Не удалось восстановить файлов медиа: $count.';
  }

  @override
  String get demoEditNoticeTitle => 'Изменения останутся на этом устройстве';

  @override
  String get demoEditNoticeBody =>
      'Архив не будет сохранён в облаке. Создайте семью и войдите в аккаунт, чтобы данные сохранялись и были доступны на других устройствах.';

  @override
  String get demoEditNoticeAction => 'Создать семью';

  @override
  String get demoEditNoticeLater => 'Позже';

  @override
  String get demoLocalOnlyNotice =>
      'Только на этом устройстве: нет синхронизации с облаком';

  @override
  String get accountNoFamilyAttached =>
      'Этот аккаунт пока не связан с семьёй — подключитесь по коду приглашения в «Общие настройки → Облако».';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String get aboutHint => 'Версия, разработчик, документы и лицензии.';

  @override
  String get aboutDescription =>
      'OurTree — семейный альбом: профили, таймлайн, календарь и медиатека. Данные хранятся на устройстве и синхронизируются с облаком, когда семья подключена.';

  @override
  String get aboutVersion => 'Версия';

  @override
  String aboutVersionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutPlatform => 'Платформа';

  @override
  String get aboutDeveloper => 'Разработчик';

  @override
  String get aboutContact => 'Связаться';

  @override
  String get aboutPrivacy => 'Политика конфиденциальности';

  @override
  String get aboutTerms => 'Условия использования';

  @override
  String get aboutLicenses => 'Лицензии открытого ПО';

  @override
  String get aboutChangelogTitle => 'Что нового';

  @override
  String get aboutChangelog1 =>
      'Правки с других устройств приезжают без перезапуска';

  @override
  String get aboutChangelog2 =>
      'Фото автоматически уходят в облако в созданной семье';

  @override
  String get aboutChangelog3 =>
      'Импорт резервной копии работает на iPhone (веб-версия)';

  @override
  String get aboutChangelog4 => 'Код приглашения копируется автоматически';

  @override
  String get aboutChangelog5 =>
      'Пуш-уведомления о днях рождения, событиях и изменениях семьи';

  @override
  String get aboutSupport => 'Поддержка';

  @override
  String get aboutFamilyId => 'ID семьи';

  @override
  String get aboutCopyFamilyId => 'Скопировать ID семьи';

  @override
  String get aboutFamilyIdCopied => 'ID семьи скопирован.';

  @override
  String get aboutNoFamily =>
      'Семья ещё не подключена: подключите её в «Общие настройки → Облако».';

  @override
  String aboutCopyright(int year) {
    return '© $year OurTree';
  }

  @override
  String get aboutLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsHint =>
      'Дни рождения, события календаря и изменения семьи.';

  @override
  String get notificationsStatusTitle => 'Состояние на этом устройстве';

  @override
  String get notificationsEnable => 'Включить уведомления';

  @override
  String get notificationsDisable => 'Отключить';

  @override
  String get notificationsRefresh => 'Обновить токен';

  @override
  String get notificationsEnabled =>
      'Уведомления включены: напоминания и изменения семьи будут приходить на это устройство.';

  @override
  String get notificationsDisabled =>
      'Уведомления выключены. Включите их, чтобы получать напоминания.';

  @override
  String get notificationsDenied =>
      'Уведомления заблокированы в браузере или настройках системы. Разрешите их для приложения и попробуйте снова.';

  @override
  String get notificationsNoFamily =>
      'Сначала подключите семью: напоминания приходят по архиву вашей семьи.';

  @override
  String get notificationsFailed => 'Не удалось включить уведомления.';

  @override
  String get notificationsFailedNoKey =>
      'В этой сборке нет ключа web-push (FIREBASE_VAPID_KEY). Пересоберите с --dart-define-from-file.';

  @override
  String get notificationsFailedPermission => 'Браузер не выдал разрешение.';

  @override
  String get notificationsFailedToken =>
      'Не удалось получить токен устройства.';

  @override
  String get notificationsPrefsTitle => 'Что присылать';

  @override
  String get notificationsBirthdays => 'Дни рождения';

  @override
  String get notificationsBirthdaysHint => 'Накануне и в сам день.';

  @override
  String get notificationsCalendar => 'События календаря';

  @override
  String get notificationsCalendarHint =>
      'События с отметкой «показывать в календаре».';

  @override
  String get notificationsFamilyUpdates => 'Изменения семьи';

  @override
  String get notificationsFamilyUpdatesHint =>
      'Когда кто-то правит общий архив.';

  @override
  String get notificationsIosHint =>
      'На iPhone уведомления работают только в приложении, добавленном на экран «Домой» (iOS 16.4+).';

  @override
  String get notificationsUpcoming => 'Ближайшее';

  @override
  String get notificationsUpcomingEmpty =>
      'В ближайшие 7 дней дней рождения и событий нет.';

  @override
  String get settingsResetLocal => 'Сбросить к версии из облака';

  @override
  String get settingsResetLocalHint =>
      'Заменить локальные правки данными семьи';

  @override
  String get settingsResetLocalTitle => 'Заменить локальные данные?';

  @override
  String get settingsResetLocalConfirmBody =>
      'Локальные правки будут заменены текущей версией семьи из облака. Демо-архив в подключённой семье не сохраняется.';

  @override
  String get settingsResetLocalAction => 'Заменить';

  @override
  String get settingsResetLocalDone =>
      'Локальные данные заменены версией из облака.';

  @override
  String get mediaSelectHint => 'Долгое нажатие на файл — выбрать несколько.';

  @override
  String mediaSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get mediaSelectAll => 'Выбрать все';

  @override
  String get mediaSelectNone => 'Снять выбор';

  @override
  String get mediaDeleteSelected => 'Удалить выбранные';

  @override
  String get mediaDeleteManyTitle => 'Удалить выбранные файлы?';

  @override
  String mediaDeleteManyBody(int count) {
    return 'Файлы ($count) будут удалены из архива и из облака.';
  }

  @override
  String mediaDeleteManyDone(int count) {
    return 'Удалено файлов: $count';
  }
}
