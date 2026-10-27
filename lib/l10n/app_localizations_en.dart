// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OurTree App';

  @override
  String get welcomeTitle => 'Welcome to OurTree';

  @override
  String get welcomeMessage =>
      'This is a clean Flutter project with localizations for ru/en and Riverpod state management.';

  @override
  String get homeFamilyLabel => 'Family';

  @override
  String get homeSubtitle =>
      'A place for your family stories, photos and dates.';

  @override
  String get homeOverviewTitle => 'Overview';

  @override
  String homeMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '$count member',
      zero: 'No members yet',
    );
    return '$_temp0';
  }

  @override
  String homeEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '$count event',
      zero: 'No events yet',
    );
    return '$_temp0';
  }

  @override
  String get homeLoading => 'Loading family data…';

  @override
  String get homeLoadError => 'We couldn\'t load the family data.';

  @override
  String get homeRetry => 'Try again';

  @override
  String get settingsTitle => 'Family settings';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navFamily => 'Family';

  @override
  String get timelineEyebrow => 'Family album';

  @override
  String get timelineTitle => 'Life timeline';

  @override
  String get timelineLede =>
      'A thread of events with our meetings, holidays and trips.';

  @override
  String get timelineEmpty => 'The timeline is still empty.';

  @override
  String timelineTogetherYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Together for $count years',
      one: 'Together for $count year',
      zero: 'Together since this day',
    );
    return '$_temp0';
  }

  @override
  String get mediaPlaceholder => 'Photo or video';

  @override
  String get familyEyebrow => 'Seven branches of one tree';

  @override
  String get familyTitle => 'Family and profiles';

  @override
  String get familyLede => 'Tap a card to open a person\'s home album.';

  @override
  String get familyEmpty => 'No family members yet.';

  @override
  String memberAgeYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '$count year',
      zero: 'Less than a year',
    );
    return '$_temp0';
  }

  @override
  String get calendarEyebrow => 'Don\'t forget the important dates';

  @override
  String get calendarTitle => 'Family calendar';

  @override
  String get calendarLede =>
      'Days with family events are highlighted. Tap a day to see what happened.';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarNoEvents => 'No events on this day.';

  @override
  String get profileBack => 'All family';

  @override
  String get profileAbout => 'About me';

  @override
  String get profileWishlist => 'Wishlist';

  @override
  String get profileWishlistEmpty => 'The wishlist is still empty.';

  @override
  String get profileGallery => 'Mini gallery';

  @override
  String get profileGalleryEmpty => 'No photos yet.';

  @override
  String get profileNotFound => 'This profile is not in the family album yet.';

  @override
  String get profileCopyWishlistLink => 'Copy wishlist link';

  @override
  String get profileLinkCopied => 'Wishlist link copied.';

  @override
  String get settingsFamilyName => 'Family name';

  @override
  String get settingsDataSource => 'Data source';

  @override
  String get settingsArchiveSource =>
      'Family archive from assets/data/family.json';

  @override
  String get settingsReload => 'Reload data';

  @override
  String get settingsReloadStarted => 'Family data reloaded.';

  @override
  String get settingsEditingSoon => 'Editing will appear in the next step.';

  @override
  String get settingsFamilyPhoto => 'Family photo';

  @override
  String get settingsFamilyPhotoHint =>
      '/photos/family.jpg or assets/photos/family.jpg';

  @override
  String get settingsPhotoPreview => 'Photo preview';

  @override
  String get settingsClearPhoto => 'Clear photo';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsShowFamilyPhoto => 'Show family photo in the header';

  @override
  String get settingsShowEventPhotos => 'Show photos in the timeline';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String get settingsNameRequired => 'Family name cannot be empty.';

  @override
  String get settingsLocalOnly => 'Changes are saved locally on this device.';

  @override
  String get settingsTabFamily => 'Family';

  @override
  String get settingsTabMembers => 'Members';

  @override
  String get settingsTabEvents => 'Events';

  @override
  String get settingsTabAccounts => 'Accounts';

  @override
  String get settingsTabBackups => 'Backups';

  @override
  String get settingsTabMedia => 'Media library';

  @override
  String get settingsMediaHint =>
      'One place for every photo and video. Videos are converted to a supported format automatically. Descriptions and cropping are set individually for each member or event.';

  @override
  String get mediaLibraryTitle => 'Family media library';

  @override
  String get mediaLibraryUpload => 'Upload files';

  @override
  String get mediaLibraryAddLink => 'Add by link';

  @override
  String get mediaAssetName => 'File name';

  @override
  String get mediaAssetType => 'Type';

  @override
  String get mediaUsageTitle => 'Where it is used';

  @override
  String get mediaUsageNone => 'Not linked to anyone yet.';

  @override
  String mediaUsageAvatar(String name) {
    return '$name — avatar';
  }

  @override
  String mediaUsageBirthday(String name) {
    return '$name — birthday';
  }

  @override
  String mediaUsageGallery(String name) {
    return '$name — gallery';
  }

  @override
  String mediaUsageEvent(String name) {
    return 'Event \"$name\"';
  }

  @override
  String get mediaUsageFamilyPhoto => 'Family photo in the header';

  @override
  String get mediaStoredLocally => 'Stored locally';

  @override
  String get mediaDeleteTitle => 'Delete this file from the library?';

  @override
  String get mediaDeleteBody =>
      'The file and all its links to members and events will be removed. The action cannot be undone.';

  @override
  String get mediaDelete => 'Delete';

  @override
  String get mediaDeleted => 'File deleted from the library.';

  @override
  String get mediaDuplicateFound =>
      'This file is already in the media library.';

  @override
  String get mediaDuplicateAttached =>
      'This file was already in the library — the existing copy was attached.';

  @override
  String get mediaViewerOpen => 'Open in viewer';

  @override
  String mediaLibrarySize(int count, String size) {
    return '$count files · $size';
  }

  @override
  String get settingsMembersHint =>
      'Edit profiles, photos and birthday visibility. New members are saved in the app session.';

  @override
  String get settingsEventsHint =>
      'Edit timeline events, dates and places. Birthday entries are generated from member profiles.';

  @override
  String get settingsAccountsHint =>
      'Create family accounts, assign roles and issue guest links.';

  @override
  String get settingsAccountsLocalOnly =>
      'Accounts, access rights and guest links are stored locally and survive restarts and backups.';

  @override
  String get settingsBackupsHint =>
      'Snapshots of the family archive. Restoring rolls the data back to the selected moment.';

  @override
  String get memberAdd => 'Add member';

  @override
  String get memberAdded => 'Member added.';

  @override
  String get memberDeleted => 'Member removed.';

  @override
  String get memberDefaultName => 'New member';

  @override
  String get memberDefaultRole => 'Family member';

  @override
  String get memberDeleteConfirmTitle => 'Remove this member?';

  @override
  String get memberDeleteConfirmBody =>
      'The profile, personal photos and events tied to this member will be removed from the album.';

  @override
  String get memberNameField => 'Name';

  @override
  String get memberRoleField => 'Role in the family';

  @override
  String get memberNicknameField => 'Nickname';

  @override
  String get memberBirthdayField => 'Birthday';

  @override
  String get memberBirthdayHint => 'YYYY-MM-DD';

  @override
  String get memberShowBirthday => 'Show birthday on the timeline';

  @override
  String get memberMainPhoto => 'Main photo';

  @override
  String get memberHabitsField => 'Habits, one per line';

  @override
  String get memberQuotesField => 'Quotes, one per line';

  @override
  String get memberAccentField => 'Accent color';

  @override
  String get memberWishlistUrlField => 'Wishlist link';

  @override
  String get memberDelete => 'Remove member';

  @override
  String get eventAdd => 'Add event';

  @override
  String get eventAdded => 'Event added.';

  @override
  String get eventDeleted => 'Event removed.';

  @override
  String get eventDefaultTitle => 'New event';

  @override
  String get eventDelete => 'Remove event';

  @override
  String get eventDeleteConfirmTitle => 'Remove this event?';

  @override
  String get eventDeleteConfirmBody =>
      'The event and its media references will disappear from the timeline.';

  @override
  String get eventTitleField => 'Event title';

  @override
  String get eventDateField => 'Date';

  @override
  String get eventKindField => 'Event type';

  @override
  String get eventPlaceField => 'Place';

  @override
  String get eventTextField => 'Description';

  @override
  String get eventMemberField => 'Related member';

  @override
  String get eventMemberNone => 'No member';

  @override
  String get eventShowElapsed => 'Show time elapsed';

  @override
  String get eventKindMeeting => 'Meeting';

  @override
  String get eventKindDate => 'Date';

  @override
  String get eventKindWedding => 'Wedding';

  @override
  String get eventKindChurch => 'Church wedding';

  @override
  String get eventKindBirth => 'Birth';

  @override
  String get eventKindTrip => 'Trip';

  @override
  String get eventKindMilestone => 'Milestone';

  @override
  String get photoPathHint => '/photos/photo.jpg or assets/photos/photo.jpg';

  @override
  String get settingsAdvancedJson => 'Advanced JSON';

  @override
  String get settingsApplyJson => 'Apply JSON';

  @override
  String get settingsInvalidJson => 'Invalid JSON object.';

  @override
  String get accountAdd => 'New account';

  @override
  String get accountCreate => 'Create account';

  @override
  String get accountCreated => 'Account created.';

  @override
  String get accountSaved => 'Account updated.';

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get accountDelete => 'Delete';

  @override
  String get accountDeleteConfirmTitle => 'Delete this account?';

  @override
  String get accountDeleteConfirmBody =>
      'The person will lose access to the family album immediately.';

  @override
  String get accountLoginField => 'Login';

  @override
  String get accountNameField => 'Name';

  @override
  String get accountPasswordField => 'Password';

  @override
  String get accountPasswordKeepHint =>
      'Leave empty to keep the current password';

  @override
  String get accountRoleField => 'Role';

  @override
  String get accountRoleViewer => 'Viewer';

  @override
  String get accountRoleEditor => 'Editor';

  @override
  String get accountRoleAdmin => 'Admin';

  @override
  String get accountLoginInvalid =>
      'Login must be 2–32 characters: Latin letters, digits, dot, dash or underscore.';

  @override
  String get accountLoginRequirements =>
      '2–32 characters: Latin letters, digits, dot, dash or underscore.';

  @override
  String get accountPasswordRequirements => 'At least 4 characters.';

  @override
  String get accountRoleInvalid => 'Unknown role.';

  @override
  String get accountPasswordTooShort => 'Password is too short.';

  @override
  String get accountLoginTaken => 'This login is already taken.';

  @override
  String get accountCannotDeleteSelf => 'You cannot delete your own account.';

  @override
  String get accountCannotChangeOwnRole => 'You cannot change your own role.';

  @override
  String get accountNotFound => 'Account not found.';

  @override
  String get accountForbidden => 'You do not have enough rights.';

  @override
  String get accountUnauthenticated => 'Please sign in again.';

  @override
  String get accountOffline => 'No connection to the server.';

  @override
  String get accountUnknownError => 'Something went wrong.';

  @override
  String get accountsEmpty => 'No accounts yet. Create the first one above.';

  @override
  String get guestLinksTitle => 'Guest links';

  @override
  String get guestLinksHint =>
      'A guest link opens the album without an account and expires automatically.';

  @override
  String get guestLinkLabelField => 'Who is the link for';

  @override
  String get guestLinkDaysField => 'Valid for, days';

  @override
  String get guestLinkCreate => 'Create guest link';

  @override
  String get guestLinkCopy => 'Copy token';

  @override
  String get guestLinkCopied => 'Guest token copied.';

  @override
  String get guestLinkRevoke => 'Revoke';

  @override
  String get guestLinksEmpty => 'No guest links yet.';

  @override
  String get guestLinkStatusActive => 'Active';

  @override
  String get guestLinkStatusExpired => 'Expired';

  @override
  String get guestLinkStatusRevoked => 'Revoked';

  @override
  String get backupCreate => 'Create snapshot now';

  @override
  String get backupCreated => 'Snapshot saved.';

  @override
  String get backupCreateFailed => 'Could not create a snapshot.';

  @override
  String get backupEmpty => 'No snapshots yet — create one above.';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupRestoreConfirmTitle => 'Restore this snapshot?';

  @override
  String get backupRestoreConfirmBody =>
      'Changes made after this moment will disappear. The current state is saved in a backup first, so the rollback can be undone.';

  @override
  String get backupRestored => 'Data restored from the snapshot.';

  @override
  String get backupRestoreFailed => 'Could not restore the snapshot.';

  @override
  String get backupDelete => 'Delete';

  @override
  String get backupDeleteConfirmTitle => 'Delete this snapshot?';

  @override
  String get backupDeleteConfirmBody =>
      'Only the backup copy will be removed; current family data stays untouched.';

  @override
  String get backupDeleted => 'Snapshot deleted.';

  @override
  String get backupExport => 'Save backup';

  @override
  String get backupExportTitle => 'Create a backup';

  @override
  String get backupExportHint =>
      'A complete copy of settings, profiles, events, accounts, access rights and the media library will be created. External links are saved without files; passwords are stored only as salted hashes.';

  @override
  String get backupIncludeMedia => 'Include photos and videos';

  @override
  String get backupIncludeMediaHint =>
      'The backup will contain copies of all local media files and may be large.';

  @override
  String get backupSaveDialogTitle => 'Where to save the family backup';

  @override
  String backupSavedTo(String path) {
    return 'Backup saved: $path';
  }

  @override
  String get backupExportCanceled => 'Saving the backup was canceled.';

  @override
  String get backupImport => 'Import backup';

  @override
  String get backupImportSuccess => 'Backup imported.';

  @override
  String get backupImportFailed => 'Could not import this backup file.';

  @override
  String backupSummary(int count, int kept, String size) {
    return '$count of $kept · $size';
  }

  @override
  String backupRevision(int revision) {
    return 'revision $revision';
  }

  @override
  String backupSizeBytes(int size) {
    return '$size B';
  }

  @override
  String backupSizeKb(String size) {
    return '$size KB';
  }

  @override
  String backupSizeMb(String size) {
    return '$size MB';
  }

  @override
  String get backupLocalOnly =>
      'Snapshots are stored locally and include copies of media files.';

  @override
  String get dateFormatHint => 'DD.MM.YYYY';

  @override
  String get invalidDate => 'Enter an existing date: DD.MM.YYYY';

  @override
  String get memberShowInCalendar => 'Mark birthday in the family calendar';

  @override
  String get memberBirthdayMedia => 'Birthday photos and videos';

  @override
  String get memberGalleryTitle => 'Photos and videos';

  @override
  String get memberGalleryAddShot => 'Add photo';

  @override
  String get memberGalleryRemoveShot => 'Remove shot';

  @override
  String get memberGalleryCaption => 'Shot caption';

  @override
  String get memberWishlistTitle => 'Wishlist';

  @override
  String get memberWishlistAdd => 'Add wish';

  @override
  String get memberWishlistEmpty => 'No wishes yet.';

  @override
  String get wishlistItemTitleField => 'Wish';

  @override
  String get wishlistItemUrlField => 'Link to the item';

  @override
  String get wishlistNoteField => 'Note';

  @override
  String get wishlistRemove => 'Remove wish';

  @override
  String get eventShowInCalendar => 'Mark date in the family calendar';

  @override
  String calendarBirthdayTitle(String name) {
    return 'Birthday: $name';
  }

  @override
  String get mediaTitle => 'Photos and videos';

  @override
  String get mediaAdd => 'Add media';

  @override
  String get mediaAddByLink => 'Add by link';

  @override
  String get mediaEmpty => 'No photos or videos yet.';

  @override
  String get mediaSourceField => 'File path or link';

  @override
  String get mediaCaptionField => 'Caption';

  @override
  String get mediaTypeField => 'Type';

  @override
  String get mediaTypeImage => 'Photo';

  @override
  String get mediaTypeVideo => 'Video';

  @override
  String get mediaPeopleField => 'Who is on the photo';

  @override
  String get mediaEventsField => 'Related events';

  @override
  String get mediaPeopleHint =>
      'A tagged photo appears on every selected person\'s profile.';

  @override
  String mediaPersonCaption(String name) {
    return 'Caption for $name';
  }

  @override
  String get mediaEventsHint =>
      'A linked photo appears in the selected events.';

  @override
  String get mediaFromLibrary => 'From the library';

  @override
  String get mediaLibraryEmpty =>
      'The media library is empty. Upload files in Settings → Media.';

  @override
  String get mediaCropField => 'Visible part for this link';

  @override
  String get videoPlay => 'Play';

  @override
  String get videoPause => 'Pause';

  @override
  String get videoMute => 'Mute';

  @override
  String get videoUnmute => 'Unmute';

  @override
  String get videoError => 'Could not play this video.';

  @override
  String get mediaViewerPrevious => 'Previous media';

  @override
  String get mediaViewerNext => 'Next media';

  @override
  String get videoConvert => 'Supported format';

  @override
  String get videoConverting => 'Preparing video…';

  @override
  String get videoConverted => 'Video saved in a supported format.';

  @override
  String get videoConvertFailed =>
      'Could not prepare the video in a supported format.';

  @override
  String get videoConvertHint =>
      'The video is converted to a supported format automatically.';

  @override
  String get mediaCropX => 'Horizontal';

  @override
  String get mediaCropY => 'Vertical';

  @override
  String get mediaZoom => 'Zoom';

  @override
  String get mediaCropHint => 'Drag the photo and pinch to zoom';

  @override
  String get mediaCropReset => 'Reset crop';

  @override
  String get mediaZoomIn => 'Zoom in';

  @override
  String get mediaZoomOut => 'Zoom out';

  @override
  String get mediaRemove => 'Remove media';

  @override
  String get mediaUpload => 'Upload from device';

  @override
  String get mediaUploading => 'Uploading…';

  @override
  String get mediaUploadHint =>
      'Photos and videos up to 20 MB. Videos are converted to a supported format automatically. Files are stored locally on this device.';

  @override
  String mediaUploadTooLarge(String name) {
    return 'File is larger than 20 MB: $name';
  }

  @override
  String get mediaUploadFailed => 'Could not upload the file.';

  @override
  String get mediaUploadEmpty => 'The selected file is empty.';

  @override
  String get mediaOpenLink => 'Open link';

  @override
  String get mediaLinkCopied => 'Link copied.';

  @override
  String timelineElapsedYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '$count year',
      zero: '$count years',
    );
    return '$_temp0';
  }

  @override
  String timelineElapsedMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '$count month',
      zero: '$count months',
    );
    return '$_temp0';
  }

  @override
  String timelineElapsedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
      zero: '$count days',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get settingsNoAccess => 'You do not have access to this section.';

  @override
  String get accountLocalAdmin => 'Local administrator';

  @override
  String get accountSignIn => 'Sign in';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignInAction => 'Sign in';

  @override
  String accountSignedIn(String name) {
    return 'Signed in as $name.';
  }

  @override
  String get accountSignedOut =>
      'Signed out; local administrator mode is active.';

  @override
  String get accountLoginFailed => 'Wrong login or password.';

  @override
  String get accountAccessTitle => 'Access';

  @override
  String get accountAccessHint =>
      'Choose which family profiles and events this account can see.';

  @override
  String get accountAllMembers => 'All family members';

  @override
  String get accountVisibleEvents => 'Visible events';

  @override
  String mediaUsagePersonTag(String name) {
    return '$name — tagged photo';
  }

  @override
  String get mediaUnused => 'Unused';

  @override
  String mediaOnlyUnused(int count) {
    return 'Only unused ($count)';
  }

  @override
  String get mediaUseInProfile => 'Use in a profile';

  @override
  String get mediaUseTitle => 'Show this file in profiles';

  @override
  String get mediaUseNoMembers =>
      'There are no family members to link this file to.';

  @override
  String get mediaUseApply => 'Apply';

  @override
  String get mediaUsed => 'The file is now shown in the selected profiles.';
}
