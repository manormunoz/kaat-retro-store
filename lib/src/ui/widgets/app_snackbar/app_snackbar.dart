import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackbarType {
  success,
  danger,
  info,
  warning,
  secondary,
}

/// Show a red snackbar with the error information.
class AppSnackbar extends GetSnackBar {
  final SnackbarType type;
  final int seconds;

  final _colors = {
    SnackbarType.success: Colors.green,
    SnackbarType.danger: Colors.redAccent,
    SnackbarType.warning: Colors.orangeAccent,
    SnackbarType.info: Colors.blue,
    SnackbarType.secondary: const Color.fromARGB(255, 31, 31, 31),
  };
  final _icons = {
    SnackbarType.success: Icons.check_sharp,
    SnackbarType.danger: Icons.error_sharp,
    SnackbarType.warning: Icons.warning_amber_sharp,
    SnackbarType.info: Icons.info_outline_rounded,
    SnackbarType.secondary: Icons.message_sharp,
  };
  AppSnackbar(this.type, String message, {super.key, this.seconds = 2})
      : super(
          message: message,
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          borderRadius: 5,
        );

  @override
  Color get backgroundColor => _colors[type]!;

  @override
  Widget? get icon => Icon(_icons[type], color: Colors.white);

  @override
  Widget? get mainButton {
    return IconButton(
      onPressed: () => Get.back(),
      color: Colors.white,
      icon: const Icon(Icons.close_outlined),
    );
  }

  @override
  Duration? get duration => Duration(seconds: seconds);

  @override
  Widget? get messageText {
    return SelectableText(
      message!,
      style: const TextStyle(
        color: Colors.white,
      ),
    );
  }

  @override
  SnackPosition get snackPosition => SnackPosition.BOTTOM;
}
