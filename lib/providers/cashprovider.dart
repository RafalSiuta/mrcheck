import 'package:flutter/foundation.dart';

import '../models/cash_model/cash.dart';
import '../models/value_model/value_item.dart';
import 'settingsprovider.dart';

class CashProvider extends ChangeNotifier {
  CashProvider({required SettingsProvider settings})
      : _settings = settings;

  SettingsProvider _settings;
  final List<Cash> _cashList = [
    Cash(
      id: 1,
      name: 'zakupy market',
      value: 36.50,
      date: DateTime(2024, 8, 12),
      itemsList:  [
        ValueItem(
          id: 1,
          name: 'pieczywo',
          value: 12.5,
          date: DateTime(2024, 8, 12),
        ),
        ValueItem(
          id: 2,
          name: 'warzywa',
          value: 24.0,
          date: DateTime(2024, 8, 12),
        ),
      ],
    ),
    Cash(
      id: 2,
      name: 'pensja',
      value: 5200.00,
      date: DateTime(2024, 8, 10),
      isIncome: true,
      itemsList:  [
        ValueItem(
          id: 3,
          name: 'wypłata netto',
          value: 5200.00,
          date: DateTime(2024, 8, 10),
        ),
      ],
    ),
    Cash(
      id: 3,
      name: 'kino z rodziną',
      value: 180.75,
      date: DateTime(2024, 8, 5),
      itemsList:  [
        ValueItem(
          id: 4,
          name: 'bilety',
          value: 120.75,
          date: DateTime(2024, 8, 5),
        ),
        ValueItem(
          id: 5,
          name: 'popcorn',
          value: 60.0,
          date: DateTime(2024, 8, 5),
        ),
      ],
    ),
    Cash(
      id: 4,
      name: 'zwrot podatku',
      value: 850.00,
      date: DateTime(2024, 7, 30),
      isIncome: true,
      itemsList:  [
        ValueItem(
          id: 6,
          name: 'rozliczenie PIT',
          value: 850.00,
          date: DateTime(2024, 7, 30),
        ),
      ],
    ),
  ];

  List<Cash> get cashList => List.unmodifiable(_cashList);

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  void addCash(Cash cash) {
    _cashList.add(cash);
    notifyListeners();
  }

  void updateCash(Cash cash) {
    final index = _cashList.indexWhere((element) => element.id == cash.id);
    if (index != -1) {
      _cashList[index] = cash;
      notifyListeners();
    }
  }

  void removeCash(int id) {
    _cashList.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
