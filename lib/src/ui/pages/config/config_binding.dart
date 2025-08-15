import 'package:kaat/src/ui/pages/config/config_controller.dart';
import 'package:get/get.dart';

class ConfigBinding implements Bindings {
  const ConfigBinding();

  @override
  void dependencies() {
    Get.lazyPut<ConfigController>(() => ConfigController());
  }
}
