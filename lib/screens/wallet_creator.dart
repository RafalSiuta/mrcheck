import 'package:flutter/material.dart';
import 'package:mrcash/models/wallet_model/wallet.dart';
import 'package:mrcash/models/value_model/value_item.dart';
import 'package:provider/provider.dart';

import '../models/color_model/color_option.dart';
import '../models/currency_model/currency.dart';
import '../models/icon_model/icon_option.dart';
import '../models/nav_model/creator_nav_item.dart';
import '../providers/walletprovider.dart';
import '../providers/settingsprovider.dart';
import '../utils/calculations/currency_calculator.dart';
import '../utils/id_generator/id_generator.dart';
import '../widgets/cards/cash_card.dart';
import '../widgets/dialogs/color_dialog.dart';
import '../widgets/dialogs/icon_dialog.dart';
import '../widgets/dialogs/inputdialog.dart';
import '../widgets/dialogs/wallet_sets_dialog.dart';
import '../widgets/menu_nav/creator_nav.dart';

class _PendingWalletTransfer {
  const _PendingWalletTransfer({
    required this.destinationWalletId,
    required this.destinationItem,
  });

  final String destinationWalletId;
  final ValueItem destinationItem;
}

class _TransferDialogResult {
  const _TransferDialogResult({
    required this.name,
    required this.amount,
    required this.destinationWalletId,
  });

  final String name;
  final double amount;
  final String destinationWalletId;
}

class _TransferDialog extends StatefulWidget {
  const _TransferDialog({
    required this.wallets,
    required this.currency,
  });

  final List<Wallet> wallets;
  final String currency;

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late String _selectedWalletId;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'przelew własny');
    _amountController = TextEditingController();
    _selectedWalletId = widget.wallets.first.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );

    if (name.isEmpty || amount == null || amount <= 0) {
      setState(() {
        _errorText = 'Podaj poprawną nazwę i kwotę';
      });
      return;
    }

    Navigator.of(context).pop(
      _TransferDialogResult(
        name: name,
        amount: amount,
        destinationWalletId: _selectedWalletId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Przelew'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nazwa przelewu',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Kwota',
              suffixText: widget.currency,
              errorText: _errorText,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.wallets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final wallet = widget.wallets[index];
                final isSelected = wallet.id == _selectedWalletId;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedWalletId = wallet.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 64,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          IconData(
                            wallet.icon,
                            fontFamily: 'MaterialIcons',
                          ),
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          wallet.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Potwierdź'),
        ),
      ],
    );
  }
}

class WalletCreator extends StatefulWidget {
  const WalletCreator({
    required this.wallet,
    this.editEnable = false,
    super.key,
  });

  final Wallet wallet;
  final bool editEnable;

  @override
  State<WalletCreator> createState() => _WalletCreatorState();
}

class _WalletCreatorState extends State<WalletCreator> {
  late final TextEditingController _titleController;
  final FocusNode _titleFocus = FocusNode();
  late List<ValueItem> _items;
  int? _editingIndex;
  late String _selectedCurrency;
  late DateTime _walletDate;
  late int _selectedColorValue;
  late int _selectedIconCode;
  late bool _isCurrentWallet;
  final List<_PendingWalletTransfer> _pendingTransfers = [];
  Color get _selectedColor => Color(_selectedColorValue);
  static const List<CurrencyOption> _currencyOptions = [
    CurrencyOption(symbol: 'PLN', short: 'zł', valueToPln: 1),
    CurrencyOption(symbol: 'CHF', short: 'chf', valueToPln: 4.65),
    CurrencyOption(symbol: 'USD', short: 'usd', valueToPln: 3.9),
    CurrencyOption(symbol: 'EUR', short: 'eur', valueToPln: 4.2),
    CurrencyOption(symbol: 'GBP', short: 'gbp', valueToPln: 5.0),
    CurrencyOption(symbol: '1oz GOLD', short: 'uncja', valueToPln: 15000),
    CurrencyOption(symbol: '1oz SILVER', short: 'uncja', valueToPln: 322),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.wallet.title);
    _items = List.of(widget.wallet.itemsList);
    _selectedCurrency = widget.wallet.currency;
    _walletDate = widget.wallet.date;
    _selectedColorValue =
        widget.wallet.color == 0 ? Colors.white.value : widget.wallet.color;
    _selectedIconCode = widget.wallet.icon == 0
        ? Icons.account_balance_wallet.codePoint
        : widget.wallet.icon;
    _isCurrentWallet = widget.wallet.isCurrentWallet;

