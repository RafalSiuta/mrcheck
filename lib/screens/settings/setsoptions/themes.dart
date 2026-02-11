import 'package:flutter/material.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Wygląd',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
