import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/wallet_model/wallet.dart';
import '../widgets/buttons/icon_btn.dart';
import '../widgets/cards/wallet_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = DateFormat('EEEE').format(now);
    final formattedDate = DateFormat('dd MMM yyyy').format(now);


    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium,
                children: [
                  TextSpan(text: '$weekday\n',style:Theme.of(context).textTheme.headlineLarge ),
                  TextSpan(text: formattedDate),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('dzisiejszy obrót:',
                style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
