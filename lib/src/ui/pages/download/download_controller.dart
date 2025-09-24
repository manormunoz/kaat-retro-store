import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/widgets/app_snackbar/app_snackbar.dart';
import 'package:path_provider/path_provider.dart';

class DownloadItem {
  DownloadItem({
    required this.task,
    required this.subdir,
    this.progress = 0.0,
    this.status = TaskStatus.enqueued,
    this.localPath,
  });

  final UriDownloadTask task; // guardamos el DownloadTask
  double progress; // 0..1
  TaskStatus status;
  String? localPath;
  String subdir;

  String get taskId => task.taskId;
  String get filename => task.filename;

  // Helpers para identificar estado
  bool get isInProgress => [
        TaskStatus.running,
        TaskStatus.enqueued,
        TaskStatus.waitingToRetry,
      ].contains(status);

  bool get isCompleted => status == TaskStatus.complete;
  bool get isFailed => status == TaskStatus.failed;
  bool get isPaused => status == TaskStatus.paused;
  bool get isCanceled => status == TaskStatus.canceled;

  // Helper para obtener descripción del estado
  String get statusDescription {
    switch (status) {
      case TaskStatus.enqueued:
        return AppLocalizations.of(Get.context!)!.downloadsStatusEnqueued;
      case TaskStatus.running:
        return AppLocalizations.of(Get.context!)!.downloadsStatusRunning;
      case TaskStatus.complete:
        return AppLocalizations.of(Get.context!)!.downloadsStatusComplete;
      case TaskStatus.paused:
        return AppLocalizations.of(Get.context!)!.downloadsStatusPaused;
      case TaskStatus.canceled:
        return AppLocalizations.of(Get.context!)!.downloadsStatusCanceled;
      case TaskStatus.failed:
        return AppLocalizations.of(Get.context!)!.downloadsStatusFailed;
      case TaskStatus.waitingToRetry:
        return AppLocalizations.of(Get.context!)!.downloadsStatusWaitingToRetry;
      case TaskStatus.notFound:
        return AppLocalizations.of(Get.context!)!.downloadsStatusNotFound;
    }
  }
}

class DownloadController extends GetxController {
  final downloads = <String, DownloadItem>{}.obs; // taskId -> item
  late final String _baseDir;
  final _box = GetStorage();

  @override
  Future<void> onInit() async {
    super.onInit();

    final dir = await getApplicationSupportDirectory();
    _baseDir = dir.path;

    // await FileDownloader().configure(
    //   globalConfig: [
    //     // activa holding queue
    //     (Config.holdingQueue, (10, 2, null)),

    //     // desactiva logs globales
    //     ('logging', Config.never),
    //   ],
    // );
    await FileDownloader().configure(globalConfig: [
      (Config.holdingQueue, (10, 2, null)),
      (Config.requestTimeout, const Duration(seconds: 100)),
      // (Config.logging, false),
    ], androidConfig: [
      (Config.useCacheDir, Config.whenAble),
      ('logging', false),
    ], iOSConfig: [
      (Config.localize, {'Cancel': 'StopIt'}),
    ]);
    // debugPrint('Configuration result = $result');

    // Un solo stream para status + progreso
    FileDownloader().updates.listen((update) async {
      if (update is TaskProgressUpdate) {
        final id = update.task.taskId;
        final it = downloads[id];
        if (it != null) {
          it.progress = update.progress;
          downloads.refresh();
        }
      } else if (update is TaskStatusUpdate) {
        final id = update.task.taskId;
        final it = downloads[id];
        if (it != null) {
          it.status = update.status;
          final uri = getSavedFolderUri(it.subdir);
          if (uri == null && update.status == TaskStatus.complete) {
            // ruta final del archivo (si la necesitas)
            try {
              final path = await update.task.filePath();
              debugPrint(
                '-----------------------------------------------------------------------------------------------------------------------------------------------------',
              );
              debugPrint(path);
              it.localPath = path;
              final finalPath = await moveDownloadToSharedStorageById(
                id,
                directory: it.subdir,
              );
              if (finalPath != null) {
                it.localPath = finalPath; // ahora apunta a /Download/...
              }
            } catch (_) {}
          }
          downloads.refresh();
        }
      }
    });
    await FileDownloader().start();
  }

  // ==================== CONSULTAS POR ESTADO ====================

  /// Obtiene todas las descargas que están actualmente en progreso
  List<DownloadItem> get downloadsInProgress {
    return downloads.values.where((item) => item.isInProgress).toList();
  }

  /// Obtiene solo las descargas que están ejecutándose activamente
  List<DownloadItem> get activeDownloads {
    return downloads.values
        .where((item) => item.status == TaskStatus.running)
        .toList();
  }

  /// Obtiene las descargas completadas
  List<DownloadItem> get completedDownloads {
    return downloads.values.where((item) => item.isCompleted).toList();
  }

  /// Obtiene las descargas fallidas
  List<DownloadItem> get failedDownloads {
    return downloads.values.where((item) => item.isFailed).toList();
  }

