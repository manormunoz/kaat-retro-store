import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaat/l10n/app_localizations.dart';
import 'package:kaat/src/ui/pages/download/download_controller.dart';
import 'package:kaat/src/ui/widgets/app_snackbar/app_snackbar.dart';
import 'package:kaat/src/ui/widgets/principal_app_bar/principal_app_bar.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DownloadController controller = Get.find<DownloadController>();

    return Scaffold(
      appBar: principalAppBar(
        context,
        title: AppLocalizations.of(context)!.downloadsTitle,
        icon: Icon(Icons.downloading_rounded),
        clear: true,
      ),
      body: Obx(() {
        final items = controller.downloads.values.toList();
        if (items.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.downloadsNoActiveDownloads,
            ),
          );
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final item = items[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(item.filename),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(item.progress * 100).toStringAsFixed(1)}% - ${item.statusDescription}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.status == TaskStatus.running) ...[
                      IconButton(
                        icon: const Icon(Icons.pause_rounded),
                        onPressed: () => controller.pause(item.taskId),
                      ),
                    ] else if (item.status == TaskStatus.paused) ...[
                      IconButton(
                        icon: const Icon(Icons.play_arrow_rounded),
                        onPressed: () => controller.resume(item.taskId),
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded),
                      onPressed: () => controller.cancel(item.taskId),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await controller.clearCompleted();
          if (!context.mounted) return;
          Get.showSnackbar(AppSnackbar(
            SnackbarType.info,
            AppLocalizations.of(context)!.downloadsDownloadsCleared,
          ));
        },
        child: const Icon(Icons.delete_sweep_rounded),
      ),
    );
  }
}
