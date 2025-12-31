class ValueItem {
  const ValueItem({
    required this.id,
    required this.date,
    required this.name,
    required this.value,
    this.category = "",
  });

  final int id;
  final DateTime date;
  final String name;
  final double value;
  final String category;
}