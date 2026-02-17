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
  List<CurrencyOption> _currencies = List<CurrencyOption>.from(defaultCurrencies);
  bool _lockWallet = false;

  List<CurrencyOption> get currencies => List<CurrencyOption>.unmodifiable(_currencies);
  bool get lockWallet => _lockWallet;

  Future<void> _init() async {
    _lockWallet = await _prefs.readBool(_lockWalletKey) ?? false;
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
      orElse: () => const CurrencyOption(symbol: 'PLN', short: 'zł', valueToPln: 1),
    );
    return match.valueToPln;
  }

  void setCurrencies(List<CurrencyOption> currencies) {
    _currencies = List<CurrencyOption>.from(currencies);
    notifyListeners();
  }

  void updateCurrencyAt(int index, CurrencyOption option) {
    if (index < 0 || index >= _currencies.length) return;
    _currencies[index] = option;
    notifyListeners();
  }
}
