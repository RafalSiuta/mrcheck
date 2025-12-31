import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../menu_nav/creator_nav.dart';
import '../models/cash_model/cash.dart';
import '../models/nav_model/creator_nav_item.dart';
import '../models/value_model/value_item.dart';
import '../providers/cashprovider.dart';
import '../widgets/cards/cash_card.dart';

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
  late final TextEditingController _itemNameController;
  late final TextEditingController _itemValueController;
  late final TextEditingController _titleController;
  final FocusNode _itemNameFocus = FocusNode();
  final FocusNode _itemValueFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  late List<ValueItem> _items;
  int? _editingIndex;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.cash.name);
    _itemNameController = TextEditingController();
    _itemValueController = TextEditingController();
    _items = List.of(widget.cash.itemsList);
    _isIncome = widget.cash.isIncome;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemNameController.dispose();
    _itemValueController.dispose();
    _itemNameFocus.dispose();
    _itemValueFocus.dispose();
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

  void _saveCash() {
    final provider = context.read<CashProvider>();
    final nextId = provider.cashList.isEmpty
        ? 1
        : provider.cashList.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    final cashId = widget.cash.id > 0 ? widget.cash.id : nextId;
    final updatedCash = Cash(
      id: cashId,
      name: _titleController.text.trim(),
      value: _itemsTotal,
      date: widget.cash.date,
      isIncome: _isIncome,
      itemsList: _items,
      currency: widget.cash.currency,
    );
    if (provider.cashList.any((c) => c.id == cashId)) {
      provider.updateCash(updatedCash);
    } else {
      provider.addCash(updatedCash);
    }
    Navigator.pop(context);
  }

  void _addItem() {
    final name = _itemNameController.text.trim();
    final value =
        double.tryParse(_itemValueController.text.replaceAll(',', '.'));
    if (name.isEmpty || value == null) return;

    if (_editingIndex != null) {
      final index = _editingIndex!;
      final existing = _items[index];
      setState(() {
        _items[index] = ValueItem(
          id: existing.id,
          name: name,
          value: value,
          date: existing.date,
        );
      });
    } else {
      final nextId = _items.isEmpty
          ? 1
          : _items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      final now = DateTime.now();
      setState(() {
        _items.add(
          ValueItem(
            id: nextId,
            name: name,
            value: value,
            date: now,
          ),
        );
      });
    }
    _itemNameController.clear();
    _itemValueController.clear();
    _editingIndex = null;
    _ensureFocus(_itemNameFocus);
  }

  void _prefillForEdit(ValueItem item) {
    _itemNameController.text = item.name;
    _itemValueController.text = item.value.toStringAsFixed(2);
    _ensureFocus(_itemNameFocus);
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_editingIndex != null) {
        if (_editingIndex == index) {
          _editingIndex = null;
          _itemNameController.clear();
          _itemValueController.clear();
        } else if (_editingIndex! > index) {
          _editingIndex = _editingIndex! - 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.cash.currency;
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
    final formattedDate =
        DateFormat('dd MMM yyyy').format(widget.cash.date);

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
                            Row(
                              children: [
                                Text(
                                  'przychód',
                                  style: Theme.of(context)
                                      .inputDecorationTheme
                                      .helperStyle,
                                ),
                                Switch(
                                  value: _isIncome,
                                  onChanged: (val) {
                                    setState(() {
                                      _isIncome = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: horizontalPadding,
                        child: TextField(
                          controller: _itemNameController,
                          focusNode: _itemNameFocus,
                          textInputAction: TextInputAction.next,
                          onTap: () => _ensureFocus(_itemNameFocus),
                          onSubmitted: (_) => _ensureFocus(_itemValueFocus),
                          decoration: const InputDecoration(
                            labelText: 'Nazwa pozycji',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: horizontalPadding,
                        child: TextField(
                          controller: _itemValueController,
                          focusNode: _itemValueFocus,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.done,
                          onTap: () => _ensureFocus(_itemValueFocus),
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                            labelText: 'Wartość pozycji',
                            suffixText: currency,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: horizontalPadding,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _addItem,
                            child: const Text('dodaj'),
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
                                onEdit: () {
                                  _editingIndex = index;
                                  _prefillForEdit(item);
                                },
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
                  CreatorNavItem(title: 'kasa', icon: Icons.attach_money),
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
                      break;
                    case 2:
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
