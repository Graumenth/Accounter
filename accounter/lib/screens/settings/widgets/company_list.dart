import 'package:flutter/material.dart';
import '../../../models/company.dart';
import '/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    if (companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business_outlined,
              size: 64,
              color: Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCompaniesYet,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
              ),
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
          leading: const Icon(
            Icons.business,
            color: Color(0xFF38A169),
          ),
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