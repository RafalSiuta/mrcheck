import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarFormatButton extends StatelessWidget {
  const CalendarFormatButton({
    required this.format,
    required this.onFormatChange,
    this.textSize,
    super.key,
  });

  final CalendarFormat format;
  final ValueChanged<CalendarFormat> onFormatChange;
  final double? textSize;

  @override
  Widget build(BuildContext context) {
    const formats = [
      CalendarFormat.week,
      CalendarFormat.twoWeeks,
      CalendarFormat.month,
    ];

    final currentIndex = formats.indexOf(format);
    final nextFormat = formats[(currentIndex + 1) % formats.length];

    String label;
    switch (format) {
      case CalendarFormat.week:
        label = 'tydz';
        break;
      case CalendarFormat.twoWeeks:
        label = '2 tyg.';
        break;
      case CalendarFormat.month:
        label = 'mies';
        break;
    }

    final textTheme = Theme.of(context).textTheme;
    final resolvedSize = textSize ?? textTheme.bodyMedium?.fontSize ?? 14;
    final textStyle = textTheme.bodyMedium?.copyWith(
      fontSize: resolvedSize,
      fontWeight: FontWeight.bold,
    );

    const borderRadius = 12.0;

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => onFormatChange(nextFormat),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          height: resolvedSize * 2,
          padding: const EdgeInsets.symmetric(horizontal: borderRadius * 1.5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dialogTheme.titleTextStyle?.color ??
                  Theme.of(context).colorScheme.onSurface,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: Text(
              label,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
