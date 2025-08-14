import 'package:get/get.dart';
import 'package:kaat/src/app/controllers/app_controller.dart';
import 'package:kaat/src/app/controllers/language_controller.dart';
import 'package:kaat/src/app/controllers/theme_controller.dart';

class AppBinding implements Bindings {
  AppBinding();

  @override
  void dependencies() {
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<LanguageController>(LanguageController(), permanent: true);
  }
}
