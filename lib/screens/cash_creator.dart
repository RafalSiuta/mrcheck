import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrcash/utils/extensions/string_extension.dart';
import 'package:provider/provider.dart';

import '../models/cash_model/cash.dart';
import '../models/nav_model/creator_nav_item.dart';
import '../models/value_model/value_item.dart';
import '../providers/cashprovider.dart';
import '../utils/id_generator/id_generator.dart';
import '../widgets/cards/cash_card.dart';
import '../widgets/dialogs/inutdialog.dart';
import '../widgets/menu_nav/creator_nav.dart';

class CashCreator extends StatefulWidget {
  const CashCreator({
    required this.cash,
    super.key,
  });

  final Cash cash;

  @override
  State<CashCreator> createState() => _CashCreatorState();
}

class _CashCreatorState extends State<CashCreator> {
  late final TextEditingController _titleController;
  final FocusNode _titleFocus = FocusNode();
  late List<ValueItem> _items;
  int? _editingIndex;
  late bool _isIncome;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.cash.name);
    _items = List.of(widget.cash.itemsList);
    _isIncome = widget.cash.isIncome;
    _selectedDate = widget.cash.date;
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

  Future<void> _saveCash() async {
    final provider = context.read<CashProvider>();
    final cashId =
        widget.cash.id.isNotEmpty ? widget.cash.id : makeId();
    final updatedCash = Cash(
      id: cashId,
      name: _titleController.text.trim(),
      value: _itemsTotal,
      date: _selectedDate,
      isIncome: _isIncome,
      itemsList: _items,
      currency: widget.cash.currency,
    );
    if (provider.cashList.any((c) => c.id == cashId)) {
      await provider.updateCash(updatedCash);
    } else {
      await provider.addCash(updatedCash);
    }
    Navigator.pop(context);
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
        currency: widget.cash.currency,
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

  Future<void> _confirmDeleteCash() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usunąć zapis?'),
        content: const Text(
          'To usunie ten zapis. Kontynuować?',
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
      if (widget.cash.id.isNotEmpty) {
        await context.read<CashProvider>().removeCash(widget.cash.id);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pl', 'PL'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.cash.currency;
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
    final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);

    return Scaffold(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge,
                            ),
                            TextField(
                              controller: _titleController,
                              focusNode: _titleFocus,
                              style: Theme.of(context).textTheme.headlineLarge,
                              textInputAction: TextInputAction.next,
                              onTap: () => _ensureFocus(_titleFocus),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: InputBorder.none,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                hintText: 'Tytuł',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'razem: ${_itemsTotal.toStringAsFixed(2)} $currency',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Switch(
                                  value: _isIncome,
                                  onChanged: (val) {
                                    setState(() {
                                      _isIncome = val;
                                    });
                                  },
                                ),
                                Text(
                                  _isIncome ? 'przychody' : 'wydatki',
                                  style: Theme.of(context)
                                      .inputDecorationTheme
                                      .helperStyle,
                                ),
                              ],
                            ),
                          ],
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
                            shrinkWrap: true,
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1.5,
                              thickness: .5,
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
                                isIncome: _isIncome,
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
                  CreatorNavItem(title: 'data', icon: Icons.calendar_month),
                  CreatorNavItem(title: 'rachunek', icon: Icons.camera_alt),
                  CreatorNavItem(title: 'usuń', icon: Icons.delete),
                  CreatorNavItem(title: 'cofnij', icon: Icons.arrow_back_ios_new),
                ],
                selectedIndex: -1,
                navIconSize: 24,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      _saveCash();
                      break;
                    case 1:
                      _showItemDialog();
                      break;
                    case 2:
                      _pickDate();
                      break;
                    case 3:
                      // rachunek placeholder
                      break;
                    case 4:
                      _confirmDeleteCash();
                      break;
                    case 5:
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
