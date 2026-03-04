import 'package:flutter/material.dart';

class WalletSetsDialog extends StatelessWidget {
  const WalletSetsDialog({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final Future<void> Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 50),
      title: const Text('Ustawienia portfela'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('bieżący portfel'),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: (nextValue) async {
                await onChanged(nextValue);
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Zamknij'),
        ),
      ],
    );
  }
}
