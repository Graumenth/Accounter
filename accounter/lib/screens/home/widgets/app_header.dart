import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String statisticsTooltip;
  final String settingsTooltip;
  final VoidCallback onSettingsChanged;

  const AppHeader({
    super.key,
    required this.title,
    required this.statisticsTooltip,
    required this.settingsTooltip,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A202C),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Color(0xFF4A5568)),
                tooltip: statisticsTooltip,
                onPressed: () => Navigator.pushNamed(context, '/statistics'),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF4A5568)),
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