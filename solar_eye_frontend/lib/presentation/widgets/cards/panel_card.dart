import 'package:flutter/material.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/presentation/widgets/cards/status_card.dart';

/// 패널 카드
/// 태양광 패널 정보 표시
class PanelCard extends StatelessWidget {
  final String name;
  final String location;
  final StatusType status;
  final String? lastDetection;
  final VoidCallback? onTap;

  const PanelCard({
    super.key,
    required this.name,
    required this.location,
    this.status = StatusType.normal,
    this.lastDetection,
    this.onTap,
    this.action,
  });

  final Widget? action;

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
            color: AppColors.border,
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
        child: Row(
          children: [
            // 패널 아이콘
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.solar_power_outlined,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTypography.titleM.copyWith(
                            color: AppColors.text1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.text3,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: AppTypography.bodyM.copyWith(
                          color: AppColors.text2,
                        ),
                      ),
                    ],
                  ),
                  if (lastDetection != null) ...[
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      '마지막 탐지: $lastDetection',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 액션 버튼
            if (action != null) ...[
              action!,
              const SizedBox(width: AppSpacing.space2),
            ],
            // 화살표
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: AppColors.text3,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case StatusType.normal:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        text = '정상';
        break;
      case StatusType.warning:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        text = '주의';
        break;
      case StatusType.danger:
        bgColor = AppColors.dangerLight;
        textColor = AppColors.danger;
        text = '위험';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
