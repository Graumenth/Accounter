import 'package:flutter/material.dart';

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
    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: companies.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final company = companies[index];
          final id = company['id'] as int;
          final name = company['name'] as String;
          final quantity = company['total_quantity'] as int;
          final revenue = company['total_revenue'] as int;

          return ListTile(
            leading: const Icon(
              Icons.business,
              color: Color(0xFF38A169),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A202C),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38A169).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$quantity adet',
                      style: const TextStyle(
                        color: Color(0xFF38A169),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(revenue / 100).toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/company-report',
                arguments: {
                  'companyId': id,
                  'companyName': name,
                  'startDate': startDate,
                  'endDate': endDate,
                },
              );
            },
          );
        },
      ),
    );
  }
}