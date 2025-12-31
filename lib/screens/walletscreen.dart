import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/walletprovider.dart';
import '../utils/routes/custom_route.dart';
import '../widgets/buttons/icon_btn.dart';
import '../widgets/cards/wallet_card.dart';
import 'wallet_creator.dart';


class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<WalletProvider>(
          builder: (context, walletProvider, _) {
            final wallets = walletProvider.wallets;
            final totalValue =
                wallets.fold<double>(0, (sum, wallet) => sum + wallet.value);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('my wallets',
                        style: Theme.of(context).textTheme.headlineMedium),
                    IconBtn(
                      icon: Icons.add,
                      onClick: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        GridView.builder(
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
                            return WalletCard(
                              title: wallet.title,
                              total: wallet.value,
                              icon: IconData(wallet.icon, fontFamily: 'MaterialIcons'),
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
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.headlineMedium,
                            children: [
                              const TextSpan(text: 'razem:\n'),
                              TextSpan(
                                text:
                                    '${totalValue.toStringAsFixed(2)} ${wallets.isNotEmpty ? wallets.first.currency : ''}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
