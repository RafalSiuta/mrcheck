import 'package:flutter/material.dart';

class PiggyCard extends StatelessWidget {
  const PiggyCard({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width /3;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/piggy.png',
            width: imageWidth,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
