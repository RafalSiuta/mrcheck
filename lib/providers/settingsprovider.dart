import 'package:flutter/foundation.dart';
import 'package:mrcash/models/currency_model/currency.dart';
import 'package:mrcash/utils/constans/currencies.dart';
import 'package:mrcash/utils/prefs/prefs.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _init();
  }

  static const String _lockWalletKey = 'lockwalletData';

  final PrefsHelper _prefs = const PrefsHelper();
  List<CurrencyOption> _currencies =
      List<CurrencyOption>.from(defaultCurrencies);
  bool _lockWallet = false;

  List<CurrencyOption> get currencies =>
      List<CurrencyOption>.unmodifiable(_currencies);
  bool get lockWallet => _lockWallet;

  Future<void> _init() async {
    _lockWallet = await _prefs.readBool(_lockWalletKey) ?? false;
    _currencies = await _readCurrenciesFromPrefs();
    notifyListeners();
  }

  Future<void> lockData([bool? value]) async {
    _lockWallet = value ?? !_lockWallet;
    await _prefs.saveBool(key: _lockWalletKey, value: _lockWallet);
    notifyListeners();
  }

  double rateFor(String currencyShort) {
    final match = _currencies.firstWhere(
      (option) => option.short.toLowerCase() == currencyShort.toLowerCase(),
      orElse: () =>
          const CurrencyOption(symbol: 'PLN', short: 'zł', valueToPln: 1),
    );
    return match.valueToPln;
  }

  void setCurrencies(List<CurrencyOption> currencies) {
    _currencies = List<CurrencyOption>.from(currencies);
    notifyListeners();
  }

  Future<void> updateCurrencyAt(int index, CurrencyOption option) async {
    if (index < 0 || index >= _currencies.length) return;
    _currencies[index] = option;
    await _prefs.saveDouble(
      key: option.symbol,
      values: <double>[option.valueToPln],
    );
    notifyListeners();
  }

  Future<void> updateCurrencyValue(String symbol, double valueToPln) async {
    final index =
        _currencies.indexWhere((currency) => currency.symbol == symbol);
    if (index == -1) return;

    _currencies[index] = _currencies[index].copyWith(valueToPln: valueToPln);
    await _prefs.saveDouble(
      key: symbol,
      values: <double>[valueToPln],
    );
    notifyListeners();
  }

  Future<List<CurrencyOption>> _readCurrenciesFromPrefs() async {
    final List<CurrencyOption> list = [];
    for (final currency in defaultCurrencies) {
      final values = await _prefs.readDouble(
        key: currency.symbol,
        fallback: <double>[currency.valueToPln],
      );
      list.add(currency.copyWith(valueToPln: values.first));
    }
    return list;
  }
}
