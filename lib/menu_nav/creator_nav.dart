import 'package:flutter/material.dart';

import '../models/nav_model/creator_nav_item.dart';

class CreatorNav extends StatelessWidget {
  const CreatorNav({
    required this.items,
    required this.onTap,
    required this.selectedIndex,
    this.navIconSize = 20,
    this.menuTop = 12,
    this.backgroundColor,
    super.key,
  });

  final List<CreatorNavItem> items;
  final void Function(int index) onTap;
  final int selectedIndex;
  final double navIconSize;
  final double menuTop;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).unselectedWidgetColor.withValues(alpha: 0.5),
            blurRadius: 1.0,
            offset: const Offset(.0, .0),
            spreadRadius: 1.0,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: menuTop),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            direction: Axis.vertical,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              final color = selected
                  ? Theme.of(context).indicatorColor
                  : Theme.of(context).unselectedWidgetColor;
              return Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: navIconSize,
                        color: color,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .inputDecorationTheme
                            .helperStyle
                            ?.copyWith(
                              fontSize: navIconSize * 0.3,
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
