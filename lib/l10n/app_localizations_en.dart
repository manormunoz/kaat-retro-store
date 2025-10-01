// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get initDb => 'Initializing the database, do not close';

  @override
  String get version => 'Version';

  @override
  String get configuration => 'Configuration';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get labelGoBack => 'Go back';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get labelSave => 'Save';

  @override
  String get authCancelButton => 'Cancel';

  @override
  String get errorRequired => 'Required.';

  @override
  String get noConnection => 'No internet connection';

  @override
  String get noPlatforms => 'No platforms to show';

  @override
  String get noRoms => 'No ROMs to show';

  @override
  String get searchoRoms => 'Search ROM name...';

  @override
  String get creditsTitle => 'Acknowledgments / Credits';

  @override
  String get creditsProjectsTitle => 'Projects & Services';

  @override
  String get creditsNotesTitle => 'Notes';

  @override
  String get creditsMyrient => 'Directory listings for No-Intro / Redump sets';

  @override
  String get creditsJsDelivr => 'Global CDN for GitHub-hosted assets';

  @override
  String get creditsLibretroThumbs => 'Community boxarts, logos, snaps';

  @override
  String get creditsLibretro => 'Emulation ecosystem & assets';

  @override
  String get creditsScreenScraper =>
      'ScreenScraper — Game metadata, covers, screenshots, and more';

  @override
  String get creditsNotes =>
      'K\'aat Retro Store does not host ROMs or media. All images, logos, and metadata belong to their respective owners. Please follow each project’s terms.';

  @override
  String get romNoMetadata => 'Metadata not found';

  @override
  String get synopsis => 'Synopsis';

  @override
  String get openLink => 'Open Link';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get linkCopied => 'Link copied!';

  @override
  String get ssConfigTitle => 'Set up your ScreenScraper credentials';

  @override
  String get ssUsernameLabel => 'Username (ssid)';

  @override
  String get ssPasswordLabel => 'Password (sspassword)';

  @override
  String get ssRememberDevice => 'Remember on this device';

  @override
  String get ssClearedMessage => 'Credentials removed';

  @override
  String get ssSavedMessage => 'Credentials updated';

  @override
  String get ssClearButton => 'Clear';

  @override
  String get ssSaveButton => 'Save';

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadsNoActiveDownloads => 'No active downloads';

  @override
  String get downloadsDownloadsClearBtn => 'Clear downloads';

  @override
  String get downloadsDownloadsCleared => 'Downloads cleared';

  @override
  String get downloadsStatusEnqueued => 'Enqueued';

  @override
  String get downloadsStatusRunning => 'Downloading';

  @override
  String get downloadsStatusComplete => 'Completed';

  @override
  String get downloadsStatusPaused => 'Paused';

  @override
  String get downloadsStatusCanceled => 'Canceled';

  @override
  String get downloadsStatusFailed => 'Failed';

  @override
  String get downloadsStatusWaitingToRetry => 'Waiting to retry';

  @override
  String get downloadsStatusNotFound => 'Not found';

  @override
  String get downloadsRomAdded => 'ROM added to the download list';

  @override
  String get downloadsActionDownload => 'Download';

  @override
  String get downloadsSelectFolderRequired => 'A folder must be selected';

  @override
  String downloadsFoldersReferencesRemoved(Object total) {
    return '$total folder reference(s) removed';
  }

  @override
  String get downloadsFolderSelectionOnceTitle => 'Select folder';

  @override
  String get downloadsFolderSelectionOnceMsg =>
      'Folder selection is only once per platform';

  @override
  String get downloadsActionsButton => 'More actions';

  @override
  String get downloadsClearAllDescription =>
      'Clears the list of completed and canceled downloads.';

  @override
  String get downloadsClearFolderPermissionsTitle =>
      'Remove folder permissions';

  @override
  String get downloadsClearFolderPermissionsDescription =>
      'Forget the folders previously authorized for downloads.';
}
