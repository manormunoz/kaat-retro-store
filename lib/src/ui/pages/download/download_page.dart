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
            final layout =
                _DownloadLayoutConfig.fromWidth(constraints.maxWidth);

            if (layout.useGrid) {
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  layout.horizontalPadding,
                  layout.topPadding,
                  layout.horizontalPadding,
                  layout.bottomPadding,
                ),
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: layout.crossAxisCount,
                  mainAxisExtent: layout.tileHeight,
                  crossAxisSpacing: layout.crossAxisSpacing,
                  mainAxisSpacing: layout.mainAxisSpacing,
                ),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  return _DownloadTile(
                    controller: controller,
                    item: item,
                    layout: layout,
                  );
                },
              );
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                0,
                layout.topPadding,
                0,
                layout.bottomPadding,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == items.length - 1 ? 0 : layout.mainAxisSpacing,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: layout.maxTileWidth),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: layout.horizontalPadding,
                        ),
                        child: _DownloadTile(
                          controller: controller,
                          item: item,
                          layout: layout,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'downloadsActionsFab',
        icon: const Icon(Icons.tune_rounded),
        label: Text(AppLocalizations.of(context)!.downloadsActionsButton),
        onPressed: () => _showDownloadsActions(context, controller),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      endDrawer: const AppDrawer(),
    );
  }
}

Future<void> _showDownloadsActions(
  BuildContext context,
  DownloadController controller,
) async {
  final localizations = AppLocalizations.of(context)!;
  final scheme = Theme.of(context).colorScheme;
  final theme = Theme.of(context);

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.downloadsActionsButton,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _ActionsTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: scheme.onErrorContainer,
                iconBackground: scheme.errorContainer,
                title: localizations.downloadsDownloadsClearBtn,
                subtitle: localizations.downloadsClearAllDescription,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await controller.clear();
                  Get.showSnackbar(AppSnackbar(
                    SnackbarType.success,
                    localizations.downloadsDownloadsCleared,
                  ));
                },
              ),
              const SizedBox(height: 8),
              _ActionsTile(
                icon: Icons.link_off_rounded,
                iconColor: scheme.onTertiaryContainer,
                iconBackground: scheme.tertiaryContainer,
                title: localizations.downloadsClearFolderPermissionsTitle,
                subtitle:
                    localizations.downloadsClearFolderPermissionsDescription,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final total = await controller.removeAllDownloadFolderUris();
                  Get.showSnackbar(AppSnackbar(
                    SnackbarType.success,
                    localizations.downloadsFoldersReferencesRemoved(total),
                  ));
                },
              ),
            ],
          ),
        ),
      );
    },
  );
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
        fit: BoxFit.contain,
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

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({
    required this.controller,
    required this.item,
    required this.layout,
  });

  final DownloadController controller;
  final DownloadItem item;
  final _DownloadLayoutConfig layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasFiniteProgress = item.progress.isFinite;
    final clampedProgress =
        hasFiniteProgress ? item.progress.clamp(0.0, 1.0).toDouble() : 0.0;

    double indicatorValue;
    String percentLabel;

    switch (item.status) {
      case TaskStatus.complete:
        indicatorValue = 1.0;
        percentLabel = '100%';
        break;
      case TaskStatus.running:
        indicatorValue = clampedProgress;
        percentLabel = '${(indicatorValue * 100).toStringAsFixed(1)}%';
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
    final displayPercent = percentLabel.isNotEmpty ? percentLabel : '--';
    final hasActions =
        (item.status == TaskStatus.running && item.task.allowPause) ||
            (item.status == TaskStatus.paused && item.task.allowPause) ||
            canCancel;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(layout.cardRadius),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      color: scheme.surface,
      child: Padding(
        padding: layout.contentPadding,
        child: Column(
          mainAxisSize: layout.useGrid ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildThumbnail(
                  item.imageUrls,
                  scheme,
                  size: layout.thumbnailSize,
                ),
                SizedBox(width: layout.thumbnailGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.filename,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: layout.titleSpacing),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusChip(
                            context,
                            item.status,
                            item.statusDescription,
                            compact: layout.compact,
                          ),
                          SizedBox(width: layout.statusSpacing),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              displayPercent,
                              key: ValueKey('${item.taskId}_$displayPercent'),
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
                    ],
                  ),
                ),
                if (hasActions) ...[
                  SizedBox(width: layout.trailingGap),
                  _DownloadActionsColumn(
                    controller: controller,
                    item: item,
                    canCancel: canCancel,
                    isCompact: layout.compact,
                    scheme: scheme,
                  ),
                ],
              ],
            ),
            SizedBox(height: layout.progressSpacing),
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
                    backgroundColor:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _DownloadActionsColumn extends StatelessWidget {
  const _DownloadActionsColumn({
    required this.controller,
    required this.item,
    required this.canCancel,
    required this.isCompact,
    required this.scheme,
  });

  final DownloadController controller;
  final DownloadItem item;
  final bool canCancel;
  final bool isCompact;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[
      if (item.status == TaskStatus.running && item.task.allowPause)
        _buildActionButton(
          context,
          icon: Icons.pause_rounded,
          tooltip: AppLocalizations.of(context)!.downloadsStatusPaused,
          color: scheme.primary,
          compact: isCompact,
          onPressed: () => controller.pause(item.taskId),
        )
      else if (item.status == TaskStatus.paused && item.task.allowPause)
        _buildActionButton(
          context,
          icon: Icons.play_arrow_rounded,
          tooltip: AppLocalizations.of(context)!.downloadsStatusRunning,
          color: scheme.primary,
          compact: isCompact,
          onPressed: () => controller.resume(item.taskId),
        ),
      if (canCancel)
        _buildActionButton(
          context,
          icon: Icons.cancel_rounded,
          tooltip: AppLocalizations.of(context)!.downloadsStatusCanceled,
          color: scheme.error,
          compact: isCompact,
          onPressed: () => controller.cancel(item.taskId),
        ),
    ].whereType<Widget>().toList();

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < buttons.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == buttons.length - 1 ? 0 : 8),
            child: buttons[i],
          ),
      ],
    );
  }
}

