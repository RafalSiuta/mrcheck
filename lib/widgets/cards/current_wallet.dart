import 'package:flutter/material.dart';

import '../../models/wallet_model/wallet.dart';

class CurrentWallet extends StatelessWidget {
  const CurrentWallet({
    required this.wallet,
    required this.income,
    required this.outcome,
    required this.currency,
    super.key,
  });

  final Wallet wallet;
  final double income;
  final double outcome;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final defaultTextColor =
        Theme.of(context).textTheme.titleMedium?.color ?? Colors.black;
    final iconData = wallet.icon == 0
        ? Icons.account_balance_wallet
        : IconData(wallet.icon, fontFamily: 'MaterialIcons');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(wallet.color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                wallet.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Icon(iconData, color: defaultTextColor),
            ],
          ),
          const SizedBox(height: 8),
          _summaryRow(
            context: context,
            label: 'Przychody',
            amount: income,
            currency: currency,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            context: context,
            label: 'Wydatki',
            amount: outcome,
            currency: currency,
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            context: context,
            label: 'Zostało',
            amount: wallet.value,
            currency: wallet.currency,
            color: defaultTextColor,
          ),
        ],
      ),
    );
  }
}

Widget _summaryRow({
  required BuildContext context,
  required String label,
  required double amount,
  required String currency,
  required Color color,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      Text(
        '${amount.toStringAsFixed(2)} $currency',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    ],
  );
}
