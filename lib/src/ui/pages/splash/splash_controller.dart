// import 'package:lakis/src/app/controllers/auth_controller.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/services/db_service.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashController();

  final RxBool _loading = RxBool(true);
  final message = "".obs;
  @override
  void onReady() {
    super.onReady();
    _init();
  }

  Future<void> _init() async {
    message.value = AppLocalizations.of(Get.context!)!.initDb;
    final dbService = DbService();
    await dbService.database;
    _loading.value = false;
    Get.offNamed(RouteNames.home);
  }

  bool get loading => _loading.value;
}
