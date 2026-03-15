import 'package:flutter/material.dart';
import 'package:mrcash/utils/mask_text_helper.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({
    this.title = 'title',
    this.total = 0,
    this.icon = Icons.attach_money,
    this.backgroundColor,
    this.onClick,
    this.lockWallet = false,
    super.key,
  });

  final String title;
  final double total;
  final IconData icon;
  final Color? backgroundColor;
  final VoidCallback? onClick;
  final bool lockWallet;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF0F0F0F);
    final textStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: ink);
    final totalText = total.toStringAsFixed(2);
    final displayTitle = lockWallet ? maskText(title, maskChar: 'x') : title;
    final displayTotal = lockWallet ? maskText(totalText) : totalText;

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 2 / 2,
        child: InkWell(
          onTap: onClick,
          borderRadius: BorderRadius.circular(12),
          child: Card(
            color: backgroundColor ?? Theme.of(context).cardColor,
            surfaceTintColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      icon,
                      color: ink,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: RichText(
                      text: TextSpan(
                        style: textStyle,
                        children: [
                          TextSpan(text: '$displayTitle\n'),
                          const TextSpan(text: 'total '),
                          TextSpan(text: displayTotal),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
