import 'package:flutter/material.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';

/// 알림 카드
/// 결함 탐지, 시스템 알림 등을 표시
class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final AlertType type;
  final bool isRead;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.type = AlertType.info,
    this.isRead = false,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(title + time),
      direction: onDismiss != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.space4),
        color: AppColors.danger,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isRead ? AppColors.background : AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isRead ? AppColors.border : _borderColor,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이콘
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  size: 20,
                  color: _iconColor,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.titleM.copyWith(
                              color: AppColors.text1,
                              fontWeight:
                                  isRead ? FontWeight.w400 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      message,
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.text2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      time,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              // 화살표
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.text3,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _borderColor {
    switch (type) {
      case AlertType.danger:
        return AppColors.danger.withValues(alpha: 0.3);
      case AlertType.warning:
        return AppColors.warning.withValues(alpha: 0.3);
      case AlertType.info:
        return AppColors.info.withValues(alpha: 0.3);
    }
  }

  Color get _backgroundColor {
    switch (type) {
      case AlertType.danger:
        return AppColors.dangerLight;
      case AlertType.warning:
        return AppColors.warningLight;
      case AlertType.info:
        return AppColors.infoLight;
    }
  }

  Color get _iconColor {
    switch (type) {
      case AlertType.danger:
        return AppColors.danger;
      case AlertType.warning:
        return AppColors.warning;
      case AlertType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (type) {
      case AlertType.danger:
        return Icons.error_outline;
      case AlertType.warning:
        return Icons.warning_amber_outlined;
      case AlertType.info:
        return Icons.info_outline;
    }
  }
}

enum AlertType {
  danger,
  warning,
  info,
}
