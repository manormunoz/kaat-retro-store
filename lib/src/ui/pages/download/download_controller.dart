import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as p;
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/widgets/app_snackbar/app_snackbar.dart';

class DownloadItem {
  DownloadItem({
    required this.task,
    required this.subdir,
    this.progress = 0.0,
    this.status = TaskStatus.enqueued,
    List<String>? imageUrls,
  }) : imageUrls = List.unmodifiable(imageUrls ?? const []);

  final DownloadTask task; // guardamos el DownloadTask (Uri or plain)
  double progress; // 0..1
  TaskStatus status;
  String subdir;
  final List<String> imageUrls;

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
  final _box = GetStorage();
  StreamSubscription<TaskRecord>? _databaseSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();

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

    // Registering a callback and configure notifications
    FileDownloader()
        .registerCallbacks(taskNotificationTapCallback:
            (Task task, NotificationType notificationType) {
          debugPrint(
              'Tapped notification $notificationType for taskId ${task.taskId}');
        })
        .configureNotificationForGroup(FileDownloader.defaultGroup,
            // For the main download button
            // which uses 'enqueue' and a default group
            running: const TaskNotification('Downloading {displayName}',
                '{progress} • {networkSpeed} • {timeRemaining} remaining'),
            complete:
                const TaskNotification('{displayName}', 'Download complete'),
            error: const TaskNotification('{displayName}', 'Download failed'),
            paused: const TaskNotification(
                '{displayName}', 'Paused with metadata {metadata}'),
            canceled:
                const TaskNotification('Download {displayName}', 'Canceled'),
            progressBar: true)
        .configureNotification(
          // but the .await group so won't use the above config
          running: const TaskNotification('Downloading {displayName}',
              '{progress} • {networkSpeed} • {timeRemaining} remaining'),
          complete:
              TaskNotification('Download finished', 'file: {displayName}'),
          progressBar: true,
          tapOpensFile: true,
        ); // dog can also open directly from tap

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
              await moveDownloadToSharedStorageById(
                id,
                directory: it.subdir,
              );
            } catch (_) {}
          }
          downloads.refresh();
        }
      }
    });
    await FileDownloader().start();
    await _restoreDownloadsFromDb();
    _databaseSubscription = FileDownloader().database.updates.listen((record) {
      _upsertFromRecord(record).then((changed) {
        if (changed) {
          downloads.refresh();
        }
      });
    });
  }

  @override
  void onClose() {
    _databaseSubscription?.cancel();
    super.onClose();
  }

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

  Future<String?> moveDownloadToSharedStorageById(
    String taskId, {
    required String directory,
    String? mimeType,
  }) async {
    SharedStorage storage = SharedStorage.downloads;

    final task = await FileDownloader().taskForId(taskId);
    if (task is DownloadTask) {
      return FileDownloader().moveToSharedStorage(
        task,
        storage,
        directory: directory,
        mimeType: mimeType,
      );
    }

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

  Future<void> clear() async {
    final toRemove = <String>[];

    for (var entry in downloads.entries) {
      final id = entry.key;
      final item = entry.value;
      if (item.status == TaskStatus.canceled ||
          item.status == TaskStatus.failed) {
        await _deleteTaskFile(item.task);
      }
      await FileDownloader().database.deleteRecordWithId(id);
      toRemove.add(id);
    }

    for (var id in toRemove) {
      downloads.remove(id);
    }
  }

  /// Attempt to get permissions if not already granted
  Future<void> getPermission(PermissionType permissionType) async {
    var status = await FileDownloader().permissions.status(permissionType);
    if (status != PermissionStatus.granted) {
      if (await FileDownloader()
          .permissions
          .shouldShowRationale(permissionType)) {
        debugPrint('Showing some rationale');
      }
      status = await FileDownloader().permissions.request(permissionType);
      debugPrint('Permission for $permissionType was $status');
    }
  }

  /// Encola una descarga y la registra en el mapa
  Future<String?> enqueue({
    required String url,
    required String subdir, // p.ej. 'roms'
    String? filename,
    bool requiresWifi = false,
    List<String>? imageUrls,
  }) async {
    await getPermission(PermissionType.notifications);
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
    final normalizedImages = imageUrls
            ?.where((element) => element.trim().isNotEmpty)
            .toList(growable: false) ??
        const <String>[];

    final encodedMeta = _encodeMetaData(subdir, normalizedImages);

    final DownloadTask task = Platform.isWindows
        ? DownloadTask(
            url: url,
            directory: destUri.toFilePath(windows: true),
            baseDirectory: BaseDirectory.root,
            filename: filenameSfe,
            displayName: filenameSfe,
            metaData: encodedMeta,
            updates: Updates.statusAndProgress,
            requiresWiFi: requiresWifi,
            allowPause: false,
            retries: 2,
          )
        : UriDownloadTask(
            url: url,
            directoryUri: destUri,
            filename: filenameSfe,
            displayName: filenameSfe,
            metaData: encodedMeta,
            updates: Updates.statusAndProgress,
            requiresWiFi: requiresWifi,
            allowPause: false,
            retries: 2,
          );

    downloads[task.taskId] = DownloadItem(
      task: task,
      progress: 0,
      subdir: subdir,
      status: TaskStatus.enqueued,
      imageUrls: normalizedImages,
    );

    await FileDownloader().enqueue(task);
    return task.taskId;
  }

  /// Pausar por taskId (necesita DownloadTask)
  Future<void> pause(String taskId) async {
    final it = downloads[taskId];
    if (it != null) {
      if (!it.task.allowPause) {
        return;
      }
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
      if (!it.task.allowPause) {
        return;
      }
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
    final existing = downloads[taskId];
    if (existing != null &&
        (existing.isCompleted || existing.isFailed || existing.isCanceled)) {
      return;
    }

    await FileDownloader().cancelTaskWithId(taskId);
    final it = downloads[taskId];
    if (it != null) {
      it.status = TaskStatus.canceled;
      downloads.refresh();
    }
  }

  Future<void> _restoreDownloadsFromDb() async {
    final records = await FileDownloader().database.allRecords();
    var didChange = false;
    for (final record in records) {
      final changed = await _upsertFromRecord(record);
      didChange = didChange || changed;
    }
    if (didChange) {
      downloads.refresh();
    }
  }

  Future<bool> _upsertFromRecord(TaskRecord record) async {
    final task = record.task;
    if (task is! DownloadTask) {
      return false;
    }

    final meta = _decodeMetaData(task.metaData, fallbackSubdir: task.group);
    final newItem = DownloadItem(
      task: task,
      subdir: meta.subdir,
      progress: record.progress,
      status: record.status,
      imageUrls: meta.imageUrls,
    );

    final previous = downloads[task.taskId];
    final changed = previous == null ||
        previous.progress != newItem.progress ||
        previous.status != newItem.status ||
        previous.subdir != newItem.subdir ||
        !listEquals(previous.imageUrls, newItem.imageUrls);

    downloads[task.taskId] = newItem;
    return changed;
  }

  String _encodeMetaData(String subdir, List<String> images) {
    final payload = <String, dynamic>{'subdir': subdir};
    if (images.isNotEmpty) {
      payload['images'] = images;
    }
    return jsonEncode(payload);
  }

  ({String subdir, List<String> imageUrls}) _decodeMetaData(
    String metaData, {
    required String fallbackSubdir,
  }) {
    if (metaData.isEmpty) {
      return (subdir: fallbackSubdir, imageUrls: const []);
    }
    try {
      final decoded = jsonDecode(metaData);
      if (decoded is Map<String, dynamic>) {
        final subdir = (decoded['subdir'] as String?)?.trim().isNotEmpty == true
            ? (decoded['subdir'] as String).trim()
            : fallbackSubdir;
        final images = (decoded['images'] as List?)
                ?.whereType<String>()
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(growable: false) ??
            const <String>[];
        return (subdir: subdir, imageUrls: images);
      }
      if (decoded is String) {
        final value = decoded.trim();
        if (value.isNotEmpty) {
          return (subdir: value, imageUrls: const []);
        }
      }
    } catch (_) {
      // fall back to legacy behavior
    }
    final fallback =
        metaData.trim().isNotEmpty ? metaData.trim() : fallbackSubdir;
    return (subdir: fallback, imageUrls: const []);
  }

  Future<void> _deleteTaskFile(Task task) async {
    if (task is UriDownloadTask) {
      final uri = task.fileUri;
      if (uri != null) {
        await FileDownloader().uri.deleteFile(uri);
        return;
      }
    }

    try {
      final path = await task.filePath();
      if (path.isEmpty) {
        return;
      }
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
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

    Uri? folderUri;
    try {
      // Abre el picker de directorio (Android → SAF, iOS → UIDocumentPicker)
      folderUri = await FileDownloader().uri.pickDirectory(
            persistedUriPermission: true,
          );
    } on UnimplementedError {
      folderUri = await _pickDirectoryWithFilePicker();
    } catch (error) {
      if (error is AssertionError &&
          error
              .toString()
              .contains('pickDirectory not implemented for this platform')) {
        folderUri = await _pickDirectoryWithFilePicker();
      } else {
        rethrow;
      }
    }

    // pickDirectory might resolve but return null on cancel, so try fallback as last resort
    folderUri ??= await _pickDirectoryWithFilePicker();

    if (folderUri != null) {
      debugPrint('Carpeta elegida: $folderUri');
      await saveFolderUri(subdir, folderUri);
      return folderUri;
    } else {
      debugPrint('Usuario canceló selección de carpeta');
      return null;
    }
  }

  Future<Uri?> _pickDirectoryWithFilePicker() async {
    try {
      final path = await FilePicker.platform.getDirectoryPath();
      if (path == null) {
        return null;
      }
      return Uri.file(
        path,
        windows: Platform.isWindows,
      );
    } catch (error, stackTrace) {
      debugPrint('Error al usar FilePicker para seleccionar carpeta: $error');
      debugPrint(stackTrace.toString());
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
