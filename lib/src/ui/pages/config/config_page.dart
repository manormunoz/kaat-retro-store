import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/pages/config/config_controller.dart';
import 'package:kaat/src/ui/widgets/app_snackbar/app_snackbar.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConfigController>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget sectionTitle(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            text,
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        );

    return Scaffold(
      appBar: principalAppBar(
        context,
        title: l10n.configuration,
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              sectionTitle(l10n.ssConfigTitle),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ssConfigExplanation,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.userCtrl,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: InputDecoration(
                            labelText: l10n.ssUsernameLabel,
                            hintText: 'e.g. your_ssid',
                            prefixIcon: const Icon(Icons.person_rounded),
                            filled: true,
                          ),
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? l10n.errorRequired
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.passCtrl,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: l10n.ssPasswordLabel,
                            prefixIcon: const Icon(Icons.lock_rounded),
                            filled: true,
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? l10n.errorRequired
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () {
                          controller.clear();
                          controller.userCtrl.clear();
                          controller.passCtrl.clear();
                          Get.showSnackbar(
                            AppSnackbar(
                              SnackbarType.info,
                              l10n.ssClearedMessage,
                            ),
                          );
                        },
                        label: Text(l10n.ssClearButton),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        onPressed: () async {
                          if (!controller.validate()) return;
                          await controller.save();
                          if (!context.mounted) return;
                          Get.showSnackbar(
                            AppSnackbar(
                              SnackbarType.info,
                              l10n.ssSavedMessage,
                            ),
                          );
                        },
                        label: Text(l10n.ssSaveButton),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
