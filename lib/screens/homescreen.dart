import 'package:flutter/material.dart';
import 'package:mrcash/models/wallet_model/wallet.dart';
import 'package:mrcash/utils/extensions/string_extension.dart';
import 'package:provider/provider.dart';

import '../providers/walletprovider.dart';
import '../utils/routes/custom_route.dart';
import '../providers/cashprovider.dart';
import '../widgets/calendar/list/calendar_list.dart';
import '../widgets/cards/current_wallet.dart';
import 'cash_creator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CashProvider, WalletProvider>(
      builder: (context, cashProvider, walletProvider, _) {
        final weekday = cashProvider.weekdayLabel;
        final formattedDate = cashProvider.formattedDate;
        final today = cashProvider.today;
        final sumItems = cashProvider.sumItems;

        final dailyCash = cashProvider.cashForDay(today).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        final totalIncome = dailyCash
            .where((c) => c.isIncome)
            .fold<double>(0, (sum, cash) => sum + sumItems(cash));
        final totalExpense = dailyCash
            .where((c) => !c.isIncome)
            .fold<double>(0, (sum, cash) => sum + sumItems(cash));
        final currency = dailyCash.isNotEmpty ? dailyCash.first.currency : '';
        Wallet? currentWallet;
        for (final wallet in walletProvider.wallets) {
          if (wallet.isCurrentWallet) {
            currentWallet = wallet;
            break;
          }
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium,
                    children: [
                      TextSpan(
                        text: '$weekday\n'.capitalizeFirstLetter(),
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      TextSpan(text: formattedDate),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentWallet != null)
                        CurrentWallet(
                          wallet: currentWallet,
                          income: totalIncome,
                          outcome: totalExpense,
                          currency: currency,
                        ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: CalendarList(
                          cashList: dailyCash,
                          showDate: false,
                          emptyText: 'Brak operacji w bieżącym dniu',
                          onEdit: (cash) async {
                            await Navigator.push(
                              context,
                              CustomPageRoute(
                                child: CashCreator(
                                  cash: cash,
                                  autofocusTitle: false,
                                ),
                                direction: AxisDirection.up,
                              ),
                            );
                          },
                          onDelete: (_) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
