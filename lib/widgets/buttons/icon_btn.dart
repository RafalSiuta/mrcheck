import 'package:flutter/material.dart';

class IconBtn extends StatelessWidget {
  const IconBtn({required this.icon, required this.onClick, super.key});

  final IconData icon;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onClick,
      padding: const EdgeInsets.all(8.0),
      constraints: const BoxConstraints(),
      icon: Icon(icon),
      splashRadius: 20,
    );
  }
}
