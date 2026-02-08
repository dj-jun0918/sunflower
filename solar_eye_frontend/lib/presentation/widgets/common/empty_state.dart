import 'package:flutter/material.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/presentation/widgets/buttons/primary_button.dart';

/// 빈 상태 위젯
/// 데이터가 없을 때 표시
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.space5),
            // 제목
            Text(
              title,
              style: AppTypography.headlineM.copyWith(
                color: AppColors.text1,
              ),
              textAlign: TextAlign.center,
            ),
            // 설명
            if (description != null) ...[
              const SizedBox(height: AppSpacing.space2),
              Text(
                description!,
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.text2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            // 액션 버튼
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.space6),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
