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
    final ConfigController controller = Get.find<ConfigController>();
    return Scaffold(
      appBar: principalAppBar(
        context,
        title: AppLocalizations.of(context)!.configuration,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: ListView(
              children: [
                Text(
                  AppLocalizations.of(context)!.ssConfigTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.userCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.ssUsernameLabel,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? AppLocalizations.of(context)!.errorRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.passCtrl,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.ssPasswordLabel,
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (v) => (v == null || v.isEmpty)
                      ? AppLocalizations.of(context)!.errorRequired
                      : null,
                ),
                const SizedBox(height: 8),
                Obx(
                  () => CheckboxListTile(
                    value: controller.remember.value,
                    onChanged: (v) => controller.remember.value = v ?? true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppLocalizations.of(context)!.ssRememberDevice),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.clear();
                          controller.userCtrl.clear();
                          controller.passCtrl.clear();
                          Get.showSnackbar(
                            AppSnackbar(
                              SnackbarType.info,
                              AppLocalizations.of(context)!.ssClearedMessage,
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.ssClearButton,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (!controller.validate()) return;
                          await controller.save();
                          if (!context.mounted) return;
                          Get.showSnackbar(
                            AppSnackbar(
                              SnackbarType.info,
                              AppLocalizations.of(context)!.ssSavedMessage,
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.ssSaveButton),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