  /// Obtiene las descargas pausadas
  List<DownloadItem> get pausedDownloads {
    return downloads.values.where((item) => item.isPaused).toList();
  }

  /// Obtiene las descargas en cola (enqueued)
  List<DownloadItem> get queuedDownloads {
    return downloads.values
        .where((item) => item.status == TaskStatus.enqueued)
        .toList();
  }

  /// Obtiene las descargas canceladas
  List<DownloadItem> get canceledDownloads {
    return downloads.values.where((item) => item.isCanceled).toList();
  }

  // ==================== CONSULTAS POR SUBDIRECTORIO ====================

  /// Obtiene descargas por subdirectorio específico
  List<DownloadItem> getDownloadsBySubdir(String subdir) {
    return downloads.values.where((item) => item.subdir == subdir).toList();
  }

  /// Obtiene descargas en progreso por subdirectorio
  List<DownloadItem> getInProgressBySubdir(String subdir) {
    return downloads.values
        .where((item) => item.subdir == subdir && item.isInProgress)
        .toList();
  }

  /// Obtiene descargas completadas por subdirectorio
  List<DownloadItem> getCompletedBySubdir(String subdir) {
    return downloads.values
        .where((item) => item.subdir == subdir && item.isCompleted)
        .toList();
  }

  // ==================== ESTADÍSTICAS ====================

  /// Contador de descargas en progreso
  int get inProgressCount => downloadsInProgress.length;

  /// Contador de descargas completadas
  int get completedCount => completedDownloads.length;

  /// Contador de descargas fallidas
  int get failedCount => failedDownloads.length;

  /// Contador de descargas pausadas
  int get pausedCount => pausedDownloads.length;

  /// Contador total de descargas
  int get totalCount => downloads.length;

  /// Progreso total promedio de descargas activas
  double get overallProgress {
    final activeItems = downloadsInProgress;
    if (activeItems.isEmpty) return 0.0;

    final totalProgress =
        activeItems.fold<double>(0.0, (sum, item) => sum + item.progress);
    return totalProgress / activeItems.length;
  }

  /// Obtiene un resumen del estado actual
  Map<String, int> get downloadSummary => {
        'total': totalCount,
        'inProgress': inProgressCount,
        'completed': completedCount,
        'failed': failedCount,
        'paused': pausedCount,
        'queued': queuedDownloads.length,
        'canceled': canceledDownloads.length,
      };

  // ==================== BÚSQUEDA Y FILTRADO ====================

