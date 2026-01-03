import 'package:hive_flutter/hive_flutter.dart';

import '../models/cash_model/cash.dart';
import '../models/value_model/value_item.dart';
import '../models/wallet_model/wallet.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Box<Cash>? _cashBox;
  Box<Wallet>? _walletBox;
  bool _initialized = false;

  Future<void> initializeHive() async {
    if (!_initialized) {
      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(ValueItemAdapter().typeId)) {
        Hive.registerAdapter(ValueItemAdapter());
      }
      if (!Hive.isAdapterRegistered(CashAdapter().typeId)) {
        Hive.registerAdapter(CashAdapter());
      }
      if (!Hive.isAdapterRegistered(WalletAdapter().typeId)) {
        Hive.registerAdapter(WalletAdapter());
      }
      _initialized = true;
    }

    _cashBox ??= await _openTypedBox<Cash>('cashBox');
    _walletBox ??= await _openTypedBox<Wallet>('walletBox');
  }

  Future<Box<T>> _openTypedBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return Hive.openBox<T>(name);
  }

  List<Cash> getAllCash() => _cashBox?.values.toList() ?? [];

  Future<void> addCash(Cash cash) async {
    await _cashBox?.put(cash.id, cash);
  }

  Future<void> updateCash(Cash cash) async {
    await _cashBox?.put(cash.id, cash);
  }

  Future<void> deleteCash(String id) async {
    await _cashBox?.delete(id);
  }

  List<Wallet> getAllWallets() => _walletBox?.values.toList() ?? [];

  Future<void> addWallet(Wallet wallet) async {
    await _walletBox?.put(wallet.id, wallet);
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _walletBox?.put(wallet.id, wallet);
  }

  Future<void> deleteWallet(String id) async {
    await _walletBox?.delete(id);
  }

  Future<void> closeHive() async {
    await Hive.close();
  }
}
