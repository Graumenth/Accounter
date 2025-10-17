import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../models/company.dart';

class CategoryTabs extends StatelessWidget {
  final List<Company> companies;
  final int? selectedCompanyId;
  final Function(int?) onCompanySelected;

  const CategoryTabs({
    super.key,
    required this.companies,
    required this.selectedCompanyId,
    required this.onCompanySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          height: 56,
          color: Colors.white,
          child: companies.isEmpty
              ? Center(
            child: Text(
              l10n.all,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF38A169),
              ),
            ),
          )
              : ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildTab(l10n.all, null, const Color(0xFF38A169)),
              ...companies.map((company) {
                final companyColor = Color(int.parse(company.color.replaceFirst('#', '0xFF')));
                return _buildTab(company.name, company.id, companyColor);
              }),
            ],
          ),
        ),
        Container(
          height: 2,
          color: const Color(0xFFE2E8F0),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int? companyId, Color color) {
    final isSelected = selectedCompanyId == companyId;

    return GestureDetector(
      onTap: () => onCompanySelected(companyId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF4A5568),
            ),
          ),
        ),
      ),
    );
  }
}