    if (widget.editEnable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureFocus(_titleFocus);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _ensureFocus(FocusNode node) {
    if (!node.hasFocus) {
      node.requestFocus();
    }
  }

  double get _itemsTotal =>
      _items.fold<double>(0, (sum, item) => sum + item.value);

  Future<void> _saveWallet() async {
    final provider = context.read<WalletProvider>();
    final walletId = widget.wallet.id.isNotEmpty ? widget.wallet.id : makeId();
    final updatedWallet = Wallet(
      id: walletId,
      title: _titleController.text.trim(),
      value: _itemsTotal,
      icon: _selectedIconCode,
      currency: _selectedCurrency,
      color: _selectedColorValue,
      date: _walletDate,
      itemsList: _items,
      isCurrentWallet: _isCurrentWallet,
    );
    if (provider.wallets.any((w) => w.id == walletId)) {
      await provider.updateWallet(updatedWallet);
    } else {
      await provider.addWallet(updatedWallet);
    }

    await _applyPendingTransfers(provider);
    _pendingTransfers.clear();

    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  Future<void> _applyPendingTransfers(WalletProvider walletProvider) async {
    for (final transfer in _pendingTransfers) {
      final index = walletProvider.wallets.indexWhere(
        (wallet) => wallet.id == transfer.destinationWalletId,
      );
      if (index == -1) {
        continue;
      }

      final wallet = walletProvider.wallets[index];
      final updatedItems = List<ValueItem>.from(wallet.itemsList)
        ..add(transfer.destinationItem);
      final updatedWallet = Wallet(
        id: wallet.id,
        title: wallet.title,
        value: wallet.value + transfer.destinationItem.value,
        icon: wallet.icon,
        currency: wallet.currency,
        color: wallet.color,
        date: wallet.date,
        itemsList: updatedItems,
        isCurrentWallet: wallet.isCurrentWallet,
      );
      await walletProvider.updateWallet(updatedWallet);
    }
  }

  double _convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency.toLowerCase() == toCurrency.toLowerCase()) {
      return amount;
    }

    final settingsProvider = context.read<SettingsProvider>();
    final amountInGlobal = toGlobalCurrency(
      amount: amount,
      rateToPln: settingsProvider.rateFor(fromCurrency),
    );
    final targetRate = settingsProvider.rateFor(toCurrency);
    if (targetRate == 0) {
      return amountInGlobal;
    }
    return amountInGlobal / targetRate;
  }

  Future<void> _showTransferDialog(WalletProvider walletProvider) async {
    final wallets = walletProvider.wallets
        .where((wallet) => wallet.id != widget.wallet.id)
        .toList();

    if (wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak dostępnych portfeli do przelewu')),
      );
      return;
    }

