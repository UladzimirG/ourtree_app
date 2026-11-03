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
  String get settingsFamilyReadOnly =>
      'Only an administrator can change the family settings.';

  @override
  String get settingsFamilySubtitle => 'Family subtitle';

  @override
  String get settingsFamilySubtitleHint =>
      'Shown under the family name on the main page';

  @override
  String get settingsDataSource => 'Data source';

  @override
  String get settingsArchiveSource =>
      'Family archive from the bundled demo files (local)';

  @override
  String get settingsResetDemo => 'Reset to demo data';

  @override
  String get settingsResetDemoHint =>
      'Restore the local archive from the bundled demo files';

  @override
  String get settingsResetDemoConfirmTitle => 'Reset to demo data?';

  @override
  String get settingsResetDemoConfirmBody =>
      'All local family changes - members, events, media library, name and photo - will be lost. This cannot be undone.';

  @override
  String settingsResetDemoCloudWarning(String deleteAction) {
    return 'Cloud data is not deleted. You can remove it in “General settings → Cloud” with the “$deleteAction” button.';
  }

  @override
  String get settingsResetDemoAction => 'Reset';

  @override
  String get settingsResetDemoBackup => 'Create a backup';

  @override
  String get settingsResetDemoBackupDone => 'Backup created.';

  @override
  String get settingsResetDemoBackupFailed => 'Could not create a backup.';

  @override
  String get settingsResetDemoDone => 'Archive reset to demo data.';

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
  String get familyRenameOwnerOnly =>
      'Only the family administrator - the person who created the family - can rename it.';

  @override
  String get familyRenamed => 'Family name updated.';

  @override
  String get familyRenameFailed =>
      'Could not update the name in the cloud. Check the connection.';

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
  String get settingsTabGeneral => 'General settings';

  @override
  String get settingsGeneralHint =>
      'Backups, interface language and album access.';

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
      'Create family accounts with a login and password, assign roles and issue guest links. Accounts are stored on the server.';

  @override
  String get settingsAccountsLocalOnly =>
      'Accounts are synced with the server: sign in with the same login and password on any device. A local copy keeps the sign-in working offline.';

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
  String get eventMemberField => 'Main member';

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
  String get accountServerUnavailable =>
      'The accounts server is unavailable. Check your connection and try again.';

  @override
  String get accountServerError =>
      'The accounts server returned an error. Try again later.';

  @override
  String get accountCreatedLocalOnly =>
      'The server is unavailable: the account is saved on this device only.';

  @override
  String get accountServerBadge => 'Server';

  @override
  String get accountMigratedOnServer => 'Account migrated to the server.';

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
  String get dateFormatHint => 'MM/DD/YYYY';

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
  String get mediaCropHint => 'Drag the photo and pinch to zoom';

  @override
  String get mediaCropExpand => 'Open full screen';

  @override
  String get mediaCropDone => 'Done';

  @override
  String get mediaCropReset => 'Reset crop';

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

  @override
  String get settingsTabLanguage => 'Language';

  @override
  String get settingsLanguage => 'Interface language';

  @override
  String get settingsLanguageHint => 'The choice is saved on this device.';

  @override
  String get settingsLanguageSystem => 'Same as system';

  @override
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageBelarusian => 'Беларуская';

  @override
  String get settingsLanguageUkrainian => 'Українська';

  @override
  String get familyCloudTitle => 'Cloud family';

  @override
  String get familyCloudHint =>
      'Create a family to sync albums between devices, or join an existing one with an invite code.';

  @override
  String get familyCloudCreateTitle => 'Create a family';

  @override
  String get familyCloudNameLabel => 'Family name';

  @override
  String get familyCloudNameHint => 'For example: Our big family';

  @override
  String get familyCloudCreateAction => 'Create and connect';

  @override
  String get familyCloudJoinTitle => 'Join with a code';

  @override
  String get familyCloudCodeLabel => 'Invite code';

  @override
  String get familyCloudCodeHint => '8 characters, for example AB2CD3EF';

  @override
  String get familyCloudJoinAction => 'Join';

  @override
  String get familyCloudInvalidCode =>
      'The code must contain 8 letters or digits.';

  @override
  String get familyCloudJoinNotFound =>
      'This invite code was not found or has expired.';

  @override
  String get familyCloudCreated => 'Family created.';

  @override
  String get familyCloudJoined => 'You joined the family.';

  @override
  String get familyCloudError =>
      'Could not complete the request. Check your connection and try again.';

  @override
  String get familyCloudRetry => 'Try again';

  @override
  String get familyCloudOwnerBadge => 'Owner';

  @override
  String get familyCloudPremiumActive => 'Premium is active';

  @override
  String get familyCloudPremiumFree => 'Free plan';

  @override
  String get familyCloudInviteTitle => 'Invite to the family';

  @override
  String get familyCloudInviteHint =>
      'Share this code: each person can use it once.';

  @override
  String get familyCloudInviteCreate => 'Create invite code';

  @override
  String get familyCloudInviteCopied => 'Invite code copied.';

  @override
  String get familyCloudNameRequired => 'Family name cannot be empty.';

  @override
  String familyCloudId(String id) {
    return 'ID: $id';
  }

  @override
  String get familyCloudPrivacyTitle => 'Data and privacy';

  @override
  String get familyCloudPrivacyHint =>
      'Your photos stay on this device. Deleting family data removes files and records from the cloud for every member.';

  @override
  String get familyCloudDisconnect => 'Disconnect this device';

  @override
  String get familyCloudDisconnectConfirm =>
      'Disconnect this device from the family? The local archive stays, cloud data is not deleted.';

  @override
  String get familyCloudDisconnected => 'Device disconnected from the family.';

  @override
  String get familyCloudDisconnectOwnerBlocked =>
      'You are the owner, and other members are still in the family. Disconnect is unavailable — delete the family data or keep this device connected.';

  @override
  String get familyCloudDeleteCloud => 'Delete family data from cloud';

  @override
  String get familyCloudDeleteCloudConfirm =>
      'All family files, events and members will be permanently deleted from the cloud. This cannot be undone. Your local archive stays on this device.';

  @override
  String get familyCloudDeleteCloudDone =>
      'Family data deleted from the cloud.';

  @override
  String get commonDelete => 'Delete';

  @override
  String get mediaLocalOnlyNotice =>
      'Saved on this device only: no cloud family is connected. Set it up in Settings → Cloud family to sync your photos.';

  @override
  String mediaUploadAllLocal(int count) {
    return 'Upload all local files ($count)';
  }

  @override
  String mediaUploadAllProgress(int done, int total) {
    return 'Uploading $done of $total…';
  }

  @override
  String mediaUploadAllDone(int count) {
    return 'Uploaded to cloud: $count';
  }

  @override
  String mediaUploadAllFailed(int count) {
    return 'Failed to upload: $count';
  }

  @override
  String get mediaUploadUnavailableHint =>
      'These files were stored on another device or lost after reinstall — please add them again.';

  @override
  String mediaOutboxRetry(int count) {
    return 'Queued: $count — retry';
  }

  @override
  String get syncStatusLoading => 'Syncing…';

  @override
  String get syncStatusSaving => 'Saving…';

  @override
  String get syncStatusSaved => 'Saved';

  @override
  String get syncStatusError => 'Offline';

  @override
  String get editModeEnter => 'Edit mode';

  @override
  String get editModeExit => 'Exit edit mode';

  @override
  String get editModeBanner => 'Edit mode: tap the pencil on a card';

  @override
  String get editModeDone => 'Done';

  @override
  String get adminOnlyAction => 'Admin only';

  @override
  String get adminOnlyDeleteHint =>
      'Only an administrator can delete events and members.';

  @override
  String get adminOnlySettingsHint =>
      'Backups, accounts and the demo reset are available to administrators only.';

  @override
  String get accountEntryTitle => 'Account';

  @override
  String get accountAuthTitle => 'Sign in or create an account';

  @override
  String get accountSignInTab => 'Sign in';

  @override
  String get accountSignUpTab => 'Sign up';

  @override
  String get accountSignInSubtitle => 'Sign in to load your family data.';

  @override
  String get accountSignUpHint =>
      'A new account gets the viewer role. An administrator can change it later.';

  @override
  String get accountFirstAdminHint =>
      'The first account of the family becomes an administrator.';

  @override
  String accountSessionTitle(String name) {
    return 'Signed in as $name';
  }

  @override
  String get accountManage => 'Manage accounts';

  @override
  String get accountSwitch => 'Switch account';

  @override
  String get calendarViewMonth => 'Month';

  @override
  String get calendarViewYear => 'Year';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarAddEvent => 'Add event';

  @override
  String get calendarAddDate => 'Add date';

  @override
  String get calendarEntryTitle => 'Calendar date';

  @override
  String get calendarEntryTitleField => 'Title';

  @override
  String get calendarEntryNoteField => 'Note';

  @override
  String get calendarEntryDateField => 'Date';

  @override
  String get calendarEntryRecurring => 'Repeat every year';

  @override
  String get calendarEntryHint =>
      'This date appears only in the calendar and is not added to the timeline.';

  @override
  String get calendarEntrySaved => 'Date added to the calendar.';

  @override
  String get calendarEntryDeleted => 'Date removed from the calendar.';

  @override
  String get calendarEntryEdit => 'Edit date';

  @override
  String get calendarEntryDelete => 'Delete date';

  @override
  String get calendarEntryDeleteConfirmTitle => 'Delete this date?';

  @override
  String get calendarEntryDeleteConfirmBody =>
      'The date will disappear from the calendar. Timeline events are not affected.';

  @override
  String get calendarEntryDefaultTitle => 'Date';

  @override
  String get calendarLegendEvent => 'Events';

  @override
  String get calendarLegendBirthday => 'Birthdays';

  @override
  String get eventShowInTimeline => 'Show in timeline';

  @override
  String get eventRecurringYearly => 'Repeat every year';

  @override
  String get eventCalendarOnlyBadge => 'Calendar only';

  @override
  String get eventMemberHint =>
      'Affects access and the profile. Tag several people on a photo in \"Who is in the photo\".';

  @override
  String get eventNewBadge => 'New';

  @override
  String get timelineOrderLabel => 'Order';

  @override
  String get timelineOrderOldest => 'Oldest first';

  @override
  String get timelineOrderNewest => 'Newest first';

  @override
  String get profileStories => 'Interesting';

  @override
  String get profileStoriesEmpty => 'No stories yet.';

  @override
  String get profileStoriesAdd => 'Add story';

  @override
  String get profileStoryDelete => 'Delete story';

  @override
  String get profileStoryTitleField => 'Title';

  @override
  String get profileStoryTextField => 'Story text';

  @override
  String get readMore => 'Read more';

  @override
  String get readLess => 'Show less';

  @override
  String get memberEditorTitle => 'Member';

  @override
  String get eventEditorTitle => 'Event';

  @override
  String get memberEdit => 'Edit member';

  @override
  String get eventEdit => 'Edit event';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get familyCloudInviteCopy => 'Copy code';

  @override
  String get familyCloudInviteCopyHint =>
      'The browser blocked copying: tap the copy icon next to the code.';

  @override
  String get backupDownloadStarted =>
      'The backup file has been downloaded by the browser.';

  @override
  String get backupImportWrongFile =>
      'Please choose an OurTree backup file (.json or .ourtree).';

  @override
  String backupImportTooLarge(int mb) {
    return 'The file is larger than $mb MB and may not fit into browser memory. Export a backup without media and try again.';
  }

  @override
  String get backupImportUnreadable =>
      'The selected file could not be read. If it is stored in iCloud, download it to the device first.';

  @override
  String backupImportPartial(int count) {
    return '$count media files could not be restored.';
  }

  @override
  String get demoEditNoticeTitle => 'Changes stay on this device';

  @override
  String get demoEditNoticeBody =>
      'The archive will not be saved to the cloud. Create a family and sign in to an account to keep the data and see it on other devices.';

  @override
  String get demoEditNoticeAction => 'Create family';

  @override
  String get demoEditNoticeLater => 'Later';

  @override
  String get demoLocalOnlyNotice =>
      'Local archive only: not synced to the cloud';

  @override
  String get accountNoFamilyAttached =>
      'This account is not linked to a family yet — connect by invite code in General settings → Cloud.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutHint => 'Version, developer, documents and licenses.';

  @override
  String get aboutDescription =>
      'OurTree is a family album: profiles, timeline, calendar and media library. Data is kept on the device and synced to the cloud once a family is connected.';

  @override
  String get aboutVersion => 'Version';

  @override
  String aboutVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPlatform => 'Platform';

  @override
  String get aboutDeveloper => 'Developer';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutTerms => 'Terms of use';

  @override
  String get aboutLicenses => 'Open source licenses';

  @override
  String get aboutChangelogTitle => 'What\'s new';

  @override
  String get aboutChangelog1 =>
      'Edits arrive from other devices without restarting the app';

  @override
  String get aboutChangelog2 =>
      'Photos are uploaded to the cloud automatically in a created family';

  @override
  String get aboutChangelog3 => 'Backup import works on iPhone (web version)';

  @override
  String get aboutChangelog4 => 'Invite code is copied automatically';

  @override
  String get aboutChangelog5 =>
      'Push notifications about birthdays, events and family updates';

  @override
  String get aboutSupport => 'Support';

  @override
  String get aboutFamilyId => 'Family ID';

  @override
  String get aboutCopyFamilyId => 'Copy family ID';

  @override
  String get aboutFamilyIdCopied => 'Family ID copied.';

  @override
  String get aboutNoFamily =>
      'No family connected yet: connect one in General settings → Cloud.';

  @override
  String aboutCopyright(int year) {
    return '© $year OurTree';
  }

  @override
  String get aboutLinkFailed => 'Could not open the link.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsHint =>
      'Birthdays, calendar events and family updates.';

  @override
  String get notificationsStatusTitle => 'Status on this device';

  @override
  String get notificationsEnable => 'Enable notifications';

  @override
  String get notificationsDisable => 'Disable';

  @override
  String get notificationsRefresh => 'Refresh token';

  @override
  String get notificationsEnabled =>
      'Notifications are on: reminders and family updates will arrive on this device.';

  @override
  String get notificationsDisabled =>
      'Notifications are off. Enable them to get reminders.';

  @override
  String get notificationsDenied =>
      'Notifications are blocked in the browser or system settings. Allow them for this app and try again.';

  @override
  String get notificationsNoFamily =>
      'Connect a family first: reminders are sent for your family archive.';

  @override
  String get notificationsFailed => 'Could not enable notifications.';

  @override
  String get notificationsFailedNoKey =>
      'This build has no web-push key (FIREBASE_VAPID_KEY). Rebuild with --dart-define-from-file.';

  @override
  String get notificationsFailedPermission =>
      'The browser did not grant permission.';

  @override
  String get notificationsFailedToken => 'Could not get a device token.';

  @override
  String get notificationsPrefsTitle => 'What to send';

  @override
  String get notificationsBirthdays => 'Birthdays';

  @override
  String get notificationsBirthdaysHint =>
      'The day before and on the day itself.';

  @override
  String get notificationsCalendar => 'Calendar events';

  @override
  String get notificationsCalendarHint => 'Events marked \"show in calendar\".';

  @override
  String get notificationsFamilyUpdates => 'Family updates';

  @override
  String get notificationsFamilyUpdatesHint =>
      'When someone edits the shared archive.';

  @override
  String get notificationsIosHint =>
      'On iPhone notifications only work in the app added to the Home Screen (iOS 16.4+).';

  @override
  String get notificationsUpcoming => 'Coming up';

  @override
  String get notificationsUpcomingEmpty =>
      'No birthdays or events in the next 7 days.';
}
