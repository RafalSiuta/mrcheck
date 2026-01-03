import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/wallet_model/wallet.dart';
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
    await _databaseHelper.addWallet(wallet);
    _wallets = _databaseHelper.getAllWallets();
    notifyListeners();
  }

  Future<void> updateWallet(Wallet wallet) async {
    if (!_initialized) await init();
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
}
