import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/app/app_binding.dart';
import 'package:kaat/src/app/app_theme.dart';
import 'package:kaat/src/app/controllers/language_controller.dart';
import 'package:kaat/src/app/controllers/theme_controller.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:kaat/src/ui/routes/route_pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final theme = AppTheme(palette: BrandPalette.evergreen);
    final lang = Get.find<LanguageController>();
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialBinding: AppBinding(),
        initialRoute: RouteNames.splash,
        getPages: RoutePages.all,
        locale: lang.locale.value,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode: themeCtrl.themeMode.value,
      ),
    );
  }
}
