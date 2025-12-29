import 'package:flutter/material.dart';
import 'package:mrcash/models/nav_model/nav_model.dart';
import 'package:mrcash/utils/extensions/string_extension.dart';



class SideNav extends StatelessWidget {
  final int itemCount;
  final List<NavModel> titles;
  final Function(int index) onTap;
  final int selectedItem;
  final Widget? leading;
  final Widget? trailing;
  final int quarterTurns;
  final Color backgroundColor;
  final double navDotIndicatorSize;

  const SideNav(
      {super.key,
      required this.itemCount,
      required this.titles,
      required this.onTap,
      required this.selectedItem,
      this.leading,
      this.trailing,
      this.quarterTurns = -1,
      this.backgroundColor = Colors.transparent,
      this.navDotIndicatorSize = 8.0});
  @override
  Widget build(BuildContext context) {
    var menuTop = 20.0;
    return Container(
      key: key,
      margin: EdgeInsets.zero,
      child: NavigationRail(
          minWidth: 40,
          leading: leading,
          trailing: trailing,
          backgroundColor: Colors.transparent,
          destinations: List.generate(
              itemCount,
                  (index) => NavigationRailDestination(
                icon: Icon(
                  titles[index].icon,
                  size: navDotIndicatorSize,
                  fill: 0.0,
                ),
                selectedIcon: Icon(
                  titles[index].icon,
                  size: navDotIndicatorSize,
                  fill: 0.0,
                ),
                label: RotatedBox(
                    quarterTurns: -1,
                    child: Text(titles[index].title
                            .capitalizeFirstLetter()
                      // '${titles[index].title}  ',
                    )),
              )).toList(),
          selectedIndex: selectedItem,
          onDestinationSelected: onTap),
    );
  }
}
