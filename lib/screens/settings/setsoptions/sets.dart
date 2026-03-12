import 'package:flutter/material.dart';
import 'package:mrcash/providers/backupPprovider.dart';
import 'package:mrcash/providers/settingsprovider.dart';
import 'package:mrcash/utils/extensions/string_extension.dart';
import 'package:provider/provider.dart';

class SetsScreen extends StatelessWidget {
  const SetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, BackupProvider>(
      builder: (context, settingsProvider, backupProvider, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ogólne'.capitalizeFirstLetter(),
                    style: Theme.of(context).textTheme.headlineLarge),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'ukryj portfel',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: settingsProvider.lockWallet,
                          onChanged: (value) {
                            settingsProvider.lockData(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await backupProvider.exportBackupFiles();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Backup exported successfully.'),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'eksportuj backup',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Icon(Icons.download),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
