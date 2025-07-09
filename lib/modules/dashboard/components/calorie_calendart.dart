import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';

class DayItem {
  final DateTime date;
  final int? consumedCalories; // null = skipped
  final int maxCalories;

  DayItem({
    required this.date,
    required this.maxCalories,
    this.consumedCalories,
  });
}

class CalorieCalendar extends StatefulWidget {
  final int maxCalories;

  const CalorieCalendar({super.key, required this.maxCalories});

  @override
  State<CalorieCalendar> createState() => _CalorieCalendarState();
}

class _CalorieCalendarState extends State<CalorieCalendar> {
  late List<DayItem> days;
  int selectedIndex = DateTime.now().day - 1;

  @override
  void initState() {
    super.initState();
    _generateDays();
  }

  void _generateDays() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);

    days = List.generate(end.day, (index) {
      final date = start.add(Duration(days: index));

      //  calorie data for demonstration
      final mockData = {
        2: 1800,
        3: 2100,
        4: 2000,
        6: 1900,
        10: 2200,
        13: 1700,
        // days 1, 5, 7... are skipped
      };

      return DayItem(
        date: date,
        maxCalories: widget.maxCalories,
        consumedCalories: mockData[date.day],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80, // reduced from 100
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final day = days[index];
          final isSelected = index == selectedIndex;

          final calorie = day.consumedCalories;
          Color? bgColor;

          if (calorie != null) {
            if (calorie < day.maxCalories) {
              bgColor = Colors.green;
            } else if (calorie > day.maxCalories) {
              bgColor = Colors.red;
            } else {
              bgColor = Colors.transparent;
            }
          }

          Widget dateWidget;
          if (calorie != null &&
              (calorie < day.maxCalories || calorie > day.maxCalories)) {
            // Show dotted border for green/red days
            dateWidget = DottedBorder(
              borderType: BorderType.Circle,
              color: calorie < day.maxCalories ? Colors.green : Colors.red,
              dashPattern: [5, 3],
              strokeWidth: 1.5,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: Text(
                  DateFormat('dd').format(day.date),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          } else {
            // Original container for all other days
            dateWidget = Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                DateFormat('dd').format(day.date),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Color(0xff676767) : Colors.transparent,
                borderRadius: BorderRadius.circular(80),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('E').format(day.date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8), // reduced from 20
                    dateWidget,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
