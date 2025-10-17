import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String statisticsTooltip;
  final String settingsTooltip;
  final VoidCallback onSettingsChanged;

  const AppHeader({
    super.key,
    required this.statisticsTooltip,
    required this.settingsTooltip,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Accounter',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                tooltip: statisticsTooltip,
                onPressed: () => Navigator.pushNamed(context, '/statistics'),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                tooltip: settingsTooltip,
                onPressed: () async {
                  await Navigator.pushNamed(context, '/settings');
                  onSettingsChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}