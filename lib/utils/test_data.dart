import 'package:flutter/material.dart';

import '../models/cash_model/cash.dart';
import '../models/value_model/value_item.dart';
import '../models/wallet_model/wallet.dart';
import '../utils/id_generator/id_generator.dart';

List<Cash> sampleCashData() {
  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);

  return [
    Cash(
      id: makeId(),
      name: 'poranna kawa',
      value: 18.50,
      date: normalizedToday,
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'flat white',
          value: 18.50,
          date: normalizedToday,
          category: 'kawa',
        ),
      ],
    ),
    Cash(
      id: makeId(),
      name: 'zakupy spożywcze',
      value: 62.30,
      date: normalizedToday,
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'owoce i pieczywo',
          value: 32.30,
          date: normalizedToday,
          category: 'spożywcze',
        ),
        ValueItem(
          id: makeId(),
          name: 'nabiał',
          value: 30.00,
          date: normalizedToday,
          category: 'spożywcze',
        ),
      ],
    ),
    Cash(
      id: makeId(),
      name: 'premia roczna',
      value: 1500.00,
      date: normalizedToday,
      isIncome: true,
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'premia uznaniowa',
          value: 1500.00,
          date: normalizedToday,
          category: 'przychód',
        ),
      ],
    ),
    Cash(
      id: makeId(),
      name: 'zakupy market',
      value: 36.50,
      date: DateTime(2025, 12, 12),
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'pieczywo',
          value: 12.5,
          date: DateTime(2025, 12, 12),
          category: 'spożywcze',
        ),
        ValueItem(
          id: makeId(),
          name: 'warzywa',
          value: 24.0,
          date: DateTime(2025, 12, 12),
          category: 'spożywcze',
        ),
      ],
    ),
    Cash(
      id: makeId(),
      name: 'pensja',
      value: 5200.00,
      date: DateTime(2025, 12, 10),
      isIncome: true,
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'wypłata netto',
          value: 5200.00,
          date: DateTime(2025, 12, 10),
          category: 'wynagrodzenie',
        ),
      ],
    ),
    Cash(
      id: makeId(),
      name: 'kino z rodziną',
      value: 1120.75,
      date: DateTime(2025, 12, 5),
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'bilety',
          value: 120.75,
          date: DateTime(2025, 12, 5),
          category: 'rozrywka',
        ),
        ValueItem(
          id: makeId(),
          name: 'popcorn',
          value: 60.0,
          date: DateTime(2025, 12, 5),
          category: 'przekąski',
        ),
      ],
    ),
    Cash(
      id: makeId(),
      name: 'zwrot podatku',
      value: 1250.00,
      date: DateTime(2025, 7, 30),
      isIncome: true,
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'rozliczenie PIT',
          value: 1250.00,
          date: DateTime(2025, 12, 30),
          category: 'podatek',
        ),
      ],
    ),
    Cash(
      id: makeId(),
      name: 'mandat',
      value: 100,
      date: DateTime(2025, 7, 30),
      isIncome: false,
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'mandat za prędkość',
          value: 100.00,
          date: DateTime(2025, 12, 30),
          category: 'mandaty',
        ),
      ],
    ),
  ];
}

List<Wallet> sampleWalletData() {
  return [
    Wallet(
      id: makeId(),
      title: 'świnka',
      value: 123.45,
      icon: Icons.account_balance_wallet.codePoint,
      date: DateTime(2024, 1, 15),
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'kieszonkowe',
          value: 10,
          date: DateTime(2024, 1, 15),
          category: 'kieszonkowe',
        ),
        ValueItem(
          id: makeId(),
          name: 'usługa',
          value: 20,
          date: DateTime(2024, 2, 2),
          category: 'usługi',
        ),
      ],
    ),
    Wallet(
      id: makeId(),
      title: 'akcje',
      value: 4567.89,
      icon: Icons.trending_up.codePoint,
      date: DateTime(2024, 2, 2),
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'kryptowaluty',
          value: 200,
          date: DateTime(2023, 11, 20),
          category: 'krypto',
        ),
        ValueItem(
          id: makeId(),
          name: 'ETF',
          value: 400,
          date: DateTime(2024, 3, 3),
          category: 'ETF',
        ),
      ],
    ),
    Wallet(
      id: makeId(),
      title: 'bank',
      value: 321.00,
      icon: Icons.account_balance.codePoint,
      date: DateTime(2024, 4, 28),
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'rachunek bieżący',
          value: 120,
          date: DateTime(2024, 4, 28),
          category: 'rachunek',
        ),
        ValueItem(
          id: makeId(),
          name: 'oszczędności',
          value: 201,
          date: DateTime(2024, 5, 12),
          category: 'oszczędności',
        ),
      ],
    ),
    Wallet(
      id: makeId(),
      title: 'waluty',
      value: 987.65,
      icon: Icons.attach_money.codePoint,
      date: DateTime(2024, 6, 8),
      itemsList: [
        ValueItem(
          id: makeId(),
          name: 'USD',
          value: 400,
          date: DateTime(2024, 6, 8),
          category: 'waluty',
        ),
        ValueItem(
          id: makeId(),
          name: 'EUR',
          value: 587.65,
          date: DateTime(2024, 7, 1),
          category: 'waluty',
        ),
      ],
    ),
  ];
}
