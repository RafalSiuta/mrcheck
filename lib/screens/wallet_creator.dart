import 'package:flutter/material.dart';
import 'package:mrcash/models/wallet_model/wallet.dart';
import 'package:mrcash/models/wallet_model/wallet_item.dart';

import '../menu_nav/creator_nav.dart';

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
  late final TextEditingController _itemNameController;
  late final TextEditingController _itemValueController;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _itemNameFocus = FocusNode();
  final FocusNode _itemValueFocus = FocusNode();
  late List<WalletItem> _items;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.wallet.title);
    _itemNameController = TextEditingController();
    _itemValueController = TextEditingController();
    _items = List.of(widget.wallet.itemsList);

    if (widget.editEnable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureFocus(_titleFocus);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemNameController.dispose();
    _itemValueController.dispose();
    _titleFocus.dispose();
    _itemNameFocus.dispose();
    _itemValueFocus.dispose();
    super.dispose();
  }

  void _ensureFocus(FocusNode node) {
    if (!node.hasFocus) {
      node.requestFocus();
    }
  }

  double get _itemsTotal =>
      _items.fold<double>(0, (sum, item) => sum + item.value);

  void _addItem() {
    final name = _itemNameController.text.trim();
    final value =
        double.tryParse(_itemValueController.text.replaceAll(',', '.'));
    if (name.isEmpty || value == null) return;

    final nextId = _items.isEmpty
        ? 1
        : _items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
    setState(() {
      _items.add(WalletItem(id: nextId, name: name, value: value));
      _itemNameController.clear();
      _itemValueController.clear();
    });
    _ensureFocus(_itemNameFocus);
  }

  @override
  Widget build(BuildContext context) {
    final iconData = IconData(widget.wallet.icon, fontFamily: 'MaterialIcons');
    final iconToShow = widget.wallet.icon == 1
        ? Icons.account_balance_wallet
        : iconData;
    final currency = widget.wallet.currency;
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

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
                        child: TextField(
                          controller: _titleController,
                          focusNode: _titleFocus,
                          style: Theme.of(context).textTheme.headlineLarge,
                          textInputAction: TextInputAction.next,
                          onTap: () => _ensureFocus(_titleFocus),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _ensureFocus(_itemNameFocus),
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
                            prefixIcon: IconButton(
                              iconSize: 24,
                              icon: Icon(
                                iconToShow,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 24,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                              onPressed: () => _ensureFocus(_titleFocus),
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
                            separatorBuilder: (_, __) =>
                                const Divider(height: 12),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.titleMedium,
                                  children: [
                                    TextSpan(
                                      text: '${item.name} ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text:
                                          '${item.value.toStringAsFixed(2)} $currency',
                                    ),
                                  ],
                                ),
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
                      Navigator.pop(context);
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
