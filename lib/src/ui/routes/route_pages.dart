import 'package:kaat/src/ui/pages/config/config_binding.dart';
import 'package:kaat/src/ui/pages/config/config_page.dart';
import 'package:kaat/src/ui/pages/credits/credits_binding.dart';
import 'package:kaat/src/ui/pages/credits/credits_page.dart';
import 'package:kaat/src/ui/pages/home/home_binding.dart';
import 'package:kaat/src/ui/pages/home/home_page.dart';
import 'package:kaat/src/ui/pages/no_connection/no_connection_binding.dart';
import 'package:kaat/src/ui/pages/no_connection/no_connection_page.dart';
import 'package:kaat/src/ui/pages/roms_list/roms_list_binding.dart';
import 'package:kaat/src/ui/pages/roms_list/roms_list_page.dart';
import 'package:kaat/src/ui/pages/splash/splash_binding.dart';
import 'package:kaat/src/ui/pages/splash/splash_page.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:get/get.dart';

class RoutePages {
  const RoutePages._();

  static List<GetPage<dynamic>> get all {
    return [
      GetPage(
        name: RouteNames.noConnection,
        page: () => const NoConnectionPage(),
        binding: const NoConnectionBinding(),
        transition: Transition.noTransition,
      ),
      GetPage(
        name: RouteNames.splash,
        page: () => const SplashPage(),
        binding: const SplashBinding(),
        transition: Transition.noTransition,
      ),
      GetPage(
        name: RouteNames.home,
        page: () => const HomePage(),
        binding: const HomeBinding(),
        transition: Transition.noTransition,
      ),
      GetPage(
        name: RouteNames.romsList,
        page: () => const RomsListPage(),
        binding: const RomsListBinding(),
        transition: Transition.noTransition,
      ),
      GetPage(
        name: RouteNames.credits,
        page: () => const CreditsPage(),
        binding: const CreditsBinding(),
        transition: Transition.noTransition,
      ),
      GetPage(
        name: RouteNames.config,
        page: () => const ConfigPage(),
        binding: const ConfigBinding(),
        transition: Transition.noTransition,
      ),
    ];
  }
}
