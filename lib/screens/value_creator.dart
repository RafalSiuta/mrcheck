import 'package:flutter/material.dart';

class ValueCreator extends StatefulWidget {
  const ValueCreator({super.key});

  @override
  State<ValueCreator> createState() => _ValueCreatorState();
}

class _ValueCreatorState extends State<ValueCreator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: Center(child: Text('add value'),)),
    );
  }
}
