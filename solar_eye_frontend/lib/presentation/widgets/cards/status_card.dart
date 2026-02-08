import 'package:flutter/material.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';

/// 상태 표시 카드
/// 정상/주의/위험 상태를 시각적으로 표시
class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final StatusType status;
  final IconData? icon;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.status = StatusType.normal,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: _iconColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelM.copyWith(
                      color: AppColors.text2,
                    ),
                  ),
                ),
                // 상태 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    _statusText,
                    style: AppTypography.caption.copyWith(
                      color: _iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            // 값
            Text(
              value,
              style: AppTypography.headlineL.copyWith(
                color: AppColors.text1,
                fontWeight: FontWeight.w700,
              ),
            ),
            // 부제목
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.space1),
              Text(
                subtitle!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.text3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color get _borderColor {
    switch (status) {
      case StatusType.normal:
        return AppColors.success.withValues(alpha: 0.3);
      case StatusType.warning:
        return AppColors.warning.withValues(alpha: 0.3);
      case StatusType.danger:
        return AppColors.danger.withValues(alpha: 0.3);
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case StatusType.normal:
        return AppColors.successLight;
      case StatusType.warning:
        return AppColors.warningLight;
      case StatusType.danger:
        return AppColors.dangerLight;
    }
  }

  Color get _iconColor {
    switch (status) {
      case StatusType.normal:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.danger:
        return AppColors.danger;
    }
  }

  String get _statusText {
    switch (status) {
      case StatusType.normal:
        return '정상';
      case StatusType.warning:
        return '주의';
      case StatusType.danger:
        return '위험';
    }
  }
}

enum StatusType {
  normal,
  warning,
  danger,
}
