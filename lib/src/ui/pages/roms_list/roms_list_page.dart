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
    if (width >= 1400) return 2.2;
    if (width >= 1080) return 2.0;
    if (width >= 760) return 1.8;
    return 1.6;
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
  final bool isGrid;
  final double? thumbnailSize;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isGrid ? 10 : 12),
          child: isGrid
              ? _buildGridLayout(context)
              : _buildListLayout(context, thumbnailSize ?? 62),
        ),
      ),
    );
  }

  Widget _buildListLayout(BuildContext context, double imageSize,
      {bool isGridLayout = false}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final downloadTooltip =
        AppLocalizations.of(context)!.downloadsActionDownload;
    final maxImageSize = isGridLayout ? 140.0 : 112.0;
    final effectiveSize = imageSize.clamp(64.0, maxImageSize).toDouble();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FallbackNetworkImage(
          urls: [boxart, logo],
          width: effectiveSize,
          height: effectiveSize,
          radius: 12,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize:
                        (theme.textTheme.titleMedium?.fontSize ?? 16) - 1),
              ),
              const SizedBox(height: 4),
              if (romName.isNotEmpty)
                Text(
                  romName,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              if (sizeLabel.isNotEmpty)
                Text(
                  sizeLabel,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton.filledTonal(
          tooltip: downloadTooltip,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(44, 44),
          ),
          icon: const Icon(Icons.download_rounded, size: 20),
          onPressed: onDownload,
        ),
      ],
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final targetImageSize =
            (constraints.maxWidth * 0.45).clamp(80.0, 144.0).toDouble();
        return _buildListLayout(
          context,
          targetImageSize,
          isGridLayout: true,
        );
      },
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
