import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class DailyTotalBar extends StatelessWidget {
  final int dailyTotal;
  final int? companyTotal;
  final String? companyName;

  const DailyTotalBar({
    super.key,
    required this.dailyTotal,
    this.companyTotal,
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 112.0;
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
                        style: AppTextStyles.heading2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Genel Toplam',
                      style: AppTextStyles.caption,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(dailyTotal / 100).toStringAsFixed(2)} ₺',
                      style: AppTextStyles.priceLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Günlük Toplam',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(dailyTotal / 100).toStringAsFixed(2)} ₺',
                  style: AppTextStyles.priceLarge.copyWith(
                    color: AppColors.primary,
                    fontSize: 28,
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