import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/pages/download/download_controller.dart';
import 'package:kaat/src/ui/pages/roms_list/roms_list_controller.dart';
import 'package:kaat/src/ui/pages/roms_list/widgets/rom_modal_bottom_sheet.dart';
import 'package:kaat/src/ui/widgets/app_drawer/app_drawer.dart';
import 'package:kaat/src/ui/widgets/fallback_network_image/fallback_network_image.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';

class RomsListPage extends GetView<RomsListController> {
  const RomsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadController = Get.find<DownloadController>();
    return Scaffold(
      appBar: principalAppBar(
        context,
        title: controller.platform['platform_abbr'],
        logo: controller.platform['platform_logo'],
        clear: true,
      ),
      endDrawer: const AppDrawer(),
      body: SafeArea(
        child: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: controller.loading.value
                ? const _RomsLoadingView(key: ValueKey('roms-loading'))
                : _RomsListContent(
                    key: const ValueKey('roms-content'),
                    controller: controller,
                    downloadController: downloadController,
                  ),
          ),
        ),
      ),
    );
  }
}

class _RomsLoadingView extends StatelessWidget {
  const _RomsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _RomsListContent extends StatelessWidget {
  const _RomsListContent({
    super.key,
    required this.controller,
    required this.downloadController,
  });

  final RomsListController controller;
  final DownloadController downloadController;

  @override
  Widget build(BuildContext context) {
    final roms = controller.roms;
    final width = MediaQuery.sizeOf(context).width;
    final localizations = AppLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final horizontalPadding = _RomsLayout.horizontalPadding(width);
    final crossAxisCount = _RomsLayout.crossAxisCount(width, roms.length);
    final useGrid = crossAxisCount > 1;
    final listThumbnailSize = _RomsLayout.listThumbnailSize(width);

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _RomsSearchSummary(
                title: localizations.searchoRoms,
                romCount: roms.length,
              ),
            ),
          ),
        ),
      ),
      SliverPersistentHeader(
        pinned: true,
        delegate: _RomsSearchHeaderDelegate(
          horizontalPadding: horizontalPadding,
          controller: controller.searchCtrl,
          hasText: controller.searchText.value.isNotEmpty,
          hintText: localizations.searchoRoms,
          clearTooltip: materialLocalizations.deleteButtonTooltip,
          onChanged: controller.onSearchChanged,
          onClear: () {
            controller.searchCtrl.clear();
            controller.onSearchChanged('');
          },
        ),
      ),
    ];

    if (roms.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: const _RomsEmptyState(),
          ),
        ),
      );
    } else if (useGrid) {
      slivers.add(
        SliverPadding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 18),
          sliver: SliverGrid.builder(
            itemCount: roms.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: _RomsLayout.gridChildAspectRatio(width),
            ),
            itemBuilder: (context, index) => _buildTile(
              context,
              roms[index],
              isGrid: true,
              listThumbnailSize: listThumbnailSize,
            ),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverPadding(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 18),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tile = _buildTile(
                  context,
                  roms[index],
                  isGrid: false,
                  listThumbnailSize: listThumbnailSize,
                );
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == roms.length - 1 ? 0 : 10),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: tile,
                    ),
                  ),
                );
              },
              childCount: roms.length,
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: slivers,
    );
  }

  Widget _buildTile(
    BuildContext context,
    dynamic item, {
    required bool isGrid,
    required double listThumbnailSize,
  }) {
    final map = item as Map?;
    final name = map?['name']?.toString() ?? '';
    final romName = map?['rom']?.toString() ?? '';
    final size = map?['size']?.toString() ?? '';
    final boxart = map?['boxart']?.toString() ?? '';
    final logo = map?['logo']?.toString() ?? '';
    final url = map?['url']?.toString() ?? '';
    final ssSystemId = map?['ssSystemId']?.toString() ?? '';
    final platformAbbr = map?['platformAbbr']?.toString() ?? '';

    return _RomListTile(
      name: name,
      romName: romName,
      sizeLabel: size,
      boxart: boxart,
      logo: logo,
      platformAbbr: platformAbbr,
      isGrid: isGrid,
      thumbnailSize: isGrid ? null : listThumbnailSize,
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (_) => RomModalBottomSheet(
            name: name,
            size: size,
            boxart: boxart,
            logo: logo,
            url: url,
            ssSystemId: ssSystemId,
            platformAbbr: platformAbbr,
          ),
        );
      },
      onDownload: () async {
        final proceed = await _handleDownloadPermission(
          context,
          downloadController,
          platformAbbr,
        );
        if (!proceed) return;
        await downloadController.enqueue(
          url: url,
          subdir: platformAbbr,
          imageUrls: [boxart, logo],
        );
      },
    );
  }
}

