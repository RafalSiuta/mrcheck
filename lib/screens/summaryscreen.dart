import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('SummaryScreen\n Welcome',style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}