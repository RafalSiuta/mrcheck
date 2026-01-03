import 'package:hive/hive.dart';

part 'value_item.g.dart';

@HiveType(typeId: 0)
class ValueItem {
  const ValueItem({
    required this.id,
    required this.date,
    required this.name,
    required this.value,
    this.category = '',
  });

  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double value;

  @HiveField(4)
  final String category;
}
