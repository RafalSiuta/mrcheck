import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../database/database_helper.dart';
import '../models/cash_model/cash.dart';
import '../models/value_model/value_item.dart';
import 'settingsprovider.dart';

class CalendarMarkerValue {
  const CalendarMarkerValue({
    required this.amount,
    required this.currency,
    required this.isIncome,
  });

  final double amount;
  final String currency;
  final bool isIncome;
}

class CashSearchResult {
  const CashSearchResult({
    required this.cash,
    required this.item,
  });

  final Cash cash;
  final ValueItem item;

  double get value => item.value;
  String get name => item.name;
  DateTime get date => cash.date;
  String get currency => cash.currency;
  bool get isIncome => cash.isIncome;
}

class CashProvider extends ChangeNotifier {
  CashProvider({required SettingsProvider settings}) : _settings = settings {
    init();
  }

  SettingsProvider _settings;
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static final DateTime _seedNow = DateTime.now();
  static final DateTime _seedToday = _normalizeDate(_seedNow);
  DateTime _focusedDay = _seedToday;
  DateTime _selectedDay = _seedToday;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  PageController? _calendarPageController;
  bool _initialized = false;

  List<Cash> _cashList = [];

  List<Cash> get cashList => List.unmodifiable(_cashList);
  DateTime get now => _seedNow;
  DateTime get today => _seedToday;
  String get weekdayLabel => DateFormat('EEEE', 'pl_PL').format(_seedNow);
  String get formattedDate =>
      DateFormat('dd MMM yyyy', 'pl_PL').format(_seedNow);
  bool isSameDayLocal(DateTime a, DateTime b) =>
      _normalizeDate(a) == _normalizeDate(b);
  double sumItems(Cash cash) => _sumItems(cash);
  String formatDisplayDate(DateTime date) =>
      DateFormat('dd MMM yyyy', 'pl_PL').format(date);
  String formatWeekdayLabel(DateTime date) =>
      DateFormat('EEEE', 'pl_PL').format(date);
  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  PageController? get calendarPageController => _calendarPageController;

  Map<DateTime, List<Cash>> get eventsByDay => _groupCashByDay(_cashList);

  Future<void> init() async {
    await _databaseHelper.initializeHive();
    _cashList = _databaseHelper.getAllCash();
    //_cashList = sampleCashData(); // utils/test_data.dart - uncomment to preload fixtures.
    _initialized = true;
    notifyListeners();
  }

  List<Cash> cashForDay(DateTime date) {
    final normalized = _normalizeDate(date);
    return eventsByDay[normalized] ?? [];
  }

  List<Cash> get selectedDayCash => cashForDay(_selectedDay);

  List<CalendarMarkerValue> markerValues(List<Cash> events) {
    if (events.isEmpty) return const <CalendarMarkerValue>[];

    double totalIncome = 0;
    double totalExpense = 0;
    String currency = '';

    for (final cash in events) {
      final total = _sumItems(cash);
      currency = cash.currency;
      if (cash.isIncome) {
        totalIncome += total;
      } else {
        totalExpense += total;
      }
    }

    final List<CalendarMarkerValue> markers = [];
    if (totalIncome > 0) {
      markers.add(
        CalendarMarkerValue(
          amount: totalIncome,
          currency: currency,
          isIncome: true,
        ),
      );
    }
    if (totalExpense > 0) {
      markers.add(
        CalendarMarkerValue(
          amount: totalExpense,
          currency: currency,
          isIncome: false,
        ),
      );
    }

    return markers;
  }

  void setCalendarPageController(PageController controller) {
    _calendarPageController = controller;
  }

  void goToPreviousCalendarPage() {
    _calendarPageController?.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void goToNextCalendarPage() {
    _calendarPageController?.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void changeCalendarFormat(CalendarFormat format) {
    if (_calendarFormat == format) return;
    _calendarFormat = format;
    notifyListeners();
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    if (isSameDay(_selectedDay, selectedDay)) return;
    _selectedDay = _normalizeDate(selectedDay);
    _focusedDay = _normalizeDate(focusedDay);
    notifyListeners();
  }

  void updateFocusedDay(DateTime day) {
    _focusedDay = _normalizeDate(day);
    notifyListeners();
  }

  // List<Cash> getCalendarValues(DateTime date) {
  //   date = DateTime(date.year, date.month, date.day);
  //   return tasks[date] ?? [];
  // }

  void updateSettings(SettingsProvider settings) {
    _settings = settings;
    notifyListeners();
  }

  Future<void> addCash(Cash cash) async {
    if (!_initialized) await init();
    await _databaseHelper.addCash(cash);
    _cashList = _databaseHelper.getAllCash();
    notifyListeners();
  }

  Future<void> updateCash(Cash cash) async {
    if (!_initialized) await init();
    await _databaseHelper.updateCash(cash);
    _cashList = _databaseHelper.getAllCash();
    notifyListeners();
  }

  Future<void> removeCash(String id) async {
    if (!_initialized) await init();
    await _databaseHelper.deleteCash(id);
    _cashList = _databaseHelper.getAllCash();
    notifyListeners();
  }

  List<CashSearchResult> searchCash({
    String keyword = '',
    DateTimeRange? dateRange,
    List<String> categories = const [],
  }) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    final selectedCategories =
        categories.map((category) => category.toLowerCase()).toSet();
    final normalizedStart =
        dateRange == null ? null : _normalizeDate(dateRange.start);
    final normalizedEnd =
        dateRange == null ? null : _normalizeDate(dateRange.end);

    final List<CashSearchResult> results = [];

    for (final cash in _cashList) {
      final normalizedCashDate = _normalizeDate(cash.date);
      final matchesDate = normalizedStart == null ||
          normalizedEnd == null ||
          (!normalizedCashDate.isBefore(normalizedStart) &&
              !normalizedCashDate.isAfter(normalizedEnd));

      if (!matchesDate) {
        continue;
      }

      for (final item in cash.itemsList) {
        final itemName = item.name.toLowerCase();
        final itemCategories =
            item.categories.map((category) => category.toLowerCase()).toSet();
        final matchesKeyword = normalizedKeyword.isEmpty ||
            itemName.contains(normalizedKeyword) ||
            cash.name.toLowerCase().contains(normalizedKeyword);
        final matchesCategory = selectedCategories.isEmpty ||
            selectedCategories.any(itemCategories.contains);

        if (matchesKeyword && matchesCategory) {
          results.add(
            CashSearchResult(
              cash: cash,
              item: item,
            ),
          );
        }
      }
    }

    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  Map<DateTime, List<Cash>> _groupCashByDay(List<Cash> cashList) {
    final Map<DateTime, List<Cash>> events = {};
    for (final cash in cashList) {
      final day = _normalizeDate(cash.date);
      events.putIfAbsent(day, () => []);
      events[day]!.add(cash);
    }
    return events;
  }

  static DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  double _sumItems(Cash cash) =>
      cash.itemsList.fold<double>(0, (sum, item) => sum + item.value);
}
