import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../providers/dashboard_provider.dart';

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
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateDays();
      _scrollToSelected();
    });
  }

  void _generateDays() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: 29));
    
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);

    days = List.generate(30, (index) {
      final date = start.add(Duration(days: index));
      
      // Calculate actual calories for this day
      final caloriesForDay = _calculateCaloriesForDay(date, dashboardProvider.meals);

      return DayItem(
        date: date,
        maxCalories: widget.maxCalories,
        consumedCalories: caloriesForDay > 0 ? caloriesForDay : null,
      );
    });
    selectedIndex = days.length - 1; // Default to today
  }

  int _calculateCaloriesForDay(DateTime date, List meals) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return meals
        .where((meal) => 
            meal.timestamp.isAfter(startOfDay) &&
            meal.timestamp.isBefore(endOfDay) &&
            !meal.isAnalyzing &&
            !meal.analysisFailed)
        .fold<double>(0.0, (sum, meal) => sum + meal.calories)
        .round();
  }

  void _scrollToSelected() {
    // Each item is about 44px wide (32 + 12 padding), adjust as needed
    final double itemWidth = 44.0;
    _scrollController.jumpTo((selectedIndex - 2).clamp(0, days.length) * itemWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        // Regenerate days when meals change
        _generateDays();
        
        // Sync selected index with dashboard provider's selected date
        if (dashboardProvider.selectedDate != null) {
          final providerSelectedDate = dashboardProvider.selectedDate!;
          final matchingIndex = days.indexWhere((day) => 
            day.date.year == providerSelectedDate.year &&
            day.date.month == providerSelectedDate.month &&
            day.date.day == providerSelectedDate.day
          );
          if (matchingIndex != -1 && matchingIndex != selectedIndex) {
            selectedIndex = matchingIndex;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToSelected();
            });
          }
        }
        
        return SizedBox(
          height: 60,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            padding: const EdgeInsets.only(left: 25, right: 16, top: 0),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final day = days[index];
              final isSelected = index == selectedIndex;
              final hasCalories = day.consumedCalories != null && day.consumedCalories! > 0;

              // Date widget with calorie indicator
              Widget dateWidget = Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                  border: hasCalories && !isSelected
                      ? Border.all(color: Colors.green, width: 2)
                      : null,
                ),
                child: Text(
                  DateFormat('dd').format(day.date),
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.black 
                        : hasCalories 
                            ? Colors.green 
                            : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );

              return GestureDetector(
                onTap: () {
                  setState(() => selectedIndex = index);
                  // Update selected date in dashboard provider (normalized to start of day)
                  final normalizedDate = DateTime(day.date.year, day.date.month, day.date.day);
                  dashboardProvider.setSelectedDate(normalizedDate);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xff676767) : Colors.transparent,
                    borderRadius: BorderRadius.circular(80),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'dashboard.calendar.day_short_${DateFormat('E', 'en').format(day.date).toLowerCase()}'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        dateWidget,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
