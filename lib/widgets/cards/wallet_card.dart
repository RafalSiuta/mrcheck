import 'package:flutter/material.dart';


class WalletCard extends StatelessWidget {
  const WalletCard({
    this.title = "title",
    this.total = 0,
    this.icon = Icons.attach_money,
    this.backgroundColor,
    this.onClick,
    super.key,
  });

  final String title;
  final double total;
  final IconData icon;
  final Color? backgroundColor;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF0F0F0F);
    final textStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: ink);

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
                          TextSpan(text: '$title\n'),
                          const TextSpan(text: 'total '),
                          TextSpan(text: total.toString()),
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
