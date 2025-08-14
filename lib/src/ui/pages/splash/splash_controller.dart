// import 'package:lakis/src/app/controllers/auth_controller.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashController();

  final RxBool _loading = RxBool(true);

  @override
  void onReady() {
    super.onReady();
    _init();
  }

  void _init() {
    Get.offNamed(RouteNames.home);
  }

  bool get loading => _loading.value;
}
