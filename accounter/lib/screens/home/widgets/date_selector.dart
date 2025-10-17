import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(int) onDateChanged;
  final String todayLabel;
  final String yesterdayLabel;
  final String tomorrowLabel;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.todayLabel,
    required this.yesterdayLabel,
    required this.tomorrowLabel,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  final PageController _pageController = PageController(
    initialPage: 500,
    viewportFraction: 0.33,
  );
  int _currentPage = 500;
  late final DateTime todayMidnight;

  @override
  void initState() {
    super.initState();
    todayMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? _currentPage;
      if (page != _currentPage) {
        final diff = page - _currentPage;
        _currentPage = page;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onDateChanged(diff);
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String getDateLabel(DateTime date) {
    if (isSameDay(date, todayMidnight)) {
      return widget.todayLabel;
    } else if (isSameDay(date, todayMidnight.subtract(const Duration(days: 1)))) {
      return widget.yesterdayLabel;
    } else if (isSameDay(date, todayMidnight.add(const Duration(days: 1)))) {
      return widget.tomorrowLabel;
    }
    return DateFormat('dd MMM', 'tr_TR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 96;
        final itemWidth = availableWidth / 3;

        return Column(
          children: [
            Container(
              height: 2,
              color: const Color(0xFFE2E8F0),
            ),
            SizedBox(
              height: 64,
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  final date = todayMidnight.add(Duration(days: index - 500));
                  final isSelected = isSameDay(date, widget.selectedDate);
                  return SizedBox(
                    width: itemWidth,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF38A169) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE', 'tr_TR').format(date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF718096),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getDateLabel(date),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF1A202C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 2,
              color: const Color(0xFFE2E8F0),
            ),
          ],
        );
      },
    );
  }
}