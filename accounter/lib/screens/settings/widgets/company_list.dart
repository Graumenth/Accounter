import 'package:flutter/material.dart';
import '../../../models/company.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCompaniesYet,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: companies.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: theme.dividerColor,
      ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.price_change,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyDetailScreen(company: company),
                    ),
                  );
                },
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
          onTap: () => onEdit(company),
        );
      },
    );
  }
}