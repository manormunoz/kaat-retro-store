import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/pages/download/download_controller.dart';
import 'package:kaat/src/ui/pages/roms_list/roms_list_controller.dart';
import 'package:kaat/src/ui/pages/roms_list/widgets/rom_modal_bottom_sheet.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:kaat/src/ui/widgets/app_drawer/app_drawer.dart';
import 'package:kaat/src/ui/widgets/fallback_network_image/fallback_network_image.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';

class RomsListPage extends GetView<RomsListController> {
  RomsListPage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final downloadController = Get.find<DownloadController>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: principalAppBar(
        context,
        title: controller.platform['platform_abbr'],
        logo: controller.platform['platform_logo'],
        clear: true,
      ),
      endDrawer: const AppDrawer(),
      body: SafeArea(
        child: Obx(
          () {
            final isLoading = controller.loading.value;
            final romsSnapshot = controller.roms.toList(growable: false);
            final hasSearchText = controller.searchText.value.isNotEmpty;
            final focusedIndex = controller.focusedIndex.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: isLoading
                  ? const _RomsLoadingView(key: ValueKey('roms-loading'))
                  : _RomsListContent(
                      key: const ValueKey('roms-content'),
                      controller: controller,
                      downloadController: downloadController,
                      roms: romsSnapshot,
                      hasSearchText: hasSearchText,
                      focusedIndex: focusedIndex,
                      scaffoldKey: _scaffoldKey,
                    ),
            );
          },
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
    required this.roms,
    required this.hasSearchText,
    required this.focusedIndex,
    required this.scaffoldKey,
  });

  final RomsListController controller;
  final DownloadController downloadController;
  final List<Map<String, dynamic>> roms;
  final bool hasSearchText;
  final int focusedIndex;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 720;
    final tight = width < 640;
    final localizations = AppLocalizations.of(context)!;
    final materialLocalizations = MaterialLocalizations.of(context);
    final horizontalPadding = _RomsLayout.horizontalPadding(width, compact);
    final crossAxisCount = _RomsLayout.crossAxisCount(width, roms.length);
    // Fuerza lista en landscape/compactos: no grid si ancho < 900
    final useGrid = width >= 900 && crossAxisCount > 1;
    final listThumbnailSize = _RomsLayout.listThumbnailSize(width, compact);
    final mainSpacing = useGrid ? 12.0 : 8.0;

    final estimatedItemExtent = useGrid
        ? _RomsLayout.estimatedGridItemExtent(
            width: width,
            horizontalPadding: horizontalPadding,
            crossAxisCount: crossAxisCount,
          )
        : _RomsLayout.estimatedListItemExtent(
            listThumbnailSize: listThumbnailSize,
          );

    controller.updateLayoutMetrics(
      useGrid: useGrid,
      crossAxisCount: crossAxisCount,
      itemExtent: estimatedItemExtent,
      mainSpacing: mainSpacing,
    );

    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              horizontalPadding, tight ? 12 : 20, horizontalPadding, 12),
          child: compact
              ? _RomsSearchSummary(
                  title: localizations.searchoRoms,
                  romCount: roms.length,
                )
              : Center(
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
          compact: compact,
          horizontalPadding: horizontalPadding,
          controller: controller.searchCtrl,
          hasText: hasSearchText,
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
              compact: compact,
              index: index,
              isSelected: focusedIndex == index,
              onFocus: () => controller.setFocusIndex(index, roms.length),
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
                  compact: compact,
                  index: index,
                  isSelected: focusedIndex == index,
                  onFocus: () => controller.setFocusIndex(index, roms.length),
                  isGrid: false,
                  listThumbnailSize: listThumbnailSize,
                );
                if (compact) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index == roms.length - 1 ? 0 : 10),
                    child: tile,
                  );
                }
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

    KeyEventResult handleKey(FocusNode node, KeyEvent event) {
      final isPress = event is KeyDownEvent || event is KeyRepeatEvent;
      if (!isPress) return KeyEventResult.ignored;

      if (_isStartKey(event)) {
        scaffoldKey.currentState?.openEndDrawer();
        return KeyEventResult.handled;
      }
      if (_isSelectKey(event)) {
        Get.toNamed(RouteNames.download);
        return KeyEventResult.handled;
      }
      if (_isBackKey(event)) {
        Get.back();
        return KeyEventResult.handled;
      }

      if (_isActivateKey(event)) {
        var index = controller.focusedIndex.value;
        if (index < 0 && roms.isNotEmpty) {
          index = 0;
          controller.setFocusIndex(index, roms.length);
        }
        if (index >= 0 && index < roms.length) {
          final map = Map<String, dynamic>.from(roms[index]);
          _openRomSheet(context, map);
        }
        return KeyEventResult.handled;
      }

      if (_isUpKey(event)) {
        final step = useGrid ? crossAxisCount : 1;
        controller.moveFocus(-step, roms.length);
        return KeyEventResult.handled;
      }
      if (_isDownKey(event)) {
        final step = useGrid ? crossAxisCount : 1;
        controller.moveFocus(step, roms.length);
        return KeyEventResult.handled;
      }
      if (useGrid && _isLeftKey(event)) {
        controller.moveFocus(-1, roms.length);
        return KeyEventResult.handled;
      }
      if (useGrid && _isRightKey(event)) {
        controller.moveFocus(1, roms.length);
        return KeyEventResult.handled;
      }

      return KeyEventResult.ignored;
    }

    return Focus(
      autofocus: true,
      onKeyEvent: handleKey,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: slivers,
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    dynamic item, {
    required bool compact,
    required int index,
    required bool isSelected,
    required VoidCallback onFocus,
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
      compact: compact,
      isSelected: isSelected,
      thumbnailSize: isGrid ? null : listThumbnailSize,
      onFocus: onFocus,
      onTap: () {
        controller.setFocusIndex(index, roms.length);
        _openRomSheet(
          context,
          {
            'name': name,
            'size': size,
            'boxart': boxart,
            'logo': logo,
            'url': url,
            'ssSystemId': ssSystemId,
            'platformAbbr': platformAbbr,
          },
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

  void _openRomSheet(BuildContext context, Map<String, dynamic> map) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => RomModalBottomSheet(
        name: map['name']?.toString() ?? '',
        size: map['size']?.toString() ?? '',
        boxart: map['boxart']?.toString() ?? '',
        logo: map['logo']?.toString() ?? '',
        url: map['url']?.toString() ?? '',
        ssSystemId: map['ssSystemId']?.toString() ?? '',
        platformAbbr: map['platformAbbr']?.toString() ?? '',
      ),
    );
  }
}

class _RomsLayout {
  static double estimatedListItemExtent({required double listThumbnailSize}) {
    final heroHeight =
        ((listThumbnailSize) * 1.35).clamp(96.0, 200.0).toDouble();
    return heroHeight + 120;
  }

  static double estimatedGridItemExtent({
    required double width,
    required double horizontalPadding,
    required int crossAxisCount,
  }) {
    final availableWidth =
        width - (horizontalPadding * 2) - (12 * (crossAxisCount - 1));
    final itemWidth = availableWidth / crossAxisCount;
    final aspect = gridChildAspectRatio(width);
    return itemWidth / aspect;
  }

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

  static double horizontalPadding(double width, bool compact) {
    if (compact) return 12;
    if (width >= 1400) return 48;
    if (width >= 1080) return 36;
    if (width >= 760) return 28;
    if (width >= 520) return 20;
    return 16;
  }

  static double listThumbnailSize(double width, bool compact) {
    if (width >= 1024) return 84;
    if (width >= 760) return 72;
    return compact ? 56 : 64;
  }

  static double gridChildAspectRatio(double width) {
    if (width >= 1400) return 1.45;
    if (width >= 1080) return 1.35;
    if (width >= 760) return 1.25;
    return 1.18;
  }
}

bool _isUpKey(KeyEvent event) {
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.arrowUp) return true;
  return _matchesUsage(event, 0x00070052) ||
      _matchesUsage(event, 0x00010090) ||
      _matchesUsage(event, 0x1100000013);
}

