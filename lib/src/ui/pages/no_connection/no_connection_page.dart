import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:kaat/l10n/app_localizations.dart';

class NoConnectionPage extends StatelessWidget {
  const NoConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final material = MaterialLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth.clamp(280.0, 420.0);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Semantics(
                          image: true,
                          label: l10n.noConnection,
                          child: SvgPicture.asset(
                            'assets/svg/error2.svg',
                            width: 160,
                            height: 160,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.noConnection,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noConnectionDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextButton.icon(
                        onPressed: SystemNavigator.pop,
                        icon: const Icon(Icons.close_rounded),
                        label: Text(material.closeButtonLabel),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
