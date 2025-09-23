import 'package:get/get.dart';
import 'package:kaat/src/ui/pages/download/download_controller.dart';

class DownloadBinding implements Bindings {
  const DownloadBinding();

  @override
  void dependencies() {
    Get.lazyPut<DownloadController>(() => DownloadController());
  }
}
