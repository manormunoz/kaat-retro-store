import 'package:flutter/material.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final CreditsController controller = Get.find<CreditsController>();
    final cs = Theme.of(context).colorScheme;
    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return Scaffold(
      appBar: principalAppBar(
        context,
        title: AppLocalizations.of(context)!.creditsTitle,
        icon: Icon(Icons.favorite_rounded, color: Colors.red),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          sectionTitle(AppLocalizations.of(context)!.creditsProjectsTitle),

          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Myrient'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'https://myrient.erista.me/',
                  style: TextStyle(color: Color(0xFF1A73E8)),
                ),
                Text(AppLocalizations.of(context)!.creditsMyrient),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Myrient',
              onPressed: () => _open('https://myrient.erista.me/'),
            ),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('jsDelivr'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'https://www.jsdelivr.com/',
                  style: TextStyle(color: Color(0xFF1A73E8)),
                ),
                Text(AppLocalizations.of(context)!.creditsJsDelivr),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'jsDelivr',
              onPressed: () => _open('https://www.jsdelivr.com/'),
            ),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.extension),
            title: const Text('Libretro / RetroArch'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'https://www.libretro.com/',
                  style: TextStyle(color: Color(0xFF1A73E8)),
                ),
                Text(AppLocalizations.of(context)!.creditsLibretro),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Libretro / RetroArch',
              onPressed: () => _open('https://www.libretro.com/'),
            ),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('libretro-thumbnails'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'https://github.com/libretro-thumbnails',
                  style: TextStyle(color: Color(0xFF1A73E8)),
                ),
                Text(AppLocalizations.of(context)!.creditsLibretroThumbs),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'libretro-thumbnails',
              onPressed: () => _open('https://github.com/libretro-thumbnails'),
            ),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('ScreenScraper'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'https://www.screenscraper.fr/',
                  style: TextStyle(color: Color(0xFF1A73E8)),
                ),
                Text(AppLocalizations.of(context)!.creditsScreenScraper),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'ScreenScraper',
              onPressed: () => _open('https://www.screenscraper.fr/'),
            ),
          ),
          sectionTitle(AppLocalizations.of(context)!.creditsNotesTitle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              AppLocalizations.of(context)!.creditsNotes,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
