import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/pages/home/home_controller.dart';
import 'package:kaat/src/ui/routes/route_names.dart';
import 'package:kaat/src/ui/widgets/app_drawer/app_drawer.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: principalAppBar(context),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.platforms.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context)!.noPlatforms));
        }

        final entries = controller.platforms.entries.toList(growable: false);
        final itemCount = entries.length;
        final focusedIndex = controller.focusedIndex.value;

        void openPlatform(Map<String, dynamic> value) {
          Get.toNamed(
            RouteNames.romsList,
            parameters: {
              'platform_logo': value['platform_logo'],
              'platform_name': value['platform_name'],
              'platform_abbr': value['platform_abbr'],
              'url': value['url'],
              'roms_boxarts': value['roms_boxarts'],
              'roms_logos': value['roms_logos'],
              'ssSystemId': value['ssSystemId'].toString(),
            },
          );
        }

        KeyEventResult handleKey(FocusNode node, KeyEvent event) {
          final isPress = event is KeyDownEvent || event is KeyRepeatEvent;
          if (!isPress) return KeyEventResult.ignored;
          if (_logKeys) _logKey(event);

          if (_isUpKey(event)) {
            controller.moveFocus(-1, itemCount);
            return KeyEventResult.handled;
          }
          if (_isDownKey(event)) {
            controller.moveFocus(1, itemCount);
            return KeyEventResult.handled;
          }
          if (_isStartKey(event)) {
            _scaffoldKey.currentState?.openEndDrawer();
            return KeyEventResult.handled;
          }
          if (_isSelectKey(event)) {
            Get.toNamed(RouteNames.download);
            return KeyEventResult.handled;
          }
          if (_isActivateKey(event)) {
            var index = controller.focusedIndex.value;
            if (index < 0 && itemCount > 0) {
              index = 0;
              controller.setFocusIndex(index, itemCount);
            }
            if (index >= 0 && index < itemCount) {
              final value =
                  Map<String, dynamic>.from(entries[index].value as Map);
              openPlatform(value);
            }
            return KeyEventResult.handled;
          }
          if (_isBackKey(event)) {
            if (Get.key.currentState?.canPop() ?? false) {
              Get.back();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          }
          return KeyEventResult.ignored;
        }

        return Focus(
          autofocus: true,
          onKeyEvent: handleKey,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            controller: controller.scrollController,
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final value =
                  Map<String, dynamic>.from(entries[index].value as Map);
              final isSelected = focusedIndex == index;
              return _PlatformTile(
                value: value,
                isSelected: isSelected,
                onTap: () => openPlatform(value),
                onFocus: () => controller.setFocusIndex(index, itemCount),
              );
            },
          ),
        );
      }),
      endDrawer: const AppDrawer(),
      //   floatingActionButton: FloatingActionButton(
      //     elevation: 2.0,
      //     backgroundColor: Colors.white,
      //     child: const Icon(Icons.add, size: 38.0, color: Colors.black),
      //     onPressed: () {
      //       showModalBottomSheet<void>(
      //         context: context,
      //         backgroundColor: Colors.transparent,
      //         enableDrag: false,
      //         useSafeArea: true,
      //         isDismissible: false,
      //         builder: (BuildContext context) {
      //           return const ModalBottomSheet();
      //         },
      //       );
      //     },
      //   ),
      //   // bottomNavigationBar: const AppBottomNavigationBar(index: 0),
    );
  }

  static bool _isUpKey(KeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) return true;
    // HID usages: keyboard arrow up (0x00070052), dpad up (0x00010090)
    return _matchesUsage(event, 0x00070052) ||
        _matchesUsage(event, 0x00010090) ||
        _matchesUsage(event, 0x1100000013);
  }

  static bool _isDownKey(KeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) return true;
    // HID usages: keyboard arrow down (0x00070051), dpad down (0x00010091)
    return _matchesUsage(event, 0x00070051) ||
        _matchesUsage(event, 0x00010091) ||
        _matchesUsage(event, 0x1100000014);
  }

  static bool _isActivateKey(KeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.gameButtonA) {
      return true;
    }
    // HID usages: dpad center (0x0001008f) and button A (0x00090001)
    if (_matchesUsage(event, 0x0001008f)) return true;
    if (_matchesUsage(event, 0x00090001)) return true;
    // Some controllers report button South / primary as 0x00090004
    if (_matchesUsage(event, 0x00090004)) return true;
    return false;
  }

  static bool _isSelectKey(KeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.gameButtonSelect) {
      return true;
    }
    return false;
  }

  static bool _isStartKey(KeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.gameButtonStart) {
      return true;
    }
    return false;
  }

  static bool _isBackKey(KeyEvent event) {
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.exit) {
      return true;
    }
    // HID usage for button B / secondary (0x00090002)
    if (_matchesUsage(event, 0x00090002)) return true;
    return false;
  }

  static bool _matchesUsage(KeyEvent event, int usage) {
    return event.physicalKey.usbHidUsage == usage;
  }

  static const bool _logKeys = true;
  static void _logKey(KeyEvent event) {
    final isRepeat = event is KeyRepeatEvent;
    debugPrint(
      'KeyEvent ${event.runtimeType} repeat=$isRepeat '
      'logical=${event.logicalKey.debugName} '
      '(${event.logicalKey.keyId.toRadixString(16)}) '
      'physicalUsage=0x${event.physicalKey.usbHidUsage.toRadixString(16)}',
    );
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.onFocus,
  });

  final Map<String, dynamic> value;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surfaceColor = scheme.surface;
    final highlightColor = scheme.primaryContainer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? highlightColor : surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? scheme.primary : scheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CachedNetworkImage(
          imageUrl: value['platform_logo'],
          width: 40,
          height: 40,
          placeholder: (context, url) => const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorWidget: (context, url, error) => const Icon(
              Icons.broken_image_rounded,
              size: 40,
              color: Colors.grey),
        ),
        title: Text(
          value['platform_name'],
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          value['platform_abbr'],
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          onFocus();
          onTap();
        },
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            onFocus();
          }
        },
      ),
    );
  }
}