class _RomsLayout {
  static int crossAxisCount(double width, int itemCount) {
    int columns;
    if (width >= 1400) {
      columns = 4;
    } else if (width >= 1080) {
      columns = 3;
    } else if (width >= 760) {
      columns = 2;
    } else {
      columns = 1;
    }

    if (itemCount <= 0) {
      return 1;
    }
    return columns > itemCount ? itemCount : columns;
  }

  static double horizontalPadding(double width) {
    if (width >= 1400) return 48;
    if (width >= 1080) return 36;
    if (width >= 760) return 28;
    if (width >= 520) return 20;
    return 16;
  }

  static double listThumbnailSize(double width) {
    if (width >= 1024) return 84;
    if (width >= 760) return 72;
    return 64;
  }

  static double gridChildAspectRatio(double width) {
    if (width >= 1400) return 1.45;
    if (width >= 1080) return 1.35;
    if (width >= 760) return 1.25;
    return 1.18;
  }
}

class _RomsSearchSummary extends StatelessWidget {
  const _RomsSearchSummary({
    required this.title,
    required this.romCount,
  });

  final String title;
  final int romCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtitle = romCount > 0
        ? '$romCount ROM${romCount == 1 ? '' : 's'}'
        : AppLocalizations.of(context)!.noRoms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RomsSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _RomsSearchHeaderDelegate({
    required this.horizontalPadding,
    required this.controller,
    required this.hasText,
    required this.hintText,
    required this.clearTooltip,
    required this.onChanged,
    required this.onClear,
  });

  final double horizontalPadding;
  final TextEditingController controller;
  final bool hasText;
  final String hintText;
  final String clearTooltip;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  static const double _height = 88;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: overlapsContent || shrinkOffset > 0 ? 2 : 0,
      shadowColor: scheme.shadow.withValues(alpha: 0.06),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          12,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _RomsSearchInput(
              controller: controller,
              hasText: hasText,
              hintText: hintText,
              clearTooltip: clearTooltip,
              onChanged: onChanged,
              onClear: onClear,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _RomsSearchHeaderDelegate oldDelegate) {
    return horizontalPadding != oldDelegate.horizontalPadding ||
        controller != oldDelegate.controller ||
        hasText != oldDelegate.hasText ||
        hintText != oldDelegate.hintText ||
        clearTooltip != oldDelegate.clearTooltip ||
        onChanged != oldDelegate.onChanged ||
        onClear != oldDelegate.onClear;
  }
}

