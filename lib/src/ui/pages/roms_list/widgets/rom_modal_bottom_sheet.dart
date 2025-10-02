import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/services/game_class.dart';
import 'package:kaat/src/ui/pages/download/download_controller.dart';
import 'package:kaat/src/ui/pages/roms_list/roms_list_controller.dart';
import 'package:kaat/src/ui/widgets/app_snackbar/app_snackbar.dart';
import 'package:kaat/src/ui/widgets/fallback_network_image/fallback_network_image.dart';

class RomModalBottomSheet extends StatelessWidget {
  final String name;
  final String size;
  final String boxart;
  final String logo;
  final String url;
  final String ssSystemId;
  final String platformAbbr;
  const RomModalBottomSheet({
    super.key,
    required this.name,
    required this.size,
    required this.boxart,
    required this.logo,
    required this.url,
    required this.ssSystemId,
    required this.platformAbbr,
  });

  Widget ssGameWidget(BuildContext context, Game game) {
    final scheme = Theme.of(context).colorScheme;
    final romsListController = Get.find<RomsListController>();

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.92,
              minChildSize: 0.6,
              maxChildSize: 0.92,
              builder: (_, scrollController) => SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RomHeader(
                      title: game.title != 'Unknown'
                          ? game.title
                          : romsListController.clearGameName(name),
                      publisher: game.publisher,
                      developer: game.developer,
                      rating: game.ratingOutOf5,
                      boxart: game.box2D != null
                          ? [game.box2D!, boxart, logo]
                          : [boxart, logo],
                      size: size,
                    ),
                    const SizedBox(height: 20),
                    _RomActionsRow(
                      url: url,
                      platformAbbr: platformAbbr,
                      artworkUrls: game.box2D != null
                          ? [game.box2D!, boxart, logo]
                          : [boxart, logo],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.synopsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.synopsis ??
                          AppLocalizations.of(context)!.romNoMetadata,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            close(context, scheme),
          ],
        ),
      ),
    );
  }

  Widget close(BuildContext context, ColorScheme scheme) {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton.filledTonal(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: Icon(Icons.close_rounded, color: scheme.onSurface),
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      ),
    );
  }

  Widget container(BuildContext context, Widget c) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: c,
    );
  }

  @override
  Widget build(BuildContext context) {
    final romsListController = Get.find<RomsListController>();
    final systemId = int.parse(ssSystemId);
    return FutureBuilder(
      future: romsListController.screenScrapper(name, systemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return container(
            context,
            const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          final fallbackGame = Game(
            id: 0,
            title: romsListController.clearGameName(name),
            developer: 'Unknown',
            publisher: 'Unknown',
          );
          return ssGameWidget(context, fallbackGame);
        }

        final game = snapshot.data as Game;
        return ssGameWidget(context, game);
      },
    );
  }
}

class _RomHeader extends StatelessWidget {
  const _RomHeader({
    required this.title,
    required this.publisher,
    required this.developer,
    required this.rating,
    required this.boxart,
    required this.size,
  });

  final String title;
  final String? publisher;
  final String? developer;
  final double? rating;
  final List<String> boxart;
  final String size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final metadata = <String>[];
    if (publisher != null &&
        publisher!.trim().isNotEmpty &&
        publisher != 'Unknown') {
      metadata.add(publisher!.trim());
    }
    if (developer != null &&
        developer!.trim().isNotEmpty &&
        developer != 'Unknown') {
      metadata.add(developer!.trim());
    }
    final infoText = metadata.isEmpty ? l10n.romNoMetadata : metadata.join(' • ');
    final showSize = size.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FallbackNetworkImage(
            urls: boxart,
            width: 110,
            height: 110,
            radius: 12,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                infoText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _RatingStars(rating: rating),
                  if (showSize)
                    Chip(
                      label: Text(size),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      backgroundColor:
                          scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RomActionsRow extends StatelessWidget {
  const _RomActionsRow({
    required this.url,
    required this.platformAbbr,
    required this.artworkUrls,
  });

  final String url;
  final String platformAbbr;
  final List<String> artworkUrls;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final romsListController = Get.find<RomsListController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final isCompact = maxWidth < 560;
        final buttonWidth = isCompact
            ? maxWidth
            : (maxWidth - (spacing * 2)) / 3;

        Widget button(Widget child) =>
            SizedBox(width: buttonWidth, child: child);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            button(
              FilledButton.icon(
                onPressed: () => _startDownload(context),
                icon: const Icon(Icons.download_rounded),
                label: Text(l10n.downloadsActionDownload),
              ),
            ),
            button(
              FilledButton.tonalIcon(
                onPressed: () => romsListController.openMyrient(url),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.openLink),
              ),
            ),
            button(
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (!context.mounted) return;
                  Get.showSnackbar(
                    AppSnackbar(
                      SnackbarType.info,
                      l10n.linkCopied,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: Text(l10n.copyLink),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startDownload(BuildContext context) async {
    final downloadController = Get.find<DownloadController>();
    final l10n = AppLocalizations.of(context)!;
    final allowed =
        await _ensureDownloadPermission(context, downloadController);
    if (!allowed) return;
    try {
      final images = artworkUrls.where((e) => e.trim().isNotEmpty).toList();
      await downloadController.enqueue(
        url: url,
        subdir: platformAbbr,
        imageUrls: images,
      );
      if (!context.mounted) return;
      Get.showSnackbar(
        AppSnackbar(
          SnackbarType.success,
          l10n.downloadsRomAdded,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      Get.showSnackbar(
        AppSnackbar(
          SnackbarType.danger,
          error.toString(),
        ),
      );
    }
  }

  Future<bool> _ensureDownloadPermission(
    BuildContext context,
    DownloadController controller,
  ) async {
    final savedUri = controller.getSavedFolderUri(platformAbbr);
    if (savedUri != null) {
      return true;
    }
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l10n.downloadsFolderSelectionOnceTitle),
            content: Text(l10n.downloadsFolderSelectionOnceMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final double? rating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = rating ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              _iconFor(value - i),
              size: 20,
              color: rating == null ? scheme.outlineVariant : scheme.secondary,
            ),
          ),
        const SizedBox(width: 6),
        Text(
          rating != null ? value.toStringAsFixed(1) : '—',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  IconData _iconFor(double score) {
    if (rating == null) return Icons.star_border_rounded;
    if (score >= 0.75) return Icons.star_rounded;
    if (score >= 0.25) return Icons.star_half_rounded;
    return Icons.star_border_rounded;
  }
}
