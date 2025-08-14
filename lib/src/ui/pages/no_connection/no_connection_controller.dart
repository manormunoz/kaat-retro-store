// import 'package:lakis/src/app/controllers/auth_controller.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kaat/src/app/controllers/app_controller.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:get/get.dart';

class NoConnectionController extends GetxController {
  NoConnectionController();

  late StreamSubscription<bool> _listen;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() async {
    super.onClose();
    await _listen.cancel();
  }

  void _init() {
    final AppController appController = Get.find<AppController>();

    _listen = appController.isOnline.listen((isOnline) {
      debugPrint('isOnline listen: $isOnline');
      if (isOnline) {
        Get.offNamed(RouteNames.home);
      }
    });
  }
}
