import 'package:mrcash/models/value_model/value_item.dart';

class Wallet {
  const Wallet({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
    this.icon = 0,
    this.color = 0xFFFFFFFF,
    this.currency = 'zł',
    this.itemsList = const [],
  });

  final int id;
  final String title;
  final double value;
  final DateTime date;
  final int icon;
  final int color;
  final String currency;
  final List<ValueItem> itemsList;
}
