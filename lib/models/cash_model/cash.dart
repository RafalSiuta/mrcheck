import '../value_model/value_item.dart';

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

  final int id;
  final DateTime date;
  final String name;
  final double value;
  final String currency;
  final bool isIncome;
  final List<ValueItem> itemsList;
}