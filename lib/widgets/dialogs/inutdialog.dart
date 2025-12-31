import 'package:flutter/material.dart';

class InutDialogResult {
  const InutDialogResult({
    required this.name,
    required this.value,
  });

  final String name;
  final double value;
}

class InutDialog extends StatefulWidget {
  const InutDialog({
    required this.title,
    this.currency,
    this.initialName = '',
    this.initialValue = '',
    this.confirmLabel = 'Zapisz',
    super.key,
  });

  final String title;
  final String? currency;
  final String initialName;
  final String initialValue;
  final String confirmLabel;

  @override
  State<InutDialog> createState() => _InutDialogState();
}

class _InutDialogState extends State<InutDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _valueController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
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
      InutDialogResult(name: name, value: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 50),
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
