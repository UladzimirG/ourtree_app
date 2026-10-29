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
  String get settingsFamilySubtitle => 'Падзагаловак сям\'і';

  @override
  String get settingsFamilySubtitleHint =>
      'Паказваецца пад назвай сям\'і на галоўнай старонцы';

  @override
  String get settingsDataSource => 'Крыніца даных';

  @override
  String get settingsArchiveSource =>
      'Сямейны архіў з дэманстрацыйных файлаў праграмы';

  @override
  String get settingsReload => 'Абнавіць даныя';

  @override
  String get settingsReloadStarted => 'Даныя сям\'і абноўленыя.';

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
      'Стварайце акаўнты сям\'і, прызначайце ролі і выдавайце гасцявыя спасылкі.';

  @override
  String get settingsAccountsLocalOnly =>
      'Акаўнты, правы доступу і гасцявыя спасылкі захоўваюцца лакальна і перажываюць перазапуск і копіі.';

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
  String get eventMemberField => 'Звязаны ўдзельнік';

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
  String get mediaCropX => 'Па гарызанталі';

  @override
  String get mediaCropY => 'Па вертыкалі';

  @override
  String get mediaZoom => 'Маштаб';

  @override
  String get mediaCropHint =>
      'Перацягніце фота і выкарыстайце жэст маштабавання';

  @override
  String get mediaCropReset => 'Скінуць кадр';

  @override
  String get mediaZoomIn => 'Наблізіць';

  @override
  String get mediaZoomOut => 'Аддаліць';

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
}
