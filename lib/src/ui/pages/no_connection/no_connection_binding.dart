import 'package:kaat/src/ui/pages/no_connection/no_connection_controller.dart';
import 'package:get/get.dart';

class NoConnectionBinding implements Bindings {
  const NoConnectionBinding();

  @override
  void dependencies() {
    Get.lazyPut<NoConnectionController>(() => NoConnectionController());
  }
}
