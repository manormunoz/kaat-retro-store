// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get initDb => 'Inicializando la base de datos, no cerrar';

  @override
  String get version => 'Versión';

  @override
  String get configuration => 'Configuración';

  @override
  String get darkTheme => 'Tema obscuro';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get labelGoBack => 'Regresar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Aceptar';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get labelSave => 'Guardar';

  @override
  String get authCancelButton => 'Cancelar';

  @override
  String get errorRequired => 'Requerido.';

  @override
  String get noConnection => 'Sin conexión a internet';

  @override
  String get noPlatforms => 'Sin plataformas por mostrar';

  @override
  String get noRoms => 'Sin ROMs por mostrar';

  @override
  String get searchoRoms => 'Buscar ROM por nombre...';

  @override
  String get creditsTitle => 'Agradecimientos / Créditos';

  @override
  String get creditsProjectsTitle => 'Proyectos & Servicios';

  @override
  String get creditsNotesTitle => 'Notas';

  @override
  String get creditsMyrient =>
      'Listados de directorios para sets No-Intro / Redump';

  @override
  String get creditsJsDelivr => 'CDN global para assets alojados en GitHub';

  @override
  String get creditsLibretroThumbs =>
      'Carátulas, logos y capturas de la comunidad';

  @override
  String get creditsLibretro => 'Ecosistema de emulación y assets';

  @override
  String get creditsScreenScraper =>
      'Metadatos de juegos, carátulas, capturas de pantalla y más';

  @override
  String get creditsNotes =>
      'K\'aat Retro Store no hospeda ROMs ni medios. Todas las imágenes, logos y metadatos pertenecen a sus respectivos dueños. Por favor, respeta los términos de cada proyecto.';

  @override
  String get romNoMetadata => 'Sin metadata';

  @override
  String get synopsis => 'Sinopsis';

  @override
  String get openLink => 'Abrir Link';

  @override
  String get copyLink => 'Copiar Link';

  @override
  String get linkCopied => '!Link copiado!';

  @override
  String get ssConfigTitle => 'Configura tus credenciales de ScreenScraper';

  @override
  String get ssUsernameLabel => 'Usuario (ssid)';

  @override
  String get ssPasswordLabel => 'Contraseña (sspassword)';

  @override
  String get ssRememberDevice => 'Recordar en este dispositivo';

  @override
  String get ssClearedMessage => 'Credenciales eliminadas';

  @override
  String get ssSavedMessage => 'Credenciales actualizadas';

  @override
  String get ssClearButton => 'Limpiar';

  @override
  String get ssSaveButton => 'Guardar';

  @override
  String get downloadsTitle => 'Descargas';

  @override
  String get downloadsNoActiveDownloads => 'No hay descargas activas';

  @override
  String get downloadsDownloadsClearBtn => 'Eliminar descargas';

  @override
  String get downloadsDownloadsCleared => 'Descargas eliminadas';

  @override
  String get downloadsStatusEnqueued => 'En cola';

  @override
  String get downloadsStatusRunning => 'Descargando';

  @override
  String get downloadsStatusComplete => 'Completado';

  @override
  String get downloadsStatusPaused => 'Pausado';

  @override
  String get downloadsStatusCanceled => 'Cancelado';

  @override
  String get downloadsStatusFailed => 'Error';

  @override
  String get downloadsStatusWaitingToRetry => 'Pendiente de reintento';

  @override
  String get downloadsStatusNotFound => 'No encontrado';

  @override
  String get downloadsRomAdded => 'ROM agregado a la lista de descargas';

  @override
  String get downloadsActionDownload => 'Descargar';

  @override
  String get downloadsSelectFolderRequired =>
      'Es necesario seleccionar una carpeta';

  @override
  String downloadsFoldersReferencesRemoved(Object total) {
    return 'Se eliminaron $total referencias de carpetas';
  }

  @override
  String get downloadsFolderSelectionOnceTitle => 'Seleccionar carpeta';

  @override
  String get downloadsFolderSelectionOnceMsg =>
      'La selección de carpeta es sólo una vez por plataforma';

  @override
  String get downloadsActionsButton => 'Más acciones';

  @override
  String get downloadsClearAllDescription =>
      'Limpia la lista de descargas completadas y canceladas.';

  @override
  String get downloadsClearFolderPermissionsTitle =>
      'Eliminar permisos de carpetas';

  @override
  String get downloadsClearFolderPermissionsDescription =>
      'Olvida las carpetas autorizadas previamente para las descargas.';

  @override
  String get noConnectionDescription =>
      'Revisa tu conexión a internet e inténtalo de nuevo.';
}
