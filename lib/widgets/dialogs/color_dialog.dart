import 'package:flutter/material.dart';

import '../../models/color_model/color_option.dart';

class ColorDialog extends StatelessWidget {
  const ColorDialog({
    super.key,
    this.initialId = 0,
  });

  final int initialId;

  static const List<ColorOption> options = [
    ColorOption(id: 0, color: Colors.white),
    ColorOption(id: 1, color: Color(0xFFF1F5F9)),
    ColorOption(id: 2, color: Color(0xFFE0F2FE)),
    ColorOption(id: 3, color: Color(0xFFE6FFFA)),
    ColorOption(id: 4, color: Color(0xFFFFF7ED)),
    ColorOption(id: 5, color: Color(0xFFEFE9F4)),
    ColorOption(id: 6, color: Color(0xFFE8F5E9)),
    ColorOption(id: 7, color: Color(0xFFFFEBF0)),
    ColorOption(id: 8, color: Color(0xFFF4F1DE)),
    ColorOption(id: 9, color: Color(0xFFE3F2FD)),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 50),
      title: const Text('Wybierz kolor'),
      content: SizedBox(
        width: double.maxFinite,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = option.id == initialId;
            return InkWell(
              onTap: () => Navigator.of(context).pop(option),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
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
