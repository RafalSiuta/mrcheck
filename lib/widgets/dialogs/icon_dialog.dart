import 'package:flutter/material.dart';

import '../../models/icon_model/icon_option.dart';

class IconDialog extends StatelessWidget {
  const IconDialog({
    super.key,
    this.initialId = 0,
  });

  final int initialId;

  static const List<IconOption> options = [
    IconOption(id: 0, iconData: Icons.account_balance_wallet),
    IconOption(id: 1, iconData: Icons.attach_money),
    IconOption(id: 2, iconData: Icons.savings),
    IconOption(id: 3, iconData: Icons.pie_chart),
    IconOption(id: 4, iconData: Icons.trending_up),
    IconOption(id: 5, iconData: Icons.credit_card),
    IconOption(id: 6, iconData: Icons.account_balance),
    IconOption(id: 7, iconData: Icons.bar_chart),
    IconOption(id: 8, iconData: Icons.monetization_on),
    IconOption(id: 9, iconData: Icons.request_quote),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 50),
      title: const Text('Wybierz ikonę'),
      content: SizedBox(
        width: double.maxFinite,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = option.id == initialId;
            return InkWell(
              onTap: () => Navigator.of(context).pop(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Icon(option.iconData, color: Colors.black54),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
      ],
    );
  }
}
