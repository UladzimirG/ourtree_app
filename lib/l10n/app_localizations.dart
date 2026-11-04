import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_be.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('be'),
    Locale('uk')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'OurTree App'**
  String get appTitle;

  /// Small label above the family name
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get homeFamilyLabel;

  /// Short description under the family name
  ///
  /// In en, this message translates to:
  /// **'A place for your family stories, photos and dates.'**
  String get homeSubtitle;

  /// Title of the statistics section
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get homeOverviewTitle;

  /// Number of family members in the overview
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members yet} one{{count} member} other{{count} members}}'**
  String homeMembersCount(int count);

  /// Number of timeline events in the overview
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No events yet} one{{count} event} other{{count} events}}'**
  String homeEventsCount(int count);

  /// Shown while family data is loading
  ///
  /// In en, this message translates to:
  /// **'Loading family data…'**
  String get homeLoading;

  /// Shown when family data failed to load
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the family data.'**
  String get homeLoadError;

  /// Button that retries loading family data
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeRetry;

  /// Settings screen title and tooltip
  ///
  /// In en, this message translates to:
  /// **'Family settings'**
  String get settingsTitle;

  /// Timeline tab label
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get navTimeline;

  /// Calendar tab label
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// Family tab label
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get navFamily;

  /// Small label above the timeline title
  ///
  /// In en, this message translates to:
  /// **'Family album'**
  String get timelineEyebrow;

  /// Timeline page title
  ///
  /// In en, this message translates to:
  /// **'Life timeline'**
  String get timelineTitle;

  /// Timeline page description
  ///
  /// In en, this message translates to:
  /// **'A thread of events with our meetings, holidays and trips.'**
  String get timelineLede;

  /// Shown when the timeline has no events
  ///
  /// In en, this message translates to:
  /// **'The timeline is still empty.'**
  String get timelineEmpty;

  /// How long a couple has been together
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Together since this day} one{Together for {count} year} other{Together for {count} years}}'**
  String timelineTogetherYears(int count);

  /// Placeholder for a missing photo or video
  ///
  /// In en, this message translates to:
  /// **'Photo or video'**
  String get mediaPlaceholder;

  /// Family page title
  ///
  /// In en, this message translates to:
  /// **'Family and profiles'**
  String get familyTitle;

  /// Family page description
  ///
  /// In en, this message translates to:
  /// **'Tap a card to open a person\'s home album.'**
  String get familyLede;

  /// Shown when there are no family members
  ///
  /// In en, this message translates to:
  /// **'No family members yet.'**
  String get familyEmpty;

  /// Age of a family member
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Less than a year} one{{count} year} other{{count} years}}'**
  String memberAgeYears(int count);

  /// Small label above the calendar title
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget the important dates'**
  String get calendarEyebrow;

  /// Calendar page title
  ///
  /// In en, this message translates to:
  /// **'Family calendar'**
  String get calendarTitle;

  /// Calendar page description
  ///
  /// In en, this message translates to:
  /// **'Days with family events are highlighted. Tap a day to see what happened.'**
  String get calendarLede;

  /// Previous month button tooltip
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// Next month button tooltip
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// Shown for a day without events
  ///
  /// In en, this message translates to:
  /// **'No events on this day.'**
  String get calendarNoEvents;

  /// Back to family button
  ///
  /// In en, this message translates to:
  /// **'All family'**
  String get profileBack;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get profileAbout;

  /// Wishlist section title
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profileWishlist;

  /// Shown when the wishlist is empty
  ///
  /// In en, this message translates to:
  /// **'The wishlist is still empty.'**
  String get profileWishlistEmpty;

  /// Gallery section title
  ///
  /// In en, this message translates to:
  /// **'Mini gallery'**
  String get profileGallery;

  /// Shown when the gallery is empty
  ///
  /// In en, this message translates to:
  /// **'No photos yet.'**
  String get profileGalleryEmpty;

  /// Shown when a profile is missing
  ///
  /// In en, this message translates to:
  /// **'This profile is not in the family album yet.'**
  String get profileNotFound;

  /// Button that copies the wishlist link
  ///
  /// In en, this message translates to:
  /// **'Copy wishlist link'**
  String get profileCopyWishlistLink;

  /// Confirmation after copying the link
  ///
  /// In en, this message translates to:
  /// **'Wishlist link copied.'**
  String get profileLinkCopied;

  /// Family name field label
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get settingsFamilyName;

  /// No description provided for @settingsFamilyReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Only an administrator can change the family settings.'**
  String get settingsFamilyReadOnly;

  /// Editable subtitle of the family page
  ///
  /// In en, this message translates to:
  /// **'Family subtitle'**
  String get settingsFamilySubtitle;

  /// Explains where the subtitle is shown
  ///
  /// In en, this message translates to:
  /// **'Shown under the family name on the main page'**
  String get settingsFamilySubtitleHint;

  /// Data source section label
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get settingsDataSource;

  /// Description of the bundled family archive
  ///
  /// In en, this message translates to:
  /// **'Family archive from the bundled demo files (local)'**
  String get settingsArchiveSource;

  /// Menu item that resets the archive to demo data
  ///
  /// In en, this message translates to:
  /// **'Reset to demo data'**
  String get settingsResetDemo;

  /// Description of the demo reset action
  ///
  /// In en, this message translates to:
  /// **'Restore the local archive from the bundled demo files'**
  String get settingsResetDemoHint;

  /// Title of the demo reset confirmation
  ///
  /// In en, this message translates to:
  /// **'Reset to demo data?'**
  String get settingsResetDemoConfirmTitle;

  /// Body of the demo reset confirmation
  ///
  /// In en, this message translates to:
  /// **'All local family changes - members, events, media library, name and photo - will be lost. This cannot be undone.'**
  String get settingsResetDemoConfirmBody;

  /// Warning about cloud data on demo reset
  ///
  /// In en, this message translates to:
  /// **'Cloud data is not deleted. You can remove it in “General settings → Cloud” with the “{deleteAction}” button.'**
  String settingsResetDemoCloudWarning(String deleteAction);

  /// Confirm button of the demo reset
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetDemoAction;

  /// Button that creates a backup before the reset
  ///
  /// In en, this message translates to:
  /// **'Create a backup'**
  String get settingsResetDemoBackup;

  /// Backup created before the reset
  ///
  /// In en, this message translates to:
  /// **'Backup created.'**
  String get settingsResetDemoBackupDone;

  /// Backup failed before the reset
  ///
  /// In en, this message translates to:
  /// **'Could not create a backup.'**
  String get settingsResetDemoBackupFailed;

  /// Confirmation of the demo reset
  ///
  /// In en, this message translates to:
  /// **'Archive reset to demo data.'**
  String get settingsResetDemoDone;

  /// Note about upcoming editing
  ///
  /// In en, this message translates to:
  /// **'Editing will appear in the next step.'**
  String get settingsEditingSoon;

  /// Family photo field label
  ///
  /// In en, this message translates to:
  /// **'Family photo'**
  String get settingsFamilyPhoto;

  /// Hint for the family photo path field
  ///
  /// In en, this message translates to:
  /// **'/photos/family.jpg or assets/photos/family.jpg'**
  String get settingsFamilyPhotoHint;

  /// Placeholder above the photo preview
  ///
  /// In en, this message translates to:
  /// **'Photo preview'**
  String get settingsPhotoPreview;

  /// Button that clears the family photo
  ///
  /// In en, this message translates to:
  /// **'Clear photo'**
  String get settingsClearPhoto;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Toggle for the header family photo
  ///
  /// In en, this message translates to:
  /// **'Show family photo in the header'**
  String get settingsShowFamilyPhoto;

  /// Toggle for photos in the timeline
  ///
  /// In en, this message translates to:
  /// **'Show photos in the timeline'**
  String get settingsShowEventPhotos;

  /// Save settings button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// Confirmation after saving settings
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get settingsSaved;

  /// Validation message for an empty family name
  ///
  /// In en, this message translates to:
  /// **'Family name cannot be empty.'**
  String get settingsNameRequired;

  /// Hint that only the family administrator (the creator) can rename the family
  ///
  /// In en, this message translates to:
  /// **'Only the family administrator - the person who created the family - can rename it.'**
  String get familyRenameOwnerOnly;

  /// Confirmation of the family rename
  ///
  /// In en, this message translates to:
  /// **'Family name updated.'**
  String get familyRenamed;

  /// Error when the cloud rename fails
  ///
  /// In en, this message translates to:
  /// **'Could not update the name in the cloud. Check the connection.'**
  String get familyRenameFailed;

  /// Note that changes are kept in memory
  ///
  /// In en, this message translates to:
  /// **'Changes are saved locally on this device.'**
  String get settingsLocalOnly;

  /// No description provided for @settingsTabFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get settingsTabFamily;

  /// No description provided for @settingsTabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get settingsTabMembers;

  /// No description provided for @settingsTabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get settingsTabEvents;

  /// No description provided for @settingsTabAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get settingsTabAccounts;

  /// No description provided for @settingsTabBackups.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get settingsTabBackups;

  /// No description provided for @settingsTabMedia.
  ///
  /// In en, this message translates to:
  /// **'Media library'**
  String get settingsTabMedia;

  /// Settings tab that groups backups, language and accounts
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get settingsTabGeneral;

  /// Intro of the general settings page
  ///
  /// In en, this message translates to:
  /// **'Backups, interface language and album access.'**
  String get settingsGeneralHint;

  /// No description provided for @settingsMediaHint.
  ///
  /// In en, this message translates to:
  /// **'One place for every photo and video. Videos are converted to a supported format automatically. Descriptions and cropping are set individually for each member or event.'**
  String get settingsMediaHint;

  /// No description provided for @mediaLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Family media library'**
  String get mediaLibraryTitle;

  /// No description provided for @mediaLibraryUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload files'**
  String get mediaLibraryUpload;

  /// No description provided for @mediaLibraryAddLink.
  ///
  /// In en, this message translates to:
  /// **'Add by link'**
  String get mediaLibraryAddLink;

  /// No description provided for @mediaAssetName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get mediaAssetName;

  /// No description provided for @mediaAssetType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get mediaAssetType;

  /// No description provided for @mediaUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Where it is used'**
  String get mediaUsageTitle;

  /// No description provided for @mediaUsageNone.
  ///
  /// In en, this message translates to:
  /// **'Not linked to anyone yet.'**
  String get mediaUsageNone;

  /// Media usage on a member avatar
  ///
  /// In en, this message translates to:
  /// **'{name} — avatar'**
  String mediaUsageAvatar(String name);

  /// Media usage on a birthday
  ///
  /// In en, this message translates to:
  /// **'{name} — birthday'**
  String mediaUsageBirthday(String name);

  /// Media usage in a gallery
  ///
  /// In en, this message translates to:
  /// **'{name} — gallery'**
  String mediaUsageGallery(String name);

  /// Media usage in an event
  ///
  /// In en, this message translates to:
  /// **'Event \"{name}\"'**
  String mediaUsageEvent(String name);

  /// No description provided for @mediaUsageFamilyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Family photo in the header'**
  String get mediaUsageFamilyPhoto;

  /// No description provided for @mediaStoredLocally.
  ///
  /// In en, this message translates to:
  /// **'Stored locally'**
  String get mediaStoredLocally;

  /// No description provided for @mediaDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this file from the library?'**
  String get mediaDeleteTitle;

  /// No description provided for @mediaDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The file and all its links to members and events will be removed. The action cannot be undone.'**
  String get mediaDeleteBody;

  /// No description provided for @mediaDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get mediaDelete;

  /// No description provided for @mediaDeleted.
  ///
  /// In en, this message translates to:
  /// **'File deleted from the library.'**
  String get mediaDeleted;

  /// No description provided for @mediaDuplicateFound.
  ///
  /// In en, this message translates to:
  /// **'This file is already in the media library.'**
  String get mediaDuplicateFound;

  /// No description provided for @mediaDuplicateAttached.
  ///
  /// In en, this message translates to:
  /// **'This file was already in the library — the existing copy was attached.'**
  String get mediaDuplicateAttached;

  /// No description provided for @mediaViewerOpen.
  ///
  /// In en, this message translates to:
  /// **'Open in viewer'**
  String get mediaViewerOpen;

  /// Library total
  ///
  /// In en, this message translates to:
  /// **'{count} files · {size}'**
  String mediaLibrarySize(int count, String size);

  /// No description provided for @settingsMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Edit profiles, photos and birthday visibility. New members are saved in the app session.'**
  String get settingsMembersHint;

  /// No description provided for @settingsEventsHint.
  ///
  /// In en, this message translates to:
  /// **'Edit timeline events, dates and places. Birthday entries are generated from member profiles.'**
  String get settingsEventsHint;

  /// No description provided for @settingsAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Create family accounts with a login and password, assign roles and issue guest links. Accounts are stored on the server.'**
  String get settingsAccountsHint;

  /// No description provided for @settingsAccountsLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Accounts are synced with the server: sign in with the same login and password on any device. A local copy keeps the sign-in working offline.'**
  String get settingsAccountsLocalOnly;

  /// No description provided for @settingsBackupsHint.
  ///
  /// In en, this message translates to:
  /// **'Snapshots of the family archive. Restoring rolls the data back to the selected moment.'**
  String get settingsBackupsHint;

  /// No description provided for @memberAdd.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get memberAdd;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'Member added.'**
  String get memberAdded;

  /// No description provided for @memberDeleted.
  ///
  /// In en, this message translates to:
  /// **'Member removed.'**
  String get memberDeleted;

  /// No description provided for @memberDefaultName.
  ///
  /// In en, this message translates to:
  /// **'New member'**
  String get memberDefaultName;

  /// No description provided for @memberDefaultRole.
  ///
  /// In en, this message translates to:
  /// **'Family member'**
  String get memberDefaultRole;

  /// No description provided for @memberDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this member?'**
  String get memberDeleteConfirmTitle;

  /// No description provided for @memberDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The profile, personal photos and events tied to this member will be removed from the album.'**
  String get memberDeleteConfirmBody;

  /// No description provided for @memberNameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get memberNameField;

  /// No description provided for @memberRoleField.
  ///
  /// In en, this message translates to:
  /// **'Role in the family'**
  String get memberRoleField;

  /// No description provided for @memberNicknameField.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get memberNicknameField;

  /// No description provided for @memberBirthdayField.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get memberBirthdayField;

  /// No description provided for @memberBirthdayHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get memberBirthdayHint;

  /// No description provided for @memberShowBirthday.
  ///
  /// In en, this message translates to:
  /// **'Show birthday on the timeline'**
  String get memberShowBirthday;

  /// No description provided for @memberMainPhoto.
  ///
  /// In en, this message translates to:
  /// **'Main photo'**
  String get memberMainPhoto;

  /// No description provided for @memberHabitsField.
  ///
  /// In en, this message translates to:
  /// **'Habits, one per line'**
  String get memberHabitsField;

  /// No description provided for @memberQuotesField.
  ///
  /// In en, this message translates to:
  /// **'Quotes, one per line'**
  String get memberQuotesField;

  /// No description provided for @memberAccentField.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get memberAccentField;

  /// No description provided for @memberWishlistUrlField.
  ///
  /// In en, this message translates to:
  /// **'Wishlist link'**
  String get memberWishlistUrlField;

  /// No description provided for @memberDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get memberDelete;

  /// No description provided for @eventAdd.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get eventAdd;

  /// No description provided for @eventAdded.
  ///
  /// In en, this message translates to:
  /// **'Event added.'**
  String get eventAdded;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Event removed.'**
  String get eventDeleted;

  /// No description provided for @eventDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get eventDefaultTitle;

  /// No description provided for @eventDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove event'**
  String get eventDelete;

  /// No description provided for @eventDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this event?'**
  String get eventDeleteConfirmTitle;

  /// No description provided for @eventDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The event and its media references will disappear from the timeline.'**
  String get eventDeleteConfirmBody;

  /// No description provided for @eventTitleField.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get eventTitleField;

  /// No description provided for @eventDateField.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDateField;

  /// No description provided for @eventKindField.
  ///
  /// In en, this message translates to:
  /// **'Event type'**
  String get eventKindField;

  /// No description provided for @eventPlaceField.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get eventPlaceField;

  /// No description provided for @eventTextField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventTextField;

  /// No description provided for @eventMemberField.
  ///
  /// In en, this message translates to:
  /// **'Main member'**
  String get eventMemberField;

  /// No description provided for @eventMemberNone.
  ///
  /// In en, this message translates to:
  /// **'No member'**
  String get eventMemberNone;

  /// No description provided for @eventShowElapsed.
  ///
  /// In en, this message translates to:
  /// **'Show time elapsed'**
  String get eventShowElapsed;

  /// No description provided for @eventKindMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get eventKindMeeting;

  /// No description provided for @eventKindDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventKindDate;

  /// No description provided for @eventKindWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get eventKindWedding;

  /// No description provided for @eventKindChurch.
  ///
  /// In en, this message translates to:
  /// **'Church wedding'**
  String get eventKindChurch;

  /// No description provided for @eventKindBirth.
  ///
  /// In en, this message translates to:
  /// **'Birth'**
  String get eventKindBirth;

  /// No description provided for @eventKindTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get eventKindTrip;

  /// No description provided for @eventKindMilestone.
  ///
  /// In en, this message translates to:
  /// **'Milestone'**
  String get eventKindMilestone;

  /// No description provided for @photoPathHint.
  ///
  /// In en, this message translates to:
  /// **'/photos/photo.jpg or assets/photos/photo.jpg'**
  String get photoPathHint;

  /// No description provided for @settingsAdvancedJson.
  ///
  /// In en, this message translates to:
  /// **'Advanced JSON'**
  String get settingsAdvancedJson;

  /// No description provided for @settingsApplyJson.
  ///
  /// In en, this message translates to:
  /// **'Apply JSON'**
  String get settingsApplyJson;

  /// No description provided for @settingsInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON object.'**
  String get settingsInvalidJson;

  /// No description provided for @accountAdd.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get accountAdd;

  /// No description provided for @accountCreate.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get accountCreate;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created.'**
  String get accountCreated;

  /// No description provided for @accountSaved.
  ///
  /// In en, this message translates to:
  /// **'Account updated.'**
  String get accountSaved;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountDelete;

  /// No description provided for @accountDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account?'**
  String get accountDeleteConfirmTitle;

  /// No description provided for @accountDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The person will lose access to the family album immediately.'**
  String get accountDeleteConfirmBody;

  /// No description provided for @accountLoginField.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get accountLoginField;

  /// No description provided for @accountNameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountNameField;

  /// No description provided for @accountPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPasswordField;

  /// No description provided for @accountPasswordKeepHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep the current password'**
  String get accountPasswordKeepHint;

  /// No description provided for @accountRoleField.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get accountRoleField;

  /// No description provided for @accountRoleViewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get accountRoleViewer;

  /// No description provided for @accountRoleEditor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get accountRoleEditor;

  /// No description provided for @accountRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get accountRoleAdmin;

  /// No description provided for @accountLoginInvalid.
  ///
  /// In en, this message translates to:
  /// **'Login must be 2–32 characters: Latin letters, digits, dot, dash or underscore.'**
  String get accountLoginInvalid;

  /// No description provided for @accountLoginRequirements.
  ///
  /// In en, this message translates to:
  /// **'2–32 characters: Latin letters, digits, dot, dash or underscore.'**
  String get accountLoginRequirements;

  /// No description provided for @accountPasswordRequirements.
  ///
  /// In en, this message translates to:
  /// **'At least 4 characters.'**
  String get accountPasswordRequirements;

  /// No description provided for @accountRoleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Unknown role.'**
  String get accountRoleInvalid;

  /// No description provided for @accountPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password is too short.'**
  String get accountPasswordTooShort;

  /// No description provided for @accountLoginTaken.
  ///
  /// In en, this message translates to:
  /// **'This login is already taken.'**
  String get accountLoginTaken;

  /// No description provided for @accountCannotDeleteSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete your own account.'**
  String get accountCannotDeleteSelf;

  /// No description provided for @accountCannotChangeOwnRole.
  ///
  /// In en, this message translates to:
  /// **'You cannot change your own role.'**
  String get accountCannotChangeOwnRole;

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found.'**
  String get accountNotFound;

  /// No description provided for @accountForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have enough rights.'**
  String get accountForbidden;

  /// No description provided for @accountUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get accountUnauthenticated;

  /// No description provided for @accountOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server.'**
  String get accountOffline;

  /// No description provided for @accountUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get accountUnknownError;

  /// No description provided for @accountServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The accounts server is unavailable. Check your connection and try again.'**
  String get accountServerUnavailable;

  /// No description provided for @accountServerError.
  ///
  /// In en, this message translates to:
  /// **'The accounts server returned an error. Try again later.'**
  String get accountServerError;

  /// No description provided for @accountCreatedLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'The server is unavailable: the account is saved on this device only.'**
  String get accountCreatedLocalOnly;

  /// No description provided for @accountServerBadge.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get accountServerBadge;

  /// No description provided for @accountMigratedOnServer.
  ///
  /// In en, this message translates to:
  /// **'Account migrated to the server.'**
  String get accountMigratedOnServer;

  /// No description provided for @accountsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet. Create the first one above.'**
  String get accountsEmpty;

  /// No description provided for @guestLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest links'**
  String get guestLinksTitle;

  /// No description provided for @guestLinksHint.
  ///
  /// In en, this message translates to:
  /// **'A guest link opens the album without an account and expires automatically.'**
  String get guestLinksHint;

  /// No description provided for @guestLinkLabelField.
  ///
  /// In en, this message translates to:
  /// **'Who is the link for'**
  String get guestLinkLabelField;

  /// No description provided for @guestLinkDaysField.
  ///
  /// In en, this message translates to:
  /// **'Valid for, days'**
  String get guestLinkDaysField;

  /// No description provided for @guestLinkCreate.
  ///
  /// In en, this message translates to:
  /// **'Create guest link'**
  String get guestLinkCreate;

  /// No description provided for @guestLinkCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy token'**
  String get guestLinkCopy;

  /// No description provided for @guestLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Guest token copied.'**
  String get guestLinkCopied;

  /// No description provided for @guestLinkRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get guestLinkRevoke;

  /// No description provided for @guestLinksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No guest links yet.'**
  String get guestLinksEmpty;

  /// No description provided for @guestLinkStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get guestLinkStatusActive;

  /// No description provided for @guestLinkStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get guestLinkStatusExpired;

  /// No description provided for @guestLinkStatusRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get guestLinkStatusRevoked;

  /// No description provided for @backupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create snapshot now'**
  String get backupCreate;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Snapshot saved.'**
  String get backupCreated;

  /// No description provided for @backupCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create a snapshot.'**
  String get backupCreateFailed;

  /// No description provided for @backupEmpty.
  ///
  /// In en, this message translates to:
  /// **'No snapshots yet — create one above.'**
  String get backupEmpty;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this snapshot?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Changes made after this moment will disappear. The current state is saved in a backup first, so the rollback can be undone.'**
  String get backupRestoreConfirmBody;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Data restored from the snapshot.'**
  String get backupRestored;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the snapshot.'**
  String get backupRestoreFailed;

  /// No description provided for @backupDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get backupDelete;

  /// No description provided for @backupDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this snapshot?'**
  String get backupDeleteConfirmTitle;

  /// No description provided for @backupDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Only the backup copy will be removed; current family data stays untouched.'**
  String get backupDeleteConfirmBody;

  /// No description provided for @backupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Snapshot deleted.'**
  String get backupDeleted;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get backupExport;

  /// No description provided for @backupExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a backup'**
  String get backupExportTitle;

  /// No description provided for @backupExportHint.
  ///
  /// In en, this message translates to:
  /// **'A complete copy of settings, profiles, events, accounts, access rights and the media library will be created. External links are saved without files; passwords are stored only as salted hashes.'**
  String get backupExportHint;

  /// No description provided for @backupIncludeMedia.
  ///
  /// In en, this message translates to:
  /// **'Include photos and videos'**
  String get backupIncludeMedia;

  /// No description provided for @backupIncludeMediaHint.
  ///
  /// In en, this message translates to:
  /// **'The backup will contain copies of all local media files and may be large.'**
  String get backupIncludeMediaHint;

  /// No description provided for @backupSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Where to save the family backup'**
  String get backupSaveDialogTitle;

  /// Path or URI of the saved backup
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {path}'**
  String backupSavedTo(String path);

  /// No description provided for @backupExportCanceled.
  ///
  /// In en, this message translates to:
  /// **'Saving the backup was canceled.'**
  String get backupExportCanceled;

  /// No description provided for @backupImport.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get backupImport;

  /// No description provided for @backupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup imported.'**
  String get backupImportSuccess;

  /// No description provided for @backupImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import this backup file.'**
  String get backupImportFailed;

  /// How many snapshots are stored and their total size
  ///
  /// In en, this message translates to:
  /// **'{count} of {kept} · {size}'**
  String backupSummary(int count, int kept, String size);

  /// Snapshot revision label
  ///
  /// In en, this message translates to:
  /// **'revision {revision}'**
  String backupRevision(int revision);

  /// Backup size in bytes
  ///
  /// In en, this message translates to:
  /// **'{size} B'**
  String backupSizeBytes(int size);

  /// Backup size in kilobytes
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String backupSizeKb(String size);

  /// Backup size in megabytes
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String backupSizeMb(String size);

  /// No description provided for @backupLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Snapshots are stored locally and include copies of media files.'**
  String get backupLocalOnly;

  /// No description provided for @dateFormatHint.
  ///
  /// In en, this message translates to:
  /// **'MM/DD/YYYY'**
  String get dateFormatHint;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Enter an existing date: DD.MM.YYYY'**
  String get invalidDate;

  /// No description provided for @memberShowInCalendar.
  ///
  /// In en, this message translates to:
  /// **'Mark birthday in the family calendar'**
  String get memberShowInCalendar;

  /// No description provided for @memberBirthdayMedia.
  ///
  /// In en, this message translates to:
  /// **'Birthday photos and videos'**
  String get memberBirthdayMedia;

  /// No description provided for @memberGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get memberGalleryTitle;

  /// No description provided for @memberGalleryAddShot.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get memberGalleryAddShot;

  /// No description provided for @memberGalleryRemoveShot.
  ///
  /// In en, this message translates to:
  /// **'Remove shot'**
  String get memberGalleryRemoveShot;

  /// No description provided for @memberGalleryCaption.
  ///
  /// In en, this message translates to:
  /// **'Shot caption'**
  String get memberGalleryCaption;

  /// No description provided for @memberWishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get memberWishlistTitle;

  /// No description provided for @memberWishlistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add wish'**
  String get memberWishlistAdd;

  /// No description provided for @memberWishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wishes yet.'**
  String get memberWishlistEmpty;

  /// No description provided for @wishlistItemTitleField.
  ///
  /// In en, this message translates to:
  /// **'Wish'**
  String get wishlistItemTitleField;

  /// No description provided for @wishlistItemUrlField.
  ///
  /// In en, this message translates to:
  /// **'Link to the item'**
  String get wishlistItemUrlField;

  /// No description provided for @wishlistNoteField.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get wishlistNoteField;

  /// No description provided for @wishlistRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove wish'**
  String get wishlistRemove;

  /// No description provided for @eventShowInCalendar.
  ///
  /// In en, this message translates to:
  /// **'Mark date in the family calendar'**
  String get eventShowInCalendar;

  /// Synthetic birthday entry in the calendar
  ///
  /// In en, this message translates to:
  /// **'Birthday: {name}'**
  String calendarBirthdayTitle(String name);

  /// No description provided for @mediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get mediaTitle;

  /// No description provided for @mediaAdd.
  ///
  /// In en, this message translates to:
  /// **'Add media'**
  String get mediaAdd;

  /// No description provided for @mediaAddByLink.
  ///
  /// In en, this message translates to:
  /// **'Add by link'**
  String get mediaAddByLink;

  /// No description provided for @mediaEmpty.
  ///
  /// In en, this message translates to:
  /// **'No photos or videos yet.'**
  String get mediaEmpty;

  /// No description provided for @mediaSourceField.
  ///
  /// In en, this message translates to:
  /// **'File path or link'**
  String get mediaSourceField;

  /// No description provided for @mediaCaptionField.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get mediaCaptionField;

  /// No description provided for @mediaTypeField.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get mediaTypeField;

  /// No description provided for @mediaTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get mediaTypeImage;

  /// No description provided for @mediaTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get mediaTypeVideo;

  /// No description provided for @mediaPeopleField.
  ///
  /// In en, this message translates to:
  /// **'Who is on the photo'**
  String get mediaPeopleField;

  /// No description provided for @mediaEventsField.
  ///
  /// In en, this message translates to:
  /// **'Related events'**
  String get mediaEventsField;

  /// No description provided for @mediaPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'A tagged photo appears on every selected person\'s profile.'**
  String get mediaPeopleHint;

  /// Personal caption of a tagged person
  ///
  /// In en, this message translates to:
  /// **'Caption for {name}'**
  String mediaPersonCaption(String name);

  /// No description provided for @mediaEventsHint.
  ///
  /// In en, this message translates to:
  /// **'A linked photo appears in the selected events.'**
  String get mediaEventsHint;

  /// No description provided for @mediaFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'From the library'**
  String get mediaFromLibrary;

  /// No description provided for @mediaLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'The media library is empty. Upload files in Settings → Media.'**
  String get mediaLibraryEmpty;

  /// No description provided for @mediaCropField.
  ///
  /// In en, this message translates to:
  /// **'Visible part for this link'**
  String get mediaCropField;

  /// No description provided for @videoPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get videoPlay;

  /// No description provided for @videoPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get videoPause;

  /// No description provided for @videoMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get videoMute;

  /// No description provided for @videoUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get videoUnmute;

  /// No description provided for @videoError.
  ///
  /// In en, this message translates to:
  /// **'Could not play this video.'**
  String get videoError;

  /// No description provided for @mediaViewerPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous media'**
  String get mediaViewerPrevious;

  /// No description provided for @mediaViewerNext.
  ///
  /// In en, this message translates to:
  /// **'Next media'**
  String get mediaViewerNext;

  /// No description provided for @videoConvert.
  ///
  /// In en, this message translates to:
  /// **'Supported format'**
  String get videoConvert;

  /// No description provided for @videoConverting.
  ///
  /// In en, this message translates to:
  /// **'Preparing video…'**
  String get videoConverting;

  /// No description provided for @videoConverted.
  ///
  /// In en, this message translates to:
  /// **'Video saved in a supported format.'**
  String get videoConverted;

  /// No description provided for @videoConvertFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the video in a supported format.'**
  String get videoConvertFailed;

  /// No description provided for @videoConvertHint.
  ///
  /// In en, this message translates to:
  /// **'The video is converted to a supported format automatically.'**
  String get videoConvertHint;

  /// No description provided for @mediaCropHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the photo and pinch to zoom'**
  String get mediaCropHint;

  /// Button that opens the full-screen crop editor
  ///
  /// In en, this message translates to:
  /// **'Open full screen'**
  String get mediaCropExpand;

  /// Confirm button of the crop editor
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mediaCropDone;

  /// No description provided for @mediaCropReset.
  ///
  /// In en, this message translates to:
  /// **'Reset crop'**
  String get mediaCropReset;

  /// No description provided for @mediaRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove media'**
  String get mediaRemove;

  /// No description provided for @mediaUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload from device'**
  String get mediaUpload;

  /// No description provided for @mediaUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get mediaUploading;

  /// No description provided for @mediaUploadHint.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos up to 20 MB. Videos are converted to a supported format automatically. Files are stored locally on this device.'**
  String get mediaUploadHint;

  /// Upload error with the file name
  ///
  /// In en, this message translates to:
  /// **'File is larger than 20 MB: {name}'**
  String mediaUploadTooLarge(String name);

  /// No description provided for @mediaUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the file.'**
  String get mediaUploadFailed;

  /// No description provided for @mediaUploadEmpty.
  ///
  /// In en, this message translates to:
  /// **'The selected file is empty.'**
  String get mediaUploadEmpty;

  /// No description provided for @mediaOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get mediaOpenLink;

  /// No description provided for @mediaLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied.'**
  String get mediaLinkCopied;

  /// Elapsed full years
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} years} one{{count} year} other{{count} years}}'**
  String timelineElapsedYears(int count);

  /// Elapsed full months
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} months} one{{count} month} other{{count} months}}'**
  String timelineElapsedMonths(int count);

  /// Elapsed days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} days} one{{count} day} other{{count} days}}'**
  String timelineElapsedDays(int count);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Closes a bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settingsNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this section.'**
  String get settingsNoAccess;

  /// No description provided for @accountLocalAdmin.
  ///
  /// In en, this message translates to:
  /// **'Local administrator'**
  String get accountLocalAdmin;

  /// No description provided for @accountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignIn;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignInAction;

  /// No description provided for @accountSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}.'**
  String accountSignedIn(String name);

  /// No description provided for @accountSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out; local administrator mode is active.'**
  String get accountSignedOut;

  /// No description provided for @accountLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Wrong login or password.'**
  String get accountLoginFailed;

  /// No description provided for @accountAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get accountAccessTitle;

  /// No description provided for @accountAccessHint.
  ///
  /// In en, this message translates to:
  /// **'Choose which family profiles and events this account can see.'**
  String get accountAccessHint;

  /// No description provided for @accountAllMembers.
  ///
  /// In en, this message translates to:
  /// **'All family members'**
  String get accountAllMembers;

  /// No description provided for @accountVisibleEvents.
  ///
  /// In en, this message translates to:
  /// **'Visible events'**
  String get accountVisibleEvents;

  /// No description provided for @mediaUsagePersonTag.
  ///
  /// In en, this message translates to:
  /// **'{name} — tagged photo'**
  String mediaUsagePersonTag(String name);

  /// No description provided for @mediaUnused.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get mediaUnused;

  /// No description provided for @mediaOnlyUnused.
  ///
  /// In en, this message translates to:
  /// **'Only unused ({count})'**
  String mediaOnlyUnused(int count);

  /// No description provided for @mediaUseInProfile.
  ///
  /// In en, this message translates to:
  /// **'Use in a profile'**
  String get mediaUseInProfile;

  /// No description provided for @mediaUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Show this file in profiles'**
  String get mediaUseTitle;

  /// No description provided for @mediaUseNoMembers.
  ///
  /// In en, this message translates to:
  /// **'There are no family members to link this file to.'**
  String get mediaUseNoMembers;

  /// No description provided for @mediaUseApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get mediaUseApply;

  /// No description provided for @mediaUsed.
  ///
  /// In en, this message translates to:
  /// **'The file is now shown in the selected profiles.'**
  String get mediaUsed;

  /// Settings tab for the interface language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsTabLanguage;

  /// Caption of the interface language block
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get settingsLanguage;

  /// Explains that the language choice is stored locally
  ///
  /// In en, this message translates to:
  /// **'The choice is saved on this device.'**
  String get settingsLanguageHint;

  /// Option that follows the device language
  ///
  /// In en, this message translates to:
  /// **'Same as system'**
  String get settingsLanguageSystem;

  /// Russian language option
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsLanguageRussian;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Belarusian language option
  ///
  /// In en, this message translates to:
  /// **'Беларуская'**
  String get settingsLanguageBelarusian;

  /// Ukrainian language option
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get settingsLanguageUkrainian;

  /// No description provided for @familyCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud family'**
  String get familyCloudTitle;

  /// No description provided for @familyCloudHint.
  ///
  /// In en, this message translates to:
  /// **'Create a family to sync albums between devices, or join an existing one with an invite code.'**
  String get familyCloudHint;

  /// No description provided for @familyCloudCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a family'**
  String get familyCloudCreateTitle;

  /// No description provided for @familyCloudNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyCloudNameLabel;

  /// No description provided for @familyCloudNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Our big family'**
  String get familyCloudNameHint;

  /// No description provided for @familyCloudCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create and connect'**
  String get familyCloudCreateAction;

  /// No description provided for @familyCloudJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get familyCloudJoinTitle;

  /// No description provided for @familyCloudCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get familyCloudCodeLabel;

  /// No description provided for @familyCloudCodeHint.
  ///
  /// In en, this message translates to:
  /// **'8 characters, for example AB2CD3EF'**
  String get familyCloudCodeHint;

  /// No description provided for @familyCloudJoinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get familyCloudJoinAction;

  /// No description provided for @familyCloudInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'The code must contain 8 letters or digits.'**
  String get familyCloudInvalidCode;

  /// No description provided for @familyCloudJoinNotFound.
  ///
  /// In en, this message translates to:
  /// **'This invite code was not found or has expired.'**
  String get familyCloudJoinNotFound;

  /// No description provided for @familyCloudCreated.
  ///
  /// In en, this message translates to:
  /// **'Family created.'**
  String get familyCloudCreated;

  /// No description provided for @familyCloudJoined.
  ///
  /// In en, this message translates to:
  /// **'You joined the family.'**
  String get familyCloudJoined;

  /// No description provided for @familyCloudError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the request. Check your connection and try again.'**
  String get familyCloudError;

  /// No description provided for @familyCloudRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get familyCloudRetry;

  /// No description provided for @familyCloudOwnerBadge.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get familyCloudOwnerBadge;

  /// No description provided for @familyCloudPremiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get familyCloudPremiumActive;

  /// No description provided for @familyCloudPremiumFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get familyCloudPremiumFree;

  /// No description provided for @familyCloudInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite to the family'**
  String get familyCloudInviteTitle;

  /// No description provided for @familyCloudInviteHint.
  ///
  /// In en, this message translates to:
  /// **'Share this code: each person can use it once.'**
  String get familyCloudInviteHint;

  /// No description provided for @familyCloudInviteCreate.
  ///
  /// In en, this message translates to:
  /// **'Create invite code'**
  String get familyCloudInviteCreate;

  /// No description provided for @familyCloudInviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied.'**
  String get familyCloudInviteCopied;

  /// No description provided for @familyCloudNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Family name cannot be empty.'**
  String get familyCloudNameRequired;

  /// Technical family document id shown for support
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String familyCloudId(String id);

  /// No description provided for @familyCloudPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Data and privacy'**
  String get familyCloudPrivacyTitle;

  /// No description provided for @familyCloudPrivacyHint.
  ///
  /// In en, this message translates to:
  /// **'Your photos stay on this device. Deleting family data removes files and records from the cloud for every member.'**
  String get familyCloudPrivacyHint;

  /// No description provided for @familyCloudDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect this device'**
  String get familyCloudDisconnect;

  /// No description provided for @familyCloudDisconnectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Disconnect this device from the family? The local archive stays, cloud data is not deleted.'**
  String get familyCloudDisconnectConfirm;

  /// No description provided for @familyCloudDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Device disconnected from the family.'**
  String get familyCloudDisconnected;

  /// No description provided for @familyCloudDisconnectOwnerBlocked.
  ///
  /// In en, this message translates to:
  /// **'You are the owner, and other members are still in the family. Disconnect is unavailable — delete the family data or keep this device connected.'**
  String get familyCloudDisconnectOwnerBlocked;

  /// No description provided for @familyCloudDeleteCloud.
  ///
  /// In en, this message translates to:
  /// **'Delete family data from cloud'**
  String get familyCloudDeleteCloud;

  /// No description provided for @familyCloudDeleteCloudConfirm.
  ///
  /// In en, this message translates to:
  /// **'All family files, events and members will be permanently deleted from the cloud. This cannot be undone. Your local archive stays on this device.'**
  String get familyCloudDeleteCloudConfirm;

  /// No description provided for @familyCloudDeleteCloudDone.
  ///
  /// In en, this message translates to:
  /// **'Family data deleted from the cloud.'**
  String get familyCloudDeleteCloudDone;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @mediaLocalOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device only: no cloud family is connected. Set it up in Settings → Cloud family to sync your photos.'**
  String get mediaLocalOnlyNotice;

  /// No description provided for @mediaUploadAllLocal.
  ///
  /// In en, this message translates to:
  /// **'Upload all local files ({count})'**
  String mediaUploadAllLocal(int count);

  /// No description provided for @mediaUploadAllProgress.
  ///
  /// In en, this message translates to:
  /// **'Uploading {done} of {total}…'**
  String mediaUploadAllProgress(int done, int total);

  /// No description provided for @mediaUploadAllDone.
  ///
  /// In en, this message translates to:
  /// **'Uploaded to cloud: {count}'**
  String mediaUploadAllDone(int count);

  /// No description provided for @mediaUploadAllFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload: {count}'**
  String mediaUploadAllFailed(int count);

  /// No description provided for @mediaUploadUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'These files were stored on another device or lost after reinstall — please add them again.'**
  String get mediaUploadUnavailableHint;

  /// No description provided for @mediaOutboxRetry.
  ///
  /// In en, this message translates to:
  /// **'Queued: {count} — retry'**
  String mediaOutboxRetry(int count);

  /// No description provided for @syncStatusLoading.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncStatusLoading;

  /// No description provided for @syncStatusSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get syncStatusSaving;

  /// No description provided for @syncStatusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get syncStatusSaved;

  /// No description provided for @syncStatusError.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncStatusError;

  /// No description provided for @editModeEnter.
  ///
  /// In en, this message translates to:
  /// **'Edit mode'**
  String get editModeEnter;

  /// No description provided for @editModeExit.
  ///
  /// In en, this message translates to:
  /// **'Exit edit mode'**
  String get editModeExit;

  /// No description provided for @editModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Edit mode: tap the pencil on a card'**
  String get editModeBanner;

  /// No description provided for @editModeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editModeDone;

  /// No description provided for @adminOnlyAction.
  ///
  /// In en, this message translates to:
  /// **'Admin only'**
  String get adminOnlyAction;

  /// No description provided for @adminOnlyDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'Only an administrator can delete events and members.'**
  String get adminOnlyDeleteHint;

  /// No description provided for @adminOnlySettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Backups, accounts and the demo reset are available to administrators only.'**
  String get adminOnlySettingsHint;

  /// No description provided for @accountEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountEntryTitle;

  /// No description provided for @accountAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account'**
  String get accountAuthTitle;

  /// No description provided for @accountSignInTab.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignInTab;

  /// No description provided for @accountSignUpTab.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get accountSignUpTab;

  /// No description provided for @accountSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to load your family data.'**
  String get accountSignInSubtitle;

  /// No description provided for @accountSignUpHint.
  ///
  /// In en, this message translates to:
  /// **'A new account gets the viewer role. An administrator can change it later.'**
  String get accountSignUpHint;

  /// No description provided for @accountFirstAdminHint.
  ///
  /// In en, this message translates to:
  /// **'The first account of the family becomes an administrator.'**
  String get accountFirstAdminHint;

  /// Current account in the account sheet
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String accountSessionTitle(String name);

  /// No description provided for @accountManage.
  ///
  /// In en, this message translates to:
  /// **'Manage accounts'**
  String get accountManage;

  /// No description provided for @accountSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get accountSwitch;

  /// No description provided for @calendarViewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarViewMonth;

  /// No description provided for @calendarViewYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get calendarViewYear;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarAddEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get calendarAddEvent;

  /// No description provided for @calendarAddDate.
  ///
  /// In en, this message translates to:
  /// **'Add date'**
  String get calendarAddDate;

  /// No description provided for @calendarEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar date'**
  String get calendarEntryTitle;

  /// No description provided for @calendarEntryTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get calendarEntryTitleField;

  /// No description provided for @calendarEntryNoteField.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get calendarEntryNoteField;

  /// No description provided for @calendarEntryDateField.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get calendarEntryDateField;

  /// No description provided for @calendarEntryRecurring.
  ///
  /// In en, this message translates to:
  /// **'Repeat every year'**
  String get calendarEntryRecurring;

  /// No description provided for @calendarEntryHint.
  ///
  /// In en, this message translates to:
  /// **'This date appears only in the calendar and is not added to the timeline.'**
  String get calendarEntryHint;

  /// No description provided for @calendarEntrySaved.
  ///
  /// In en, this message translates to:
  /// **'Date added to the calendar.'**
  String get calendarEntrySaved;

  /// No description provided for @calendarEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Date removed from the calendar.'**
  String get calendarEntryDeleted;

  /// No description provided for @calendarEntryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit date'**
  String get calendarEntryEdit;

  /// No description provided for @calendarEntryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete date'**
  String get calendarEntryDelete;

  /// No description provided for @calendarEntryDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this date?'**
  String get calendarEntryDeleteConfirmTitle;

  /// No description provided for @calendarEntryDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The date will disappear from the calendar. Timeline events are not affected.'**
  String get calendarEntryDeleteConfirmBody;

  /// No description provided for @calendarEntryDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get calendarEntryDefaultTitle;

  /// No description provided for @calendarLegendEvent.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get calendarLegendEvent;

  /// No description provided for @calendarLegendBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get calendarLegendBirthday;

  /// No description provided for @eventShowInTimeline.
  ///
  /// In en, this message translates to:
  /// **'Show in timeline'**
  String get eventShowInTimeline;

  /// No description provided for @eventRecurringYearly.
  ///
  /// In en, this message translates to:
  /// **'Repeat every year'**
  String get eventRecurringYearly;

  /// No description provided for @eventCalendarOnlyBadge.
  ///
  /// In en, this message translates to:
  /// **'Calendar only'**
  String get eventCalendarOnlyBadge;

  /// No description provided for @eventMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Affects access and the profile. Tag several people on a photo in \"Who is in the photo\".'**
  String get eventMemberHint;

  /// No description provided for @eventNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get eventNewBadge;

  /// No description provided for @timelineOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get timelineOrderLabel;

  /// No description provided for @timelineOrderOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get timelineOrderOldest;

  /// No description provided for @timelineOrderNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get timelineOrderNewest;

  /// No description provided for @profileStories.
  ///
  /// In en, this message translates to:
  /// **'Interesting'**
  String get profileStories;

  /// No description provided for @profileStoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No stories yet.'**
  String get profileStoriesEmpty;

  /// No description provided for @profileStoriesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add story'**
  String get profileStoriesAdd;

  /// No description provided for @profileStoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete story'**
  String get profileStoryDelete;

  /// No description provided for @profileStoryTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get profileStoryTitleField;

  /// No description provided for @profileStoryTextField.
  ///
  /// In en, this message translates to:
  /// **'Story text'**
  String get profileStoryTextField;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get readLess;

  /// No description provided for @memberEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberEditorTitle;

  /// No description provided for @eventEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get eventEditorTitle;

  /// No description provided for @memberEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit member'**
  String get memberEdit;

  /// No description provided for @eventEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get eventEdit;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @familyCloudInviteCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get familyCloudInviteCopy;

  /// No description provided for @familyCloudInviteCopyHint.
  ///
  /// In en, this message translates to:
  /// **'The browser blocked copying: tap the copy icon next to the code.'**
  String get familyCloudInviteCopyHint;

  /// No description provided for @backupDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'The backup file has been downloaded by the browser.'**
  String get backupDownloadStarted;

  /// No description provided for @backupImportWrongFile.
  ///
  /// In en, this message translates to:
  /// **'Please choose an OurTree backup file (.json or .ourtree).'**
  String get backupImportWrongFile;

  /// No description provided for @backupImportTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than {mb} MB and may not fit into browser memory. Export a backup without media and try again.'**
  String backupImportTooLarge(int mb);

  /// No description provided for @backupImportUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The selected file could not be read. If it is stored in iCloud, download it to the device first.'**
  String get backupImportUnreadable;

  /// No description provided for @backupImportPartial.
  ///
  /// In en, this message translates to:
  /// **'{count} media files could not be restored.'**
  String backupImportPartial(int count);

  /// No description provided for @demoEditNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes stay on this device'**
  String get demoEditNoticeTitle;

  /// No description provided for @demoEditNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'The archive will not be saved to the cloud. Create a family and sign in to an account to keep the data and see it on other devices.'**
  String get demoEditNoticeBody;

  /// No description provided for @demoEditNoticeAction.
  ///
  /// In en, this message translates to:
  /// **'Create family'**
  String get demoEditNoticeAction;

  /// No description provided for @demoEditNoticeLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get demoEditNoticeLater;

  /// No description provided for @demoLocalOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Local archive only: not synced to the cloud'**
  String get demoLocalOnlyNotice;

  /// No description provided for @accountNoFamilyAttached.
  ///
  /// In en, this message translates to:
  /// **'This account is not linked to a family yet — connect by invite code in General settings → Cloud.'**
  String get accountNoFamilyAttached;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutHint.
  ///
  /// In en, this message translates to:
  /// **'Version, developer, documents and licenses.'**
  String get aboutHint;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'OurTree is a family album: profiles, timeline, calendar and media library. Data is kept on the device and synced to the cloud once a family is connected.'**
  String get aboutDescription;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersionLabel(String version);

  /// No description provided for @aboutPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get aboutPlatform;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContact;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get aboutTerms;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutChangelogTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get aboutChangelogTitle;

  /// No description provided for @aboutChangelog1.
  ///
  /// In en, this message translates to:
  /// **'Edits arrive from other devices without restarting the app'**
  String get aboutChangelog1;

  /// No description provided for @aboutChangelog2.
  ///
  /// In en, this message translates to:
  /// **'Photos are uploaded to the cloud automatically in a created family'**
  String get aboutChangelog2;

  /// No description provided for @aboutChangelog3.
  ///
  /// In en, this message translates to:
  /// **'Backup import works on iPhone (web version)'**
  String get aboutChangelog3;

  /// No description provided for @aboutChangelog4.
  ///
  /// In en, this message translates to:
  /// **'Invite code is copied automatically'**
  String get aboutChangelog4;

  /// No description provided for @aboutChangelog5.
  ///
  /// In en, this message translates to:
  /// **'Push notifications about birthdays, events and family updates'**
  String get aboutChangelog5;

  /// No description provided for @aboutSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get aboutSupport;

  /// No description provided for @aboutFamilyId.
  ///
  /// In en, this message translates to:
  /// **'Family ID'**
  String get aboutFamilyId;

  /// No description provided for @aboutCopyFamilyId.
  ///
  /// In en, this message translates to:
  /// **'Copy family ID'**
  String get aboutCopyFamilyId;

  /// No description provided for @aboutFamilyIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Family ID copied.'**
  String get aboutFamilyIdCopied;

  /// No description provided for @aboutNoFamily.
  ///
  /// In en, this message translates to:
  /// **'No family connected yet: connect one in General settings → Cloud.'**
  String get aboutNoFamily;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} OurTree'**
  String aboutCopyright(int year);

  /// No description provided for @aboutLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get aboutLinkFailed;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Birthdays, calendar events and family updates.'**
  String get notificationsHint;

  /// No description provided for @notificationsStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Status on this device'**
  String get notificationsStatusTitle;

  /// No description provided for @notificationsEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationsEnable;

  /// No description provided for @notificationsDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get notificationsDisable;

  /// No description provided for @notificationsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh token'**
  String get notificationsRefresh;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are on: reminders and family updates will arrive on this device.'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off. Enable them to get reminders.'**
  String get notificationsDisabled;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked in the browser or system settings. Allow them for this app and try again.'**
  String get notificationsDenied;

  /// No description provided for @notificationsNoFamily.
  ///
  /// In en, this message translates to:
  /// **'Connect a family first: reminders are sent for your family archive.'**
  String get notificationsNoFamily;

  /// No description provided for @notificationsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not enable notifications.'**
  String get notificationsFailed;

  /// No description provided for @notificationsFailedNoKey.
  ///
  /// In en, this message translates to:
  /// **'This build has no web-push key (FIREBASE_VAPID_KEY). Rebuild with --dart-define-from-file.'**
  String get notificationsFailedNoKey;

  /// No description provided for @notificationsFailedPermission.
  ///
  /// In en, this message translates to:
  /// **'The browser did not grant permission.'**
  String get notificationsFailedPermission;

  /// No description provided for @notificationsFailedToken.
  ///
  /// In en, this message translates to:
  /// **'Could not get a device token.'**
  String get notificationsFailedToken;

  /// No description provided for @notificationsPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'What to send'**
  String get notificationsPrefsTitle;

  /// No description provided for @notificationsBirthdays.
  ///
  /// In en, this message translates to:
  /// **'Birthdays'**
  String get notificationsBirthdays;

  /// No description provided for @notificationsBirthdaysHint.
  ///
  /// In en, this message translates to:
  /// **'The day before and on the day itself.'**
  String get notificationsBirthdaysHint;

  /// No description provided for @notificationsCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar events'**
  String get notificationsCalendar;

  /// No description provided for @notificationsCalendarHint.
  ///
  /// In en, this message translates to:
  /// **'Events marked \"show in calendar\".'**
  String get notificationsCalendarHint;

  /// No description provided for @notificationsFamilyUpdates.
  ///
  /// In en, this message translates to:
  /// **'Family updates'**
  String get notificationsFamilyUpdates;

  /// No description provided for @notificationsFamilyUpdatesHint.
  ///
  /// In en, this message translates to:
  /// **'When someone edits the shared archive.'**
  String get notificationsFamilyUpdatesHint;

  /// No description provided for @notificationsIosHint.
  ///
  /// In en, this message translates to:
  /// **'On iPhone notifications only work in the app added to the Home Screen (iOS 16.4+).'**
  String get notificationsIosHint;

  /// No description provided for @notificationsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get notificationsUpcoming;

  /// No description provided for @notificationsUpcomingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No birthdays or events in the next 7 days.'**
  String get notificationsUpcomingEmpty;

  /// No description provided for @settingsResetLocal.
  ///
  /// In en, this message translates to:
  /// **'Reset to the cloud copy'**
  String get settingsResetLocal;

  /// No description provided for @settingsResetLocalHint.
  ///
  /// In en, this message translates to:
  /// **'Replace local edits with the family data'**
  String get settingsResetLocalHint;

  /// No description provided for @settingsResetLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace local data?'**
  String get settingsResetLocalTitle;

  /// No description provided for @settingsResetLocalConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Local edits will be replaced with the current family copy from the cloud. The demo archive is not kept inside a connected family.'**
  String get settingsResetLocalConfirmBody;

  /// No description provided for @settingsResetLocalAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get settingsResetLocalAction;

  /// No description provided for @settingsResetLocalDone.
  ///
  /// In en, this message translates to:
  /// **'Local data replaced with the cloud copy.'**
  String get settingsResetLocalDone;

  /// No description provided for @mediaSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press a file to select several.'**
  String get mediaSelectHint;

  /// No description provided for @mediaSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String mediaSelectedCount(int count);

  /// No description provided for @mediaSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get mediaSelectAll;

  /// No description provided for @mediaSelectNone.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get mediaSelectNone;

  /// No description provided for @mediaDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get mediaDeleteSelected;

  /// No description provided for @mediaDeleteManyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete selected files?'**
  String get mediaDeleteManyTitle;

  /// No description provided for @mediaDeleteManyBody.
  ///
  /// In en, this message translates to:
  /// **'Files ({count}) will be removed from the archive and the cloud.'**
  String mediaDeleteManyBody(int count);

  /// No description provided for @mediaDeleteManyDone.
  ///
  /// In en, this message translates to:
  /// **'Deleted files: {count}'**
  String mediaDeleteManyDone(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['be', 'en', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'be':
      return AppLocalizationsBe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
