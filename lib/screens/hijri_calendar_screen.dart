import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late HijriCalendar _today;
  late int _firstWeekday;
  late int _daysInMonth;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal("en");
    _today = HijriCalendar.now();

    final calendar = HijriCalendar();

    _firstWeekday = calendar
        .hijriToGregorian(_today.hYear, _today.hMonth, 1)
        .weekday;

    _daysInMonth = _daysInHijriMonth(_today.hYear, _today.hMonth);
  }

  int _daysInHijriMonth(int year, int month) {
    final calendar = HijriCalendar();

    final currentGregorian = calendar.hijriToGregorian(year, month, 1);

    int nextMonth = month == 12 ? 1 : month + 1;
    int nextYear = month == 12 ? year + 1 : year;

    final nextGregorian = calendar.hijriToGregorian(nextYear, nextMonth, 1);

    return nextGregorian.difference(currentGregorian).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(title: const Text('Hijri Calendar')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            Text(
              'Gregorian: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Hijri: ${_today.hDay} ${_today.longMonthName} ${_today.hYear}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellWidth = constraints.maxWidth / 7;
                  final cellHeight = cellWidth * 1.2;

                  final totalCells = _daysInMonth + (_firstWeekday - 1);
                  final rows = (totalCells / 7).ceil();

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rows * 7,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: cellWidth / cellHeight,
                    ),
                    itemBuilder: (context, index) {
                      final dayNum = index - (_firstWeekday - 2);
                      final isToday = dayNum == _today.hDay;

                      if (dayNum < 1 || dayNum > _daysInMonth) {
                        return const SizedBox();
                      }

                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.green.shade300
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isToday
                                ? Colors.green.shade700
                                : Colors.grey.shade300,
                            width: isToday ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 18,
                              color: isToday ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
