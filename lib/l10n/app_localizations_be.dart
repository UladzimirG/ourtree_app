// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Belarusian (`be`).
class AppLocalizationsBe extends AppLocalizations {
  AppLocalizationsBe([String locale = 'be']) : super(locale);

  @override
  String get appTitle => 'OurTree App';

  @override
  String get homeFamilyLabel => 'Сям\'я';

  @override
  String get homeSubtitle => 'Месца для сямейных гісторый, фотаздымкаў і дат.';

  @override
  String get homeOverviewTitle => 'Агляд';

  @override
  String homeMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count удзельніка',
      many: '$count удзельнікаў',
      few: '$count удзельнікі',
      one: '$count удзельнік',
      zero: 'Пакуль няма ўдзельнікаў',
    );
    return '$_temp0';
  }

  @override
  String homeEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count падзеі',
      many: '$count падзей',
      few: '$count падзеі',
      one: '$count падзея',
      zero: 'Пакуль няма падзей',
    );
    return '$_temp0';
  }

  @override
  String get homeLoading => 'Загружаем даныя сям\'і…';

  @override
  String get homeLoadError => 'Не ўдалося загрузіць даныя сям\'і.';

  @override
  String get homeRetry => 'Паўтарыць';

  @override
  String get settingsTitle => 'Налады сям\'і';

  @override
  String get navTimeline => 'Храналогія';

  @override
  String get navCalendar => 'Каляндар';

  @override
  String get navFamily => 'Сям\'я';

  @override
  String get timelineEyebrow => 'Сямейны альбом';

  @override
  String get timelineTitle => 'Храналогія жыцця';

  @override
  String get timelineLede =>
      'Нітка падзей, на якую нанізаныя нашы сустрэчы, святы і вандроўкі.';

  @override
  String get timelineEmpty => 'Храналогія пакуль пустая.';

  @override
  String timelineTogetherYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Разам ужо $count года',
      many: 'Разам ужо $count гадоў',
      few: 'Разам ужо $count гады',
      one: 'Разам ужо $count год',
      zero: 'Разам з гэтага дня',
    );
    return '$_temp0';
  }

  @override
  String get mediaPlaceholder => 'Фота або відэа';

  @override
  String get familyTitle => 'Сям\'я і профілі';

  @override
  String get familyLede =>
      'Націсніце на картку, каб адкрыць хатні альбом чалавека.';

  @override
  String get familyEmpty => 'У сям\'і пакуль няма ўдзельнікаў.';

  @override
  String memberAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count гадоў',
      few: '$count гады',
      one: '$count год',
      zero: 'Менш за год',
    );
    return '$_temp0';
  }

  @override
  String get calendarEyebrow => 'Не забыць галоўнае';

  @override
  String get calendarTitle => 'Сямейны каляндар';

  @override
  String get calendarLede =>
      'Дні з сямейнымі падзеямі выдзелены. Націсніце на дзень, каб убачыць падзеі.';

  @override
  String get calendarPreviousMonth => 'Папярэдні месяц';

  @override
  String get calendarNextMonth => 'Наступны месяц';

  @override
  String get calendarNoEvents => 'У гэты дзень падзей няма.';

  @override
  String get profileBack => 'Усе свае';

  @override
  String get profileAbout => 'Пра мяне';

  @override
  String get profileWishlist => 'Вішліст';

  @override
  String get profileWishlistEmpty => 'Спіс жаданняў пакуль пусты.';

  @override
  String get profileGallery => 'Міні-галерэя';

  @override
  String get profileGalleryEmpty => 'Фотаздымкаў пакуль няма.';

  @override
  String get profileNotFound =>
      'Гэты профіль яшчэ не запісаны ў сямейны альбом.';

  @override
  String get profileCopyWishlistLink => 'Скапіяваць спасылку на вішліст';

  @override
  String get profileLinkCopied => 'Спасылка на вішліст скапіяваная.';

  @override
  String get settingsFamilyName => 'Назва сям\'і';

  @override
  String get settingsFamilyReadOnly =>
      'Мяняць налады сям\'і можа толькі адміністратар.';

  @override
  String get settingsFamilySubtitle => 'Падзагаловак сям\'і';

  @override
  String get settingsFamilySubtitleHint =>
      'Паказваецца пад назвай сям\'і на галоўнай старонцы';

  @override
  String get settingsDataSource => 'Крыніца даных';

  @override
  String get settingsArchiveSource =>
      'Сямейны архіў з дэманстрацыйных файлаў праграмы (лакальна)';

  @override
  String get settingsResetDemo => 'Адкат да дэманстрацыйных даных';

  @override
  String get settingsResetDemoHint =>
      'Вярнуць лакальны архіў да дэманстрацыйных файлаў праграмы';

  @override
  String get settingsResetDemoConfirmTitle =>
      'Адкаціць да дэманстрацыйных даных?';

  @override
  String get settingsResetDemoConfirmBody =>
      'Усе лакальныя змены сям\'і — удзельнікі, падзеі, медыятэка, назва і фота — будуць страчаныя. Адмяніць гэта немагчыма.';

  @override
  String settingsResetDemoCloudWarning(String deleteAction) {
    return 'Даныя ў воблаку не выдаляюцца. Выдаліць іх можна ў раздзеле «Агульныя налады → Воблака» — кнопка «$deleteAction».';
  }

  @override
  String get settingsResetDemoAction => 'Адкаціць';

  @override
  String get settingsResetDemoBackup => 'Зрабіць бэкап';

  @override
  String get settingsResetDemoBackupDone => 'Рэзервовая копія створаная.';

  @override
  String get settingsResetDemoBackupFailed =>
      'Не ўдалося стварыць рэзервовую копію.';

  @override
  String get settingsResetDemoDone => 'Архіў вернуты да дэманстрацыйных даных.';

  @override
  String get settingsEditingSoon => 'Рэдагаванне з\'явіцца на наступным кроку.';

  @override
  String get settingsFamilyPhoto => 'Фота сям\'і';

  @override
  String get settingsFamilyPhotoHint =>
      '/photos/сям\'я.jpg або assets/photos/сям\'я.jpg';

  @override
  String get settingsPhotoPreview => 'Папярэдні прагляд фота';

  @override
  String get settingsClearPhoto => 'Прыбраць фота';

  @override
  String get settingsAppearance => 'Знешні выгляд';

  @override
  String get settingsShowFamilyPhoto => 'Паказваць фота сям\'і ў шапцы';

  @override
  String get settingsShowEventPhotos => 'Паказваць фотаздымкі ў храналогіі';

  @override
  String get settingsSave => 'Захаваць';

  @override
  String get settingsSaved => 'Налады захаваныя.';

  @override
  String get settingsNameRequired => 'Назва сям\'і не можа быць пустой.';

  @override
  String get familyRenameOwnerOnly =>
      'Перайменаваць сям\'ю можа толькі адміністратар сям\'і — той, хто яе стварыў.';

  @override
  String get familyRenamed => 'Назва сям\'і змененая.';

  @override
  String get familyRenameFailed =>
      'Не ўдалося змяніць назву ў воблаку. Праверце злучэнне.';

  @override
  String get settingsLocalOnly =>
      'Змены захоўваюцца лакальна на гэтай прыладзе.';

  @override
  String get settingsTabFamily => 'Сям\'я';

  @override
  String get settingsTabMembers => 'Удзельнікі';

  @override
  String get settingsTabEvents => 'Падзеі';

  @override
  String get settingsTabAccounts => 'Акаўнты';

  @override
  String get settingsTabBackups => 'Копіі';

  @override
  String get settingsTabMedia => 'Медыятэка';

  @override
  String get settingsTabGeneral => 'Агульныя налады';

  @override
  String get settingsGeneralHint =>
      'Рэзервовыя копіі, мова інтэрфейсу і доступы да альбома.';

  @override
  String get settingsMediaHint =>
      'Усе фота і відэа ў адным месцы. Відэа аўтаматычна прыводзяцца да падтрыманага фармату. Апісанне і кадраванне задаюцца асобна для кожнага ўдзельніка і падзеі.';

  @override
  String get mediaLibraryTitle => 'Медыятэка сям\'і';

  @override
  String get mediaLibraryUpload => 'Загрузіць файлы';

  @override
  String get mediaLibraryAddLink => 'Дадаць па спасылцы';

  @override
  String get mediaAssetName => 'Імя файла';

  @override
  String get mediaAssetType => 'Тып';

  @override
  String get mediaUsageTitle => 'Дзе выкарыстоўваецца';

  @override
  String get mediaUsageNone => 'Пакуль ні з чым не звязана.';

  @override
  String mediaUsageAvatar(String name) {
    return '$name — аватар';
  }

  @override
  String mediaUsageBirthday(String name) {
    return '$name — дзень нараджэння';
  }

  @override
  String mediaUsageGallery(String name) {
    return '$name — галерэя';
  }

  @override
  String mediaUsageEvent(String name) {
    return 'Падзея \"$name\"';
  }

  @override
  String get mediaUsageFamilyPhoto => 'Фота сям\'і ў шапцы';

  @override
  String get mediaStoredLocally => 'Захоўваецца лакальна';

  @override
  String get mediaDeleteTitle => 'Выдаліць гэты файл з медыятэкі?';

  @override
  String get mediaDeleteBody =>
      'Файл і ўсе яго сувязі з удзельнікамі і падзеямі знікнуць. Дзеянне нельга адмяніць.';

  @override
  String get mediaDelete => 'Выдаліць';

  @override
  String get mediaDeleted => 'Файл выдалены з медыятэкі.';

  @override
  String get mediaDuplicateFound => 'Гэты файл ужо ёсць у медыятэцы.';

  @override
  String get mediaDuplicateAttached =>
      'Файл ужо быў у медыятэцы — далучаны існуючы экзэмпляр.';

  @override
  String get mediaViewerOpen => 'Адкрыць у праглядзе';

  @override
  String mediaLibrarySize(int count, String size) {
    return '$count файлаў · $size';
  }

  @override
  String get settingsMembersHint =>
      'Рэдагуйце профілі, фота і бачнасць дзён нараджэння. Новыя ўдзельнікі захоўваюцца ў сесіі праграмы.';

  @override
  String get settingsEventsHint =>
      'Рэдагуйце падзеі храналогіі, даты і месцы. Запісы пра дні нараджэння фарміруюцца з профіляў.';

  @override
  String get settingsAccountsHint =>
      'Стварайце акаўнты сям\'і з лагінам і паролем, прызначайце ролі і выдавайце гасцявыя спасылкі. Акаўнты захоўваюцца на серверы.';

  @override
  String get settingsAccountsLocalOnly =>
      'Акаўнты сінхранізуюцца з серверам: уваходзьце з тым жа лагінам і паролем на любой прыладзе. Лакальная копія дазваляе ўвайсці без сеткі.';

  @override
  String get settingsBackupsHint =>
      'Здымкі сямейнага архіва. Аднаўленне вяртае даныя да выбранага моманту.';

  @override
  String get memberAdd => 'Дадаць удзельніка';

  @override
  String get memberAdded => 'Удзельнік дададзены.';

  @override
  String get memberDeleted => 'Удзельнік выдалены.';

  @override
  String get memberDefaultName => 'Новы ўдзельнік';

  @override
  String get memberDefaultRole => 'Член сям\'і';

  @override
  String get memberDeleteConfirmTitle => 'Выдаліць гэтага ўдзельніка?';

  @override
  String get memberDeleteConfirmBody =>
      'Профіль, асабістыя фота і падзеі гэтага ўдзельніка знікнуць з альбома.';

  @override
  String get memberNameField => 'Імя';

  @override
  String get memberRoleField => 'Роля ў сям\'і';

  @override
  String get memberNicknameField => 'Мянушка';

  @override
  String get memberBirthdayField => 'Дзень нараджэння';

  @override
  String get memberBirthdayHint => 'ГГГГ-ММ-ДД';

  @override
  String get memberShowBirthday => 'Паказваць дзень нараджэння ў храналогіі';

  @override
  String get memberMainPhoto => 'Галоўнае фота';

  @override
  String get memberHabitsField => 'Звычкі, па адной у радку';

  @override
  String get memberQuotesField => 'Цытаты, па адной у радку';

  @override
  String get memberAccentField => 'Колер акцэнту';

  @override
  String get memberWishlistUrlField => 'Спасылка на вішліст';

  @override
  String get memberDelete => 'Выдаліць удзельніка';

  @override
  String get eventAdd => 'Дадаць падзею';

  @override
  String get eventAdded => 'Падзея дададзеная.';

  @override
  String get eventDeleted => 'Падзея выдаленая.';

  @override
  String get eventDefaultTitle => 'Новая падзея';

  @override
  String get eventDelete => 'Выдаліць падзею';

  @override
  String get eventDeleteConfirmTitle => 'Выдаліць гэтую падзею?';

  @override
  String get eventDeleteConfirmBody =>
      'Падзея і яе сувязі з медыя знікнуць з храналогіі.';

  @override
  String get eventTitleField => 'Назва падзеі';

  @override
  String get eventDateField => 'Дата';

  @override
  String get eventKindField => 'Тып падзеі';

  @override
  String get eventPlaceField => 'Месца';

  @override
  String get eventTextField => 'Апісанне';

  @override
  String get eventMemberField => 'Асноўны ўдзельнік';

  @override
  String get eventMemberNone => 'Без удзельніка';

  @override
  String get eventShowElapsed => 'Паказваць, колькі прайшло';

  @override
  String get eventKindMeeting => 'Знаёмства';

  @override
  String get eventKindDate => 'Сустрэча';

  @override
  String get eventKindWedding => 'Вяселле';

  @override
  String get eventKindChurch => 'Вянчанне';

  @override
  String get eventKindBirth => 'Нараджэнне';

  @override
  String get eventKindTrip => 'Вандроўка';

  @override
  String get eventKindMilestone => 'Важная падзея';

  @override
  String get photoPathHint => '/photos/фота.jpg або assets/photos/фота.jpg';

  @override
  String get settingsAdvancedJson => 'Пашыраны JSON';

  @override
  String get settingsApplyJson => 'Ужыць JSON';

  @override
  String get settingsInvalidJson => 'Няправільны JSON-аб\'ект.';

  @override
  String get accountAdd => 'Новы акаўнт';

  @override
  String get accountCreate => 'Стварыць акаўнт';

  @override
  String get accountCreated => 'Акаўнт створаны.';

  @override
  String get accountSaved => 'Акаўнт абноўлены.';

  @override
  String get accountDeleted => 'Акаўнт выдалены.';

  @override
  String get accountDelete => 'Выдаліць';

  @override
  String get accountDeleteConfirmTitle => 'Выдаліць гэты акаўнт?';

  @override
  String get accountDeleteConfirmBody =>
      'Чалавек адразу страціць доступ да сямейнага альбома.';

  @override
  String get accountLoginField => 'Лагін';

  @override
  String get accountNameField => 'Імя';

  @override
  String get accountPasswordField => 'Пароль';

  @override
  String get accountPasswordKeepHint =>
      'Пакіньце пустым, каб захаваць бягучы пароль';

  @override
  String get accountRoleField => 'Роля';

  @override
  String get accountRoleViewer => 'Назіральнік';

  @override
  String get accountRoleEditor => 'Рэдактар';

  @override
  String get accountRoleAdmin => 'Адміністратар';

  @override
  String get accountLoginInvalid =>
      'Лагін мусіць быць 2–32 сімвалы: лацінскія літары, лічбы, кропка, працяжнік або падкрэсліванне.';

  @override
  String get accountLoginRequirements =>
      '2–32 сімвалы: лацінскія літары, лічбы, кропка, працяжнік або падкрэсліванне.';

  @override
  String get accountPasswordRequirements => 'Мінімум 4 сімвалы.';

  @override
  String get accountRoleInvalid => 'Невядомая роля.';

  @override
  String get accountPasswordTooShort => 'Пароль занадта кароткі.';

  @override
  String get accountLoginTaken => 'Гэты лагін ужо заняты.';

  @override
  String get accountCannotDeleteSelf => 'Нельга выдаліць уласны акаўнт.';

  @override
  String get accountCannotChangeOwnRole => 'Нельга змяніць уласную ролю.';

  @override
  String get accountNotFound => 'Акаўнт не знойдзены.';

  @override
  String get accountForbidden => 'У вас недастаткова правоў.';

  @override
  String get accountUnauthenticated => 'Увайдзіце зноў.';

  @override
  String get accountOffline => 'Няма сувязі з серверам.';

  @override
  String get accountUnknownError => 'Штосьці пайшло не так.';

  @override
  String get accountServerUnavailable =>
      'Сервер акаўнтаў недаступны. Праверце злучэнне і паспрабуйце зноў.';

  @override
  String get accountServerError =>
      'Сервер акаўнтаў вярнуў памылку. Паспрабуйце пазней.';

  @override
  String get accountCreatedLocalOnly =>
      'Сервер недаступны: акаўнт захаваны толькі на гэтай прыладзе.';

  @override
  String get accountServerBadge => 'Сервер';

  @override
  String get accountMigratedOnServer => 'Акаўнт перанесены на сервер.';

  @override
  String get accountsEmpty => 'Акаўнтаў пакуль няма. Стварыце першы вышэй.';

  @override
  String get guestLinksTitle => 'Гасцявыя спасылкі';

  @override
  String get guestLinksHint =>
      'Гасцявая спасылка адкрывае альбом без акаўнта і аўтаматычна сканчаецца.';

  @override
  String get guestLinkLabelField => 'Для каго спасылка';

  @override
  String get guestLinkDaysField => 'Дзейнічае, дзён';

  @override
  String get guestLinkCreate => 'Стварыць гасцявую спасылку';

  @override
  String get guestLinkCopy => 'Скапіяваць токен';

  @override
  String get guestLinkCopied => 'Гасцявы токен скапіяваны.';

  @override
  String get guestLinkRevoke => 'Адклікаць';

  @override
  String get guestLinksEmpty => 'Гасцявых спасылак пакуль няма.';

  @override
  String get guestLinkStatusActive => 'Дзейнічае';

  @override
  String get guestLinkStatusExpired => 'Скончылася';

  @override
  String get guestLinkStatusRevoked => 'Адкліканая';

  @override
  String get backupCreate => 'Стварыць копію зараз';

  @override
  String get backupCreated => 'Здымак захаваны.';

  @override
  String get backupCreateFailed => 'Не ўдалося стварыць здымак.';

  @override
  String get backupEmpty => 'Копій пакуль няма — стварыце першую вышэй.';

  @override
  String get backupRestore => 'Аднавіць';

  @override
  String get backupRestoreConfirmTitle => 'Аднавіць гэты здымак?';

  @override
  String get backupRestoreConfirmBody =>
      'Змены пасля гэтага моманту знікнуць. Бягучы стан спачатку захаваецца ў копію, таму адкат можна вярнуць.';

  @override
  String get backupRestored => 'Даныя адноўленыя са здымка.';

  @override
  String get backupRestoreFailed => 'Не ўдалося аднавіць здымак.';

  @override
  String get backupDelete => 'Выдаліць';

  @override
  String get backupDeleteConfirmTitle => 'Выдаліць гэты здымак?';

  @override
  String get backupDeleteConfirmBody =>
      'Выдаліцца толькі рэзервовая копія, даныя сям\'і застануцца ранейшымі.';

  @override
  String get backupDeleted => 'Здымак выдалены.';

  @override
  String get backupExport => 'Захаваць бэкап';

  @override
  String get backupExportTitle => 'Стварэнне бэкапа';

  @override
  String get backupExportHint =>
      'Будзе створана поўная копія наладаў, профіляў, падзей, акаўнтаў, правоў доступу і медыятэкі. Знешнія спасылкі захоўваюцца без файлаў; паролі — толькі ў выглядзе солі і хеша.';

  @override
  String get backupIncludeMedia => 'Захоўваць фота і відэа';

  @override
  String get backupIncludeMediaHint =>
      'У бэкап трапяць копіі ўсіх лакальных медыяфайлаў, таму файл можа быць вялікім.';

  @override
  String get backupSaveDialogTitle => 'Куды захаваць бэкап сям\'і';

  @override
  String backupSavedTo(String path) {
    return 'Бэкап захаваны: $path';
  }

  @override
  String get backupExportCanceled => 'Захаванне бэкапа адменена.';

  @override
  String get backupImport => 'Імпартаваць бэкап';

  @override
  String get backupImportSuccess => 'Бэкап імпартаваны.';

  @override
  String get backupImportFailed => 'Не ўдалося імпартаваць гэты файл бэкапа.';

  @override
  String backupSummary(int count, int kept, String size) {
    return '$count з $kept · $size';
  }

  @override
  String backupRevision(int revision) {
    return 'рэвізія $revision';
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
      'Здымкі захоўваюцца лакальна і ўключаюць копіі файлаў медыятэкі.';

  @override
  String get dateFormatHint => 'ДД.ММ.ГГГГ';

  @override
  String get invalidDate => 'Увядзіце існуючую дату: ДД.ММ.ГГГГ';

  @override
  String get memberShowInCalendar =>
      'Адзначаць дзень нараджэння ў сямейным календары';

  @override
  String get memberBirthdayMedia => 'Фота і відэа да дня нараджэння';

  @override
  String get memberGalleryTitle => 'Фота і відэа';

  @override
  String get memberGalleryAddShot => 'Дадаць фота';

  @override
  String get memberGalleryRemoveShot => 'Выдаліць кадр';

  @override
  String get memberGalleryCaption => 'Подпіс кадра';

  @override
  String get memberWishlistTitle => 'Вішліст';

  @override
  String get memberWishlistAdd => 'Дадаць жаданне';

  @override
  String get memberWishlistEmpty => 'Жаданняў пакуль няма.';

  @override
  String get wishlistItemTitleField => 'Жаданне';

  @override
  String get wishlistItemUrlField => 'Спасылка на тавар';

  @override
  String get wishlistNoteField => 'Заўвага';

  @override
  String get wishlistRemove => 'Выдаліць жаданне';

  @override
  String get eventShowInCalendar => 'Адзначаць дату ў сямейным календары';

  @override
  String calendarBirthdayTitle(String name) {
    return 'Дзень нараджэння: $name';
  }

  @override
  String get mediaTitle => 'Фота і відэа';

  @override
  String get mediaAdd => 'Дадаць медыя';

  @override
  String get mediaAddByLink => 'Дадаць па спасылцы';

  @override
  String get mediaEmpty => 'Фота і відэа пакуль няма.';

  @override
  String get mediaSourceField => 'Шлях да файла або спасылка';

  @override
  String get mediaCaptionField => 'Подпіс';

  @override
  String get mediaTypeField => 'Тып';

  @override
  String get mediaTypeImage => 'Фота';

  @override
  String get mediaTypeVideo => 'Відэа';

  @override
  String get mediaPeopleField => 'Хто на фота';

  @override
  String get mediaEventsField => 'Звязаныя падзеі';

  @override
  String get mediaPeopleHint =>
      'Пазначанае фота з\'явіцца ў профілі кожнага выбранага чалавека.';

  @override
  String mediaPersonCaption(String name) {
    return 'Подпіс для $name';
  }

  @override
  String get mediaEventsHint => 'Звязанае фота з\'явіцца ў выбраных падзеях.';

  @override
  String get mediaFromLibrary => 'З медыятэкі';

  @override
  String get mediaLibraryEmpty =>
      'Медыятэка пустая. Загрузіце файлы ў «Налады → Медыятэка».';

  @override
  String get mediaCropField => 'Бачная частка для гэтай сувязі';

  @override
  String get videoPlay => 'Гуляць';

  @override
  String get videoPause => 'Пауза';

  @override
  String get videoMute => 'Выключыць гук';

  @override
  String get videoUnmute => 'Уключыць гук';

  @override
  String get videoError => 'Не ўдалося прайграць відэа.';

  @override
  String get mediaViewerPrevious => 'Папярэдняе медыя';

  @override
  String get mediaViewerNext => 'Наступнае медыя';

  @override
  String get videoConvert => 'Падтрыманы фармат';

  @override
  String get videoConverting => 'Падрыхтоўка відэа…';

  @override
  String get videoConverted => 'Відэа захаванае ў падтрыманым фармаце.';

  @override
  String get videoConvertFailed =>
      'Не ўдалося падрыхтаваць відэа ў падтрыманым фармаце.';

  @override
  String get videoConvertHint =>
      'Відэа аўтаматычна прыводзіцца да падтрыманага фармату.';

  @override
  String get mediaCropHint => 'Перацягвайце фота і маштабуйце дшчыпкам';

  @override
  String get mediaCropExpand => 'Разгарнуць';

  @override
  String get mediaCropDone => 'Гатова';

  @override
  String get mediaCropReset => 'Скінуць кадр';

  @override
  String get mediaRemove => 'Выдаліць медыя';

  @override
  String get mediaUpload => 'Загрузіць з прылады';

  @override
  String get mediaUploading => 'Загрузка…';

  @override
  String get mediaUploadHint =>
      'Фота і відэа да 20 МБ. Відэа аўтаматычна прыводзяцца да падтрыманага фармату. Файлы захоўваюцца лакальна на гэтай прыладзе.';

  @override
  String mediaUploadTooLarge(String name) {
    return 'Файл большы за 20 МБ: $name';
  }

  @override
  String get mediaUploadFailed => 'Не ўдалося загрузіць файл.';

  @override
  String get mediaUploadEmpty => 'Выбраны файл пусты.';

  @override
  String get mediaOpenLink => 'Адкрыць спасылку';

  @override
  String get mediaLinkCopied => 'Спасылка скапіяваная.';

  @override
  String timelineElapsedYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count гадоў',
      few: '$count гады',
      one: '$count год',
      zero: '$count гадоў',
    );
    return '$_temp0';
  }

  @override
  String timelineElapsedMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца',
      many: '$count месяцаў',
      few: '$count месяцы',
      one: '$count месяц',
      zero: '$count месяцаў',
    );
    return '$_temp0';
  }

  @override
  String timelineElapsedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дзён',
      few: '$count дні',
      one: '$count дзень',
      zero: '$count дзён',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Адмяніць';

  @override
  String get close => 'Закрыць';

  @override
  String get settingsNoAccess => 'У вас няма доступу да гэтага раздзела.';

  @override
  String get accountLocalAdmin => 'Лакальны адміністратар';

  @override
  String get accountSignIn => 'Увайсці';

  @override
  String get accountSignOut => 'Выйсці';

  @override
  String get accountSignInAction => 'Увайсці';

  @override
  String accountSignedIn(String name) {
    return 'Вы ўвайшлі як $name.';
  }

  @override
  String get accountSignedOut =>
      'Вы выйшлі. Актыўны рэжым лакальнага адміністратара.';

  @override
  String get accountLoginFailed => 'Няправільны лагін або пароль.';

  @override
  String get accountAccessTitle => 'Доступ';

  @override
  String get accountAccessHint =>
      'Выберыце профілі і падзеі, якія бачыць гэты акаўнт.';

  @override
  String get accountAllMembers => 'Усе члены сям\'і';

  @override
  String get accountVisibleEvents => 'Бачныя падзеі';

  @override
  String mediaUsagePersonTag(String name) {
    return '$name — пазначаны на фота';
  }

  @override
  String get mediaUnused => 'Не выкарыстоўваецца';

  @override
  String mediaOnlyUnused(int count) {
    return 'Толькі невыкарыстаныя ($count)';
  }

  @override
  String get mediaUseInProfile => 'Выкарыстаць у профілі';

  @override
  String get mediaUseTitle => 'Паказаць файл у профілях';

  @override
  String get mediaUseNoMembers =>
      'Няма членаў сям\'і, да якіх можна прывязаць файл.';

  @override
  String get mediaUseApply => 'Ужыць';

  @override
  String get mediaUsed => 'Файл цяпер паказваецца ў выбраных профілях.';

  @override
  String get settingsTabLanguage => 'Мова';

  @override
  String get settingsLanguage => 'Мова інтэрфейсу';

  @override
  String get settingsLanguageHint => 'Выбар захоўваецца на гэтай прыладзе.';

  @override
  String get settingsLanguageSystem => 'Як у сістэме';

  @override
  String get settingsLanguageRussian => 'Руская';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageBelarusian => 'Беларуская';

  @override
  String get settingsLanguageUkrainian => 'Українська';

  @override
  String get familyCloudTitle => 'Сям\'я ў воблаку';

  @override
  String get familyCloudHint =>
      'Стварыце сям\'ю, каб сінхранізаваць альбомы паміж прыладамі, або далучыцеся па кодзе запрашэння.';

  @override
  String get familyCloudCreateTitle => 'Стварыць сям\'ю';

  @override
  String get familyCloudNameLabel => 'Назва сям\'і';

  @override
  String get familyCloudNameHint => 'Напрыклад: Наша вялікая сям\'я';

  @override
  String get familyCloudCreateAction => 'Стварыць і падключыць';

  @override
  String get familyCloudJoinTitle => 'Далучыцца па кодзе';

  @override
  String get familyCloudCodeLabel => 'Код запрашэння';

  @override
  String get familyCloudCodeHint => '8 сімвалаў, напрыклад AB2CD3EF';

  @override
  String get familyCloudJoinAction => 'Далучыцца';

  @override
  String get familyCloudInvalidCode =>
      'Код павінен складацца з 8 літар або лічбаў.';

  @override
  String get familyCloudJoinNotFound =>
      'Код запрашэння не знойдзены або скончыўся.';

  @override
  String get familyCloudCreated => 'Сям\'я створана.';

  @override
  String get familyCloudJoined => 'Вы далучыліся да сям\'і.';

  @override
  String get familyCloudError =>
      'Не ўдалося выканаць запыт. Праверце злучэнне і паспрабуйце зноў.';

  @override
  String get familyCloudRetry => 'Паспрабаваць зноў';

  @override
  String get familyCloudOwnerBadge => 'Уладальнік';

  @override
  String get familyCloudPremiumActive => 'Прэміум актыўны';

  @override
  String get familyCloudPremiumFree => 'Бясплатны план';

  @override
  String get familyCloudInviteTitle => 'Запрашэнне ў сям\'ю';

  @override
  String get familyCloudInviteHint =>
      'Падзяліцеся кодам: яго можна выкарыстаць адзін раз на чалавека.';

  @override
  String get familyCloudInviteCreate => 'Стварыць код запрашэння';

  @override
  String get familyCloudInviteCopied => 'Код запрашэння скапіраваны.';

  @override
  String get familyCloudNameRequired => 'Назва сям\'і не можа быць пустой.';

  @override
  String familyCloudId(String id) {
    return 'ID: $id';
  }

  @override
  String get familyCloudPrivacyTitle => 'Даныя і прыватнасць';

  @override
  String get familyCloudPrivacyHint =>
      'Вашыя фота застаюцца на прыладзе. Выдаленне даных сям\'і сцірае файлы і запісы з воблака для ўсіх удзельнікаў.';

  @override
  String get familyCloudDisconnect => 'Адключыць гэтую прыладу';

  @override
  String get familyCloudDisconnectConfirm =>
      'Адключыць прыладу ад сям\'і? Лакальны архіў застанецца, даныя ў воблаку не выдаляцца.';

  @override
  String get familyCloudDisconnected => 'Прылада адключана ад сям\'і.';

  @override
  String get familyCloudDisconnectOwnerBlocked =>
      'Вы ўладальнік, і ў сям\'і яшчэ ёсць іншыя ўдзельнікі. Адключэнне недаступнае — выдаліце даныя сям\'і або пакіньце прыладу падключанай.';

  @override
  String get familyCloudDeleteCloud => 'Выдаліць даныя сям\'і з воблака';

  @override
  String get familyCloudDeleteCloudConfirm =>
      'Усе файлы, падзеі і ўдзельнікі сям\'і будуць беззваротна выдаленыя з воблака. Адмяніць гэта нельга. Лакальны архіў застанецца на прыладзе.';

  @override
  String get familyCloudDeleteCloudDone => 'Даныя сям\'і выдаленыя з воблака.';

  @override
  String get commonDelete => 'Выдаліць';

  @override
  String get mediaLocalOnlyNotice =>
      'Захавана толькі на гэтай прыладзе: хмарная сям\'я не падключана. Падключыце яе ў Наладах → «Сям\'я ў воблаку», каб фота сінхранізаваліся.';

  @override
  String mediaUploadAllLocal(int count) {
    return 'Загрузіць усё лакальнае ($count)';
  }

  @override
  String mediaUploadAllProgress(int done, int total) {
    return 'Загрузка $done з $total…';
  }

  @override
  String mediaUploadAllDone(int count) {
    return 'Загружана ў воблака: $count';
  }

  @override
  String mediaUploadAllFailed(int count) {
    return 'Не ўдалося загрузіць: $count';
  }

  @override
  String get mediaUploadUnavailableHint =>
      'Гэтыя файлы захоўваліся толькі на іншай прыладзе або зніклі пасля пераўсталёўкі — дадайце іх зноў.';

  @override
  String mediaOutboxRetry(int count) {
    return 'У чарзе: $count — адправіць';
  }

  @override
  String get syncStatusLoading => 'Сінхранізацыя…';

  @override
  String get syncStatusSaving => 'Захаванне…';

  @override
  String get syncStatusSaved => 'Захавана';

  @override
  String get syncStatusError => 'Няма сувязі';

  @override
  String get editModeEnter => 'Рэжым рэдагавання';

  @override
  String get editModeExit => 'Выйсці з рэжыму рэдагавання';

  @override
  String get editModeBanner =>
      'Рэжым рэдагавання: націсніце на аловак каля карткі';

  @override
  String get editModeDone => 'Гатова';

  @override
  String get adminOnlyAction => 'Толькі адміністратар';

  @override
  String get adminOnlyDeleteHint =>
      'Выдаляць падзеі і ўдзельнікаў можа толькі адміністратар.';

  @override
  String get adminOnlySettingsHint =>
      'Рэзервовыя копіі, акаўнты і вяртанне да дэма-даных даступныя толькі адміністратару.';

  @override
  String get accountEntryTitle => 'Акаўнт';

  @override
  String get accountAuthTitle => 'Уваход або стварэнне акаўнта';

  @override
  String get accountSignInTab => 'Уваход';

  @override
  String get accountSignUpTab => 'Рэгістрацыя';

  @override
  String get accountSignInSubtitle =>
      'Увайдзіце, каб загрузіць даныя сваёй сям\'і.';

  @override
  String get accountSignUpHint =>
      'Новы акаўнт атрымае ролю назіральніка. Адміністратар зможа змяніць яе пазней.';

  @override
  String get accountFirstAdminHint =>
      'Першы акаўнт сям\'і стане адміністратарам.';

  @override
  String accountSessionTitle(String name) {
    return 'Вы ўвайшлі як $name';
  }

  @override
  String get accountManage => 'Кіраванне акаўнтамі';

  @override
  String get accountSwitch => 'Змяніць акаўнт';

  @override
  String get calendarViewMonth => 'Месяц';

  @override
  String get calendarViewYear => 'Год';

  @override
  String get calendarToday => 'Сёння';

  @override
  String get calendarAddEvent => 'Дадаць падзею';

  @override
  String get calendarAddDate => 'Дадаць дату';

  @override
  String get calendarEntryTitle => 'Дата ў календары';

  @override
  String get calendarEntryTitleField => 'Назва';

  @override
  String get calendarEntryNoteField => 'Заўвага';

  @override
  String get calendarEntryDateField => 'Дата';

  @override
  String get calendarEntryRecurring => 'Паўтараць кожны год';

  @override
  String get calendarEntryHint =>
      'Дата з\'явіцца толькі ў календары і не трапіць у таймлайн.';

  @override
  String get calendarEntrySaved => 'Дата дададзена ў каляндар.';

  @override
  String get calendarEntryDeleted => 'Дата выдалена з календара.';

  @override
  String get calendarEntryEdit => 'Змяніць дату';

  @override
  String get calendarEntryDelete => 'Выдаліць дату';

  @override
  String get calendarEntryDeleteConfirmTitle => 'Выдаліць гэтую дату?';

  @override
  String get calendarEntryDeleteConfirmBody =>
      'Дата знікне з календара. Падзеі таймлайна не закранаюцца.';

  @override
  String get calendarEntryDefaultTitle => 'Дата';

  @override
  String get calendarLegendEvent => 'Падзеі';

  @override
  String get calendarLegendBirthday => 'Дні нараджэння';

  @override
  String get eventShowInTimeline => 'Паказваць у таймлайне';

  @override
  String get eventRecurringYearly => 'Паўтараць кожны год';

  @override
  String get eventCalendarOnlyBadge => 'Толькі каляндар';

  @override
  String get eventMemberHint =>
      'Уплывае на доступ і профіль. Некалькі чалавек на фота адзначайце ў «Хто на фота».';

  @override
  String get eventNewBadge => 'Новае';

  @override
  String get timelineOrderLabel => 'Парадак';

  @override
  String get timelineOrderOldest => 'Спачатку старыя';

  @override
  String get timelineOrderNewest => 'Спачатку новыя';

  @override
  String get profileStories => 'Цікавае';

  @override
  String get profileStoriesEmpty => 'Пакуль няма гісторый.';

  @override
  String get profileStoriesAdd => 'Дадаць гісторыю';

  @override
  String get profileStoryDelete => 'Выдаліць гісторыю';

  @override
  String get profileStoryTitleField => 'Загаловак';

  @override
  String get profileStoryTextField => 'Тэкст гісторыі';

  @override
  String get readMore => 'Чытаць далей';

  @override
  String get readLess => 'Згарнуць';

  @override
  String get memberEditorTitle => 'Удзельнік';

  @override
  String get eventEditorTitle => 'Падзея';

  @override
  String get memberEdit => 'Рэдагаваць удзельніка';

  @override
  String get eventEdit => 'Рэдагаваць падзею';

  @override
  String get profileEdit => 'Рэдагаваць профіль';

  @override
  String get familyCloudInviteCopy => 'Капіраваць код';

  @override
  String get familyCloudInviteCopyHint =>
      'Браузер не дазволіў схапіраваць аўтаматычна: націсніце значок капіравання побач з кодам.';

  @override
  String get backupDownloadStarted =>
      'Файл рэзервовай копіі спампаваны браўзерам.';

  @override
  String get backupImportWrongFile =>
      'Выберыце файл рэзервовай копіі OurTree (.json або .ourtree).';

  @override
  String backupImportTooLarge(int mb) {
    return 'Файл большы за $mb МБ і можа не змясціцца ў памяць браўзера. Захавайце копію без медыя і паспрабуйце зноў.';
  }

  @override
  String get backupImportUnreadable =>
      'Не ўдалося прачытаць выбраны файл. Калі ён у iCloud, спачатку спампуйце яго на прыладу.';

  @override
  String backupImportPartial(int count) {
    return 'Не ўдалося аднавіць файлаў медыя: $count.';
  }

  @override
  String get demoEditNoticeTitle => 'Змены застануцца на гэтай прыладзе';

  @override
  String get demoEditNoticeBody =>
      'Архіў не будзе захаваны ў воблаку. Стварыце сям\'ю і ўвайдзіце ў акаўнт, каб даныя захоўваліся і былі даступныя на іншых прыладах.';

  @override
  String get demoEditNoticeAction => 'Стварыць сям\'ю';

  @override
  String get demoEditNoticeLater => 'Пазней';

  @override
  String get demoLocalOnlyNotice =>
      'Толькі на гэтай прыладзе: няма сінхранізацыі з воблакам';

  @override
  String get accountNoFamilyAttached =>
      'Гэты акаўнт пакуль не звязаны з сям\'ёй — падключыцеся па кодзе запрашэння ў «Агульныя налады → Воблака».';

  @override
  String get aboutTitle => 'Пра праграму';

  @override
  String get aboutHint => 'Версія, распрацоўшчык, дакументы і ліцэнзіі.';

  @override
  String get aboutDescription =>
      'OurTree — сямейны альбом: профілі, таймлайн, каляндар і медыятэка. Даныя захоўваюцца на прыладзе і сінхранізуюцца з воблакам, калі сям\'я падключана.';

  @override
  String get aboutVersion => 'Версія';

  @override
  String aboutVersionLabel(String version) {
    return 'Версія $version';
  }

  @override
  String get aboutPlatform => 'Платформа';

  @override
  String get aboutDeveloper => 'Распрацоўшчык';

  @override
  String get aboutContact => 'Звязацца';

  @override
  String get aboutPrivacy => 'Палітыка прыватнасці';

  @override
  String get aboutTerms => 'Умовы выкарыстання';

  @override
  String get aboutLicenses => 'Ліцэнзіі адкрытага ПЗ';

  @override
  String get aboutChangelogTitle => 'Што новага';

  @override
  String get aboutChangelog1 =>
      'Праўкі з іншых прылад прыходзяць без перазапуску';

  @override
  String get aboutChangelog2 =>
      'Фота аўтаматычна сыходзяць у воблака ў створанай сям\'і';

  @override
  String get aboutChangelog3 =>
      'Імпарт рэзервовай копіі працуе на iPhone (вэб-версія)';

  @override
  String get aboutChangelog4 => 'Код запрашэння капіруецца аўтаматычна';

  @override
  String get aboutChangelog5 =>
      'Push-апавяшчэнні пра дні нараджэння, падзеі і змены сям\'і';

  @override
  String get aboutSupport => 'Падтрымка';

  @override
  String get aboutFamilyId => 'ID сям\'і';

  @override
  String get aboutCopyFamilyId => 'Скапіраваць ID сям\'і';

  @override
  String get aboutFamilyIdCopied => 'ID сям\'і скапіраваны.';

  @override
  String get aboutNoFamily =>
      'Сям\'я яшчэ не падключана: падключыце яе ў «Агульныя налады → Воблака».';

  @override
  String aboutCopyright(int year) {
    return '© $year OurTree';
  }

  @override
  String get aboutLinkFailed => 'Не ўдалося адкрыць спасылку.';

  @override
  String get notificationsTitle => 'Апавяшчэнні';

  @override
  String get notificationsHint =>
      'Дні нараджэння, падзеі календара і змены сям\'і.';

  @override
  String get notificationsStatusTitle => 'Стан на гэтай прыладзе';

  @override
  String get notificationsEnable => 'Уключыць апавяшчэнні';

  @override
  String get notificationsDisable => 'Адключыць';

  @override
  String get notificationsRefresh => 'Абнавіць токен';

  @override
  String get notificationsEnabled =>
      'Апавяшчэнні ўключаны: напаміны і змены сям\'і будуць прыходзіць на гэтую прыладу.';

  @override
  String get notificationsDisabled =>
      'Апавяшчэнні выключаны. Уключыце іх, каб атрымліваць напаміны.';

  @override
  String get notificationsDenied =>
      'Апавяшчэнні заблакаваны ў браўзеры або наладах сістэмы. Дазвольце іх для праграмы і паспрабуйце зноў.';

  @override
  String get notificationsNoFamily =>
      'Спачатку падключыце сям\'ю: напаміны прыходзяць па архіве вашай сям\'і.';

  @override
  String get notificationsFailed => 'Не ўдалося ўключыць апавяшчэнні.';

  @override
  String get notificationsFailedNoKey =>
      'У гэтай зборцы няма ключа web-push (FIREBASE_VAPID_KEY). Перасабжыце з --dart-define-from-file.';

  @override
  String get notificationsFailedPermission => 'Браўзер не выдаў дазвол.';

  @override
  String get notificationsFailedToken => 'Не ўдалося атрымаць токен прылады.';

  @override
  String get notificationsPrefsTitle => 'Што дасылаць';

  @override
  String get notificationsBirthdays => 'Дні нараджэння';

  @override
  String get notificationsBirthdaysHint => 'Напярэдадні і ў сам дзень.';

  @override
  String get notificationsCalendar => 'Падзеі календара';

  @override
  String get notificationsCalendarHint =>
      'Падзеі з адзнакай «паказваць у календары».';

  @override
  String get notificationsFamilyUpdates => 'Змены сям\'і';

  @override
  String get notificationsFamilyUpdatesHint =>
      'Калі хтосьці правіць агульны архіў.';

  @override
  String get notificationsIosHint =>
      'На iPhone апавяшчэнні працуюць толькі ў праграме, дададзенай на экран «Хатні» (iOS 16.4+).';

  @override
  String get notificationsUpcoming => 'Бліжэйшае';

  @override
  String get notificationsUpcomingEmpty =>
      'У бліжэйшыя 7 дзён дзён нараджэння і падзей няма.';

  @override
  String get settingsResetLocal => 'Скінуць да версіі з воблака';

  @override
  String get settingsResetLocalHint =>
      'Замяніць лакальныя праўкі данымі сям\'і';

  @override
  String get settingsResetLocalTitle => 'Замяніць лакальныя даныя?';

  @override
  String get settingsResetLocalConfirmBody =>
      'Лакальныя праўкі будуць заменены бягучай версіяй сям\'і з воблака. Дэма-архіў у падключанай сям\'і не захоўваецца.';

  @override
  String get settingsResetLocalAction => 'Замяніць';

  @override
  String get settingsResetLocalDone =>
      'Лакальныя даныя заменены версіяй з воблака.';

  @override
  String get mediaSelectHint => 'Доўгае націсканне на файл — выбраць некалькі.';

  @override
  String mediaSelectedCount(int count) {
    return 'Выбрана: $count';
  }

  @override
  String get mediaSelectAll => 'Выбраць усе';

  @override
  String get mediaSelectNone => 'Зняць выбар';

  @override
  String get mediaDeleteSelected => 'Выдаліць выбраныя';

  @override
  String get mediaDeleteManyTitle => 'Выдаліць выбраныя файлы?';

  @override
  String mediaDeleteManyBody(int count) {
    return 'Файлы ($count) будуць выдалены з архіва і з воблака.';
  }

  @override
  String mediaDeleteManyDone(int count) {
    return 'Выдалена файлаў: $count';
  }

  @override
  String get demoAfterLoginNotice =>
      'Вы ўвайшлі ў акаўнт, але ў праграме ўсё яшчэ дэма-даныя. Адкрыйце «Сям\'я ў воблаку», каб загрузіць даныя вашай сям\'і.';

  @override
  String get demoAfterLoginAction => 'Адкрыць';
}
