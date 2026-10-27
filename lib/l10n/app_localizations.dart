import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('ru')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'OurTree App'**
  String get appTitle;

  /// Welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to OurTree'**
  String get welcomeTitle;

  /// Welcome screen message
  ///
  /// In en, this message translates to:
  /// **'This is a clean Flutter project with localizations for ru/en and Riverpod state management.'**
  String get welcomeMessage;

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

  /// Small label above the family title
  ///
  /// In en, this message translates to:
  /// **'Seven branches of one tree'**
  String get familyEyebrow;

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

  /// Data source section label
  ///
  /// In en, this message translates to:
  /// **'Data source'**
  String get settingsDataSource;

  /// Description of the bundled family archive
  ///
  /// In en, this message translates to:
  /// **'Family archive from assets/data/family.json'**
  String get settingsArchiveSource;

  /// Button that reloads family data
  ///
  /// In en, this message translates to:
  /// **'Reload data'**
  String get settingsReload;

  /// Confirmation after reloading data
  ///
  /// In en, this message translates to:
  /// **'Family data reloaded.'**
  String get settingsReloadStarted;

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

  /// No description provided for @settingsMediaHint.
  ///
  /// In en, this message translates to:
  /// **'One place for every photo and video. Descriptions and cropping are set individually for each member or event.'**
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
  /// **'Create family accounts, assign roles and issue guest links.'**
  String get settingsAccountsHint;

  /// No description provided for @settingsAccountsLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Accounts and guest links are kept in the app until you restart it.'**
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
  /// **'Related member'**
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
  /// **'Login must be 2–32 characters: letters, digits, dot, dash or underscore.'**
  String get accountLoginInvalid;

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
  /// **'DD.MM.YYYY'**
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

  /// No description provided for @videoConvert.
  ///
  /// In en, this message translates to:
  /// **'Convert to WebM'**
  String get videoConvert;

  /// No description provided for @videoConverting.
  ///
  /// In en, this message translates to:
  /// **'Converting…'**
  String get videoConverting;

  /// No description provided for @videoConverted.
  ///
  /// In en, this message translates to:
  /// **'Video converted to WebM.'**
  String get videoConverted;

  /// No description provided for @videoConvertFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not convert the video.'**
  String get videoConvertFailed;

  /// No description provided for @videoConvertHint.
  ///
  /// In en, this message translates to:
  /// **'Conversion runs in the browser. Keep this screen open until it finishes.'**
  String get videoConvertHint;

  /// No description provided for @mediaCropX.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get mediaCropX;

  /// No description provided for @mediaCropY.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get mediaCropY;

  /// No description provided for @mediaZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get mediaZoom;

  /// No description provided for @mediaCropHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the photo and pinch to zoom'**
  String get mediaCropHint;

  /// No description provided for @mediaCropReset.
  ///
  /// In en, this message translates to:
  /// **'Reset crop'**
  String get mediaCropReset;

  /// No description provided for @mediaZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get mediaZoomIn;

  /// No description provided for @mediaZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get mediaZoomOut;

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
  /// **'Photos and videos up to 20 MB. Files are stored locally on this device.'**
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
