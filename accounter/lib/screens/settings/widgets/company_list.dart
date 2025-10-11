import 'package:flutter/material.dart';
import '../../../models/company.dart';

class CompanyList extends StatelessWidget {
  final List<Company> companies;
  final Function(Company) onEdit;

  const CompanyList({
    super.key,
    required this.companies,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Henüz şirket eklenmemiş',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: companies.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final company = companies[index];
        return ListTile(
          title: Text(
            company.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
          onTap: () => onEdit(company),
        );
      },
    );
  }
}