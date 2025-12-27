import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';
import 'dart:math' as math;

class HomeController extends GetxController {
  var platforms = <String, dynamic>{}.obs;
  var loading = true.obs;
  final focusedIndex = (-1).obs;
  final scrollController = ScrollController();
  static const double itemExtent = 88.0;
  static const double separatorExtent = 6.0;

  HomeController();
  @override
  void onInit() {
    super.onInit();
    loadPlatformsYaml();
    ever<int>(focusedIndex, (_) => _scrollToFocused());
  }

  Future<void> loadPlatformsYaml() async {
    try {
      final yamlString = await rootBundle.loadString(
        'assets/config/platforms.yaml',
      );

      final yamlMap = loadYaml(yamlString);
      final map = json.decode(json.encode(yamlMap));
      platforms.value = Map<String, dynamic>.from(map);
      focusedIndex.value = -1;
    } catch (e) {
      debugPrint("Error loading platforms.yml: $e");
    } finally {
      loading.value = false;
    }
  }

  void moveFocus(int delta, int itemCount) {
    if (itemCount <= 0) {
      focusedIndex.value = -1;
      return;
    }
    final current = focusedIndex.value == -1
        ? 0
        : focusedIndex.value.clamp(0, itemCount - 1);
    final next = (current + delta).clamp(0, itemCount - 1);
    focusedIndex.value = next.toInt();
    debugPrint('Home focus move: current=$current delta=$delta next=$next');
  }

  void setFocusIndex(int index, int itemCount) {
    if (itemCount <= 0) {
      focusedIndex.value = -1;
      return;
    }
    final next = index.clamp(0, itemCount - 1).toInt();
    focusedIndex.value = next;
    debugPrint('Home focus set: index=$index clamped=$next');
  }

  void _scrollToFocused() {
    final idx = focusedIndex.value;
    if (idx < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final targetOffset =
          math.max(0.0, idx * (itemExtent + separatorExtent) - itemExtent)
              .toDouble();
      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
