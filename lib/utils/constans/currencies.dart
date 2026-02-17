import 'package:mrcash/models/currency_model/currency.dart';

const List<CurrencyOption> defaultCurrencies = [
  CurrencyOption(symbol: 'PLN', short: 'zł', valueToPln: 1),
  CurrencyOption(symbol: 'CHF', short: 'chf', valueToPln: 4.65),
  CurrencyOption(symbol: 'USD', short: 'usd', valueToPln: 3.9),
  CurrencyOption(symbol: 'EUR', short: 'eur', valueToPln: 4.2),
  CurrencyOption(symbol: 'GBP', short: 'gbp', valueToPln: 5.0),
  CurrencyOption(symbol: '1oz GOLD', short: 'uncja', valueToPln: 16500),
  CurrencyOption(symbol: '1oz SILVER', short: 'uncja', valueToPln: 322),
];
