class CurrencyOption {
  const CurrencyOption({
    required this.symbol,
    required this.short,
    required this.valueToPln,
  });

  final String symbol;
  final String short;
  final double valueToPln;

  CurrencyOption copyWith({
    String? symbol,
    String? short,
    double? valueToPln,
  }) {
    return CurrencyOption(
      symbol: symbol ?? this.symbol,
      short: short ?? this.short,
      valueToPln: valueToPln ?? this.valueToPln,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'symbol': symbol,
      'short': short,
      'valueToPln': valueToPln,
    };
  }

  factory CurrencyOption.fromMap(Map<String, dynamic> map) {
    return CurrencyOption(
      symbol: (map['symbol'] as String?) ?? '',
      short: (map['short'] as String?) ?? '',
      valueToPln: (map['valueToPln'] as num?)?.toDouble() ?? 1,
    );
  }
}
