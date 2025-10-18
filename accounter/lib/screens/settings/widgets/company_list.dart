import 'package:flutter/material.dart';
import '../../../models/company.dart';
import '../../../constants/app_colors.dart';
import '../../../services/database_service.dart';
import 'company_detail_screen.dart';
import '/l10n/app_localizations.dart';

class CompanyList extends StatelessWidget {
  final List<Company> companies;
  final Function(Company) onEdit;
  final VoidCallback onRefresh;

  const CompanyList({
    super.key,
    required this.companies,
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextTertiary : AppColors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCompaniesYet,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: companies.length,
      itemBuilder: (context, index) {
        final company = companies[index];
        final companyColor = Color(int.parse('0xFF${company.color.substring(1)}'));
        final isTabletOrDesktop = MediaQuery.of(context).size.width >= 600;

        return Dismissible(
          key: Key(company.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: isDark ? AppColors.darkError : AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.surface,
              size: 28,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(l10n.deleteCompany),
                  content: Text(l10n.deleteCompanyConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkError : AppColors.error,
                      ),
                      child: Text(l10n.delete),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) async {
            await DatabaseService.instance.deleteCompany(company.id!);
            onRefresh();
          },
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyDetailScreen(company: company),
                ),
              );
              onRefresh();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 1),
              padding: EdgeInsets.symmetric(
                horizontal: isTabletOrDesktop ? AppSpacing.xxl : AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: companyColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  SizedBox(width: isTabletOrDesktop ? AppSpacing.lg : AppSpacing.md),
                  Expanded(
                    child: Text(
                      company.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}