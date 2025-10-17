import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class CompanyStats extends StatelessWidget {
  final List<Map<String, dynamic>> companies;
  final DateTime startDate;
  final DateTime endDate;

  const CompanyStats({
    super.key,
    required this.companies,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: companies.map((company) => _buildCompanyStat(context, l10n, company)).toList(),
    );
  }

  Widget _buildCompanyStat(BuildContext context, AppLocalizations l10n, Map<String, dynamic> company) {
    final theme = Theme.of(context);
    final total = (company['total'] as int) / 100;
    final quantity = company['quantity'] as int;
    final color = Color(int.parse('0xFF${company['color'].toString().substring(1)}'));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity ${l10n.quantitySuffix}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ₺',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}