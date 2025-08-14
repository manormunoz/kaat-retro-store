import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:kaat/src/app/app.dart';
import 'package:kaat/src/app/controllers/language_controller.dart';
import 'package:kaat/src/app/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ThemeController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  runApp(const App());
}
