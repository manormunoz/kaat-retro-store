import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/app/controllers/app_controller.dart';
import 'package:kaat/src/app/controllers/language_controller.dart';
import 'package:kaat/src/app/controllers/theme_controller.dart';
import 'package:kaat/src/ui/routes/route_names.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final LanguageController languageController =
        Get.find<LanguageController>();
    return Drawer(
      child: Column(
        children: [
          Flexible(
            child: ListView(
              children: [
                SizedBox(
                  height: 90.0,
                  child: DrawerHeader(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.configuration,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.close,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 3,
                    ),
                    child: ListTile(
                      leading: Icon(
                        themeController.isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                      title: Text(
                        themeController.isDark
                            ? AppLocalizations.of(context)!.lightTheme
                            : AppLocalizations.of(context)!.darkTheme,
                      ),
                      onTap: () {
                        themeController.toggle();
                      },
                    ),
                  ),
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 3,
                    ),
                    child: ListTile(
                      leading: Icon(Icons.translate_outlined),
                      title: Text(
                        languageController.locale.value?.languageCode
                                .toUpperCase() ??
                            AppLocalizations.of(context)!.systemLanguage,
                      ),
                      onTap: () => languageController.nextLocale(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 3,
                  ),
                  child: ListTile(
                    leading: Icon(Icons.favorite_rounded, color: Colors.red),
                    title: Text(AppLocalizations.of(context)!.creditsTitle),
                    onTap: () => Get.toNamed(RouteNames.credits),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Divider(),
                Obx(() {
                  if (!appController.loading) {
                    return Column(
                      children: [
                        Text(
                          '${appController.packageInfo.appName} ${DateTime.now().year.toString()}',
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.version} ${appController.packageInfo.version}/${appController.packageInfo.buildNumber}',
                        ),
                        const SizedBox(height: 4.0),
                      ],
                    );
                  }
                  return Container();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
