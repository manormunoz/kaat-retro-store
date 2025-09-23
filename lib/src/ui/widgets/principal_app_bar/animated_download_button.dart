import 'package:flutter/material.dart';

class AnimatedDownloadButton extends StatelessWidget {
  final int downloadCount;
  final VoidCallback onPressed;
  final double iconSize;
  final Color? badgeColor;
  final Color? badgeTextColor;

  const AnimatedDownloadButton({
    super.key,
    required this.downloadCount,
    required this.onPressed,
    this.iconSize = 24.0,
    this.badgeColor = Colors.blue,
    this.badgeTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: iconSize,
      onPressed: onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.downloading_rounded,
            size: iconSize,
          ),
          Positioned(
            right: -6,
            top: -3,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.elasticOut,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: downloadCount <= 0
                  ? const SizedBox.shrink()
                  : Container(
                      key: Key('$downloadCount'),
                      width: iconSize * 0.65,
                      height: iconSize * 0.65,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).canvasColor,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$downloadCount',
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: iconSize * 0.35,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
