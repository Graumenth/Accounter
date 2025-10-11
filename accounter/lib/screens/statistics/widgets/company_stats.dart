import 'package:flutter/material.dart';
import '../../../models/sale.dart';

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
    return Column(
      children: companies.map((company) => _buildCompanyItem(context, company)).toList(),
    );
  }

  Widget _buildCompanyItem(BuildContext context, Map<String, dynamic> company) {
    final total = (company['total'] as int) / 100;
    final quantity = company['quantity'] as int;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/company-report',
          arguments: {
            'companyId': company['id'],
            'companyName': company['name'],
            'startDate': Sale.dateToString(startDate),
            'endDate': Sale.dateToString(endDate),
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$quantity adet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '${total.toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF38A169),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF4A5568),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}