class _ActionsTile extends StatelessWidget {
  const _ActionsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
      subtitle: subtitle?.isNotEmpty == true
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _DownloadLayoutConfig {
  const _DownloadLayoutConfig({
    required this.compact,
    required this.useGrid,
    required this.crossAxisCount,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.tileHeight,
    required this.maxTileWidth,
    required this.cardRadius,
    required this.contentPadding,
    required this.thumbnailSize,
    required this.thumbnailGap,
    required this.trailingGap,
    required this.titleSpacing,
    required this.statusSpacing,
    required this.progressSpacing,
  });

  final bool compact;
  final bool useGrid;
  final int crossAxisCount;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double tileHeight;
  final double maxTileWidth;
  final double cardRadius;
  final EdgeInsets contentPadding;
  final double thumbnailSize;
  final double thumbnailGap;
  final double trailingGap;
  final double titleSpacing;
  final double statusSpacing;
  final double progressSpacing;

  static _DownloadLayoutConfig fromWidth(double width) {
    final compact = width < 420;
    final medium = width >= 420 && width < 680;
    final expanded = width >= 680 && width < 900;
    final wide = width >= 900;

    final crossAxisCount = width >= 1260
        ? 3
        : width >= 880
            ? 2
            : 1;
    final useGrid = crossAxisCount > 1;

    final horizontalPadding = useGrid
        ? (width >= 1280 ? 28.0 : 20.0)
        : (wide
            ? 24.0
            : expanded
                ? 20.0
                : compact
                    ? 12.0
                    : 16.0);

    final contentPadding = EdgeInsets.all(
      compact
          ? 12
          : useGrid
              ? 16
              : medium
                  ? 14
                  : 18,
    );

    final thumbnailSize = compact
        ? 48.0
        : useGrid
            ? 60.0
            : wide
                ? 64.0
                : 56.0;

    final mainAxisSpacing =
        useGrid ? (width >= 1280 ? 20.0 : 16.0) : (compact ? 8.0 : 12.0);

    final crossAxisSpacing = useGrid ? (width >= 1280 ? 20.0 : 16.0) : 0.0;

    final tileHeight = useGrid
        ? (crossAxisCount >= 3
            ? 184.0
            : width >= 1024
                ? 180.0
                : 176.0)
        : 0.0;

    final maxTileWidth = useGrid
        ? double.infinity
        : width >= 1100
            ? 820.0
            : width >= 920
                ? 760.0
                : width >= 760
                    ? 700.0
                    : double.infinity;

    final cardRadius = compact
        ? 12.0
        : useGrid
            ? 18.0
            : wide
                ? 20.0
                : 16.0;

    final thumbnailGap = compact ? 12.0 : 16.0;
    final trailingGap = useGrid ? 16.0 : 12.0;
    final titleSpacing = compact ? 6.0 : 8.0;
    final statusSpacing = compact ? 6.0 : 8.0;
    final progressSpacing = compact ? 14.0 : 16.0;

    return _DownloadLayoutConfig(
      compact: compact,
      useGrid: useGrid,
      crossAxisCount: crossAxisCount,
      horizontalPadding: horizontalPadding,
      topPadding: compact ? 8.0 : 12.0,
      bottomPadding: 96.0,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      tileHeight: tileHeight,
      maxTileWidth: maxTileWidth,
      cardRadius: cardRadius,
      contentPadding: contentPadding,
      thumbnailSize: thumbnailSize,
      thumbnailGap: thumbnailGap,
      trailingGap: trailingGap,
      titleSpacing: titleSpacing,
      statusSpacing: statusSpacing,
      progressSpacing: progressSpacing,
    );
  }
}
