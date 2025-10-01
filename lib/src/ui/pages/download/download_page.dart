import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/pages/download/download_controller.dart';
import 'package:kaat/src/ui/widgets/app_drawer/app_drawer.dart';
import 'package:kaat/src/ui/widgets/app_snackbar/app_snackbar.dart';
import 'package:kaat/src/ui/widgets/fallback_network_image/fallback_network_image.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DownloadController controller = Get.find<DownloadController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: principalAppBar(
        context,
        title: AppLocalizations.of(context)!.downloadsTitle,
        icon: Icon(Icons.downloading_rounded),
        clear: true,
      ),
      body: Obx(() {
        final items = controller.downloads.values.toList();
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.downloading_rounded,
                    size: 56,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.downloadsNoActiveDownloads,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 420;
            final listPadding =
                EdgeInsets.symmetric(vertical: isCompact ? 8 : 12);
            final horizontalPadding = isCompact ? 12.0 : 16.0;
            final verticalPadding = isCompact ? 4.0 : 6.0;
            final cardRadius = isCompact ? 12.0 : 16.0;
            final contentPadding = EdgeInsets.all(isCompact ? 12 : 16);
            final thumbSize = isCompact ? 48.0 : 56.0;

            return ListView.separated(
              padding: listPadding,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (ctx, i) {
                final item = items[i];
                final hasFiniteProgress = item.progress.isFinite;
                final clampedProgress = hasFiniteProgress
                    ? item.progress.clamp(0.0, 1.0).toDouble()
                    : 0.0;
                double indicatorValue;
                String percentLabel;

                switch (item.status) {
                  case TaskStatus.complete:
                    indicatorValue = 1.0;
                    percentLabel = '100%';
                    break;
                  case TaskStatus.running:
                    indicatorValue = clampedProgress;
                    percentLabel =
                        '${(indicatorValue * 100).toStringAsFixed(1)}%';
                    break;
                  case TaskStatus.paused:
                    indicatorValue = hasFiniteProgress ? clampedProgress : 0.0;
                    percentLabel = hasFiniteProgress
                        ? '${(indicatorValue * 100).toStringAsFixed(1)}%'
                        : '';
                    break;
                  default:
                    indicatorValue = 0.0;
                    percentLabel = '';
                }
                final canCancel = !{
                  TaskStatus.complete,
                  TaskStatus.canceled,
                  TaskStatus.failed,
                  TaskStatus.notFound,
                }.contains(item.status);
                final displayPercent =
                    percentLabel.isNotEmpty ? percentLabel : '--';

                final actions = <Widget>[];
                if (item.status == TaskStatus.running && item.task.allowPause) {
                  actions.add(_buildActionButton(
                    context,
                    icon: Icons.pause_rounded,
                    tooltip:
                        AppLocalizations.of(context)!.downloadsStatusPaused,
                    color: scheme.primary,
                    compact: isCompact,
                    onPressed: () => controller.pause(item.taskId),
                  ));
                } else if (item.status == TaskStatus.paused &&
                    item.task.allowPause) {
                  actions.add(_buildActionButton(
                    context,
                    icon: Icons.play_arrow_rounded,
                    tooltip:
                        AppLocalizations.of(context)!.downloadsStatusRunning,
                    color: scheme.primary,
                    compact: isCompact,
                    onPressed: () => controller.resume(item.taskId),
                  ));
                }
                if (canCancel) {
                  actions.add(_buildActionButton(
                    context,
                    icon: Icons.cancel_rounded,
                    tooltip:
                        AppLocalizations.of(context)!.downloadsStatusCanceled,
                    color: scheme.error,
                    compact: isCompact,
                    onPressed: () => controller.cancel(item.taskId),
                  ));
                }

                Widget? trailing;
                if (actions.isNotEmpty) {
                  trailing = isCompact
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions
                              .map((action) => Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: action,
                                  ))
                              .toList(),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var j = 0; j < actions.length; j++) ...[
                              if (j > 0) const SizedBox(height: 8),
                              actions[j],
                            ],
                          ],
                        );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding, vertical: verticalPadding),
                  child: Card(
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                      side: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    color: scheme.surface,
                    child: ListTile(
                      contentPadding: contentPadding,
                      leading: _buildThumbnail(
                        item.imageUrls,
                        scheme,
                        size: thumbSize,
                      ),
                      title: Text(
                        item.filename,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildStatusChip(
                                context,
                                item.status,
                                item.statusDescription,
                                compact: isCompact,
                              ),
                              const SizedBox(width: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  displayPercent,
                                  key: ValueKey(
                                      '${item.taskId}_$displayPercent'),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: indicatorValue,
                            ),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            builder: (context, value, _) => SizedBox(
                              height: 6,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: scheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: trailing,
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón para borrar descargas completadas
          FloatingActionButton(
            heroTag: 'clearCompleted',
            onPressed: () async {
              await controller.clear();
              if (!context.mounted) return;
              Get.showSnackbar(AppSnackbar(
                SnackbarType.success,
                AppLocalizations.of(context)!.downloadsDownloadsCleared,
              ));
            },
            child: const Icon(Icons.delete_sweep_rounded),
          ),
          const SizedBox(height: 12), // espacio entre botones

          // Botón para borrar los keys guardados de folderUri
          FloatingActionButton(
            heroTag: 'clearFolderUris',
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              final total = await controller.removeAllDownloadFolderUris();
              if (!context.mounted) return;
              Get.showSnackbar(AppSnackbar(
                SnackbarType.success,
                AppLocalizations.of(context)!
                    .downloadsFoldersReferencesRemoved(total),
              ));
            },
            child: const Icon(Icons.folder_off_rounded),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
    );
  }
}

Widget _buildThumbnail(List<String> urls, ColorScheme scheme,
    {double size = 56, double? radius}) {
  final borderRadius = BorderRadius.circular(radius ?? (size * 0.21));
  if (urls.isEmpty) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: borderRadius,
      ),
      child: Icon(Icons.insert_drive_file_rounded,
          color: scheme.onSurface.withValues(alpha: 0.6)),
    );
  }
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.2),
    ),
    child: ClipRRect(
      borderRadius: borderRadius,
      child: FallbackNetworkImage(
        urls: urls,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    ),
  );
}

