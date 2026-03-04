import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/cash_model/cash.dart';
import '../models/value_model/value_item.dart';
import '../models/wallet_model/wallet.dart';
import '../utils/calculations/currency_calculator.dart';
import '../utils/id_generator/id_generator.dart';
import 'settingsprovider.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider({required SettingsProvider settings}) : _settings = settings {
    init();
  }

  SettingsProvider _settings;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Wallet> _wallets = [];
  bool _initialized = false;

  List<Wallet> get wallets => List.unmodifiable(_wallets);

  Wallet? currentWallet({String? excludeWalletId}) {
    for (final wallet in _wallets) {
      final isExcluded = excludeWalletId != null && wallet.id == excludeWalletId;
      if (!isExcluded && wallet.isCurrentWallet) {
        return wallet;
      }
    }
    return null;
  }

  Future<void> init() async {
    await _databaseHelper.initializeHive();
    _wallets = _databaseHelper.getAllWallets();
    // _wallets = sampleWalletData(); // utils/test_data.dart - uncomment to preload fixtures.
    _initialized = true;
    notifyListeners();
  }

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  Wallet createEmptyWallet() {
    final newId = makeId();
    final currency = _wallets.isNotEmpty ? _wallets.first.currency : 'zł';

    return Wallet(
      id: newId,
      title: 'nowy portfel',
      value: 0,
      icon: Icons.account_balance_wallet.codePoint,
      color: Colors.white.value,
      currency: currency,
      itemsList: const [],
      date: DateTime.now(),
    );
  }

  Future<void> addWallet(Wallet wallet) async {
    if (!_initialized) await init();
    await _unsetOtherCurrentWallets(wallet);
    await _databaseHelper.addWallet(wallet);
    _wallets = _databaseHelper.getAllWallets();
    notifyListeners();
  }

  Future<void> updateWallet(Wallet wallet) async {
    if (!_initialized) await init();
    await _unsetOtherCurrentWallets(wallet);
    await _databaseHelper.updateWallet(wallet);
    _wallets = _databaseHelper.getAllWallets();
    notifyListeners();
  }

  Future<void> removeWallet(String id) async {
    if (!_initialized) await init();
    await _databaseHelper.deleteWallet(id);
    _wallets = _databaseHelper.getAllWallets();
    notifyListeners();
  }

  Future<bool> addAmountToCurrentWallet(
    double amount, {
    String? sourceCurrency,
  }) async {
    if (!_initialized) await init();
    final current = currentWallet();
    if (current == null) {
      return false;
    }

    final convertedAmount = _convertAmount(
      amount: amount,
      fromCurrency: sourceCurrency ?? current.currency,
      toCurrency: current.currency,
    );

    final updated = Wallet(
      id: current.id,
      title: current.title,
      value: current.value + convertedAmount,
      date: current.date,
      icon: current.icon,
      color: current.color,
      currency: current.currency,
      itemsList: current.itemsList,
      isCurrentWallet: true,
    );

    await _databaseHelper.updateWallet(updated);
    _wallets = _databaseHelper.getAllWallets();
    notifyListeners();
    return true;
  }

  Future<bool> syncCurrentWalletWithCash({
    required Cash cash,
    Cash? previousCash,
  }) async {
    if (!_initialized) await init();
    final current = currentWallet();
    if (current == null) {
      return false;
    }

    final items = List<ValueItem>.from(current.itemsList);
    final itemId = _cashWalletItemId(cash.id);
    items.removeWhere((item) => item.id == itemId);

    if (previousCash != null && previousCash.id != cash.id) {
      items.removeWhere((item) => item.id == _cashWalletItemId(previousCash.id));
    }

    final signedAmount = _signedCashAmount(cash);
    final convertedAmount = _convertAmount(
      amount: signedAmount,
      fromCurrency: cash.currency,
      toCurrency: current.currency,
    );

    items.add(
      ValueItem(
        id: itemId,
        date: cash.date,
        name: cash.name.trim().isEmpty
            ? (cash.isIncome ? 'Przychód' : 'Wydatek')
            : cash.name.trim(),
        value: convertedAmount,
        categories: const ['cash_sync'],
      ),
    );

    final updated = Wallet(
      id: current.id,
      title: current.title,
      value: current.value +
          convertedAmount -
          _previousCashAmountInWalletCurrency(previousCash, current.currency),
      date: current.date,
      icon: current.icon,
      color: current.color,
      currency: current.currency,
      itemsList: items,
      isCurrentWallet: true,
    );

    await _databaseHelper.updateWallet(updated);
    _wallets = _databaseHelper.getAllWallets();
    notifyListeners();
    return true;
  }

  Future<bool> removeCashFromCurrentWallet(Cash cash) async {
    if (!_initialized) await init();
    final current = currentWallet();
    if (current == null) {
      return false;
    }

    final itemId = _cashWalletItemId(cash.id);
    final items = List<ValueItem>.from(current.itemsList)
      ..removeWhere((item) => item.id == itemId);
    final signedAmount = _signedCashAmount(cash);
    final convertedAmount = _convertAmount(
      amount: signedAmount,
      fromCurrency: cash.currency,
      toCurrency: current.currency,
    );

    final updated = Wallet(
      id: current.id,
      title: current.title,
      value: current.value - convertedAmount,
      date: current.date,
      icon: current.icon,
      color: current.color,
      currency: current.currency,
      itemsList: items,
      isCurrentWallet: true,
    );

    await _databaseHelper.updateWallet(updated);
    _wallets = _databaseHelper.getAllWallets();
    notifyListeners();
    return true;
  }

  Future<void> _unsetOtherCurrentWallets(Wallet wallet) async {
    if (!wallet.isCurrentWallet) {
      return;
    }

    final walletsToUpdate = _wallets.where(
      (item) => item.id != wallet.id && item.isCurrentWallet,
    );

    for (final item in walletsToUpdate) {
      final updated = Wallet(
        id: item.id,
        title: item.title,
        value: item.value,
        date: item.date,
        icon: item.icon,
        color: item.color,
        currency: item.currency,
        itemsList: item.itemsList,
        isCurrentWallet: false,
      );
      await _databaseHelper.updateWallet(updated);
    }
  }

  String _cashWalletItemId(String cashId) => 'cash:$cashId';

  double _signedCashAmount(Cash cash) {
    final total = cash.itemsList.fold<double>(0, (sum, item) => sum + item.value);
    return cash.isIncome ? total : -total;
  }

  double _previousCashAmountInWalletCurrency(Cash? cash, String targetCurrency) {
    if (cash == null) return 0;
    return _convertAmount(
      amount: _signedCashAmount(cash),
      fromCurrency: cash.currency,
      toCurrency: targetCurrency,
    );
  }

  double _convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency.toLowerCase() == toCurrency.toLowerCase()) {
      return amount;
    }

    final amountInGlobal = toGlobalCurrency(
      amount: amount,
      rateToPln: _settings.rateFor(fromCurrency),
    );
    final targetRate = _settings.rateFor(toCurrency);
    if (targetRate == 0) return amountInGlobal;
    return amountInGlobal / targetRate;
  }
}
