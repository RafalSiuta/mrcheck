import 'package:flutter/material.dart';

class CurrenciesScreen extends StatelessWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Kursy walut',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
