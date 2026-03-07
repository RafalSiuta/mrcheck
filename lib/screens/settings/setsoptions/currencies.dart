import 'package:flutter/material.dart';
import 'package:mrcash/models/currency_model/currency.dart';
import 'package:mrcash/providers/settingsprovider.dart';
import 'package:mrcash/utils/extensions/string_extension.dart';
import 'package:provider/provider.dart';

class CurrenciesScreen extends StatelessWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'waluty'.capitalizeFirstLetter(),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: settingsProvider.currencies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final currency = settingsProvider.currencies[index];
                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showCurrencyDialog(
                            context,
                            settingsProvider,
                            currency,
                          ),
                          child: ListTile(
                            title: Align(
                              alignment: Alignment.topLeft,
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: '${currency.symbol}  ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(fontSize: 16),
                                    ),
                                    TextSpan(
                                      text:
                                          '${currency.valueToPln.toStringAsFixed(2)}  ',
                                    ),
                                    TextSpan(text: currency.short),
                                  ],
                                ),
                              ),
                            ),
                            trailing: const Icon(Icons.more_vert),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCurrencyDialog(
    BuildContext context,
    SettingsProvider provider,
    CurrencyOption currency,
  ) async {
    String valueInput = currency.valueToPln.toStringAsFixed(2);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(currency.symbol),
          content: TextFormField(
            initialValue: valueInput,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Wartość',
            ),
            onChanged: (value) {
              valueInput = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () async {
                final normalized = valueInput.replaceAll(',', '.').trim();
                final parsed = double.tryParse(normalized);
                if (parsed == null) return;
                await provider.updateCurrencyValue(currency.symbol, parsed);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Zapisz'),
            ),
          ],
        );
      },
    );
  }
}