bool _isDownKey(KeyEvent event) {
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.arrowDown) return true;
  return _matchesUsage(event, 0x00070051) ||
      _matchesUsage(event, 0x00010091) ||
      _matchesUsage(event, 0x1100000014);
}

bool _isLeftKey(KeyEvent event) {
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.arrowLeft) return true;
  return _matchesUsage(event, 0x00070050) ||
      _matchesUsage(event, 0x0001008c) ||
      _matchesUsage(event, 0x1100000012);
}

bool _isRightKey(KeyEvent event) {
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.arrowRight) return true;
  return _matchesUsage(event, 0x0007004f) ||
      _matchesUsage(event, 0x0001008d) ||
      _matchesUsage(event, 0x1100000015);
}

bool _isActivateKey(KeyEvent event) {
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter ||
      key == LogicalKeyboardKey.space ||
      key == LogicalKeyboardKey.gameButtonA) {
    return true;
  }
  if (_matchesUsage(event, 0x0001008f)) return true; // dpad center
  if (_matchesUsage(event, 0x00090001)) return true; // button A
  if (_matchesUsage(event, 0x00090004)) return true; // button south/primary
  return false;
}

bool _isSelectKey(KeyEvent event) {
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.select ||
      key == LogicalKeyboardKey.gameButtonSelect) {
    return true;
  }
  return false;
}

