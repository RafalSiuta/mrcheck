import 'package:flutter/material.dart';
import 'package:mrcash/screens/homescreen.dart';
import 'package:mrcash/screens/summaryscreen.dart';
import 'package:mrcash/screens/value_creator.dart';

import '../models/nav_model/nav_model.dart';
import '../models/screen_model/screen_model.dart';
import '../utils/routes/custom_route.dart';
import '../widgets/buttons/custom_fab.dart';
import '../widgets/menu_nav/nav_rail.dart';
import 'calendarscreen.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation _degOneTranslationAnimation, _degTwoTranslationAnimation;
  late Animation _animationRotation;
  late Animation<Offset> _menuAnimation;
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
      page: const CalendarScreen(),
      title: NavModel(
        title: 'kalendarz',
      ),
    ),
    ScreenModel(
        page: const SummaryScreen(),
        title: NavModel(
          title: 'podsumowanie',
        )),

  ];

  void hideTrigger() {
    if (_animationController.isCompleted) {
      setState(() {
        _animationController.reverse();
      });
    }
  }

  void trigger() {
    setState(() {
      if (_animationController.isCompleted) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: _currentPage);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0)
    ]).animate(_animationController);
    _degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0)
    ]).animate(_animationController);

    _animationRotation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _menuAnimation = Tween<Offset>(
        begin: const Offset(0.0, 0.0), end: const Offset(-0.5, 0.0))
        .animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutBack));

    super.initState();

    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: CustomFab(
        translationValueOne: _degOneTranslationAnimation.value,
        translationValueTwo: _degTwoTranslationAnimation.value,
        rotationValue: _animationRotation.value,
        ignorePointer: _animationController.isCompleted ? true : false,
        onTap: () {
          trigger();
        },
        hideBtn: () {
          hideTrigger();
        },
        addTask: () async {
          await Navigator.push(
              context,
              CustomPageRoute(
                  child: ValueCreator(),
                  direction: AxisDirection.up));
        },
        addNote: () async {
          await Navigator.push(
              context,
              CustomPageRoute(
                child: ValueCreator(),
              ));
        },
      ),
    );
  }
}
