import 'package:flutter/material.dart';
import 'package:mrcash/models/wallet_model/wallet_item.dart';
import '../models/wallet_model/wallet.dart';
import '../utils/routes/custom_route.dart';
import '../widgets/buttons/icon_btn.dart';
import '../widgets/cards/wallet_card.dart';
import 'wallet_creator.dart';


class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const wallets = [
      Wallet(
        id: 1,
        title: 'świnka',
        value: 123.45,
        icon: 1,
        itemsList: const [
          WalletItem(id: 1, name: 'kieszonkowe', value: 10),
          WalletItem(id: 2, name: 'usługa', value: 20),
        ],
      ),
      Wallet(
        id: 2,
        title: 'akcje',
        value: 4567.89,
        icon: 1,
        itemsList: const [
          WalletItem(id: 3, name: 'kryptowaluty', value: 200),
          WalletItem(id: 4, name: 'ETF', value: 400),
        ],
      ),
      Wallet(
        id: 3,
        title: 'bank',
        value: 321.00,
        icon: 1,
        itemsList: const [
          WalletItem(id: 5, name: 'rachunek bieżący', value: 120),
          WalletItem(id: 6, name: 'oszczędności', value: 201),
        ],
      ),
      Wallet(
        id: 4,
        title: 'waluty',
        value: 987.65,
        icon: 1,
        itemsList: const [
          WalletItem(id: 7, name: 'USD', value: 400),
          WalletItem(id: 8, name: 'EUR', value: 587.65),
        ],
      ),
    ];
    final totalValue =
        wallets.fold<double>(0, (sum, wallet) => sum + wallet.value);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                                '${totalValue.toStringAsFixed(2)} ${wallets.first.currency}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
