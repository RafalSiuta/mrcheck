import 'package:flutter/material.dart';
import 'package:mrcash/utils/extensions/string_extension.dart';
import 'package:provider/provider.dart';

import '../models/currency_model/currency.dart';
import '../providers/walletprovider.dart';
import '../utils/calculations/currency_calculator.dart';
import '../utils/routes/custom_route.dart';
import '../widgets/buttons/icon_btn.dart';
import '../widgets/cards/wallet_card.dart';
import 'wallet_creator.dart';


class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const List<CurrencyOption> _currencyOptions = [
    CurrencyOption(symbol: 'PLN', short: 'zł', valueToPln: 1),
    CurrencyOption(symbol: 'CHF', short: 'chf', valueToPln: 4.65),
    CurrencyOption(symbol: 'USD', short: 'usd', valueToPln: 3.9),
    CurrencyOption(symbol: 'EUR', short: 'eur', valueToPln: 4.2),
    CurrencyOption(symbol: 'GBP', short: 'gbp', valueToPln: 5.0),
    CurrencyOption(symbol: '1oz GOLD', short: 'uncja', valueToPln: 15000),
    CurrencyOption(symbol: '1oz SILVER', short: 'uncja', valueToPln: 322),
  ];

  double _rateFor(String currencyShort) {
    final match = _currencyOptions.firstWhere(
      (option) => option.short.toLowerCase() == currencyShort.toLowerCase(),
      orElse: () =>
          const CurrencyOption(symbol: 'PLN', short: 'zł', valueToPln: 1),
    );
    return match.valueToPln;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8.0),
        child: Consumer<WalletProvider>(
          builder: (context, walletProvider, _) {
            final wallets = walletProvider.wallets;
            final totalValuePln = wallets.fold<double>(0, (sum, wallet) {
              final rate = _rateFor(wallet.currency);
              return sum + wallet.value * rate;
            });
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('portfele'.capitalizeFirstLetter(),
                        style: Theme.of(context).textTheme.headlineLarge),
                    IconBtn(
                      icon: Icons.add,
                      onClick: () {
                        final newWallet =
                            context.read<WalletProvider>().createEmptyWallet();
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            child: WalletCreator(
                              wallet: newWallet,
                              editEnable: true,
                            ),
                            direction: AxisDirection.up,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium,
                    children: [
                      const TextSpan(text: 'razem: '),
                      TextSpan(
                        text: '${totalValuePln.toStringAsFixed(2)} $globalCurrency',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wallets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                            final wallet = wallets[index];
                            final iconCode = wallet.icon == 0
                                ? Icons.account_balance_wallet.codePoint
                                : wallet.icon;
                            return WalletCard(
                              title: wallet.title,
                              total: wallet.value,
                              icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
                              backgroundColor: Color(wallet.color),
                              onClick: () async {
                          await Navigator.push(
                            context,
                            CustomPageRoute(
                              child: WalletCreator(
                                wallet: wallet,
                                editEnable: false,
                              ),
                              direction: AxisDirection.up,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
