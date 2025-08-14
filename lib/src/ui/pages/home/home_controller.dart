import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

class HomeController extends GetxController {
  var platforms = <String, dynamic>{}.obs;
  var loading = true.obs;
  HomeController();
  @override
  void onInit() {
    super.onInit();
    loadPlatformsYaml();
  }

  Future<void> loadPlatformsYaml() async {
    try {
      final yamlString = await rootBundle.loadString(
        'assets/config/platforms.yaml',
      );

      final yamlMap = loadYaml(yamlString);
      final map = json.decode(json.encode(yamlMap));
      platforms.value = Map<String, dynamic>.from(map);
    } catch (e) {
      debugPrint("Error loading platforms.yml: $e");
    } finally {
      loading.value = false;
    }
  }
}