class _RomsSearchInput extends StatelessWidget {
  const _RomsSearchInput({
    required this.controller,
    required this.hasText,
    required this.hintText,
    required this.clearTooltip,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasText;
  final String hintText;
  final String clearTooltip;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        hintText: hintText,
        prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
        suffixIcon: hasText
            ? IconButton(
                tooltip: clearTooltip,
                onPressed: onClear,
                icon: const Icon(Icons.clear_rounded),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

class _RomsEmptyState extends StatelessWidget {
  const _RomsEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.videogame_asset_off_rounded,
            size: 56,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noRoms,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RomListTile extends StatelessWidget {
  const _RomListTile({
    required this.name,
    required this.romName,
    required this.sizeLabel,
    required this.boxart,
    required this.logo,
    required this.platformAbbr,
    required this.isGrid,
    required this.onTap,
    required this.onDownload,
    this.thumbnailSize,
  });

  final String name;
  final String romName;
  final String sizeLabel;
  final String boxart;
  final String logo;
  final String platformAbbr;
  final bool isGrid;
  final double? thumbnailSize;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: isGrid ? 2.5 : 1.5,
      shadowColor: scheme.shadow.withValues(alpha: 0.16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.14)),
      ),
      child: InkWell(
        onTap: onTap,
        splashFactory: Theme.of(context).splashFactory,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return scheme.primary.withValues(alpha: 0.08);
            }
            return null;
          },
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final downloadTooltip =
        AppLocalizations.of(context)!.downloadsActionDownload;

    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        final metadataPadding = EdgeInsets.fromLTRB(
          16,
          isGrid ? 10 : 14,
          16,
          isGrid ? 12 : 18,
        );

        if (boundedHeight) {
          final heroHeight = constraints.maxHeight * (isGrid ? 0.54 : 0.5);
          final metadataScrollPhysics =
              constraints.maxHeight < (isGrid ? 236 : 210)
                  ? const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    )
                  : const NeverScrollableScrollPhysics();
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: heroHeight,
                  child: _buildArtworkHeader(
                    scheme: scheme,
                    tooltip: downloadTooltip,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: metadataScrollPhysics,
                    padding: metadataPadding,
                    child: _buildMetadata(theme, scheme),
                  ),
                ),
              ],
            ),
          );
        }

        final heroHeight = ((thumbnailSize ?? 88) * (isGrid ? 1.1 : 1.5))
            .clamp(132.0, 252.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: heroHeight,
              child: _buildArtworkHeader(
                scheme: scheme,
                tooltip: downloadTooltip,
              ),
            ),
            Padding(
              padding: metadataPadding,
              child: _buildMetadata(theme, scheme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArtworkHeader({
    required ColorScheme scheme,
    required String tooltip,
  }) {
    final fallback = Center(
      child: Icon(
        Icons.image_not_supported_rounded,
        size: 34,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.65),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: scheme.surface.withValues(alpha: 0.12),
              ),
              child: LayoutBuilder(
                builder: (context, innerConstraints) {
                  final width = innerConstraints.maxWidth.isFinite
                      ? innerConstraints.maxWidth
                      : null;
                  final height = innerConstraints.maxHeight.isFinite
                      ? innerConstraints.maxHeight
                      : null;
                  return FallbackNetworkImage(
                    urls: [boxart, logo],
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                    placeholder: const SizedBox.shrink(),
                    fallback: fallback,
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: _DownloadBadge(
              tooltip: tooltip,
              scheme: scheme,
              onPressed: onDownload,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(ThemeData theme, ColorScheme scheme) {
    final subtitleStyle =
        theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final chips = <Widget>[];
    if (sizeLabel.trim().isNotEmpty) {
      chips.add(_MetadataChip(
        label: sizeLabel.trim(),
        scheme: scheme,
        theme: theme,
      ));
    }
    if (platformAbbr.trim().isNotEmpty) {
      chips.add(_MetadataChip(
        label: platformAbbr.trim().toUpperCase(),
        scheme: scheme,
        theme: theme,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        if (romName.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            romName.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: subtitleStyle,
          ),
        ],
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: chips,
          ),
        ],
      ],
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.label,
    required this.scheme,
    required this.theme,
  });

  final String label;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _DownloadBadge extends StatelessWidget {
  const _DownloadBadge({
    required this.tooltip,
    required this.scheme,
    required this.onPressed,
  });

  final String tooltip;
  final ColorScheme scheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.2),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            minimumSize: const Size.square(44),
            padding: const EdgeInsets.all(10),
            shape: const CircleBorder(),
            backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
            shadowColor: Colors.transparent,
          ),
          icon: Icon(
            Icons.download_rounded,
            color: scheme.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

Future<bool> _handleDownloadPermission(
  BuildContext context,
  DownloadController controller,
  String subdir,
) async {
  final savedUri = controller.getSavedFolderUri(subdir);
  if (savedUri != null) {
    return true;
  }
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
              AppLocalizations.of(context)!.downloadsFolderSelectionOnceTitle),
          content: Text(
              AppLocalizations.of(context)!.downloadsFolderSelectionOnceMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        ),
      ) ??
      false;
}
