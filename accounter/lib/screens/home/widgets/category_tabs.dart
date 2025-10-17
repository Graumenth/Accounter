import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/company.dart';

class CategoryTabs extends StatelessWidget {
  final List<Company> companies;
  final int? selectedCompanyId;
  final Function(int?) onCompanySelected;
  final String allLabel;

  const CategoryTabs({
    super.key,
    required this.companies,
    required this.selectedCompanyId,
    required this.onCompanySelected,
    required this.allLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          height: 56,
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          child: companies.isEmpty
              ? Center(
            child: Text(
              allLabel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
          )
              : ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildTab(allLabel, null, isDark ? AppColors.darkPrimary : AppColors.primary, isDark),
              ...companies.map((company) {
                final companyColor = Color(int.parse(company.color.replaceFirst('#', '0xFF')));
                return _buildTab(company.name, company.id, companyColor, isDark);
              }),
            ],
          ),
        ),
        Container(
          height: 2,
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ],
    );
  }

  Widget _buildTab(String label, int? companyId, Color color, bool isDark) {
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
              color: isSelected
                  ? AppColors.surface
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}