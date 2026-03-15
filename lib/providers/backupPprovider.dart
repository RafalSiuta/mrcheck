// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/cash_model/cash.dart';
import '../models/value_model/value_item.dart';
import '../models/wallet_model/wallet.dart';
import 'cashprovider.dart';
import 'walletprovider.dart';

class BackupProvider extends ChangeNotifier {
  BackupProvider({
    CashProvider? cashProvider,
    WalletProvider? walletProvider,
  }) {
    updateProviders(
      cashProvider: cashProvider,
      walletProvider: walletProvider,
    );
  }

  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  CashProvider? _cashProvider;
  WalletProvider? _walletProvider;
  VoidCallback? _cashListener;
  VoidCallback? _walletListener;
  bool _isSyncing = false;
  bool _hasPendingSync = false;

  List<Cash> get cashList => _cashProvider?.cashList ?? const <Cash>[];
  List<Wallet> get wallets => _walletProvider?.wallets ?? const <Wallet>[];

  void updateProviders({
    CashProvider? cashProvider,
    WalletProvider? walletProvider,
  }) {
    final didCashChange = !identical(_cashProvider, cashProvider);
    final didWalletChange = !identical(_walletProvider, walletProvider);

    if (!didCashChange && !didWalletChange) {
      return;
    }

    if (_cashProvider != null && _cashListener != null) {
      _cashProvider!.removeListener(_cashListener!);
    }
    if (_walletProvider != null && _walletListener != null) {
      _walletProvider!.removeListener(_walletListener!);
    }

    _cashProvider = cashProvider;
    _walletProvider = walletProvider;

    _cashListener = _handleSourceChanged;
    _walletListener = _handleSourceChanged;

    _cashProvider?.addListener(_cashListener!);
    _walletProvider?.addListener(_walletListener!);

    unawaited(syncBackup());
  }

  Future<void> syncBackup() async {
    if (_isSyncing) {
      _hasPendingSync = true;
      return;
    }

    _isSyncing = true;
    _isSyncing = false;

    if (_hasPendingSync) {
      _hasPendingSync = false;
      await syncBackup();
      return;
    }

    notifyListeners();
  }

  Future<void> rebuildBackupFromCurrentData() async {
    await syncBackup();
  }

  void _handleSourceChanged() {
    unawaited(syncBackup());
  }

  Future<List<File>> buildBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDirectory = Directory('${directory.path}/backup');
    if (!await backupDirectory.exists()) {
      await backupDirectory.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final cashFile = File('${backupDirectory.path}/cash_$timestamp.json');
    final walletFile = File('${backupDirectory.path}/wallet_$timestamp.json');

    await cashFile.writeAsString(
      _encoder.convert(cashList.map(_cashToJson).toList(growable: false)),
    );
    await walletFile.writeAsString(
      _encoder.convert(wallets.map(_walletToJson).toList(growable: false)),
    );

    return <File>[cashFile, walletFile];
  }

  Future<List<String>> exportBackupFiles() async {
    final files = await buildBackupFiles();
    final xFiles = files
        .map((file) => XFile(file.path, mimeType: 'application/json'))
        .toList();

    await Share.shareXFiles(
      xFiles,
      text: 'MrCash backup JSON',
      subject: 'MrCash backup',
    );

    return files.map((file) => file.path).toList(growable: false);
  }

  Map<String, dynamic> _cashToJson(Cash cash) {
    return <String, dynamic>{
      'id': cash.id,
      'date': cash.date.toIso8601String(),
      'name': cash.name,
      'value': cash.value,
      'currency': cash.currency,
      'isIncome': cash.isIncome,
      'itemsList': cash.itemsList.map(_valueItemToJson).toList(growable: false),
    };
  }

  Map<String, dynamic> _walletToJson(Wallet wallet) {
    return <String, dynamic>{
      'id': wallet.id,
      'title': wallet.title,
      'value': wallet.value,
      'date': wallet.date.toIso8601String(),
      'icon': wallet.icon,
      'color': wallet.color,
      'currency': wallet.currency,
      'isCurrentWallet': wallet.isCurrentWallet,
      'itemsList':
          wallet.itemsList.map(_valueItemToJson).toList(growable: false),
    };
  }

  Map<String, dynamic> _valueItemToJson(ValueItem item) {
    return <String, dynamic>{
      'id': item.id,
      'date': item.date.toIso8601String(),
      'name': item.name,
      'value': item.value,
      'categories': item.categories,
      'isIncome': item.isIncome,
    };
  }

  @override
  void dispose() {
    if (_cashProvider != null && _cashListener != null) {
      _cashProvider!.removeListener(_cashListener!);
    }
    if (_walletProvider != null && _walletListener != null) {
      _walletProvider!.removeListener(_walletListener!);
    }
    super.dispose();
  }
}