    final result = await showDialog<_TransferDialogResult>(
      context: context,
      builder: (_) => _TransferDialog(
        wallets: wallets,
        currency: _selectedCurrency,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final destinationWallet = walletProvider.wallets.firstWhere(
      (wallet) => wallet.id == result.destinationWalletId,
    );
    final destinationAmount = _convertAmount(
      amount: result.amount,
      fromCurrency: _selectedCurrency,
      toCurrency: destinationWallet.currency,
    );
    final now = DateTime.now();

    setState(() {
      _items.add(
        ValueItem(
          id: makeId(),
          name: result.name,
          value: -result.amount,
          date: now,
          categories: const ['transfer_out'],
          isIncome: false,
        ),
      );
      _pendingTransfers.add(
        _PendingWalletTransfer(
          destinationWalletId: destinationWallet.id,
          destinationItem: ValueItem(
            id: makeId(),
            name: result.name,
            value: destinationAmount,
            date: now,
            categories: const ['transfer_in'],
            isIncome: true,
          ),
        ),
      );
    });
  }

  Future<void> _showItemDialog({ValueItem? item, int? index}) async {
    if (index != null) {
      setState(() {
        _editingIndex = index;
      });
    }
    final isEdit = item != null && index != null;
    final result = await showDialog<InputDialogResult>(
      context: context,
      builder: (_) => InputDialog(
        title: isEdit ? 'Edytuj pozycję' : 'Dodaj pozycję',
        currency: _selectedCurrency,
        initialName: item?.name ?? '',
        initialValue: item != null ? item.value.abs().toStringAsFixed(2) : '',
        initialCategories: item?.categories ?? const [],
        initialIsIncome:
            item?.isIncome ?? (item != null ? item.value >= 0 : true),
        showCategories: false,
        showIncomeOption: true,
        confirmLabel: isEdit ? 'Zapisz' : 'Dodaj',
      ),
    );

    if (!mounted) return;
    if (result == null) {
      setState(() {
        _editingIndex = null;
      });
      return;
    }

    setState(() {
      final signedValue =
          result.isIncome ? result.value.abs() : -result.value.abs();
      if (isEdit) {
        final editIndex = index;
        final existing = _items[editIndex];
        _items[editIndex] = ValueItem(
          id: existing.id,
          name: result.name,
          value: signedValue,
          date: existing.date,
          categories: result.categories,
          isIncome: result.isIncome,
        );
      } else {
        final now = DateTime.now();
        _items.add(
          ValueItem(
            id: makeId(),
            name: result.name,
            value: signedValue,
            date: now,
            categories: result.categories,
            isIncome: result.isIncome,
          ),
        );
      }
      _editingIndex = null;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_editingIndex != null) {
        if (_editingIndex == index) {
          _editingIndex = null;
        } else if (_editingIndex! > index) {
          _editingIndex = _editingIndex! - 1;
        }
      }
    });
  }

  Future<void> _pickColor() async {
    final initialId = ColorDialog.options
        .firstWhere(
          (option) => option.color.value == _selectedColorValue,
          orElse: () => const ColorOption(id: 0, color: Colors.white),
        )
        .id;

    final selected = await showDialog<ColorOption>(
      context: context,
      builder: (_) => ColorDialog(initialId: initialId),
    );

    if (selected != null) {
      setState(() {
        _selectedColorValue = selected.color.value;
      });
    }
  }

  Future<void> _pickIcon() async {
    final initialId = IconDialog.options
        .firstWhere(
          (option) => option.iconData.codePoint == _selectedIconCode,
          orElse: () => IconDialog.options.first,
        )
        .id;

    final selected = await showDialog<IconOption>(
      context: context,
      builder: (_) => IconDialog(initialId: initialId),
    );

    if (selected != null) {
      setState(() {
        _selectedIconCode = selected.iconData.codePoint;
      });
    }
  }