bool _isStartKey(KeyEvent event) {
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.gameButtonStart) return true;
  return false;
}

bool _isBackKey(KeyEvent event) {
  final key = event.logicalKey;
  if (key == LogicalKeyboardKey.escape ||
      key == LogicalKeyboardKey.goBack ||
      key == LogicalKeyboardKey.exit) {
    return true;
  }
  if (_matchesUsage(event, 0x00090002)) return true; // button B / secondary
  return false;
}

bool _matchesUsage(KeyEvent event, int usage) {
  return event.physicalKey.usbHidUsage == usage;
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
    required this.compact,
    required this.horizontalPadding,
    required this.controller,
    required this.hasText,
    required this.hintText,
    required this.clearTooltip,
    required this.onChanged,
    required this.onClear,
  });

  final bool compact;
  final double horizontalPadding;
  final TextEditingController controller;
  final bool hasText;
  final String hintText;
  final String clearTooltip;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  double get minExtent => compact ? 64 : 88;

  @override
  double get maxExtent => compact ? 64 : 88;

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
        compact != oldDelegate.compact ||
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
    required this.compact,
    required this.isSelected,
    required this.onTap,
    required this.onDownload,
    required this.onFocus,
    this.thumbnailSize,
  });

  final String name;
  final String romName;
  final String sizeLabel;
  final String boxart;
  final String logo;
  final String platformAbbr;
  final bool isGrid;
  final bool compact;
  final bool isSelected;
  final double? thumbnailSize;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final borderColor = isSelected
        ? scheme.primary
        : scheme.outlineVariant.withValues(alpha: 0.14);
    final borderWidth = isSelected ? 2.0 : 1.0;
    final cardColor = isSelected
        ? scheme.primaryContainer.withValues(alpha: 0.45)
        : scheme.surfaceContainerLowest;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Card(
        elevation: isGrid ? 2.5 : 1.5,
        shadowColor: scheme.shadow.withValues(alpha: 0.16),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.transparent, width: 0),
        ),
        child: InkWell(
          onTap: onTap,
          onFocusChange: (hasFocus) {
            if (hasFocus) onFocus();
          },
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
              color: cardColor,
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final downloadTooltip =
        AppLocalizations.of(context)!.downloadsActionDownload;

    if (!isGrid) {
      final thumbSize = (thumbnailSize ?? 78)
          .clamp(compact ? 56.0 : 72.0, compact ? 110.0 : 132.0)
          .toDouble();
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

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: thumbSize,
                height: thumbSize,
                child: FallbackNetworkImage(
                  urls: [boxart, logo],
                  fit: BoxFit.cover,
                  fallback: Container(
                    color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                    child: Icon(
                      Icons.image_outlined,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  if (romName.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      romName.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: chips,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: downloadTooltip,
              onPressed: onDownload,
              icon: Icon(Icons.download_rounded, color: scheme.primary),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        final metadataPadding = EdgeInsets.fromLTRB(
          compact ? 12 : 16,
          isGrid ? 10 : (compact ? 10 : 14),
          compact ? 12 : 16,
          isGrid ? 12 : (compact ? 14 : 18),
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

        final heroHeight = (((thumbnailSize ?? 88) *
                (isGrid ? 1.05 : 1.25) *
                (compact ? 0.85 : 1.0)))
            .clamp(110.0, 220.0)
            .toDouble();

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
