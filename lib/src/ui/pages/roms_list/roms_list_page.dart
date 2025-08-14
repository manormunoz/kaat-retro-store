import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/pages/roms_list/roms_list_controller.dart';
import 'package:kaat/src/ui/pages/roms_list/widgets/rom_modal_bottom_sheet.dart';
import 'package:kaat/src/ui/widgets/app_drawer/app_drawer.dart';
import 'package:kaat/src/ui/widgets/fallback_network_image/fallback_network_image.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';

class RomsListPage extends GetView<RomsListController> {
  const RomsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: principalAppBar(
        context,
        title: controller.platform['platform_name'],
        logo: controller.platform['platform_logo'],
        clear: true,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                controller: controller.searchCtrl,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchoRoms,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: controller.roms.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)!.noRoms))
                  : ListView.builder(
                      itemCount: controller.roms.length,
                      itemBuilder: (context, i) {
                        final item = controller.roms[i];
                        final name = item['name']?.toString() ?? '';
                        final size = item['size']?.toString() ?? '';
                        final boxart = item['boxart']?.toString() ?? '';
                        final logo = item['logo']?.toString() ?? '';
                        final url = item['url']?.toString() ?? '';
                        final ssSystemId = item['ssSystemId']?.toString() ?? '';

                        return ListTile(
                          leading: FallbackNetworkImage(
                            urls: [boxart, logo],
                            width: 40,
                            height: 40,
                            radius: 5,
                          ),
                          title: Text(name),
                          subtitle: Text(size),
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              // backgroundColor: Colors.transparent,
                              enableDrag: false,
                              useSafeArea: true,
                              isDismissible: true,
                              builder: (BuildContext context) {
                                return RomModalBottomSheet(
                                  name: name,
                                  size: size,
                                  boxart: boxart,
                                  logo: logo,
                                  url: url,
                                  ssSystemId: ssSystemId,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      endDrawer: const AppDrawer(),
    );
  }
}
