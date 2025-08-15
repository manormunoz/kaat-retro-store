import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppController extends GetxController {
  AppController();

  final RxBool _loading = RxBool(true);
  final RxBool isOnline = RxBool(true);

  final Rx<PackageInfo> _packageInfo = Rx(
    PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown',
      buildSignature: 'Unknown',
      installerStore: 'Unknown',
    ),
  );

  final RxBool _isLightTheme = false.obs;

  final Rx<ConnectivityResult> _connectionStatus = Rx(ConnectivityResult.none);
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // _connectivitySubscription.cancel();
  // }

  void _init() async {
    _initPackageInfo().then((info) {
      _packageInfo.value = info;
      _packageInfo.trigger(info);
      _loading(false);
    });
    await initConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<PackageInfo> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    return info;
  }

  bool get loading => _loading.value;

  PackageInfo get packageInfo => _packageInfo.value;
  bool get isLightTheme => _isLightTheme.value;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) {
    //   return Future.value(null);
    // }
    await _updateConnectionStatus(result);
  }

  FutureOr<void> _updateConnectionStatus(
    List<ConnectivityResult> result,
  ) async {
    debugPrint('----------------_updateConnectionStatus----------------');

    debugPrint(result.first.name);
    _connectionStatus.value = result.first;
    await _checkStatus();
  }

  ConnectivityResult get connectionStatus => _connectionStatus.value;

  Future<void> _checkStatus() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      debugPrint(result.isNotEmpty.toString());
      debugPrint(result[0].rawAddress.isNotEmpty.toString());
      isOnline.value = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      debugPrint(isOnline.value.toString());
    } on SocketException catch (_) {
      isOnline.value = false;
    }
    if (_connectionStatus.value == ConnectivityResult.none || !isOnline.value) {
      Get.offNamed(RouteNames.noConnection);
    } else {
      Get.offNamed(RouteNames.home);
    }
  }
}
