import 'package:flutter/material.dart';

import '../../../models/cash_model/cash.dart';
import '../../cards/cash_card.dart';

class CalendarList extends StatelessWidget {
  const CalendarList({
    super.key,
    required this.cashList,
    required this.onEdit,
    required this.onDelete,
    this.showDate = false,
    this.emptyText = 'Brak operacji w wybranym dniu',
  });

  final List<Cash> cashList;
  final void Function(Cash cash) onEdit;
  final void Function(Cash cash) onDelete;
  final bool showDate;
  final String emptyText;

  double _sumItems(Cash cash) =>
      cash.itemsList.fold<double>(0, (sum, item) => sum + item.value);

  @override
  Widget build(BuildContext context) {
    if (cashList.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      itemCount: cashList.length,
      separatorBuilder: (_, __) => Divider(
        height: 0.5,
        thickness: 0.5,
        color: Colors.grey.shade400,
      ),
      itemBuilder: (context, index) {
        final cash = cashList[index];
        final cashValue = _sumItems(cash);
        return CashCard(
          name: cash.name,
          value: cashValue,
          date: cash.date,
          isIncome: cash.isIncome,
          currency: cash.currency,
          showDate: showDate,
          onEdit: () => onEdit(cash),
          onDelete: () => onDelete(cash),
        );
      },
    );
  }
}
