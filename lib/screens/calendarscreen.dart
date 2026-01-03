import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/cash_model/cash.dart';
import '../providers/cashprovider.dart';
import '../utils/routes/custom_route.dart';
import '../widgets/calendar/marker/calendar_marker.dart';
import '../widgets/calendar/list/calendar_list.dart';
import '../widgets/headers/calendar_header.dart';
import 'cash_creator.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color ink = Color(0xFF0F0F0F);
    return Consumer<CashProvider>(
      builder: (context, cashProvider, _) {
        final selectedCash = [...cashProvider.selectedDayCash]
          ..sort((a, b) => b.date.compareTo(a.date));

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarHeader(
                  date: cashProvider.focusedDay,
                  locale: 'pl_PL',
                  previous: cashProvider.goToPreviousCalendarPage,
                  next: cashProvider.goToNextCalendarPage,
                  widget: DropdownButton<CalendarFormat>(
                    value: cashProvider.calendarFormat,
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
                        cashProvider.changeCalendarFormat(format);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TableCalendar<Cash>(
                  locale: 'pl_PL',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: cashProvider.focusedDay,
                  availableGestures: AvailableGestures.all,
                  calendarFormat: cashProvider.calendarFormat,
                  onFormatChanged: cashProvider.changeCalendarFormat,
                  onPageChanged: cashProvider.updateFocusedDay,
                  onCalendarCreated: cashProvider.setCalendarPageController,
                  selectedDayPredicate: (day) =>
                      isSameDay(cashProvider.selectedDay, day),
                  onDaySelected: cashProvider.selectDay,
                  eventLoader: cashProvider.cashForDay,
                  headerVisible: false,
                  daysOfWeekVisible: true,
                  rowHeight: 64,
                  calendarStyle: CalendarStyle(
                    cellMargin: EdgeInsets.zero,
                    cellPadding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 4,
                    ),
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
                      color: ink.withValues(alpha: 0.3),
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
                        DateFormat.E('pl_PL').format(day),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    markerBuilder: (context, day, events) {
                      final markerValues = cashProvider.markerValues(events);
                      if (markerValues.isEmpty) return const SizedBox.shrink();

                      final markers = markerValues
                          .map(
                            (marker) => CalendarMarker(
                              label:
                                  '${marker.isIncome ? '+' : '-'}${marker.amount.toStringAsFixed(2)} ${marker.currency}',
                              backgroundColor: marker.isIncome
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                              textColor: marker.isIncome
                                  ? Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.color ??
                                      Colors.white
                                  : Colors.white,
                            ),
                          )
                          .toList();

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: markers,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: CalendarList(
                    cashList: selectedCash,
                    showDate: false,
                    onEdit: (cash) async {
                      await Navigator.push(
                        context,
                        CustomPageRoute(
                          child: CashCreator(cash: cash),
                          direction: AxisDirection.up,
                        ),
                      );
                    },
                    onDelete: (_) {},
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
