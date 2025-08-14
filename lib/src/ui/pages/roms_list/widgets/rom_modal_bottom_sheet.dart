import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/services/game_class.dart';
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
  const RomModalBottomSheet({
    super.key,
    required this.name,
    required this.size,
    required this.boxart,
    required this.logo,
    required this.url,
    required this.ssSystemId,
  });

  Widget ssGameWidget(BuildContext context, Game? game) {
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
      child: Stack(
        children: [
          DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1,
            maxChildSize: 1,
            minChildSize: 1,
            builder: (_, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                top: 40,
                bottom: 10,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FallbackNetworkImage(
                          urls: game?.box2D != null
                              ? [game!.box2D!, boxart, logo]
                              : [boxart, logo],
                          width: 100,
                          height: 100,
                          radius: 5,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game?.title != null && game?.title != 'Unknown'
                                  ? game!.title
                                  : romsListController.clearGameName(name),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                            ),

                            const SizedBox(height: 2),
                            Text(
                              '${game?.publisher ?? 'Unknown'}/${game?.developer ?? 'Unknown'}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            game?.rating != null
                                ? Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < game!.rating!.round()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  )
                                : Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        Icons.star_border,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    game?.synopsis ??
                        AppLocalizations.of(context)!.romNoMetadata,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  buttons(context, url),
                ],
              ),
            ),
          ),
          close(scheme),
        ],
      ),
    );
  }

  Widget close(ColorScheme scheme) {
    return Positioned(
      top: 5,
      right: 5,
      child: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.close, color: scheme.onSurface),
      ),
    );
  }

  Widget buttons(BuildContext context, String url) {
    final romsListController = Get.find<RomsListController>();
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: Text(AppLocalizations.of(context)!.openLink),
              onPressed: () => romsListController.openMyrient(url),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(AppLocalizations.of(context)!.copyLink),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Get.showSnackbar(
                  AppSnackbar(
                    SnackbarType.info,
                    AppLocalizations.of(context)!.linkCopied,
                  ),
                );
              },
            ),
          ),
        ],
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
    debugPrint(name);
    return FutureBuilder(
      future: romsListController.screenScrapper(name, systemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return container(context, Center(child: CircularProgressIndicator()));
        }
        // if (snapshot.hasError) {
        //   return ssGameWidget(context, null);
        // }

        final game = snapshot.data;
        return ssGameWidget(context, game);
      },
    );
  }
}
