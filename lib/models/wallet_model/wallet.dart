import 'package:hive/hive.dart';
import 'package:mrcash/models/value_model/value_item.dart';

part 'wallet.g.dart';

@HiveType(typeId: 2)
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

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double value;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int icon;

  @HiveField(5)
  final int color;

  @HiveField(6)
  final String currency;

  @HiveField(7)
  final List<ValueItem> itemsList;
}
