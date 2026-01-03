import 'package:flutter/material.dart';
import 'package:mrcash/models/wallet_model/wallet.dart';
import 'package:mrcash/models/value_model/value_item.dart';
import 'package:provider/provider.dart';

import '../models/color_model/color_option.dart';
import '../models/icon_model/icon_option.dart';
import '../models/nav_model/creator_nav_item.dart';
import '../providers/walletprovider.dart';
import '../utils/id_generator/id_generator.dart';
import '../widgets/cards/cash_card.dart';
import '../widgets/dialogs/color_dialog.dart';
import '../widgets/dialogs/icon_dialog.dart';
import '../widgets/dialogs/inutdialog.dart';
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
  late DateTime _walletDate;
  late int _selectedColorValue;
  late int _selectedIconCode;
  Color get _selectedColor => Color(_selectedColorValue);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.wallet.title);
    _items = List.of(widget.wallet.itemsList);
    _walletDate = widget.wallet.date;
    _selectedColorValue =
        widget.wallet.color == 0 ? Colors.white.value : widget.wallet.color;
    _selectedIconCode = widget.wallet.icon == 0
        ? Icons.account_balance_wallet.codePoint
        : widget.wallet.icon;

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
      currency: widget.wallet.currency,
      color: _selectedColorValue,
      date: _walletDate,
      itemsList: _items,
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
        currency: widget.wallet.currency,
        initialName: item?.name ?? '',
        initialValue: item != null ? item.value.toStringAsFixed(2) : '',
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
        final existing = _items[index!];
        _items[index!] = ValueItem(
          id: existing.id,
          name: result.name,
          value: result.value,
          date: existing.date,
        );
      } else {
        final now = DateTime.now();
        _items.add(
          ValueItem(
            id: makeId(),
            name: result.name,
            value: result.value,
            date: now,
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

    if (shouldDelete == true) {
      if (widget.wallet.id.isNotEmpty) {
        context.read<WalletProvider>().removeWallet(widget.wallet.id);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData =
        IconData(_selectedIconCode, fontFamily: 'MaterialIcons');
    final currency = widget.wallet.currency;
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

    return Scaffold(
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
                              return CashCard(
                                name: item.name,
                                value: item.value,
                                date: item.date,
                                currency: currency,
                                showDate: true,
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
              CreatorNav(
                items: const [
                  CreatorNavItem(title: 'zapisz', icon: Icons.save),
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
                      _showItemDialog();
                      break;
                    case 2:
                      //pick currency
                      break;
                    case 3:
                      _pickIcon();
                      break;
                    case 4:
                      _pickColor();
                      break;
                    case 5:
                      _confirmDeleteCash();
                      break;
                    case 6:
                      Navigator.pop(context);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