  /// Busca descargas por nombre de archivo
  List<DownloadItem> searchByFilename(String query) {
    final lowerQuery = query.toLowerCase();
    return downloads.values
        .where((item) => item.filename.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Obtiene descarga por taskId
  DownloadItem? getDownloadById(String taskId) {
    return downloads[taskId];
  }

  /// Verifica si una descarga existe por taskId
  bool hasDownload(String taskId) {
    return downloads.containsKey(taskId);
  }

  /// Verifica si hay descargas activas
  bool get hasActiveDownloads => activeDownloads.isNotEmpty;

  /// Verifica si hay descargas en progreso
  bool get hasDownloadsInProgress => inProgressCount > 0;

  // ==================== MÉTODOS ORIGINALES ====================

  Future<String?> moveDownloadToSharedStorageById(
    String taskId, {
    required String directory,
    String? mimeType,
  }) async {
    SharedStorage storage = SharedStorage.downloads;
    // if (Platform.isIOS) {
    //   // En iOS usa documents, que es accesible por el usuario a través de Files app
    //   storage = SharedStorage.files;
    // } else if (Platform.isAndroid) {
    //   // En Android usa downloads
    //   storage = SharedStorage.downloads;
    // } else {
    //   // Para otras plataformas, usa documents como fallback
    //   storage = SharedStorage.files;
    // }

    // 1) Intenta recuperar el DownloadTask original
    final task = await FileDownloader().taskForId(taskId);
    if (task is DownloadTask) {
      return FileDownloader().moveToSharedStorage(
        task,
        storage,
        directory: directory,
        mimeType: mimeType,
      );
    }

    // 2) Fallback: usa la base para obtener la ruta y mover por filePath
    final rec = await FileDownloader().database.recordForId(taskId);
    final path = await rec?.task.filePath();
    final filePath = path ??
        (rec?.task is DownloadTask
            ? await (rec!.task as DownloadTask).filePath()
            : null);

    if (filePath != null) {
      return FileDownloader().moveFileToSharedStorage(
        filePath,
        storage,
        directory: directory,
        mimeType: mimeType,
      );
    }

    return null;
  }

  Future<void> clearCompleted() async {
    final toRemove = <String>[];

    for (var entry in downloads.entries) {
      final id = entry.key;
      final item = entry.value;

      if (item.status == TaskStatus.complete) {
        // 1. Borrar archivo si existe
        if (item.localPath != null) {
          final file = File(item.localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // 2. Borrar registro del plugin
        await FileDownloader().database.deleteRecordWithId(id);

        // 3. Marcar para limpiar del mapa
        toRemove.add(id);
      }
    }

    // 4. Limpiar del observable
    for (var id in toRemove) {
      downloads.remove(id);
    }
  }

  /// Encola una descarga y la registra en el mapa
  Future<String?> enqueue({
    required String url,
    required String subdir, // p.ej. 'roms'
    String? filename,
    bool requiresWifi = false,
  }) async {
    final destUri = await pickFolder(subdir);
    if (destUri == null) {
      Get.showSnackbar(AppSnackbar(
        SnackbarType.danger,
        AppLocalizations.of(Get.context!)!.downloadsSelectFolderRequired,
      ));

      return null;
    }
    final uri = Uri.parse(url);
    final filenameSfe = filename ??
        (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'unknown.file');

    final task = UriDownloadTask(
      url: url,
      directoryUri: destUri,
      filename: filenameSfe,
      updates: Updates.statusAndProgress,
      requiresWiFi: requiresWifi,
      allowPause: true,
      retries: 2,
    );
    //  DownloadTask(
    //     url: url,
    //     filename: filenameSfe,
    //     baseDirectory: BaseDirectory.applicationSupport,
    //     directory: subdir,
    //     updates: Updates.statusAndProgress,
    //     requiresWiFi: requiresWifi,
    //     allowPause: true,
    //     retries: 2,
    //   );

    final localPath = '$_baseDir/$subdir/$filenameSfe';
    debugPrint(localPath);
    downloads[task.taskId] = DownloadItem(
      task: task,
      progress: 0,
      subdir: subdir,
      status: TaskStatus.enqueued,
      localPath: localPath,
    );

    await FileDownloader().enqueue(task);
    return task.taskId;
  }

  /// Pausar por taskId (necesita DownloadTask)
  Future<void> pause(String taskId) async {
    final it = downloads[taskId];
    if (it != null) {
      await FileDownloader().pause(it.task);
      return;
    }
    // Si no está en memoria, intenta leer de la DB y castear
    final rec = await FileDownloader().database.recordForId(taskId);
    final task = rec?.task;
    if (task is DownloadTask) {
      await FileDownloader().pause(task);
    }
  }

  /// Reanudar por taskId (necesita DownloadTask)
  Future<void> resume(String taskId) async {
    final it = downloads[taskId];
    if (it != null) {
      await FileDownloader().resume(it.task);
      return;
    }
    final rec = await FileDownloader().database.recordForId(taskId);
    final task = rec?.task;
    if (task is DownloadTask) {
      await FileDownloader().resume(task);
    }
  }

  /// Cancelar por taskId
  Future<void> cancel(String taskId) async {
    await FileDownloader().cancelTaskWithId(taskId);
    final it = downloads[taskId];
    if (it != null) {
      it.status = TaskStatus.canceled;
      downloads.refresh();
    }
  }

  /// Obtener el File descargado a partir del taskId
  Future<File?> getDownloadedFile(String taskId) async {
    final rec = await FileDownloader().database.recordForId(taskId);
    if (rec == null) return null;
    try {
      final path = await rec.task.filePath();
      final file = File(path);
      return await file.exists() ? file : null;
    } catch (_) {
      return null;
    }
  }

  Future<Uri?> pickFolder(String subdir) async {
    final cached = getSavedFolderUri(subdir);
    if (cached != null) {
      return cached;
    }

    // Abre el picker de directorio (Android → SAF, iOS → UIDocumentPicker)
    final Uri? folderUri = await FileDownloader().uri.pickDirectory(
          persistedUriPermission: true,
        );

    if (folderUri != null) {
      debugPrint('Carpeta elegida: $folderUri');
      await saveFolderUri(subdir, folderUri);
      return folderUri;
    } else {
      debugPrint('Usuario canceló selección de carpeta');
      return null;
    }
  }

  Future<void> saveFolderUri(String subdir, Uri folderUri) async {
    await _box.write('downloads_folder_${subdir}_uri', folderUri.toString());
  }

  Uri? getSavedFolderUri(String subdir) {
    final uriStr = _box.read<String>('downloads_folder_${subdir}_uri');
    return uriStr != null ? Uri.parse(uriStr) : null;
  }

  Future<int> removeAllDownloadFolderUris() async {
    final allKeys = _box.getKeys().whereType<String>().toList(growable: false);

    // 2) Filtra las que te interesan
    final toDelete = allKeys
        .where((k) => k.startsWith('downloads_folder_') && k.endsWith('_uri'))
        .toList(growable: false);

    // 3) Borra sobre la lista materializada (¡no sobre el iterable original!)
    for (final k in toDelete) {
      await _box.remove(k);
    }

    return toDelete.length;
  }

  Future<void> removeDownloadFolderUri(String subdir) async {
    final key = 'downloads_folder_${subdir}_uri';
    await _box.remove(key);
  }

  List<String> listDownloadFolderUris() {
    return _box
        .getKeys()
        .whereType<String>()
        .where((k) => k.startsWith('downloads_folder_') && k.endsWith('_uri'))
        .toList();
  }
}
