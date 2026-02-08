import 'package:flutter/material.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/domain/model/alert.dart';

/// 알림 상세 화면
class AlertDetailScreen extends StatelessWidget {
  final Alert alert;

  const AlertDetailScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '알림 상세',
          style: AppTypography.titleL.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 심각도 뱃지
            _buildSeverityBadge(),
            const SizedBox(height: AppSpacing.space4),

            // 제목
            Text(
              alert.title,
              style: AppTypography.headlineM.copyWith(
                color: AppColors.text1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),

            // 시간
            Text(
              _formatDateTime(alert.createdAt),
              style: AppTypography.bodyM.copyWith(
                color: AppColors.text2,
              ),
            ),
            const SizedBox(height: AppSpacing.space5),

            // 메시지
            _buildSection(
              title: '내용',
              child: Text(
                alert.message,
                style: AppTypography.bodyL.copyWith(
                  color: AppColors.text1,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space5),

            // 패널 정보
            if (alert.panelName != null) ...[
              _buildSection(
                title: '관련 패널',
                child: _buildPanelInfo(),
              ),
              const SizedBox(height: AppSpacing.space5),
            ],

            // 스냅샷 이미지 (있을 경우)
            if (alert.snapshotUrl != null) ...[
              _buildSection(
                title: '탐지 스냅샷',
                child: _buildSnapshotImage(),
              ),
              const SizedBox(height: AppSpacing.space5),
            ],

            // 조치 버튼
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge() {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (alert.severity) {
      case AlertSeverity.danger:
        bgColor = AppColors.dangerLight;
        textColor = AppColors.danger;
        label = '위험';
        icon = Icons.error;
        break;
      case AlertSeverity.warning:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        label = '주의';
        icon = Icons.warning_amber;
        break;
      case AlertSeverity.info:
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        label = '정보';
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelM.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleM.copyWith(
            color: AppColors.text1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        child,
      ],
    );
  }

  Widget _buildPanelInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.solar_power_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.panelName!,
                  style: AppTypography.titleM.copyWith(
                    color: AppColors.text1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '패널 상세 보기',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.text3,
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.text3,
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              '스냅샷 이미지',
              style: AppTypography.bodyM.copyWith(
                color: AppColors.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (alert.severity == AlertSeverity.info) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: 패널 상세 화면으로 이동
            },
            icon: const Icon(Icons.solar_power_outlined),
            label: const Text('패널 확인'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: 점검 예약 또는 조치 기능
            },
            icon: const Icon(Icons.build_outlined),
            label: const Text('조치 하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month}.${dateTime.day} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
