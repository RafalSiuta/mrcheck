import 'package:flutter/foundation.dart';

import '../models/value_model/value_item.dart';
import '../models/wallet_model/wallet.dart';
import 'settingsprovider.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider({required SettingsProvider settings})
      : _settings = settings;

  SettingsProvider _settings;
  final List<Wallet> _wallets = [
    Wallet(
      id: 1,
      title: 'świnka',
      value: 123.45,
      icon: 1,
      itemsList:  [
        ValueItem(
          id: 1,
          name: 'kieszonkowe',
          value: 10,
          date: DateTime(2024, 1, 15),
        ),
        ValueItem(
          id: 2,
          name: 'usługa',
          value: 20,
          date: DateTime(2024, 2, 2),
        ),
      ],
    ),
    Wallet(
      id: 2,
      title: 'akcje',
      value: 4567.89,
      icon: 1,
      itemsList:  [
        ValueItem(
          id: 3,
          name: 'kryptowaluty',
          value: 200,
          date: DateTime(2023, 11, 20),
        ),
        ValueItem(
          id: 4,
          name: 'ETF',
          value: 400,
          date: DateTime(2024, 3, 3),
        ),
      ],
    ),
    Wallet(
      id: 3,
      title: 'bank',
      value: 321.00,
      icon: 1,
      itemsList:  [
        ValueItem(
          id: 5,
          name: 'rachunek bieżący',
          value: 120,
          date: DateTime(2024, 4, 28),
        ),
        ValueItem(
          id: 6,
          name: 'oszczędności',
          value: 201,
          date: DateTime(2024, 5, 12),
        ),
      ],
    ),
    Wallet(
      id: 4,
      title: 'waluty',
      value: 987.65,
      icon: 1,
      itemsList:  [
        ValueItem(
          id: 7,
          name: 'USD',
          value: 400,
          date: DateTime(2024, 6, 8),
        ),
        ValueItem(
          id: 8,
          name: 'EUR',
          value: 587.65,
          date: DateTime(2024, 7, 1),
        ),
      ],
    ),
  ];

  List<Wallet> get wallets => List.unmodifiable(_wallets);

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  void addWallet(Wallet wallet) {
    _wallets.add(wallet);
    notifyListeners();
  }

  void updateWallet(Wallet wallet) {
    final index = _wallets.indexWhere((element) => element.id == wallet.id);
    if (index != -1) {
      _wallets[index] = wallet;
      notifyListeners();
    }
  }

  void removeWallet(int id) {
    _wallets.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
