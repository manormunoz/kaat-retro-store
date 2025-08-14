import 'package:flutter/material.dart';

class OverlayProgressIndicator extends StatelessWidget {
  const OverlayProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 60.0,
        width: 60.0,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
