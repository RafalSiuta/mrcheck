import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrcash/utils/extensions/string_extension.dart';

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
    final formatted = DateFormat('MMMM yy', locale).format(date);
    final titleStyle = Theme.of(context)
        .textTheme
        .headlineMedium
        ?.copyWith(fontSize: textSize);
    final iconColor = Theme.of(context).iconTheme.color;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: padding,
      margin: EdgeInsets.only(top: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget != null ? widget! : Placeholder(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconBtn(
                icon: Icons.arrow_left,
                onClick: previous,
              ),
              Text(formatted.capitalizeFirstLetter(), style: titleStyle),

              // widget != null
              //     ? Row(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //
              //           const SizedBox(width: 12),
              //           widget!,
              //         ],
              //       )
              //     : Text(formatted, style: titleStyle),
              IconBtn(
                icon: Icons.arrow_right,
                onClick: next,
              ),

            ],

          ),

        ],
      ),
    );
  }
}
