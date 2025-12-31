import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashCard extends StatelessWidget {
  const CashCard({
    super.key,
    required this.name,
    required this.value,
    required this.date,
    required this.onEdit,
    required this.onDelete,
    this.isIncome,
    this.showDate = true,
    required this.currency,
    this.isEditing = false,
  });

  final String name;
  final double value;
  final DateTime date;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool? isIncome;
  final bool showDate;
  final String currency;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final baseTitleStyle = Theme.of(context).textTheme.titleMedium;
    final valueColor = isIncome == null
        ? baseTitleStyle?.color
        : (isIncome! ? Colors.green : Colors.red);
    final effectiveColor =
        isIncome == null && isEditing ? Colors.grey : valueColor;
    final dateTextStyle = Theme.of(context)
            .inputDecorationTheme
            .helperStyle
            ?.copyWith(color: Theme.of(context).unselectedWidgetColor) ??
        Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).unselectedWidgetColor);
    final formattedDate = DateFormat('dd MMM yyyy').format(date);

    return Dismissible(
      key: ValueKey('$name$value$formattedDate$isIncome'),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.transparent),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: ListTile(
         contentPadding: const EdgeInsets.symmetric(horizontal: .0),

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
                visible: !showDate,
                child: _DirectionIcon(isIncome: isIncome, color: effectiveColor)),
            RichText(
              text: TextSpan(
                style: baseTitleStyle?.copyWith(
                  color: isEditing ? Colors.grey : baseTitleStyle.color,
                ),
                children: [
                  TextSpan(
                    text: value.toStringAsFixed(2),
                    style: baseTitleStyle?.copyWith(color: effectiveColor),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: currency,
                    style: baseTitleStyle?.copyWith(color: effectiveColor),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(text: name),
                ],
              ),
            ),
          ],
        ),
        subtitle: Visibility(
          visible: showDate,
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              formattedDate,
              style: dateTextStyle,
            ),
          ),
        ),
        trailing: showDate ? null : const Icon(Icons.more_vert),
        onTap: onEdit,
      ),
    );
  }
}

class _DirectionIcon extends StatelessWidget {
  const _DirectionIcon({required this.isIncome, required this.color});

  final bool? isIncome;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color? iconColor = color;

    if (isIncome == null) {
      icon = Icons.horizontal_rule;
      iconColor ??= Theme.of(context).unselectedWidgetColor;
    } else if (isIncome!) {
      icon = Icons.arrow_drop_up;
      iconColor ??= Colors.green;
    } else {
      icon = Icons.arrow_drop_down;
      iconColor ??= Colors.red;
    }

    return Icon(
      icon,
      color: iconColor,
      size: 18,
    );
  }
}
