import 'package:flutter/material.dart';
import 'package:mrcash/screens/homescreen.dart';
import 'package:mrcash/screens/summaryscreen.dart';
import 'package:mrcash/screens/walletscreen.dart';

import '../models/nav_model/nav_model.dart';
import '../models/screen_model/screen_model.dart';
import '../utils/routes/custom_route.dart';
import '../widgets/menu_nav/nav_rail.dart';
import 'calendarscreen.dart';
import 'cash_creator.dart';
import '../models/cash_model/cash.dart';
import '../models/value_model/value_item.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  _onPageChange(int page) {
    setState(() {
      _pageController.animateToPage(page,
          duration: const Duration(microseconds: 500), curve: Curves.easeIn);

      _currentPage = page;
    });
  }

  final List<ScreenModel> _pages = [
    ScreenModel(
      page: const HomeScreen(),
      title: NavModel(
        title: 'start',
      ),
    ),
    ScreenModel(
        page: const WalletScreen(),
        title: NavModel(
          title: 'portfele',
        )),
    ScreenModel(
      page: const CalendarScreen(),
      title: NavModel(
        title: 'kalendarz',
      ),
    ),
    ScreenModel(
        page: const SummaryScreen(),
        title: NavModel(
          title: 'statystyki',
        )),

  ];

  void hideTrigger() {
  }

  void trigger() {
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: _currentPage);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final placeholderCash = Cash(
      id: -1,
      name: '',
      value: 0,
      date: DateTime.now(),
      itemsList: const <ValueItem>[],
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Center(
                  key: widget.key,
                  child: PageView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _pages.length,
                      controller: _pageController,
                      onPageChanged: _onPageChange,
                      itemBuilder: (context, index) {
                        return _pages
                            .map((e) => e.page!)
                            .toList()
                            .elementAt(index);
                      })),
            ),
          ),
          SideNav(
            key: widget.key,
            leading: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).textTheme.displayLarge!.color,
                size: 18,
              ),
              onPressed: () async {
                await Navigator.pushNamed(context, '/settings');
              },
            ),
            itemCount: _pages.length,
            titles: _pages.map((e) => e.title!).toList(),
            selectedItem: _currentPage,
            onTap: (int sel) {
              _onPageChange(sel);
              hideTrigger();
            },
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            Theme.of(context).floatingActionButtonTheme.backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
        onPressed: () async {
          await Navigator.push(
            context,
            CustomPageRoute(
              child: CashCreator(cash: placeholderCash),
              direction: AxisDirection.up,
            ),
          );
        },
      ),
    );
  }
}
