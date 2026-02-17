import 'package:flutter/material.dart';
import 'package:mrcash/models/nav_model/nav_model.dart';
import 'package:mrcash/models/screen_model/screen_model.dart';
import 'package:mrcash/screens/settings/setsoptions/about.dart';
import 'package:mrcash/screens/settings/setsoptions/sets.dart';
import 'package:mrcash/screens/settings/setsoptions/currencies.dart';
import 'package:mrcash/widgets/menu_nav/nav_rail.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<ScreenModel> _pages = [
    ScreenModel(
      page: const SetsScreen(),
      title: NavModel(
        title: 'ustawienia',
      ),
    ),
    ScreenModel(
      page: const CurrenciesScreen(),
      title: NavModel(
        title: 'waluty',
      ),
    ),
    ScreenModel(
      page: const AboutScreen(),
      title: NavModel(
        title: 'o apce',
      ),
    ),
  ];

  void _onPageChange(int page) {
    setState(() {
      _pageController.animateToPage(
        page,
        duration: const Duration(microseconds: 500),
        curve: Curves.easeIn,
      );
      _currentPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Center(
                  key: widget.key,
                  child: PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pages.length,
                    controller: _pageController,
                    onPageChanged: _onPageChange,
                    itemBuilder: (context, index) {
                      return _pages.map((e) => e.page!).toList().elementAt(index);
                    },
                  ),
                ),
              ),
            ),
            SideNav(
              key: widget.key,
              leading: IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.displayLarge!.color,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              itemCount: _pages.length,
              titles: _pages.map((e) => e.title!).toList(),
              selectedItem: _currentPage,
              onTap: _onPageChange,
            ),
          ],
        ),
      ),
    );
  }
}
