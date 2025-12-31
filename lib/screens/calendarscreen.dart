import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/cash_model/cash.dart';
import '../providers/cashprovider.dart';
import '../widgets/headers/calendar_header.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  Map<DateTime, List<Cash>> _groupCashByDay(List<Cash> cashList) {
    final Map<DateTime, List<Cash>> events = {};
    for (final cash in cashList) {
      final day = DateTime(cash.date.year, cash.date.month, cash.date.day);
      events.putIfAbsent(day, () => []);
      events[day]!.add(cash);
    }
    return events;
  }

  List<Widget> _buildMarkers(
    BuildContext context,
    DateTime day,
    List<Cash> events,
  ) {
    if (events.isEmpty) return [];

    double totalIncome = 0;
    double totalExpense = 0;
    String currency = '';

    double sumItems(Cash cash) =>
        cash.itemsList.fold<double>(0, (sum, item) => sum + item.value);

    for (final cash in events) {
      currency = cash.currency;
      final total = sumItems(cash);
      if (cash.isIncome) {
        totalIncome += total;
      } else {
        totalExpense += total;
      }
    }

    final List<Widget> markers = [];
    if (totalIncome > 0) {
      markers.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '+${totalIncome.toStringAsFixed(2)} $currency',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }
    if (totalExpense > 0) {
      markers.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '-${totalExpense.toStringAsFixed(2)} $currency',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    const Color ink = Color(0xFF0F0F0F);
    return Consumer<CashProvider>(
      builder: (context, cashProvider, _) {
        final eventsByDay = _groupCashByDay(cashProvider.cashList);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarHeader(
                  date: _focusedDay,
                  previous: () => _pageController?.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                  next: () => _pageController?.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                  widget: DropdownButton<CalendarFormat>(
                    value: _calendarFormat,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: CalendarFormat.month,
                        child: Text('mies'),
                      ),
                      DropdownMenuItem(
                        value: CalendarFormat.twoWeeks,
                        child: Text('2 tyg.'),
                      ),
                      DropdownMenuItem(
                        value: CalendarFormat.week,
                        child: Text('tydz'),
                      ),
                    ],
                    onChanged: (format) {
                      if (format != null) {
                        setState(() => _calendarFormat = format);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TableCalendar<Cash>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    availableGestures: AvailableGestures.all,
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) =>
                        setState(() => _calendarFormat = format),
                    onPageChanged: (day) =>
                        setState(() => _focusedDay = day),
                    onCalendarCreated: (controller) =>
                        _pageController = controller,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    eventLoader: (day) =>
                        eventsByDay[DateTime(day.year, day.month, day.day)] ??
                        <Cash>[],
                    headerVisible: false,
                    daysOfWeekVisible: true,
                    rowHeight: 64,
                    calendarStyle: CalendarStyle(
                      isTodayHighlighted: true,
                      todayDecoration: BoxDecoration(
                        color: ink,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ink,
                          width: 0.3,
                        ),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: ink.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markersMaxCount: 3,
                      markersAnchor: 1,
                    ),
                    calendarBuilders: CalendarBuilders<Cash>(
                      defaultBuilder: (context, day, _) => Center(
                        child: Text(
                          '${day.day}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      outsideBuilder: (context, day, _) => Center(
                        child: Text(
                          '${day.day}',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ),
                      dowBuilder: (context, day) => Center(
                        child: Text(
                          DateFormat.E().format(day),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      markerBuilder: (context, day, events) {
                        final markers = _buildMarkers(context, day, events);
                        if (markers.isEmpty) return const SizedBox.shrink();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: markers,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
