import 'package:mrcash/models/wallet_model/wallet_item.dart';

class Wallet {
  const Wallet({
    required this.id,
    required this.title,
    required this.value,
    required this.icon,
    this.currency = 'zł',
    this.itemsList = const [],
  });

  final int id;
  final String title;
  final double value;
  final int icon;
  final String currency;
  final List<WalletItem> itemsList;
}
