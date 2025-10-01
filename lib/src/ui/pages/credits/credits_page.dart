import 'package:flutter/material.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  Future<void> _open(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch ${uri.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            text,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        );
    return Scaffold(
      appBar: principalAppBar(
        context,
        title: AppLocalizations.of(context)!.creditsTitle,
        icon: Icon(Icons.favorite_rounded, color: Colors.red),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          sectionTitle(AppLocalizations.of(context)!.creditsProjectsTitle),
          _CreditTile(
            icon: Icons.storage_rounded,
            title: 'Myrient',
            url: Uri.parse('https://myrient.erista.me'),
            description: AppLocalizations.of(context)!.creditsMyrient,
            onTap: _open,
          ),
          _CreditTile(
            icon: Icons.cloud_rounded,
            title: 'jsDelivr',
            url: Uri.parse('https://www.jsdelivr.com'),
            description: AppLocalizations.of(context)!.creditsJsDelivr,
            onTap: _open,
          ),
          _CreditTile(
            icon: Icons.extension_rounded,
            title: 'Libretro / RetroArch',
            url: Uri.parse('https://www.libretro.com'),
            description: AppLocalizations.of(context)!.creditsLibretro,
            onTap: _open,
          ),
          _CreditTile(
            icon: Icons.image_rounded,
            title: 'libretro-thumbnails',
            url: Uri.parse('https://github.com/libretro-thumbnails'),
            description: AppLocalizations.of(context)!.creditsLibretroThumbs,
            onTap: _open,
          ),
          _CreditTile(
            icon: Icons.image_rounded,
            title: 'ScreenScraper',
            url: Uri.parse('https://www.screenscraper.fr'),
            description: AppLocalizations.of(context)!.creditsScreenScraper,
            onTap: _open,
          ),
          sectionTitle(AppLocalizations.of(context)!.creditsNotesTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppLocalizations.of(context)!.creditsNotes,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditTile extends StatelessWidget {
  const _CreditTile({
    required this.icon,
    required this.title,
    required this.url,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Uri url;
  final String description;
  final Future<void> Function(Uri) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: () => onTap(url),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        url.toString(),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_new_rounded,
                  color: scheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
