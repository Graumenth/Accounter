import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class DailyTotalBar extends StatelessWidget {
  final int dailyTotal;
  final int? companyTotal;
  final String? companyName;
  final String dailyTotalLabel;
  final String grandTotalLabel;

  const DailyTotalBar({
    super.key,
    required this.dailyTotal,
    required this.dailyTotalLabel,
    required this.grandTotalLabel,
    this.companyTotal,
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 128.0;
    return Container(
      height: barHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            companyTotal != null && companyName != null
                ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        companyName!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '${(companyTotal! / 100).toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        grandTotalLabel,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '${(dailyTotal / 100).toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dailyTotalLabel,
                  style: AppTextStyles.caption,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  '${(dailyTotal / 100).toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}