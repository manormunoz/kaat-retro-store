import 'package:kaat/src/ui/pages/credits/credits_controller.dart';
import 'package:get/get.dart';

class CreditsBinding implements Bindings {
  const CreditsBinding();

  @override
  void dependencies() {
    Get.lazyPut<CreditsController>(() => CreditsController());
  }
}
