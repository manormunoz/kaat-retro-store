// import 'package:lakis/src/app/controllers/auth_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/services/db_service.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashController();

  final RxBool _loading = RxBool(true);
  final message = "".obs;
  bool _booted = false;
  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    try {
      if (_booted) return;
      _booted = true;
      debugPrint('ENTRA al splash _init');
      message.value = AppLocalizations.of(Get.context!)!.initDb;
      final dbService = DbService();
      await dbService.initDb();
      _loading.value = false;
      debugPrint('SALE DESDE EL SPLASH');
      Get.offAllNamed(RouteNames.home);
    } catch (error) {
      debugPrint('ERROR:');
      debugPrint(error.toString());
    }
  }

  bool get loading => _loading.value;
}
