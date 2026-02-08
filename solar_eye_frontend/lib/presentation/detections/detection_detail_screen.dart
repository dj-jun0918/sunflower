import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/detection_provider.dart';
import 'package:solar_eye_frontend/domain/model/detection.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 탐지 상세 화면
class DetectionDetailScreen extends ConsumerWidget {
  final String detectionId;

  const DetectionDetailScreen({
    super.key,
    required this.detectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectionAsync = ref.watch(detectionDetailProvider(detectionId));

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
          '탐지 상세 정보',
          style: AppTypography.titleL.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: detectionAsync.when(
        loading: () => const LoadingIndicator(message: '상세 정보 로딩 중...'),
        error: (error, stack) => EmptyState(
          icon: Icons.error_outline,
          title: '오류가 발생했습니다',
          description: error.toString(),
          actionLabel: '뒤로가기',
          onAction: () => Navigator.pop(context),
        ),
        data: (detection) => _buildContent(context, detection),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Detection detection) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 탐지 이미지 (스냅샷 + 바운딩 박스 플레이스홀더)
          _buildImageSection(detection),
          const SizedBox(height: AppSpacing.space5),

          // 결과 요약
          _buildResultSummary(detection),
          const SizedBox(height: AppSpacing.space5),

          // 상세 속성
          _buildDetailAttributes(detection),

          const SizedBox(height: AppSpacing.space6),
          // 관련 알림 확인 버튼
          if (detection.alertId != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: 알림 상세로 이동
                },
                icon: const Icon(Icons.notifications_outlined),
                label: const Text('관련 알림 확인'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection(Detection detection) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Stack(
        children: [
          // 이미지
          Center(
            child: detection.imageUrl != null
                ? Image.network(detection.imageUrl!, fit: BoxFit.contain)
                : const Icon(Icons.image_not_supported,
                    color: Colors.white54, size: 64),
          ),

          // 바운딩 박스 (예시)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'AI 분석 결과',
                    style: AppTypography.labelM.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSummary(Detection detection) {
    Color color = AppColors.success;
    String label = '정상';
    IconData icon = Icons.check_circle;

    switch (detection.type) {
      case DetectionType.normal:
        color = AppColors.success;
        label = '정상';
        icon = Icons.check_circle;
        break;
      case DetectionType.soiling:
        color = AppColors.warning;
        label = '오염 감지';
        icon = Icons.warning_amber;
        break;
      case DetectionType.crack:
        color = AppColors.danger;
        label = '결함 발견';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(width: AppSpacing.space4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.headlineM.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '신뢰도 ${(detection.confidence * 100).toInt()}%',
                style: AppTypography.bodyM.copyWith(color: AppColors.text2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailAttributes(Detection detection) {
    return Column(
      children: [
        _AttributeRow(label: '탐지 ID', value: detection.id),
        const Divider(),
        _AttributeRow(label: '패널명', value: detection.panelName),
        const Divider(),
        _AttributeRow(
          label: '탐지 시간',
          value: _formatDateTime(detection.detectedAt),
        ),
        const Divider(),
        _AttributeRow(label: '패널 ID', value: detection.panelId),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _AttributeRow extends StatelessWidget {
  final String label;
  final String value;

  const _AttributeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyL.copyWith(color: AppColors.text2),
          ),
          Text(
            value,
            style: AppTypography.bodyL.copyWith(
              color: AppColors.text1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