Widget _buildStatusChip(
    BuildContext context, TaskStatus status, String description,
    {bool compact = false}) {
  final scheme = Theme.of(context).colorScheme;
  final background = _statusBackground(status, scheme);
  final foreground = _statusForeground(status, scheme);

  return Container(
    padding: compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _statusIcon(status),
          size: compact ? 12 : 14,
          color: foreground,
        ),
        const SizedBox(width: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11 : null,
              ),
        ),
      ],
    ),
  );
}

Color _statusBackground(TaskStatus status, ColorScheme scheme) {
  switch (status) {
    case TaskStatus.complete:
      return scheme.secondaryContainer;
    case TaskStatus.paused:
      return scheme.tertiaryContainer;
    case TaskStatus.failed:
    case TaskStatus.canceled:
    case TaskStatus.notFound:
      return scheme.errorContainer;
    case TaskStatus.waitingToRetry:
      return scheme.tertiaryContainer.withValues(alpha: 0.6);
    case TaskStatus.running:
      return scheme.primaryContainer;
    case TaskStatus.enqueued:
      return scheme.surfaceContainerHighest;
  }
}

Color _statusForeground(TaskStatus status, ColorScheme scheme) {
  switch (status) {
    case TaskStatus.complete:
      return scheme.onSecondaryContainer;
    case TaskStatus.paused:
      return scheme.onTertiaryContainer;
    case TaskStatus.failed:
    case TaskStatus.canceled:
    case TaskStatus.notFound:
      return scheme.onErrorContainer;
    case TaskStatus.waitingToRetry:
      return scheme.onTertiaryContainer;
    case TaskStatus.running:
      return scheme.onPrimaryContainer;
    case TaskStatus.enqueued:
      return scheme.onSurfaceVariant;
  }
}

IconData _statusIcon(TaskStatus status) {
  switch (status) {
    case TaskStatus.complete:
      return Icons.check_circle_rounded;
    case TaskStatus.running:
      return Icons.downloading_rounded;
    case TaskStatus.paused:
      return Icons.pause_circle_filled_rounded;
    case TaskStatus.failed:
    case TaskStatus.notFound:
      return Icons.error_rounded;
    case TaskStatus.canceled:
      return Icons.cancel_rounded;
    case TaskStatus.waitingToRetry:
      return Icons.history_rounded;
    case TaskStatus.enqueued:
      return Icons.schedule_rounded;
  }
}

Widget _buildActionButton(
  BuildContext context, {
  required IconData icon,
  required String tooltip,
  required VoidCallback onPressed,
  Color? color,
  bool compact = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  return Tooltip(
    message: tooltip,
    waitDuration: const Duration(milliseconds: 400),
    child: IconButton(
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      splashRadius: compact ? 18 : 22,
      iconSize: compact ? 20 : 24,
      icon: Icon(icon, color: color ?? scheme.primary),
      onPressed: onPressed,
    ),
  );
}
