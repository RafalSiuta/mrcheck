import 'package:flutter/material.dart';

class SetsScreen extends StatelessWidget {
  const SetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Ustawienia',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
