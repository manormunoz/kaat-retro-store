import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ConfigController extends GetxController {
  ConfigController();
  static const kUser = 'ss_user';
  static const kPass = 'ss_pass';

  final _box = GetStorage();

  // Form + campos
  final formKey = GlobalKey<FormState>();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final remember = true.obs; // si desmarcas, no se guardan

  @override
  void onInit() {
    // Cargar si había guardado
    final u = _box.read<String?>(kUser);
    final p = _box.read<String?>(kPass);
    if (u != null) userCtrl.text = u;
    if (p != null) passCtrl.text = p;
    super.onInit();
  }

  @override
  void onClose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  Future<void> save() async {
    if (!remember.value) {
      await clear();
      return;
    }
    await _box.write(kUser, userCtrl.text.trim());
    await _box.write(kPass, passCtrl.text);
  }

  Future<void> clear() async {
    await _box.remove(kUser);
    await _box.remove(kPass);
  }

  String get ssid => userCtrl.text.trim();
  String get ssPassword => passCtrl.text;
}
