import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es'),
  ];

  /// No description provided for @initDb.
  ///
  /// In en, this message translates to:
  /// **'Initializing the database'**
  String get initDb;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @configuration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// No description provided for @labelGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get labelGoBack;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Sistema'**
  String get systemLanguage;

  /// No description provided for @labelSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get labelSave;

  /// No description provided for @authCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authCancelButton;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'Required.'**
  String get errorRequired;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noConnection;

  /// No description provided for @noPlatforms.
  ///
  /// In en, this message translates to:
  /// **'No platforms to show'**
  String get noPlatforms;

  /// No description provided for @noRoms.
  ///
  /// In en, this message translates to:
  /// **'No ROMs to show'**
  String get noRoms;

  /// No description provided for @searchoRoms.
  ///
  /// In en, this message translates to:
  /// **'Search ROM name...'**
  String get searchoRoms;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgments / Credits'**
  String get creditsTitle;

  /// No description provided for @creditsProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects & Services'**
  String get creditsProjectsTitle;

  /// No description provided for @creditsNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get creditsNotesTitle;

  /// No description provided for @creditsMyrient.
  ///
  /// In en, this message translates to:
  /// **'Directory listings for No-Intro / Redump sets'**
  String get creditsMyrient;

  /// No description provided for @creditsJsDelivr.
  ///
  /// In en, this message translates to:
  /// **'Global CDN for GitHub-hosted assets'**
  String get creditsJsDelivr;

  /// No description provided for @creditsLibretroThumbs.
  ///
  /// In en, this message translates to:
  /// **'Community boxarts, logos, snaps'**
  String get creditsLibretroThumbs;

  /// No description provided for @creditsLibretro.
  ///
  /// In en, this message translates to:
  /// **'Emulation ecosystem & assets'**
  String get creditsLibretro;

  /// No description provided for @creditsScreenScraper.
  ///
  /// In en, this message translates to:
  /// **'ScreenScraper — Game metadata, covers, screenshots, and more'**
  String get creditsScreenScraper;

  /// No description provided for @creditsNotes.
  ///
  /// In en, this message translates to:
  /// **'K\'aat Retro Store does not host ROMs or media. All images, logos, and metadata belong to their respective owners. Please follow each project’s terms.'**
  String get creditsNotes;

  /// No description provided for @romNoMetadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata not found'**
  String get romNoMetadata;

  /// No description provided for @synopsis.
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get synopsis;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open Link'**
  String get openLink;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get linkCopied;

  /// No description provided for @ssConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your ScreenScraper credentials'**
  String get ssConfigTitle;

  /// No description provided for @ssUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username (ssid)'**
  String get ssUsernameLabel;

  /// No description provided for @ssPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password (sspassword)'**
  String get ssPasswordLabel;

  /// No description provided for @ssRememberDevice.
  ///
  /// In en, this message translates to:
  /// **'Remember on this device'**
  String get ssRememberDevice;

  /// No description provided for @ssClearedMessage.
  ///
  /// In en, this message translates to:
  /// **'Credentials removed'**
  String get ssClearedMessage;

  /// No description provided for @ssSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Credentials updated'**
  String get ssSavedMessage;

  /// No description provided for @ssClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get ssClearButton;

  /// No description provided for @ssSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get ssSaveButton;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
