import 'package:flutter/material.dart';


class WalletCard extends StatelessWidget {
  const WalletCard( {this.title = "title",super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text(title,style: Theme.of(context).textTheme.labelMedium,),
    );
  }
}
