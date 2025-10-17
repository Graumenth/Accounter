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
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildButton(l10n.today, 'today'),
          const SizedBox(width: 8),
          _buildButton(l10n.thisWeek, 'week'),
          const SizedBox(width: 8),
          _buildButton(l10n.thisMonth, 'month'),
          const SizedBox(width: 8),
          _buildButton(l10n.thisYear, 'year'),
          const SizedBox(width: 8),
          _buildButton(l10n.selectDate, 'custom'),
        ],
      ),
    );
  }

  Widget _buildButton(String label, String period) {
    final isSelected = selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPeriodChanged(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF38A169) : const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF38A169) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4A5568),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}