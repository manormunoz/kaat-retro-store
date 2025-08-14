import 'package:kaat/src/ui/pages/home/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  const HomeBinding();

  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
  }
}
