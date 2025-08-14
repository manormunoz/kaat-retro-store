import 'package:get/get.dart';
import 'package:kaat/src/ui/pages/roms_list/roms_list_controller.dart';

class RomsListBinding implements Bindings {
  const RomsListBinding();

  @override
  void dependencies() {
    Get.put<RomsListController>(RomsListController());
  }
}
