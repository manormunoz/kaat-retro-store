import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/src/ui/pages/download/download_controller.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/animated_download_button.dart';

PreferredSize principalAppBar(
  BuildContext context, {
  bool clear = false,
  String? title,
  String? logo,
  Icon? icon,
}) {
  final downloadController = Get.find<DownloadController>();
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final effectiveTitle = (title == null || title.trim().isEmpty)
      ? "K'aat Retro Store"
      : title.trim();
  final showLogo = logo != null && logo.isNotEmpty;
  final showIcon = icon != null;

  final canPop = ModalRoute.of(context)?.canPop ?? false;

  return PreferredSize(
    preferredSize: const Size.fromHeight(72),
    child: AppBar(
      elevation: clear ? 0 : 1,
      surfaceTintColor: Colors.transparent,
      backgroundColor: clear ? Colors.transparent : scheme.surface,
      centerTitle: false,
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      leadingWidth: canPop ? 56 : null,
      leading: canPop ? BackButton(color: scheme.onSurface) : null,
      titleSpacing: canPop ? 0 : 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _BrandAvatar(imageUrl: logo, size: 40),
            )
          else if (showIcon)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                icon.icon,
                color: icon.color ?? scheme.primary,
                size: icon.size ?? 28,
              ),
            ),
          Flexible(
            child: Text(
              effectiveTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actionsIconTheme: IconThemeData(color: scheme.onSurface),
      actions: [
        if (!_shouldHideActions())
          Obx(() {
            final count = downloadController.downloadsInProgress.length;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: AnimatedDownloadButton(
                downloadCount: count,
                onPressed: () => Get.toNamed(RouteNames.download),
              ),
            );
          }),
        if (!_shouldHideActions())
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Builder(
              builder: (ctx) => IconButton(
                tooltip: MaterialLocalizations.of(ctx).openAppDrawerTooltip,
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ),
      ],
    ),
  );
}

bool _shouldHideActions() {
  return {
    RouteNames.download,
    RouteNames.config,
    RouteNames.credits,
  }.contains(Get.currentRoute);
}

class _BrandAvatar extends StatelessWidget {
  const _BrandAvatar({required this.imageUrl, this.size = 48});

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              alignment: Alignment.center,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(scheme.primary),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
