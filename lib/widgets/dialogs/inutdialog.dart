import 'package:flutter/material.dart';
import 'package:mrcash/utils/constans/category_list.dart';

const Color ink = Color(0xFF0F0F0F);

class InutDialogResult {
  const InutDialogResult({
    required this.name,
    required this.value,
    required this.categories,
  });

  final String name;
  final double value;
  final List<String> categories;
}

class InutDialog extends StatefulWidget {
  const InutDialog({
    required this.title,
    this.currency,
    this.initialName = '',
    this.initialValue = '',
    this.initialCategories = const [],
    this.confirmLabel = 'Zapisz',
    this.showCategories = true,
    super.key,
  });

  final String title;
  final String? currency;
  final String initialName;
  final String initialValue;
  final List<String> initialCategories;
  final String confirmLabel;
  final bool showCategories;

  @override
  State<InutDialog> createState() => _InutDialogState();
}

class _InutDialogState extends State<InutDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  late Set<String> _selectedCategories;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _valueController = TextEditingController(text: widget.initialValue);
    _selectedCategories = {...widget.initialCategories};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final value =
        double.tryParse(_valueController.text.replaceAll(',', '.'));

    if (name.isEmpty || value == null) {
      setState(() {
        _errorText = 'Podaj nazwę i wartość';
      });
      return;
    }

    Navigator.of(context).pop(
      InutDialogResult(
        name: name,
        value: value,
        categories: _selectedCategories.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nazwa pozycji'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valueController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Wartość pozycji',
              suffixText: widget.currency,
              errorText: _errorText,
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (widget.showCategories) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kategorie',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 80,
              child: GridView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1 / 1.6,
                ),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  final category = categoryList[index];
                  final isSelected =
                      _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 8.0,
                        color: isSelected ? Colors.white : ink,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    side: const BorderSide(color: ink),
                    backgroundColor: Colors.transparent,
                    selectedColor: ink,
                    disabledColor: Colors.transparent,
                    selected: isSelected,
                    onSelected: (_) => _toggleCategory(category),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
