import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/app/controllers/app_controller.dart';
import 'package:kaat/src/app/controllers/language_controller.dart';
import 'package:kaat/src/app/controllers/theme_controller.dart';
import 'package:kaat/src/ui/routes/route_names.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Obx(() {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      final l10n = AppLocalizations.of(context)!;
      final material = MaterialLocalizations.of(context);
      final isDark = themeController.isDark;
      final currentLocaleCode =
          languageController.locale.value?.languageCode.toUpperCase() ??
              l10n.systemLanguage;

      return Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.configuration,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: material.closeButtonLabel,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _InteractiveSettingTile(
                      icon: isDark
                          ? Icons.nightlight_round
                          : Icons.wb_sunny_rounded,
                      title: l10n.themeSetting,
                      subtitle: isDark ? l10n.darkTheme : l10n.lightTheme,
                      onTap: themeController.toggle,
                    ),
                    _InteractiveSettingTile(
                      icon: Icons.translate_rounded,
                      title: l10n.languageSetting,
                      subtitle: currentLocaleCode,
                      onTap: languageController.nextLocale,
                    ),
                    const Divider(height: 24),
                    _NavigationTile(
                      icon: Icons.settings_rounded,
                      label: l10n.configuration,
                      onTap: () {
                        Navigator.of(context).maybePop();
                        Get.toNamed(RouteNames.config);
                      },
                    ),
                    _NavigationTile(
                      icon: Icons.favorite_rounded,
                      iconColor: scheme.error,
                      label: l10n.creditsTitle,
                      onTap: () {
                        Navigator.of(context).maybePop();
                        Get.toNamed(RouteNames.credits);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Obx(() {
                    if (appController.loading) {
                      return const SizedBox.shrink();
                    }
                    final info = appController.packageInfo;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.appName,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.version} ${info.version} (build ${info.buildNumber})',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.label,
    this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? scheme.onSurfaceVariant,
        ),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _InteractiveSettingTile extends StatelessWidget {
  const _InteractiveSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: scheme.onSurfaceVariant,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
