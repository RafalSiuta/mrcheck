import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../buttons/icon_btn.dart';

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    required this.next,
    required this.previous,
    required this.date,
    this.widget,
    this.padding = EdgeInsets.zero,
    this.locale,
    super.key,
  });

  final VoidCallback next;
  final VoidCallback previous;
  final DateTime date;
  final Widget? widget;
  final EdgeInsets padding;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    final textSize = Theme.of(context).textTheme.headlineMedium?.fontSize ?? 18;
    final formatted = DateFormat('MMM yy', locale).format(date);
    final titleStyle = Theme.of(context)
        .textTheme
        .headlineMedium
        ?.copyWith(fontSize: textSize);
    final iconColor = Theme.of(context).iconTheme.color;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: padding,
      height: textSize * 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconBtn(
            icon: Icons.arrow_left,
            onClick: previous,
          ),
          widget != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(formatted, style: titleStyle),
                    const SizedBox(width: 12),
                    widget!,
                  ],
                )
              : Text(formatted, style: titleStyle),
          IconBtn(
            icon: Icons.arrow_right,
            onClick: next,
          ),
        ],
      ),
    );
  }
}
