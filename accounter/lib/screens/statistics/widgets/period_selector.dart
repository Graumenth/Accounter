import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildPeriodButton(l10n.today, 'today'),
              const SizedBox(width: 8),
              _buildPeriodButton(l10n.thisWeek, 'week'),
              const SizedBox(width: 8),
              _buildPeriodButton(l10n.thisMonth, 'month'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPeriodButton(l10n.thisYear, 'year'),
              const SizedBox(width: 8),
              _buildPeriodButton(l10n.selectDate, 'custom', icon: Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period, {IconData? icon}) {
    final isSelected = selectedPeriod == period;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => onPeriodChanged(period),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF38A169) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF4A5568),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? const Color(0xFF38A169) : Colors.grey[300]!,
            ),
          ),
        ),
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}