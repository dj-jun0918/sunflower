import 'package:flutter/material.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';

/// 로딩 인디케이터
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool overlay;

  const LoadingIndicator({
    super.key,
    this.message,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.space4),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: overlay ? Colors.white : AppColors.text2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (overlay) {
      return Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
