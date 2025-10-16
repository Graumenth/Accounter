import 'package:flutter/material.dart';
import '../../../models/company.dart';
import '../company_detail_screen.dart';

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
        final companyColor = Color(int.parse('0xFF${company.color.substring(1)}'));

        return ListTile(
          leading: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: companyColor,
              shape: BoxShape.circle,
            ),
          ),
          title: Text(
            company.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.price_change, color: Color(0xFF38A169)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyDetailScreen(company: company),
                    ),
                  );
                },
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
            ],
          ),
          onTap: () => onEdit(company),
        );
      },
    );
  }
}