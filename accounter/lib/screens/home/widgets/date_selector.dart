import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(int) onDateChanged;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
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
  late DateTime todayMidnight;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _updateTodayMidnight();
    _setupMidnightTimer();
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

  void _updateTodayMidnight() {
    final now = DateTime.now();
    todayMidnight = DateTime(now.year, now.month, now.day);
  }

  void _setupMidnightTimer() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(timeUntilMidnight, () {
      if (mounted) {
        setState(() {
          _updateTodayMidnight();
        });
        _setupMidnightTimer();
      }
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String getDateLabel(DateTime date) {
    final l10n = AppLocalizations.of(context)!;

    if (isSameDay(date, todayMidnight)) {
      return l10n.today;
    } else if (isSameDay(date, todayMidnight.subtract(const Duration(days: 1)))) {
      return l10n.yesterday;
    } else if (isSameDay(date, todayMidnight.add(const Duration(days: 1)))) {
      return l10n.tomorrow;
    }
    return DateFormat('dd MMM', 'tr_TR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 96;
        final itemWidth = availableWidth / 3;

        return Column(
          children: [
            Container(
              height: 2,
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
            SizedBox(
              height: 56,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                    ),
                  ),
                  Positioned(
                    left: 48,
                    right: 48,
                    top: 8,
                    bottom: 8,
                    child: Center(
                      child: Container(
                        width: itemWidth,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackgroundSecondary : AppColors.backgroundSecondary,
                          borderRadius: AppRadius.mdRadius,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 48,
                    right: 48,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        final velocity = details.velocity.pixelsPerSecond;
                        if (velocity.dy.abs() > 1000 && velocity.dy.abs() > velocity.dx.abs() * 2) {
                          final selectedMidnight = DateTime(
                            widget.selectedDate.year,
                            widget.selectedDate.month,
                            widget.selectedDate.day,
                          );
                          final difference = selectedMidnight.difference(todayMidnight).inDays;
                          if (difference != 0) {
                            _pageController.animateToPage(
                              _currentPage - difference,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        }
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: 1000,
                        itemBuilder: (context, index) {
                          final dayOffset = index - 500;
                          final date = todayMidnight.add(Duration(days: dayOffset));

                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = (_pageController.page ?? _currentPage.toDouble()) - index;
                                value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                              }
                              final isCenter = value > 0.95;
                              return Center(
                                child: Semantics(
                                  label: getDateLabel(date),
                                  selected: isCenter,
                                  child: GestureDetector(
                                    onTap: () {
                                      _pageController.animateToPage(
                                        index,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Transform.scale(
                                      scale: value,
                                      child: Opacity(
                                        opacity: (0.3 + (value * 0.7)).clamp(0.3, 1.0),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                          alignment: Alignment.center,
                                          child: Text(
                                            getDateLabel(date),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isCenter ? FontWeight.w600 : FontWeight.w400,
                                              color: isCenter
                                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 48,
                    child: IconButton(
                      tooltip: 'Önceki gün',
                      icon: const Icon(Icons.chevron_left, size: 24),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 48,
                    child: IconButton(
                      tooltip: 'Sonraki gün',
                      icon: const Icon(Icons.chevron_right, size: 24),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ],
        );
      },
    );
  }
}