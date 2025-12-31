import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/cash_model/cash.dart';
import '../utils/routes/custom_route.dart';
import '../providers/cashprovider.dart';
import '../widgets/cards/cash_card.dart';
import 'cash_creator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = DateFormat('EEEE').format(now);
    final formattedDate = DateFormat('dd MMM yyyy').format(now);
    double sumItems(Cash cash) => cash.itemsList.fold<double>(
          0,
          (sum, item) => sum + item.value,
        );


    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium,
                children: [
                  TextSpan(text: '$weekday\n',style:Theme.of(context).textTheme.headlineLarge ),
                  TextSpan(text: formattedDate),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Consumer<CashProvider>(
              builder: (context, cashProvider, _) {
                final cashList = cashProvider.cashList;
                final totalIncome = cashList
                    .where((c) => c.isIncome)
                    .fold<double>(0, (sum, cash) => sum + sumItems(cash));
                final totalExpense = cashList
                    .where((c) => !c.isIncome)
                    .fold<double>(0, (sum, cash) => sum + sumItems(cash));
                final currency =
                    cashList.isNotEmpty ? cashList.first.currency : '';

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headlineMedium,
                          children: [
                            const TextSpan(text: 'podsumowanie\n'),
                            TextSpan(
                              text:
                                  'przychody: ${totalIncome.toStringAsFixed(2)} $currency\n',
                            ),
                            TextSpan(
                              text:
                                  'wydatki: ${totalExpense.toStringAsFixed(2)} $currency',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: cashList.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: Colors.grey.shade400,
                          ),
                          itemBuilder: (context, index) {
                            final cash = cashList[index];
                            final cashValue = sumItems(cash);
                            return CashCard(
                              name: cash.name,
                              value: cashValue,
                              date: cash.date,
                              isIncome: cash.isIncome,
                              currency: cash.currency,
                              showDate: false,
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  CustomPageRoute(
                                    child: CashCreator(cash: cash),
                                    direction: AxisDirection.up,
                                  ),
                                );
                              },
                              onDelete: () {},
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
