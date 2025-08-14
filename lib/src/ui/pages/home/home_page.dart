import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/pages/home/home_controller.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:kaat/src/ui/widgets/app_drawer/app_drawer.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: principalAppBar(context),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.platforms.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noPlatforms));
        }

        return ListView(
          children: controller.platforms.entries.map((entry) {
            final value = entry.value as Map<String, dynamic>;
            return ListTile(
              leading: CachedNetworkImage(
                imageUrl: value['platform_logo'],
                width: 40,
                height: 40,
                placeholder: (context, url) => SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
              title: Text(value['platform_name']),
              subtitle: Text(value['platform_abbr']),
              onTap: () => Get.toNamed(
                RouteNames.romsList,
                parameters: {
                  'platform_logo': value['platform_logo'],
                  'platform_name': value['platform_name'],
                  'platform_abbr': value['platform_abbr'],
                  'url': value['url'],
                  'roms_boxarts': value['roms_boxarts'],
                  'roms_logos': value['roms_logos'],
                  'ssSystemId': value['ssSystemId'].toString(),
                },
              ),
            );
          }).toList(),
        );
      }),
      endDrawer: const AppDrawer(),
      //   floatingActionButton: FloatingActionButton(
      //     elevation: 2.0,
      //     backgroundColor: Colors.white,
      //     child: const Icon(Icons.add, size: 38.0, color: Colors.black),
      //     onPressed: () {
      //       showModalBottomSheet<void>(
      //         context: context,
      //         backgroundColor: Colors.transparent,
      //         enableDrag: false,
      //         useSafeArea: true,
      //         isDismissible: false,
      //         builder: (BuildContext context) {
      //           return const ModalBottomSheet();
      //         },
      //       );
      //     },
      //   ),
      //   // bottomNavigationBar: const AppBottomNavigationBar(index: 0),
    );
  }
}
