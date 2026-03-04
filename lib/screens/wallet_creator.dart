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
import '../widgets/dialogs/inutdialog.dart';
import '../widgets/dialogs/wallet_sets_dialog.dart';
import '../widgets/menu_nav/creator_nav.dart';

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

  void _saveWallet() {
    final provider = context.read<WalletProvider>();
    final walletId =
        widget.wallet.id.isNotEmpty ? widget.wallet.id : makeId();
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
      provider.updateWallet(updatedWallet);
    } else {
      provider.addWallet(updatedWallet);
    }
    Navigator.pop(context);
  }

  Future<void> _showItemDialog({ValueItem? item, int? index}) async {
    if (index != null) {
      setState(() {
        _editingIndex = index;
      });
    }
    final isEdit = item != null && index != null;
    final result = await showDialog<InutDialogResult>(
      context: context,
      builder: (_) => InutDialog(
        title: isEdit ? 'Edytuj pozycję' : 'Dodaj pozycję',
        currency: _selectedCurrency,
        initialName: item?.name ?? '',
        initialValue: item != null ? item.value.toStringAsFixed(2) : '',
        initialCategories: item?.categories ?? const [],
        showCategories: false,
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
      if (isEdit) {
        final editIndex = index;
        final existing = _items[editIndex];
        _items[editIndex] = ValueItem(
          id: existing.id,
          name: result.name,
          value: result.value,
          date: existing.date,
          categories: result.categories,
        );
      } else {
        final now = DateTime.now();
        _items.add(
          ValueItem(
            id: makeId(),
            name: result.name,
            value: result.value,
            date: now,
            categories: result.categories,
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
                      backgroundColor:
                          _selectedCurrency == option.short ? Colors.grey.shade200 : null,
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
      (option) =>
          option.short.toLowerCase() == shortCurrency.toLowerCase(),
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

              final currentWallet =
                  walletProvider.currentWallet(excludeWalletId: widget.wallet.id);
              if (currentWallet == null) {
                setState(() {
                  _isCurrentWallet = true;
                });
                setDialogState(() {
                  dialogValue = true;
                });
                return;
              }

              final confirmed = await _confirmSwitchCurrentWallet(currentWallet);
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
    final iconData =
        IconData(_selectedIconCode, fontFamily: 'MaterialIcons');
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
                              final isIncome = item.value == 0
                                  ? null
                                  : item.value > 0;
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
                      CreatorNavItem(title: 'waluta', icon: Icons.attach_money),
                      CreatorNavItem(title: 'symbol', icon: Icons.account_balance_wallet),
                      CreatorNavItem(title: 'kolor', icon: Icons.color_lens),
                      CreatorNavItem(title: 'usuń', icon: Icons.delete),
                      CreatorNavItem(title: 'cofnij', icon: Icons.arrow_back_ios_new),
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
                          _pickCurrency();
                          break;
                        case 4:
                          _pickIcon();
                          break;
                        case 5:
                          _pickColor();
                          break;
                        case 6:
                          _confirmDeleteCash();
                          break;
                        case 7:
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
