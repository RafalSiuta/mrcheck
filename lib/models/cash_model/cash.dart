import 'package:hive/hive.dart';
import '../value_model/value_item.dart';

part 'cash.g.dart';

@HiveType(typeId: 1)
class Cash {
  const Cash({
    required this.id,
    required this.date,
    required this.name,
    required this.value,
    this.currency = 'zł',
    this.isIncome = false,
    this.itemsList = const [],
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double value;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final bool isIncome;

  @HiveField(6)
  final List<ValueItem> itemsList;
}