  Future<void> _pickCurrency() async {
    final selected = await showDialog<CurrencyOption>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Wybierz walutę'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencyOptions
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedCurrency == option.short
                          ? Colors.grey.shade200
                          : null,
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: () => Navigator.of(context).pop(option),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option.symbol),
                        Text(option.short),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (selected != null) {
      if (_isCurrentWallet &&
          selected.short.toLowerCase() != globalCurrency.toLowerCase()) {
        if (!mounted) return;
        final settingsProvider = context.read<SettingsProvider>();
        final fromCurrency = _selectedCurrency;
        final shouldConvert = await _confirmConvertToGlobalCurrency(
          fromCurrencyShort: fromCurrency,
        );
        if (!mounted) return;
        if (!shouldConvert) return;

        setState(() {
          _convertDraftWalletCurrencyToGlobal(settingsProvider, fromCurrency);
        });
        return;
      }

      setState(() {
        _selectedCurrency = selected.short;
      });
    }
  }

  Future<void> _confirmDeleteCash() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usunąć zapis?'),
        content: const Text(
          'To usunie ten zapis i wszystkie pozycje listy. Kontynuować?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (shouldDelete == true) {
      if (widget.wallet.id.isNotEmpty) {
        await context.read<WalletProvider>().removeWallet(widget.wallet.id);
      }
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<bool> _confirmSwitchCurrentWallet(Wallet currentWallet) async {
    final newWalletName = _titleController.text.trim().isEmpty
        ? 'nowy portfel'
        : _titleController.text.trim();
    final currentWalletAmount =
        '${currentWallet.value.toStringAsFixed(2)} ${currentWallet.currency}';

    final shouldSwitch = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Zmienić bieżący portfel?'),
        content: Text(
          'Bieżący portfel to "${currentWallet.title}" '
          '($currentWalletAmount).\n\n'
          'Czy chcesz ustawić "$newWalletName" jako bieżący portfel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Zmień'),
          ),
        ],
      ),
    );

    return shouldSwitch ?? false;
  }

  Future<bool> _confirmConvertToGlobalCurrency({
    required String fromCurrencyShort,
  }) async {
    final fromSymbol = _currencySymbol(fromCurrencyShort);
    final globalSymbol = _currencySymbol(globalCurrency);
    final shouldConvert = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Zmiana waluty bieżącego portfela'),
        content: Text(
          'Bieżący portfel musi mieć walutę globalną '
          '($globalSymbol / $globalCurrency).\n\n'
          'Obecna waluta: $fromSymbol / $fromCurrencyShort.\n'
          'Czy przeliczyć dane portfela na walutę globalną?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Nie'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Tak'),
          ),
        ],
      ),
    );

    return shouldConvert ?? false;
  }

  String _currencySymbol(String shortCurrency) {
    final match = _currencyOptions.where(
      (option) => option.short.toLowerCase() == shortCurrency.toLowerCase(),
    );
    if (match.isNotEmpty) {
      return match.first.symbol;
    }
    return shortCurrency.toUpperCase();
  }

  void _convertDraftWalletCurrencyToGlobal(
    SettingsProvider settingsProvider,
    String fromCurrency,
  ) {
    if (fromCurrency.toLowerCase() == globalCurrency.toLowerCase()) {
      _selectedCurrency = globalCurrency;
      return;
    }

    final sourceRate = settingsProvider.rateFor(fromCurrency);
    _items = _items
        .map(
          (item) => ValueItem(
            id: item.id,
            name: item.name,
            value: toGlobalCurrency(
              amount: item.value,
              rateToPln: sourceRate,
            ),
            date: item.date,
            categories: item.categories,
            isIncome: item.isIncome,
          ),
        )
        .toList();
    _selectedCurrency = globalCurrency;
  }

  Future<void> _showSetsDialog(WalletProvider walletProvider) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var dialogValue = _isCurrentWallet;
        return StatefulBuilder(
          builder: (context, setDialogState) => WalletSetsDialog(
            value: dialogValue,
            onChanged: (nextValue) async {
              if (!nextValue) {
                setState(() {
                  _isCurrentWallet = false;
                });
                setDialogState(() {
                  dialogValue = false;
                });
                return;
              }

              if (_selectedCurrency.toLowerCase() !=
                  globalCurrency.toLowerCase()) {
                final settingsProvider = context.read<SettingsProvider>();
                final fromCurrency = _selectedCurrency;
                final shouldConvert = await _confirmConvertToGlobalCurrency(
                  fromCurrencyShort: fromCurrency,
                );
                if (!mounted) return;
                if (!shouldConvert) {
                  setDialogState(() {
                    dialogValue = false;
                  });
                  return;
                }

                setState(() {
                  _convertDraftWalletCurrencyToGlobal(
                    settingsProvider,
                    fromCurrency,
                  );
                });
              }

              final currentWallet = walletProvider.currentWallet(
                  excludeWalletId: widget.wallet.id);
              if (currentWallet == null) {
                setState(() {
                  _isCurrentWallet = true;
                });
                setDialogState(() {
                  dialogValue = true;
                });
                return;
              }

              final confirmed =
                  await _confirmSwitchCurrentWallet(currentWallet);
              if (!mounted) return;

              if (confirmed) {
                setState(() {
                  _isCurrentWallet = true;
                });
                setDialogState(() {
                  dialogValue = true;
                });
              } else {
                setDialogState(() {
                  dialogValue = false;
                });
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconData = IconData(_selectedIconCode, fontFamily: 'MaterialIcons');
    final currency = _selectedCurrency;
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _selectedColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: horizontalPadding,
                        child: TextField(
                          controller: _titleController,
                          focusNode: _titleFocus,
                          style: Theme.of(context).textTheme.headlineLarge,
                          textInputAction: TextInputAction.next,
                          onTap: () => _ensureFocus(_titleFocus),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            hintText: 'Tytuł portfela',
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F0F0F),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                iconSize: 24,
                                icon: Icon(
                                  iconData,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                                onPressed: () => _pickIcon(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: horizontalPadding,
                        child: Text(
                          'Suma: ${_itemsTotal.toStringAsFixed(2)} $currency',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: horizontalPadding,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              side: const BorderSide(color: Colors.black54),
                              foregroundColor: Colors.black87,
                            ),
                            onPressed: _showItemDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Dodaj pozycję'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Padding(
                          padding: horizontalPadding,
                          child: ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Colors.grey,
                            ),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              final isIncome =
                                  item.value == 0 ? null : item.isIncome;
                              return CashCard(
                                name: item.name,
                                value: item.value,
                                date: item.date,
                                currency: currency,
                                showDate: true,
                                isIncome: isIncome,
                                isEditing: _editingIndex == index,
                                onEdit: () =>
                                    _showItemDialog(item: item, index: index),
                                onDelete: () => _removeItem(index),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Consumer<WalletProvider>(
                builder: (context, walletProvider, _) {
                  return CreatorNav(
                    items: const [
                      CreatorNavItem(title: 'zapisz', icon: Icons.save),
                      CreatorNavItem(title: 'sets', icon: Icons.settings),
                      CreatorNavItem(title: 'dodaj', icon: Icons.add),
                      CreatorNavItem(
                        title: 'przelew',
                        icon: Icons.currency_exchange,
                      ),
                      CreatorNavItem(title: 'waluta', icon: Icons.attach_money),
                      CreatorNavItem(
                          title: 'symbol', icon: Icons.account_balance_wallet),
                      CreatorNavItem(title: 'kolor', icon: Icons.color_lens),
                      CreatorNavItem(title: 'usuń', icon: Icons.delete),
                      CreatorNavItem(
                          title: 'cofnij', icon: Icons.arrow_back_ios_new),
                    ],
                    selectedIndex: -1,
                    navIconSize: 24,
                    onTap: (index) {
                      switch (index) {
                        case 0:
                          _saveWallet();
                          break;
                        case 1:
                          _showSetsDialog(walletProvider);
                          break;
                        case 2:
                          _showItemDialog();
                          break;
                        case 3:
                          _showTransferDialog(walletProvider);
                          break;
                        case 4:
                          _pickCurrency();
                          break;
                        case 5:
                          _pickIcon();
                          break;
                        case 6:
                          _pickColor();
                          break;
                        case 7:
                          _confirmDeleteCash();
                          break;
                        case 8:
                          Navigator.pop(context);
                          break;
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
